extends "res://tools/launch_enemy_arrival_review.gd"

const ArtEffect := preload("res://tools/enemy_arrival_preview_effect.gd")
const ART_NAMES := {"a": "Veil Tear", "b": "Earthwake", "c": "Shadow Cocoon"}
const ART_EVIDENCE := "res://art_source/review/encounters/arrival_art_2026_10_03/"
var _art_key := "a"
var _dark_ground := false
var _last_count := 1
var _rebuilding := false

func _run() -> void:
	# Do not invoke the parent capture branch: it documents the old seam.
	root.get_node("SaveService").configure_storage_path_for_testing("user://enemy_arrival_art_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await open_review()
	if "--capture-art" in OS.get_cmdline_user_args():
		await _capture_art()
		quit()

func open_review() -> void:
	await super.open_review()
	var effect := ArtEffect.new()
	effect.art_key = _art_key
	var packed := PackedScene.new()
	assert(packed.pack(effect) == OK)
	effect.free()
	stage.encounter_controller.summon_effect_scene = packed
	# Keep the first comparison below the eastern gateway's tall occluding arch.
	stage.encounter_controller.offsets = [Vector2(150,80),Vector2(220,120),Vector2(90,150),Vector2(-120,70),Vector2(-130,-40),Vector2(20,-160),Vector2(200,-150),Vector2(-190,-140)]
	_visit(Vector2(1040,480) if _dark_ground else Vector2(520,480))
	root.title = "Battle of Gods — Spawn Art A / B / C (NO SAVES / REWARDS)"
	var column: VBoxContainer = toolbar.get_child(0)
	var heading: Label = column.get_child(0)
	heading.text = "SPAWN ART · NO SAVES / REWARDS\n%s · %s\nWASD · attack / skills · Tab bag" % [ART_NAMES[_art_key], "dark ground" if _dark_ground else "grass"]
	var options := HBoxContainer.new()
	column.add_child(options)
	column.move_child(options, 1)
	for key: String in ART_NAMES:
		var button := Button.new()
		button.text = key.to_upper()
		button.tooltip_text = ART_NAMES[key] + " — switch and replay"
		button.toggle_mode = true
		button.button_pressed = key == _art_key
		button.focus_mode = Control.FOCUS_NONE
		button.custom_minimum_size = Vector2(52,24)
		button.pressed.connect(_choose_art.bind(key))
		options.add_child(button)
	_button(column,"Replay same batch",_replay)
	_button(column,"Ground: dark" if _dark_ground else "Ground: grass",_change_ground)

func _spawn_batch(count: int) -> void:
	_last_count = count
	super._spawn_batch(count)

func _choose_art(key: String) -> void:
	_art_key = key
	await _replay()

func _change_ground() -> void:
	_dark_ground = not _dark_ground
	await _replay()

func _replay() -> void:
	await reset_review()
	_spawn_batch(_last_count)

func reset_review() -> void:
	_rebuilding = true
	await super.reset_review()
	_rebuilding = false

func _capture_art() -> void:
	root.size = Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ART_EVIDENCE))
	await _save_capture("controls.png")
	for key: String in ART_NAMES:
		_art_key = key
		for dark in [false, true]:
			_dark_ground = dark
			await reset_review()
			toolbar.hide()
			_spawn_batch(1)
			for spec in [["warning",.10],["open",.30],["collapse",.24],["walking",.65]]:
				await create_timer(spec[1],false).timeout
				await _save_capture(key + ("_dark_" if dark else "_grass_") + spec[0] + ".png")

func _save_capture(file: String) -> void:
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(ART_EVIDENCE + file) == OK)
