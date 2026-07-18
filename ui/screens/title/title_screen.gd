class_name TitleScreen
extends Control

signal journey_requested(destination: String)
signal settings_opened
signal quit_requested

@export_file("*.tscn") var new_journey_scene := "res://levels/sanctuary/sanctuary.tscn"

@onready var content: Control = %Content
@onready var main_menu_panel: PanelContainer = %MainMenuPanel
@onready var settings_panel: PanelContainer = %SettingsPanel
@onready var start_button: Button = %StartButton
@onready var settings_button: Button = %SettingsButton
@onready var quit_button: Button = %QuitButton
@onready var music_button: Button = %MusicButton
@onready var sfx_button: Button = %SfxButton
@onready var ui_audio_button: Button = %UiAudioButton

var _transitioning := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	settings_panel.hide()
	_refresh_audio_labels()
	content.modulate.a = 0.0
	var reveal := create_tween()
	reveal.tween_property(content, "modulate:a", 1.0, 0.55)
	start_button.call_deferred("grab_focus")


func _unhandled_input(event: InputEvent) -> void:
	if settings_panel.visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_settings()


func begin_new_journey() -> void:
	if _transitioning or new_journey_scene.is_empty() or not ResourceLoader.exists(new_journey_scene):
		return
	_transitioning = true
	_set_main_buttons_disabled(true)
	journey_requested.emit(new_journey_scene)
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		run_session.reset_run()
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.reset_story()
	var transition_service := get_node_or_null("/root/SceneTransition")
	if transition_service == null:
		push_error("TitleScreen requires the SceneTransition autoload.")
		_transitioning = false
		_set_main_buttons_disabled(false)
		return
	# SceneTransition outlives this screen. Do not await from a scene that the
	# transition itself will free before the service finishes fading back in.
	transition_service.transition_to(new_journey_scene)


func open_settings() -> void:
	if _transitioning or settings_panel.visible:
		return
	main_menu_panel.hide()
	settings_panel.show()
	settings_opened.emit()
	music_button.grab_focus()


func close_settings() -> void:
	if not settings_panel.visible:
		return
	settings_panel.hide()
	main_menu_panel.show()
	settings_button.grab_focus()


func toggle_music() -> void:
	_toggle_bus(AudioDirector.MUSIC_BUS)


func toggle_sfx() -> void:
	_toggle_bus(AudioDirector.SFX_BUS)


func toggle_ui_audio() -> void:
	_toggle_bus(AudioDirector.UI_BUS)


func request_quit() -> void:
	if _transitioning:
		return
	quit_requested.emit()
	get_tree().quit()


func _toggle_bus(bus_name: String) -> void:
	var bus_index := AudioServer.get_bus_index(bus_name)
	if bus_index < 0:
		push_error("TitleScreen could not find the %s audio bus." % bus_name)
		return
	AudioServer.set_bus_mute(bus_index, not AudioServer.is_bus_mute(bus_index))
	_refresh_audio_labels()


func _refresh_audio_labels() -> void:
	music_button.text = _bus_label("MUSIC", AudioDirector.MUSIC_BUS)
	sfx_button.text = _bus_label("COMBAT SOUND", AudioDirector.SFX_BUS)
	ui_audio_button.text = _bus_label("MENU SOUND", AudioDirector.UI_BUS)


func _bus_label(label: String, bus_name: String) -> String:
	var bus_index := AudioServer.get_bus_index(bus_name)
	var state := "OFF" if bus_index >= 0 and AudioServer.is_bus_mute(bus_index) else "ON"
	return "%s  %s" % [label, state]


func _set_main_buttons_disabled(is_disabled: bool) -> void:
	start_button.disabled = is_disabled
	settings_button.disabled = is_disabled
	quit_button.disabled = is_disabled
