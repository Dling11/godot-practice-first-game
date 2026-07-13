extends SceneTree

const TitleScene = preload("res://ui/screens/title/title_screen.tscn")
const ThemeResource = preload("res://assets/ui/themes/battle_of_gods_theme.tres")
const SANCTUARY := "res://levels/sanctuary/sanctuary.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var title := TitleScene.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	await process_frame
	await process_frame
	if title.theme != ThemeResource:
		_fail("Title screen is not using the shared UI theme.")
		return
	var background := title.get_node("Background")
	for layer_name in ["Base", "DistantSilhouette", "Atmosphere", "Vignette"]:
		if not background.has_node(layer_name):
			_fail("Replaceable title background is missing layer: %s" % layer_name)
			return
	var base_texture := background.get_node("Base").texture as Texture2D
	if base_texture == null or base_texture.get_size() != Vector2(960, 540):
		_fail("Title base background is not the required 960x540 asset.")
		return
	if root.gui_get_focus_owner() != title.start_button:
		_fail("Title screen did not give initial keyboard/gamepad focus to Start.")
		return
	title.open_settings()
	if title.main_menu_panel.visible or not title.settings_panel.visible:
		_fail("Settings did not replace the main menu cleanly.")
		return
	if root.gui_get_focus_owner() != title.music_button:
		_fail("Settings did not move focus to its first control.")
		return
	var music_bus := AudioServer.get_bus_index(AudioDirector.MUSIC_BUS)
	var original_music_mute := AudioServer.is_bus_mute(music_bus)
	title.toggle_music()
	if AudioServer.is_bus_mute(music_bus) == original_music_mute:
		_fail("Title music setting did not change the Music bus.")
		return
	title.toggle_music()
	title.close_settings()
	if not title.main_menu_panel.visible or title.settings_panel.visible:
		_fail("Closing settings did not restore the main menu.")
		return
	if root.gui_get_focus_owner() != title.settings_button:
		_fail("Closing settings did not restore focus to its invoking button.")
		return
	var run_session := root.get_node("RunSession")
	run_session.update_progression(80, 12)
	var transition_state := {"requested": "", "started": false, "finished": false}
	title.journey_requested.connect(func(destination: String) -> void: transition_state.requested = destination)
	var transition_service := root.get_node("SceneTransition")
	transition_service.transition_started.connect(func(_destination: String) -> void: transition_state.started = true, CONNECT_ONE_SHOT)
	transition_service.transition_finished.connect(func(_destination: String) -> void: transition_state.finished = true, CONNECT_ONE_SHOT)
	title.begin_new_journey()
	var timeout := create_timer(3.0, true, true)
	while not transition_state.finished and timeout.time_left > 0.0:
		await process_frame
	if not transition_state.finished:
		_fail("Title Start transition timed out (started=%s, current=%s)." % [transition_state.started, current_scene.scene_file_path if current_scene != null else "none"])
		return
	if transition_state.requested != SANCTUARY:
		_fail("Start did not request the configured Sanctuary destination.")
		return
	if current_scene == null or current_scene.scene_file_path != SANCTUARY:
		_fail("Title Start did not transition into the Sanctuary.")
		return
	if run_session.total_experience != 0 or run_session.coins != 0:
		_fail("A new journey did not reset the in-memory run state.")
		return
	print("Title screen smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
