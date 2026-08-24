extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var lab := LabScene.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	await physics_frame

	if lab.get_live_enemy_count() != 1 or lab._active_enemies.is_empty():
		_fail("Examiner trial did not create its opening actor.")
		return
	var examiner := lab._active_enemies[0] as Examiner
	if examiner == null:
		_fail("Combat Lab opening actor is not the Examiner.")
		return
	if examiner.definition.maximum_health != 1800.0 or examiner.definition.axiom_damage != 38.0:
		_fail("Examiner did not receive its data-driven trial tuning.")
		return
	var body := examiner.get_node("Visual/Body") as AnimatedSprite2D
	if not is_equal_approx(body.position.y, -56.0):
		_fail("Examiner lost its normalized visual origin.")
		return
	var expected_frames := {
		&"idle_down": 2,
		&"walk_right": 4,
		&"thrust_down": 6,
		&"sweep_left": 6,
		&"zero_travel_right": 3,
		&"refutation_active_down": 3,
		&"hurt_up": 3,
		&"withdrawal_left": 3,
		&"axiom_wind_up_up": 3,
		&"axiom_cut_one_down": 4,
		&"axiom_cut_two_right": 4,
		&"axiom_dash_left": 4,
	}
	for animation: StringName in expected_frames:
		if not body.sprite_frames.has_animation(animation) or body.sprite_frames.get_frame_count(animation) != expected_frames[animation]:
			_fail("Examiner lost required animation %s." % animation)
			return
		for frame_index in body.sprite_frames.get_frame_count(animation):
			var frame_texture := body.sprite_frames.get_frame_texture(animation, frame_index) as AtlasTexture
			if frame_texture == null or frame_texture.region.size != Vector2(192.0, 128.0):
				_fail("Examiner animation %s lost its exact 192x128 frame grid." % animation)
				return

	await create_timer(examiner.definition.spawn_seconds + 0.05).timeout
	examiner._enter(Examiner.State.APPROACH, 0.0)
	examiner._axiom_cooldown = 0.0
	examiner._physics_process(0.016)
	if examiner.state != Examiner.State.AXIOM_WIND_UP:
		_fail("Examiner did not enter Axiom Divide when the signature became ready.")
		return
	if lab.effects.get_child_count() != 3:
		_fail("Axiom Divide did not create three independent readable lane warnings.")
		return
	if examiner.health_component.is_invulnerable:
		_fail("Axiom Divide incorrectly made the Examiner invulnerable.")
		return

	print("Examiner trial data, authored animation set, divine court, and three-lane Axiom Divide telegraph passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
