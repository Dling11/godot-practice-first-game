extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TrainingTargetScene = preload("res://entities/training/training_target.tscn")
const VFX_SHEET_PATH := "res://assets/vfx/abilities/king/sovereign_pursuit_vfx_sheet_192.png"


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
	var saw_impact := false
	for frame_index in range(70):
		await physics_frame
		saw_active = saw_active or ability.phase == AbilityComponent.Phase.ACTIVE
		saw_impact = saw_impact or effect.animation == &"impact"
		if not ability.is_casting():
			break
	if not saw_active or not saw_impact:
		_fail("Sovereign Pursuit did not traverse and show its generated landing impact.")
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
	print("Sovereign Pursuit targeting, traversal, landing damage, and generated presentation smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
