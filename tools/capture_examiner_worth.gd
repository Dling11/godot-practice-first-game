extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")
const OUT := "res://art_source/review/characters/disciples/examiner/worth_2026_09_12/"
var lab: Node
var examiner: Examiner
var _drive := false
var _walk_direction := Vector2.ZERO


func _initialize() -> void:
	call_deferred("_run")


func _process(delta: float) -> bool:
	if is_instance_valid(examiner) and not _walk_direction.is_zero_approx():
		examiner.global_position += _walk_direction * delta * 70.0
	if _drive and is_instance_valid(examiner) and examiner.state != Examiner.State.APPROACH:
		examiner._physics_process(delta)
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
	_drive = true
	examiner._phase_transition_requested = true
	examiner.global_position = Vector2(305,280)
	lab.player.global_position = Vector2(430,280)
	examiner._begin_pursuit(Vector2.RIGHT * 125)
	await create_timer(.30).timeout
	await _capture("01_reprisal_warning")
	lab.player.global_position = Vector2(430,350)
	await create_timer(1.3).timeout
	examiner.global_position = Vector2(365,260)
	lab.player.global_position = Vector2(365,315)
	examiner._set_facing(Vector2.DOWN)
	examiner._enter(Examiner.State.HELD_JUDGMENT,1.05)
	await create_timer(.70).timeout
	await _capture("02_held_judgment")
	await create_timer(1.3).timeout
	examiner._begin_trial()
	await create_timer(1.4).timeout
	await _capture("03_seal_cut")
	# Review fixture: real damage application drives the meter, independent of VFX.
	for hit in 5:
		lab.player.request_directional_primary_attack(examiner.global_position)
		examiner.health_component.apply_damage(DamageInfo.new(70.0,lab.player,Vector2.UP))
		await create_timer(.65).timeout
		if examiner.state != Examiner.State.TRIAL_CHANNEL:
			break
	await _capture("04_sanctuary_earned")
	if examiner._trial_succeeded:
		var route := create_tween()
		route.tween_property(lab.player,"global_position",examiner._sanctuary_position,1.6)
	await create_timer(3.3).timeout
	await _capture("05_protected_impact")
	await create_timer(1.0).timeout
	examiner.global_position = Vector2(365,270)
	lab.player.global_position = Vector2(365,350)
	examiner._begin_trial()
	await create_timer(6.7).timeout
	await _capture("06_trial_failed")
	await create_timer(1.3).timeout
	await _capture("07_no_sanctuary")
	# Keep the capture alive to show finite mitigation rather than triggering death flow.
	lab.set_player_invincible(false)
	lab.player.health_component.set_maximum_health(1000,false)
	lab.player.health_component.set_current_health(1000)
	await create_timer(2.8).timeout
	await _capture("08_verdict_damage")
	await create_timer(.6).timeout
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
