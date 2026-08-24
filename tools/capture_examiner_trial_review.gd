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
		"res://art_source/review/characters/disciples/examiner/examiner_boss_idle_review_v3_2026-08-25.png"
	)
	examiner._enter(Examiner.State.COMBO_WIND_UP, 0.8)
	await create_timer(0.36).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_boss_thrust_review_v3_2026-08-25.png"
	)
	examiner._enter(Examiner.State.SWEEP_WIND_UP, 0.8)
	await create_timer(0.32).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_boss_sweep_windup_review_v3_2026-08-25.png"
	)
	examiner._begin_judgment_charge(Vector2(190.0, 0.0))
	await create_timer(0.32).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_boss_charge_warning_review_v3_2026-08-25.png"
	)
	examiner._enter(Examiner.State.CHARGE_TRAVEL, 0.8)
	await create_timer(0.12).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_boss_charge_review_v3_2026-08-25.png"
	)
	examiner._enter(Examiner.State.SLAM_WIND_UP, 0.82)
	await create_timer(0.58).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_boss_slam_windup_review_v3_2026-08-25.png"
	)
	examiner.action_impact.emit(&"ground_judgment", examiner.global_position + Vector2(0, -6), Vector2.DOWN)
	examiner._enter(Examiner.State.SLAM_ACTIVE, 0.14)
	await create_timer(0.05).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_boss_slam_impact_review_v3_2026-08-25.png"
	)
	examiner.target = lab.player
	examiner._begin_axiom(lab.player.global_position - examiner.global_position)
	await create_timer(0.32).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_boss_axiom_review_v3_2026-08-25.png"
	)
	examiner._phase_transition_requested = true
	examiner.health_component.set_invulnerable(true)
	examiner._enter(Examiner.State.PHASE_STANCE, 0.0)
	examiner.begin_divine_descent()
	await create_timer(0.38).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_divine_descent_prepare_review_v5_2026-08-25.png"
	)
	await create_timer(0.29).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_divine_descent_launch_review_v5_2026-08-25.png"
	)
	examiner.visible = false
	lab.player.global_position = lab.court_arena.protection_points()[2]
	lab.court_arena.begin_divine_descent_charge(3.8)
	await create_timer(2.45).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_divine_descent_cover_review_v4_2026-08-25.png"
	)
	examiner.visible = true
	examiner.global_position = Vector2(365.0, 287.0)
	examiner._enter(Examiner.State.DESCENT_IMPACT, Examiner.DESCENT_IMPACT_SECONDS)
	examiner.action_impact.emit(&"divine_descent", examiner.global_position, Vector2.DOWN)
	lab.court_arena.resolve_divine_descent(lab.player, 260.0, examiner)
	await create_timer(0.025).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_divine_descent_impact_accent_review_v5_2026-08-25.png"
	)
	await create_timer(0.055).timeout
	_save_capture(
		"res://art_source/review/characters/disciples/examiner/examiner_divine_descent_impact_review_v5_2026-08-25.png"
	)
	lab.queue_free()
	await process_frame
	await process_frame
	print("Saved Examiner Combat Lab review.")
	quit(0)


func _save_capture(resource_path: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	if image == null:
		push_error("Examiner capture requires a rendering driver; do not run this review tool with --headless.")
		return
	var path := ProjectSettings.globalize_path(resource_path)
	var error := image.save_png(path)
	if error != OK:
		push_error("Unable to save Examiner review: %s" % resource_path)
