extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TrainingTargetScene = preload("res://entities/training/training_target.tscn")
const VFX_SHEET_PATH := "res://assets/vfx/abilities/king/sovereign_pursuit_vfx_sheet_192.png"
const TRAVEL_VFX_SHEET_PATH := "res://assets/vfx/abilities/king/sovereign_pursuit_travel_vfx_sheet_128.png"
const TRAVEL_VFX_FRAMES_PATH := "res://assets/vfx/abilities/king/sovereign_pursuit_travel_vfx_frames.tres"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var target := TrainingTargetScene.instantiate()
	root.add_child(player)
	root.add_child(target)
	player.global_position = Vector2(200, 200)
	target.global_position = Vector2(340, 200)
	await physics_frame
	var ability := player.ability_3_component as SovereignPursuitComponent
	var body := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	var effect := player.get_node("AbilityPivot/SovereignPursuitVisual/EffectSprite") as AnimatedSprite2D
	var visual := player.get_node("AbilityPivot/SovereignPursuitVisual") as SovereignPursuitVisual
	var travel_visual := player.get_node("VisualRoot/SovereignPursuitTravelVisual") as SovereignPursuitTravelVisual
	var travel_effect := player.get_node("VisualRoot/SovereignPursuitTravelVisual/EffectSprite") as AnimatedSprite2D
	var launch_audio := player.get_node("PlayerActionSfx/SovereignPursuitLaunch") as AudioStreamPlayer2D
	var landing_audio := player.get_node("PlayerActionSfx/SovereignPursuitLanding") as AudioStreamPlayer2D
	var circle := player.get_node("AbilityPivot/Ability3Hitbox/CollisionShape2D") as CollisionShape2D
	if ability == null or ability.definition.ability_id != &"sovereign_pursuit":
		_fail("King Skill 3 is not owned by SovereignPursuitComponent.")
		return
	if not player.request_ability(3) or not player.ground_point_targeting.is_targeting():
		_fail("Skill 3 did not enter ground-point targeting.")
		return
	if ability.is_casting():
		_fail("Sovereign Pursuit cast before target confirmation.")
		return
	player.ground_point_targeting.update_aim(Vector2(340, 200), Vector2.ZERO)
	player.ground_point_targeting.confirm_targeting()
	if not ability.is_casting() or body.animation != &"sovereign_pursuit_right":
		_fail("Confirmed Skill 3 did not begin its dedicated right-facing action.")
		return
	var saw_active := false
	var saw_launch := false
	var saw_travel := false
	var saw_impact := false
	var launch_origin := Vector2.ZERO
	for frame_index in range(70):
		await physics_frame
		if ability.phase == AbilityComponent.Phase.ACTIVE:
			if not saw_active:
				launch_origin = visual.global_position
			saw_active = true
			saw_launch = saw_launch or effect.animation == &"launch"
			saw_travel = saw_travel or (travel_visual.visible and travel_effect.animation == &"travel")
			if visual.global_position.distance_to(launch_origin) > 0.1:
				_fail("Sovereign Pursuit launch dust followed King instead of remaining at takeoff.")
				return
			if travel_visual.global_position.distance_to(player.global_position + Vector2(0.0, -16.0)) > 0.1:
				_fail("Sovereign Pursuit's power sheath did not follow King during traversal.")
				return
		saw_impact = saw_impact or effect.animation == &"impact"
		if not ability.is_casting():
			break
	if not saw_active or not saw_launch or not saw_travel or not saw_impact:
		_fail("Sovereign Pursuit did not separate fixed ground VFX from its character-following travel sheath.")
		return
	if travel_visual.visible:
		_fail("Sovereign Pursuit travel sheath remained visible after landing.")
		return
	if effect.animation != &"crater" or not visual.visible:
		_fail("Sovereign Pursuit did not leave its post-recovery crater visible.")
		return
	if effect.position != Vector2(0.0, 16.0):
		_fail("Sovereign Pursuit VFX no longer shares the authored ground-center offset.")
		return
	var crater_origin := visual.global_position
	player.global_position += Vector2(32.0, 0.0)
	await physics_frame
	if visual.global_position.distance_to(crater_origin) > 0.1:
		_fail("Sovereign Pursuit crater followed King instead of remaining at the landing point.")
		return
	player.global_position -= Vector2(32.0, 0.0)
	if launch_audio == null or launch_audio.stream == null or landing_audio == null or landing_audio.stream == null:
		_fail("Sovereign Pursuit is missing separate launch and landing audio.")
		return
	if player.global_position.distance_to(Vector2(340, 200)) > 18.0:
		_fail("Sovereign Pursuit did not reach its confirmed collision-safe landing point: %s." % player.global_position)
		return
	if not is_equal_approx(target.get_node("HealthComponent").current_health, 68.75):
		_fail("Sovereign Pursuit did not deal one 125% Ashwood landing hit.")
		return
	if not (circle.shape is CircleShape2D) or not is_equal_approx((circle.shape as CircleShape2D).radius, 52.0):
		_fail("Sovereign Pursuit does not use its authored 52-pixel landing circle.")
		return
	var texture := load(VFX_SHEET_PATH) as Texture2D
	if texture == null or texture.get_image().get_size() != Vector2i(576, 384):
		_fail("Sovereign Pursuit VFX is not an exact 3x2 atlas of 192-pixel cells.")
		return
	var ground_image := texture.get_image()
	for frame_index in range(6):
		var frame_region := ground_image.get_region(Rect2i((frame_index % 3) * 192, (frame_index / 3) * 192, 192, 192))
		var used_rect := frame_region.get_used_rect()
		var visible_center_x := used_rect.position.x + used_rect.size.x * 0.5
		if absf(visible_center_x - 96.0) > 1.0:
			_fail("Sovereign Pursuit ground frame %d drifted away from King's foot center." % frame_index)
			return
	var travel_texture := load(TRAVEL_VFX_SHEET_PATH) as Texture2D
	var travel_image := travel_texture.get_image() if travel_texture != null else null
	var travel_frames := load(TRAVEL_VFX_FRAMES_PATH) as SpriteFrames
	if travel_image == null or travel_image.get_size() != Vector2i(384, 128):
		_fail("Sovereign Pursuit travel VFX is not an exact 3x1 atlas of 128-pixel cells.")
		return
	if travel_frames == null or travel_frames.get_frame_count(&"travel") != 3:
		_fail("Sovereign Pursuit travel VFX is missing its three-frame power sheath.")
		return
	for y in range(travel_image.get_height()):
		for x in range(travel_image.get_width()):
			var alpha := travel_image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("Sovereign Pursuit travel VFX runtime atlas contains non-binary alpha.")
				return
	for frame_index in range(100):
		await physics_frame
	if visual.visible:
		_fail("Sovereign Pursuit crater did not fade and clean itself up.")
		return
	print("Sovereign Pursuit targeting, traversal, landing damage, and generated presentation smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
