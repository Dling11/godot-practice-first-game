extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TrainingTargetScene = preload("res://entities/training/training_target.tscn")
const VFX_SHEET_PATH := "res://assets/vfx/abilities/king/riftbreak_vfx_sheet_192.png"
const VFX_FRAMES_PATH := "res://assets/vfx/abilities/king/riftbreak_vfx_frames.tres"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var left_target := TrainingTargetScene.instantiate()
	var right_target := TrainingTargetScene.instantiate()
	var far_target := TrainingTargetScene.instantiate()
	root.add_child(player)
	root.add_child(left_target)
	root.add_child(right_target)
	root.add_child(far_target)
	player.global_position = Vector2(200.0, 200.0)
	left_target.global_position = Vector2(145.0, 200.0)
	right_target.global_position = Vector2(255.0, 200.0)
	far_target.global_position = Vector2(315.0, 200.0)
	player.set_physics_process(false)
	var ability := player.ability_2_component as RiftbreakComponent
	var visual := player.get_node("AbilityPivot/RiftbreakVisual") as RiftbreakVisual
	var effect_sprite := player.get_node("AbilityPivot/RiftbreakVisual/EffectSprite") as AnimatedSprite2D
	var body_visual := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	var hitbox := player.get_node("AbilityPivot/Ability2Hitbox") as MeleeHitbox
	var slam_audio := player.get_node("PlayerActionSfx/RiftbreakGroundSlam") as AudioStreamPlayer2D
	var collision_shape := player.get_node("AbilityPivot/Ability2Hitbox/CollisionShape2D") as CollisionShape2D
	if ability == null or ability.definition.ability_id != &"riftbreak":
		_fail("King Skill 2 is not owned by RiftbreakComponent.")
		return
	var vfx_texture := load(VFX_SHEET_PATH) as Texture2D
	var vfx_image := vfx_texture.get_image() if vfx_texture != null else null
	var vfx_frames := load(VFX_FRAMES_PATH) as SpriteFrames
	if vfx_image == null or vfx_image.get_size() != Vector2i(576, 384):
		_fail("Riftbreak VFX is not an exact 3x2 atlas of 192-pixel cells.")
		return
	for y in range(vfx_image.get_height()):
		for x in range(vfx_image.get_width()):
			var alpha := vfx_image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("Riftbreak VFX runtime atlas contains non-binary alpha.")
				return
	if (
		vfx_frames == null
		or vfx_frames.get_frame_count(&"wind_up") != 2
		or vfx_frames.get_frame_count(&"impact") != 3
		or vfx_frames.get_frame_count(&"residual") != 1
	):
		_fail("Riftbreak VFX is missing its authored six-frame phase animations.")
		return
	if player.skill_loadout.get_slot(2).ability != ability.definition:
		_fail("King's second skill slot does not expose Riftbreak.")
		return
	if ability.definition.activation_mode != AbilityDefinition.ActivationMode.SELF_AREA:
		_fail("Riftbreak is not configured as a self-area skill.")
		return
	if not player.request_ability(2):
		_fail("Skill 2 did not cast immediately as a self-centered AOE.")
		return
	if not ability.is_casting() or ability.cooldown_remaining <= 0.0:
		_fail("Riftbreak did not begin cast and cooldown together.")
		return
	if player.directional_wedge_targeting.is_targeting():
		_fail("Riftbreak incorrectly opened Skill 1's targeting preview.")
		return
	if body_visual.animation != &"riftbreak_down" or body_visual.frame != 0:
		_fail("Riftbreak did not begin on its dedicated grounded wind-up animation.")
		return
	if effect_sprite == null or effect_sprite.animation != &"wind_up" or not effect_sprite.visible:
		_fail("Riftbreak did not begin its generated VFX wind-up frames.")
		return
	if slam_audio == null or slam_audio.stream == null:
		_fail("Riftbreak is missing its dedicated ground-slam audio presentation.")
		return
	var strikes: Array[int] = []
	var observed_vfx_animations: Array[StringName] = []
	ability.strike_started.connect(func(index: int, _count: int, _duration: float) -> void:
		strikes.append(index)
		observed_vfx_animations.append(effect_sprite.animation)
	)
	var observed_directions := {
		"left": Vector2.ZERO,
		"right": Vector2.ZERO,
	}
	left_target.get_node("HealthComponent").damaged.connect(func(info: DamageInfo) -> void:
		observed_directions.left = info.direction
	)
	right_target.get_node("HealthComponent").damaged.connect(func(info: DamageInfo) -> void:
		observed_directions.right = info.direction
	)
	for frame_index in range(36):
		await physics_frame
	if strikes != [0]:
		_fail("Riftbreak did not open exactly one damage window.")
		return
	if observed_vfx_animations != [&"impact"]:
		_fail("Riftbreak's generated VFX did not switch to impact frames on contact.")
		return
	var circle := collision_shape.shape as CircleShape2D
	if circle == null or not is_equal_approx(circle.radius, 84.0):
		_fail("Riftbreak authority does not use its authored 84-pixel circle.")
		return
	if not is_equal_approx(left_target.get_node("HealthComponent").current_health, 62.5):
		_fail("Riftbreak did not deal its authored damage inside the left edge.")
		return
	if not is_equal_approx(right_target.get_node("HealthComponent").current_health, 62.5):
		_fail("Riftbreak did not deal its authored damage inside the right edge.")
		return
	if not is_equal_approx(far_target.get_node("HealthComponent").current_health, 100.0):
		_fail("Riftbreak damaged a target outside its circle.")
		return
	if observed_directions.left.x >= -0.9 or observed_directions.right.x <= 0.9:
		_fail("Riftbreak did not push targets outward from King's feet.")
		return
	if not body_visual.visible:
		_fail("Riftbreak hid King's body presentation.")
		return
	if hitbox.position != Vector2.ZERO or ability.is_casting():
		_fail("Riftbreak did not restore its hitbox and return to idle cleanly.")
		return
	if not visual.visible or effect_sprite.animation != &"residual":
		_fail("Riftbreak did not preserve its residual ground fracture after recovery.")
		return
	var residual_origin := visual.global_position
	player.global_position += Vector2(48.0, 0.0)
	await physics_frame
	if visual.global_position.distance_to(residual_origin) > 0.1:
		_fail("Riftbreak residual followed King instead of remaining at the cast point.")
		return
	for frame_index in range(90):
		await physics_frame
	if visual.visible:
		_fail("Riftbreak residual did not fade and clean itself up.")
		return
	print("Riftbreak self-AOE, radial knockback, and presentation smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
