extends SceneTree

const BossScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")
const LandingFeedback = preload("res://entities/enemies/stage_5_boss/stage_5_boss_landing_feedback.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var effects := Node2D.new()
	effects.add_to_group("boss_effects")
	root.add_child(effects)
	var target := _build_target()
	root.add_child(target)
	target.global_position = Vector2(360.0, 260.0)
	var boss := BossScene.instantiate() as Stage5Boss
	boss.target = target
	boss.global_position = Vector2(260.0, 260.0)
	root.add_child(boss)
	var camera := Camera2D.new()
	root.add_child(camera)
	var landing_feedback := LandingFeedback.new()
	landing_feedback.boss = boss
	landing_feedback.camera = camera
	root.add_child(landing_feedback)
	var camera_shakes := [0]
	landing_feedback.shake_started.connect(func() -> void: camera_shakes[0] += 1)
	await process_frame
	await physics_frame

	var body := boss.get_node("Visual/Body") as AnimatedSprite2D
	var expected_counts := {
		"idle": 4,
		"walk": 6,
		"hurt": 3,
		"dead": 5,
		"lunge_wind_up": 4,
		"lunge_active": 2,
		"lunge_recovery": 2,
		"slap_wind_up": 4,
		"slap_active": 2,
		"slap_recovery": 2,
		"jump_wind_up": 2,
		"jump_travel": 4,
		"jump_land": 1,
		"jump_recovery": 1,
	}
	for direction in ["down", "left", "right", "up"]:
		for action: String in expected_counts:
			var animation := StringName(action + "_" + direction)
			if not body.sprite_frames.has_animation(animation) or body.sprite_frames.get_frame_count(animation) != expected_counts[action]:
				_fail("Stage 5 boss animation %s lost its authored frame range." % animation)
				return
	if body.sprite_frames.get_animation_names().size() != 56:
		_fail("Stage 5 boss must expose exactly 56 directional runtime animations.")
		return

	var visited: Array[int] = []
	boss.state_changed.connect(func(state: Stage5Boss.State, _duration: float) -> void: visited.append(state))
	boss.state = Stage5Boss.State.CHASE
	boss._attacks_since_jump = 0
	boss._jump_cooldown = 10.0
	target.global_position = boss.global_position + Vector2(60.0, 0.0)
	await physics_frame
	if boss.state != Stage5Boss.State.LUNGE_WIND_UP:
		_fail("Boss did not enter its readable root-arm lunge wind-up.")
		return
	await create_timer(boss.definition.wind_up_seconds + boss.definition.active_seconds + 0.06).timeout
	if not visited.has(Stage5Boss.State.LUNGE_ACTIVE) or not visited.has(Stage5Boss.State.LUNGE_RECOVERY):
		_fail("Boss lunge did not expose separate contact and recovery states.")
		return

	await create_timer(boss.definition.recovery_seconds + 0.05).timeout
	boss._jump_cooldown = 10.0
	target.global_position = boss.global_position + Vector2(60.0, 0.0)
	await physics_frame
	if boss.state != Stage5Boss.State.SLAP_WIND_UP:
		_fail("Boss did not alternate into its separate overhead slap wind-up.")
		return
	await create_timer(boss.slap_wind_up_seconds + boss.slap_active_seconds + 0.06).timeout
	if not visited.has(Stage5Boss.State.SLAP_ACTIVE) or not visited.has(Stage5Boss.State.SLAP_RECOVERY):
		_fail("Boss slap did not expose separate overhead contact and recovery states.")
		return

	boss.state = Stage5Boss.State.CHASE
	boss._attacks_since_jump = 2
	boss._jump_cooldown = 0.0
	boss.global_position = Vector2(260.0, 260.0)
	target.global_position = Vector2(520.0, 300.0)
	var locked_target := target.global_position
	var target_health := target.get_node("HealthComponent") as HealthComponent
	var before := target_health.current_health
	# State is forced immediately after the previous timer callback. Give the
	# next physics tick (and its deferred scene-tree additions) time to settle.
	for tick in 3:
		await physics_frame
		if boss.state == Stage5Boss.State.JUMP_WIND_UP and is_instance_valid(boss._marker):
			break
	if boss.state != Stage5Boss.State.JUMP_WIND_UP or not is_instance_valid(boss._marker):
		_fail("Boss jump did not lock a visible target marker.")
		return
	target.global_position = Vector2(700.0, 420.0)
	await create_timer(boss.jump_wind_up_seconds + boss.jump_travel_seconds + 0.08).timeout
	if boss.global_position.distance_to(locked_target) > 1.0:
		_fail("Boss jump retargeted after committing its warning marker.")
		return
	if not visited.has(Stage5Boss.State.JUMP_TRAVEL) or not visited.has(Stage5Boss.State.JUMP_LAND):
		_fail("Boss jump did not expose travel and landing states.")
		return
	if camera_shakes[0] != 1:
		_fail("Boss landing did not trigger exactly one presentation-only camera shake.")
		return
	if effects.get_child_count() == 0:
		_fail("Boss landing did not spawn a world-owned impact/crater effect.")
		return
	var impact_effect := effects.find_child("Stage5BossJumpImpact", false, false)
	if impact_effect == null:
		_fail("Boss landing impact is not owned by the world effects layer.")
		return
	var impact_sprite := impact_effect.get_node("Impact") as AnimatedSprite2D
	var spike_sprite := impact_effect.get_node("Spikes") as AnimatedSprite2D
	if impact_sprite.sprite_frames.get_frame_count(&"impact") != 8:
		_fail("Boss landing crater lost one of its eight chronological frames.")
		return
	if spike_sprite.sprite_frames.get_frame_count(&"impact") != 6:
		_fail("Boss landing spike eruption lost one of its six chronological frames.")
		return
	if impact_sprite.position != Vector2(0.0, -26.0) or spike_sprite.position != Vector2(0.0, -44.0):
		_fail("Boss landing layers no longer share the exact foot-contact ground anchor.")
		return
	# Move the target back onto the locked landing point while the short radial
	# contact is active, then allow Area2D overlap resolution.
	target.global_position = locked_target
	await physics_frame
	await physics_frame
	if not is_equal_approx(before - target_health.current_health, boss.jump_damage):
		_fail("Boss landing did not resolve exactly one authored radial hit.")
		return
	await create_timer(0.25).timeout
	if not camera.offset.is_zero_approx():
		_fail("Boss landing camera shake did not restore the authored camera offset.")
		return

	print("Stage 5 boss runtime animations, lunge, overhead slap, locked jump, landing damage, and world impact passed.")
	quit(0)


func _build_target() -> CharacterBody2D:
	var target := CharacterBody2D.new()
	var health := HealthComponent.new()
	health.name = "HealthComponent"
	health.maximum_health = 200.0
	target.add_child(health)
	var hurtbox := HurtboxComponent.new()
	hurtbox.collision_layer = 64
	hurtbox.collision_mask = 32
	hurtbox.health_component = health
	target.add_child(hurtbox)
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = 10.0
	shape.shape = circle
	hurtbox.add_child(shape)
	return target


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
