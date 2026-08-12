extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TrainingTargetScene = preload("res://entities/training/training_target.tscn")
const SWORD_PATH := "res://assets/vfx/abilities/king/king_skill_4_spirit_sword_sheet_144x192.png"
const SWORD_FRAMES_PATH := "res://assets/vfx/abilities/king/king_skill_4_spirit_sword_frames.tres"
const GROUND_PATH := "res://assets/vfx/abilities/king/king_skill_4_ground_vfx_sheet_256.png"
const FRAMES_PATH := "res://assets/vfx/abilities/king/king_skill_4_ground_vfx_frames.tres"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var center_target := TrainingTargetScene.instantiate()
	var outer_target := TrainingTargetScene.instantiate()
	var far_target := TrainingTargetScene.instantiate()
	root.add_child(player)
	root.add_child(center_target)
	root.add_child(outer_target)
	root.add_child(far_target)
	player.global_position = Vector2(200, 200)
	var cast_point := Vector2(360, 200)
	center_target.global_position = cast_point
	outer_target.global_position = cast_point + Vector2(80, 0)
	far_target.global_position = cast_point + Vector2(132, 0)
	await physics_frame

	var ability := player.ability_4_component as KingSkill4Component
	var visual := player.get_node("AbilityPivot/KingSkill4Visual") as KingSkill4Visual
	var sword := player.get_node("AbilityPivot/KingSkill4Visual/SpiritSword") as AnimatedSprite2D
	var ground := player.get_node("AbilityPivot/KingSkill4Visual/GroundEffect") as AnimatedSprite2D
	var impact_shape := player.get_node("AbilityPivot/Ability4Hitbox/CollisionShape2D") as CollisionShape2D
	if ability == null or ability.definition == null or ability.definition.ability_id != &"king_skill_4":
		_fail("King Skill 4 is not equipped through its dedicated component.")
		return
	var hit_counts := {}
	ability.hit_landed.connect(func(target: HurtboxComponent, _info: DamageInfo) -> void:
		var key := target.get_instance_id()
		hit_counts[key] = int(hit_counts.get(key, 0)) + 1
	)
	if not player.request_ability(4) or not player.ground_point_targeting.is_targeting():
		_fail("Skill 4 did not open ground-point targeting.")
		return
	if ability.is_casting() or not is_equal_approx(ability.cooldown_remaining, 0.0):
		_fail("Skill 4 spent its cast before target confirmation.")
		return
	player.ground_point_targeting.update_aim(cast_point, Vector2.ZERO)
	player.ground_point_targeting.confirm_targeting()
	if not ability.is_casting() or ability.cooldown_remaining < 19.9:
		_fail("Confirmed Skill 4 did not begin its committed 20-second cooldown.")
		return
	if not visual.visible or not sword.visible:
		_fail("Skill 4 did not begin the rigid spirit-sword descent presentation.")
		return
	if visual.global_position.distance_to(cast_point) > 0.1:
		_fail("Skill 4 visual root did not lock to the confirmed ground point.")
		return

	var saw_build_up := false
	var saw_explosion := false
	var minimum_sword_cutoff := 1.0
	var seen_ground_frames := {}
	var seen_sword_frames := {}
	var first_health := 100.0
	var center_min_health := 100.0
	var outer_min_health := 100.0
	var far_min_health := 100.0
	for frame_index in range(120):
		await physics_frame
		center_min_health = minf(center_min_health, center_target.get_node("HealthComponent").current_health)
		outer_min_health = minf(outer_min_health, outer_target.get_node("HealthComponent").current_health)
		far_min_health = minf(far_min_health, far_target.get_node("HealthComponent").current_health)
		if ground.visible:
			seen_ground_frames["%s:%d" % [ground.animation, ground.frame]] = true
		if sword.visible:
			seen_sword_frames["%s:%d" % [sword.animation, sword.frame]] = true
		if ability.get_current_strike_index() == 0 and ability.phase == AbilityComponent.Phase.ACTIVE:
			saw_build_up = saw_build_up or ground.animation == &"build_up"
			first_health = center_target.get_node("HealthComponent").current_health
			minimum_sword_cutoff = minf(
				minimum_sword_cutoff,
				float(sword.material.get_shader_parameter("visible_cutoff_uv"))
			)
		if ability.get_current_strike_index() == 1:
			saw_explosion = saw_explosion or ground.animation == &"explosion" or ground.animation == &"crater"
		if not ability.is_casting():
			break
	if not saw_build_up or not saw_explosion:
		_fail("Skill 4 did not present its unified build-up and second explosion in order.")
		return
	if minimum_sword_cutoff > 0.91:
		_fail("Skill 4 did not swallow the sword point below ground during the unified build-up.")
		return
	for expected_ground_frame in ["build_up:0", "build_up:1", "build_up:2", "build_up:3", "build_up:4", "build_up:5", "explosion:0", "crater:0"]:
		if not seen_ground_frames.has(expected_ground_frame):
			_fail("Skill 4 left an authored ground frame unused: %s." % expected_ground_frame)
			return
	for expected_sword_frame in ["formation:0", "formation:1", "formation:2", "embedded:0", "embedded:1", "embedded:2", "embedded:3", "dissolve:0"]:
		if not seen_sword_frames.has(expected_sword_frame):
			_fail("Skill 4 left an authored sword frame unused: %s." % expected_sword_frame)
			return
	if not is_equal_approx(first_health, 45.0):
		_fail("Skill 4 first impact was not one concentrated 220% Ashwood hit: %s." % first_health)
		return
	var center_hurtbox := center_target.get_node("Hurtbox") as HurtboxComponent
	var outer_hurtbox := outer_target.get_node("Hurtbox") as HurtboxComponent
	var far_hurtbox := far_target.get_node("Hurtbox") as HurtboxComponent
	if int(hit_counts.get(center_hurtbox.get_instance_id(), 0)) != 2:
		_fail("A center target did not receive both Skill 4 damage windows.")
		return
	if not is_equal_approx(outer_min_health, 25.0):
		_fail("An outer target did not receive exactly the 300% explosion hit.")
		return
	if not is_equal_approx(far_min_health, 100.0):
		_fail("Skill 4 damaged a target outside its authored 104-pixel explosion radius.")
		return
	if int(hit_counts.get(outer_hurtbox.get_instance_id(), 0)) != 1 or int(hit_counts.get(far_hurtbox.get_instance_id(), 0)) != 0:
		_fail("Skill 4 hit-count boundaries drifted between center, outer ring, and outside targets.")
		return
	if not (impact_shape.shape is CircleShape2D) or not is_equal_approx((impact_shape.shape as CircleShape2D).radius, 104.0):
		_fail("Skill 4 did not swap to its 104-pixel circle for the final strike.")
		return
	if not visual.visible or ground.animation != &"crater":
		_fail("Skill 4 did not preserve its crater beyond recovery.")
		return
	var crater_origin := visual.global_position
	player.global_position += Vector2(40, 0)
	await physics_frame
	if visual.global_position.distance_to(crater_origin) > 0.1:
		_fail("Skill 4 crater followed King instead of remaining at the cast point.")
		return

	var sword_image := (load(SWORD_PATH) as Texture2D).get_image()
	var sword_frames := load(SWORD_FRAMES_PATH) as SpriteFrames
	var ground_image := (load(GROUND_PATH) as Texture2D).get_image()
	var frames := load(FRAMES_PATH) as SpriteFrames
	if sword_image.get_size() != Vector2i(576, 384):
		_fail("Skill 4 sword VFX is not an exact 4x2 atlas of 144x192 cells.")
		return
	if (
		sword_frames == null
		or sword_frames.get_frame_count(&"formation") != 3
		or sword_frames.get_frame_count(&"embedded") != 4
		or sword_frames.get_frame_count(&"dissolve") != 1
	):
		_fail("Skill 4 sword SpriteFrames lost its complete eight-frame sequence.")
		return
	for sword_index in range(8):
		var sword_row := sword_index / 4
		var sword_column := sword_index % 4
		var local_bottom := -1
		for local_y in range(192):
			for local_x in range(144):
				if sword_image.get_pixel(sword_column * 144 + local_x, sword_row * 192 + local_y).a > 0.5:
					local_bottom = local_y + 1
		if local_bottom != 188:
			_fail("Skill 4 sword frame %d drifted from the y=188 point baseline." % sword_index)
			return
	if ground_image.get_size() != Vector2i(1024, 512):
		_fail("Skill 4 ground VFX is not an exact 4x2 atlas of 256-pixel cells.")
		return
	if (
		frames == null
		or frames.get_frame_count(&"build_up") != 6
		or frames.get_frame_count(&"explosion") != 1
		or frames.get_frame_count(&"crater") != 1
	):
		_fail("Skill 4 ground SpriteFrames lost its complete eight-frame sequence.")
		return
	for image in [sword_image, ground_image]:
		for y in range(image.get_height()):
			for x in range(image.get_width()):
				var alpha: float = image.get_pixel(x, y).a
				if alpha != 0.0 and alpha != 1.0:
					_fail("Skill 4 runtime VFX contains non-binary alpha.")
					return
	for frame_index in range(140):
		await physics_frame
	if visual.visible:
		_fail("Skill 4 crater did not fade and clean itself up.")
		return
	print("King Skill 4 targeting, eight-frame sword/ground sequences, corrected crater anchor, and world-locked residue test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
