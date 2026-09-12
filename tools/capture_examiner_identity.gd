extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://art_source/review/characters/disciples/examiner/identity_2026_09_12/"
var lab: Node
var examiner: Examiner
var _drive := false
var _walk_direction := Vector2.ZERO


func _initialize() -> void:
	call_deferred("_run")


func _process(delta: float) -> bool:
	if is_instance_valid(examiner) and not _walk_direction.is_zero_approx():
		examiner.global_position += _walk_direction * delta * 70.0
	if _drive and is_instance_valid(examiner):
		if examiner.state in [Examiner.State.CHARGE_TRAVEL, Examiner.State.AXIOM_DASH]:
			examiner._process_travel(delta)
		elif examiner.state >= Examiner.State.DESCENT_PREPARE and examiner.state <= Examiner.State.DESCENT_RECOVERY:
			examiner._process_divine_descent(delta)
		elif examiner.state != Examiner.State.APPROACH:
			examiner._tick_state(delta)
	return false


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	lab = LabScene.instantiate()
	root.add_child(lab)
	current_scene = lab
	await create_timer(1.0).timeout
	examiner = lab._active_enemies[0] as Examiner
	examiner.set_physics_process(false)
	lab.player.set_physics_process(false)
	examiner._deactivate_hitboxes()
	examiner._enter(Examiner.State.APPROACH, 0.0)
	examiner.global_position = Vector2(365, 270)
	lab.player.global_position = Vector2(365, 380)
	examiner._set_facing(Vector2.DOWN)
	await _capture("01_court")
	for direction: Vector2 in [Vector2.DOWN, Vector2.RIGHT, Vector2.LEFT, Vector2.UP]:
		examiner.global_position = Vector2(365, 285) - direction * 35
		examiner._set_facing(direction)
		examiner._set_moving(false)
		await create_timer(.6).timeout
		examiner._set_moving(true)
		_walk_direction = direction
		await create_timer(1.6).timeout
		_walk_direction = Vector2.ZERO
		examiner._set_moving(false)
		await create_timer(.4).timeout
		_drive = true
		lab.player.global_position = examiner.global_position + direction * 110
		examiner._begin_combo(direction)
		await create_timer(1.85).timeout
		_drive = false
		examiner._deactivate_hitboxes()
		examiner._enter(Examiner.State.APPROACH, 0.0)
	print("Examiner rendered review saved to ", OUT)
	_drive = false
	lab.clear_simulation()
	lab.queue_free()
	lab = null
	examiner = null
	await process_frame
	await process_frame
	for shape in range(DisplayServer.CURSOR_MAX):
		DisplayServer.cursor_set_custom_image(null, shape)
	await process_frame
	quit()


func _capture(label: String) -> void:
	await RenderingServer.frame_post_draw
	var result := root.get_texture().get_image().save_png(OUT + label + ".png")
	if result != OK:
		push_error("Capture failed: " + label)
