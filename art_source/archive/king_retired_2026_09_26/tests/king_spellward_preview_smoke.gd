extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(value: bool, message: String) -> void:
	checks += 1
	if not value:
		failures += 1
		push_error(message)

func _run() -> void:
	var lab := Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	var actor: Player = lab.player
	var body: AnimatedSprite2D = actor.get_node("VisualRoot/Body")
	var review: Node = lab.get_node("KingSpellwardReview")
	var original_frames := body.sprite_frames
	var original_script: Script = body.get_script()
	var original_material := body.material
	var hit_shape := actor.attack_component.collision_shape.shape
	var weapon := actor.attack_component.weapon
	var original_speed := actor.movement_component.max_speed
	_check(not review.enabled and body.scale == Vector2.ONE, "Default Lab must retain original King")
	review.open_review()
	await process_frame
	_check(review.enabled and body.scale == Vector2(.5, .5), "C review must use double-density art at unchanged logical scale")
	_check(body.sprite_frames != original_frames, "C review did not replace presentation frames")
	_check(body.material is ShaderMaterial, "C outline must apply consistently to every body animation")
	_check(actor.attack_component.weapon == weapon and actor.attack_component.collision_shape.shape == hit_shape, "Presentation changed combat resources")
	for direction: Vector2 in [Vector2.DOWN, Vector2.LEFT, Vector2.RIGHT, Vector2.UP]:
		actor._set_facing_direction(direction)
		_check(String(body.animation) == "idle_" + String(body.call("_direction_name", direction)), "Idle must follow actual facing signals after script replacement")
	for direction in ["down", "left", "right", "up"]:
		for action in ["idle", "walk", "attack", "return_cut", "heavy_cleave", "hurt", "stagger", "dash", "defeat"]:
			var clip: String = action + "_" + direction
			_check(body.sprite_frames.has_animation(clip), "Missing " + clip)
			for i in body.sprite_frames.get_frame_count(clip):
				var tex := body.sprite_frames.get_frame_texture(clip, i)
				_check(tex.get_size() == Vector2(192, 128), "Wrong preview cell dimensions")
	actor._set_facing_direction(Vector2.RIGHT)
	body.call("set_movement", Vector2.RIGHT, true)
	body.set_frame_and_progress(6, .5)
	actor._set_facing_direction(Vector2.UP)
	_check(body.frame == 3 and is_equal_approx(body.frame_progress, .25), "Turning into four-frame walk must preserve stride phase")
	actor._set_facing_direction(Vector2.LEFT)
	_check(body.frame == 6 and is_equal_approx(body.frame_progress, .5), "Turning back into eight-frame side walk must preserve stride phase")
	_check(is_equal_approx(body.sprite_frames.get_frame_count("walk_left") / body.sprite_frames.get_animation_speed("walk_left"), body.sprite_frames.get_frame_count("walk_up") / body.sprite_frames.get_animation_speed("walk_up")), "Extra side drawings must preserve cycle cadence")
	body.call("set_movement", Vector2.ZERO, false)
	actor._set_facing_direction(Vector2.RIGHT)
	var foe: Node2D = lab._active_enemies[0]
	foe.global_position = actor.global_position + Vector2(28, 0)
	foe.set_physics_process(false)
	var foe_health: HealthComponent = foe.get_node("HealthComponent")
	foe_health.maximum_health = 100000
	foe_health.set_current_health(100000)
	var contacts: Array[int] = [0]
	actor.attack_component.hit_landed.connect(func(_target: HurtboxComponent, _info: DamageInfo) -> void: contacts[0] += 1)
	actor.attack_component.reset_combo()
	for key in ["attack", "return_cut", "heavy_cleave"]:
		_check(actor.attack_component.request_attack(Vector2.RIGHT), "Real combo request failed")
		_check(String(body.animation) == key + "_right", "Combo did not use distinct accepted animation")
		_check(not review.set_preview_enabled(false), "Appearance switch should reject during attack")
		while actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
			await physics_frame
	_check(String(body.animation).begins_with("idle_"), "Combo did not return to idle")
	_check(contacts[0] == 3 and foe_health.current_health < 100000, "Three visible cuts must each connect through real collision once")
	review.open_review()
	_check(lab._active_enemies[0] == foe, "Reopening review controls must not reset the fight")
	review.cycle_speed()
	_check(review.speed_mode == 1 and actor.movement_component.max_speed == actor.movement_component._base_max_speed, "Base speed review incorrect")
	review.cycle_speed()
	_check(review.speed_mode == 2 and is_equal_approx(actor.movement_component.max_speed, actor.movement_component._base_max_speed * 1.35), "Movement cap review incorrect")
	_check(is_equal_approx(actor.attack_component._scaled_duration(1.0), 1.0 / 1.5), "Attack cap review incorrect")
	body.call("set_movement", Vector2.RIGHT, true)
	_check(is_equal_approx(body.speed_scale, 1.35), "Walking cadence did not follow capped equipment speed")
	body.call("set_movement", Vector2.ZERO, false)
	review.cycle_speed()
	_check(review.speed_mode == 0 and is_equal_approx(actor.movement_component.max_speed, original_speed), "Real equipment stats were not restored")
	var before := actor.health_component.current_health
	review.sample_hit(.8)
	_check(actor.is_in_hit_recovery() and String(body.animation).begins_with("stagger_"), "Long accepted control did not select stun hold")
	_check(is_equal_approx(before, actor.health_component.current_health), "Reaction sample changed health")
	_check(not review.set_preview_enabled(false), "Cannot swap appearance during stun")
	await create_timer(.35).timeout
	_check(String(body.animation).begins_with("stagger_"), "Stun artwork returned to idle before authority released control")
	await create_timer(.7).timeout
	_check(not actor.is_in_hit_recovery() and String(body.animation).begins_with("idle_"), "Stun failed to release on authority completion")
	_check(review.set_preview_enabled(false), "Could not restore original appearance")
	_check(body.get_script() == original_script and body.sprite_frames == original_frames and body.scale == Vector2.ONE, "Original presentation was not restored exactly")
	_check(body.material == original_material, "Original material must be restored on comparison")
	_check(actor.attack_component.weapon == weapon and actor.attack_component.collision_shape.shape == hit_shape, "Review mutated shared combat resources")
	_check(review.set_preview_enabled(true), "Repeated comparison toggle failed")
	actor.health_component.set_current_health(.5)
	review.sample_hit(.11)
	_check(not actor.is_defeated and is_equal_approx(actor.health_component.current_health, .5), "Reaction sample must not kill low-health King")
	lab.queue_free()
	await process_frame
	await process_frame
	print("SPELLWARD_PREVIEW_CHECKS=", checks, " FAILURES=", failures)
	quit(0 if failures == 0 else 1)
