extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var lab := LabScene.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	lab.set_enemy_ai_enabled(false)
	var examiner := lab._active_enemies[0] as Examiner
	examiner.global_position = Vector2(365.0, 225.0)
	examiner._enter(Examiner.State.APPROACH, 0.0)
	examiner.facing_changed.emit(Vector2.DOWN)
	for frame in range(4):
		await process_frame
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_compact_idle_review_v2_2026-08-24.png"
	)
	examiner._enter(Examiner.State.COMBO_WIND_UP, 0.8)
	await create_timer(0.36).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_compact_thrust_review_v2_2026-08-24.png"
	)
	examiner._enter(Examiner.State.SWEEP_ACTIVE, 0.8)
	await create_timer(0.32).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_compact_sweep_review_v2_2026-08-24.png"
	)
	examiner._enter(Examiner.State.ZERO_TRAVEL, 0.8)
	await create_timer(0.12).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_compact_dash_review_v2_2026-08-24.png"
	)
	examiner.target = lab.player
	examiner._begin_axiom(lab.player.global_position - examiner.global_position)
	await create_timer(0.32).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_compact_axiom_review_v2_2026-08-24.png"
	)
	lab.queue_free()
	await process_frame
	await process_frame
	print("Saved Examiner Combat Lab review.")
	quit(0)


func _save_capture(resource_path: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(resource_path)
	var error := image.save_png(path)
	if error != OK:
		push_error("Unable to save Examiner review: %s" % resource_path)
