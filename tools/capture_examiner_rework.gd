extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://art_source/review/characters/disciples/examiner/rework_2026_09_12/"
var lab: Node
var examiner: Examiner
var _drive := false


func _initialize() -> void:
	call_deferred("_run")


func _process(delta: float) -> bool:
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
	_drive = true
	examiner._begin_combo(Vector2.DOWN)
	await create_timer(.46).timeout
	await _capture("02_thrust")
	await create_timer(.70).timeout
	await _capture("03_sweep")
	await create_timer(.90).timeout
	examiner.global_position = Vector2(250, 270)
	lab.player.global_position = Vector2(560, 270)
	examiner._begin_judgment_charge(Vector2(310, 0))
	await create_timer(.50).timeout
	await _capture("04_charge_warning")
	await create_timer(.31).timeout
	await _capture("05_charge")
	await create_timer(.85).timeout
	examiner.global_position = Vector2(365, 285)
	lab.player.global_position = Vector2(365, 375)
	examiner._begin_ground_judgment(Vector2.DOWN)
	await create_timer(.61).timeout
	await _capture("06_slam_raise")
	await create_timer(.25).timeout
	await _capture("07_slam_contact")
	await create_timer(.85).timeout
	examiner._begin_refutation(Vector2.RIGHT)
	await create_timer(.35).timeout
	await _capture("08_refutation")
	await create_timer(.80).timeout
	examiner._begin_axiom(Vector2.DOWN)
	await create_timer(.65).timeout
	await _capture("09_axiom_warning")
	await create_timer(.33).timeout
	await _capture("10_axiom_contact")
	await create_timer(2.0).timeout
	examiner.global_position = Vector2(365, 270)
	examiner._set_facing(Vector2.DOWN)
	examiner._phase_transition_requested = true
	examiner._enter(Examiner.State.PHASE_STANCE, 0)
	examiner.begin_divine_descent()
	await create_timer(1.2).timeout
	lab.player.global_position = lab.court_arena.protection_points()[2]
	await _capture("11_descent_cover")
	await create_timer(3.60).timeout
	await _capture("12_descent_impact")
	await create_timer(1.5).timeout
	await _capture("13_second_measure")
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
