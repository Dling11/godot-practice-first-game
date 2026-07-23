extends SceneTree


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var scene_path := _argument_value("--scene=")
	var output_path := _argument_value("--output=")
	var focus_text := _argument_value("--focus=")
	if scene_path.is_empty() or output_path.is_empty():
		push_error("Usage: --scene=res://... --output=res://... [--focus=x,y]")
		quit(1)
		return

	var packed_scene := load(scene_path) as PackedScene
	if packed_scene == null:
		push_error("Unable to load scene: %s" % scene_path)
		quit(1)
		return
	var stage := packed_scene.instantiate()
	var controller := stage.get_node_or_null("GameplayServices/EncounterController")
	if controller != null:
		controller.auto_start = false
	root.add_child(stage)

	var ui := stage.get_node_or_null("UI") as CanvasLayer
	if ui != null:
		ui.visible = false
	var player := stage.get_node_or_null("World/Actors/Player") as Node2D
	if player != null:
		player.set_physics_process(false)
		var focus := _parse_focus(focus_text)
		if focus != Vector2.INF:
			player.global_position = focus

	paused = false
	for frame in range(4):
		await process_frame
	var viewport_texture := root.get_viewport().get_texture()
	if viewport_texture == null:
		push_error("The active display driver does not expose a viewport texture.")
		quit(1)
		return
	var image := viewport_texture.get_image()
	if image == null:
		push_error("The active display driver returned no viewport image.")
		quit(1)
		return
	var absolute_output := ProjectSettings.globalize_path(output_path)
	var error := image.save_png(absolute_output)
	if error != OK:
		push_error("Unable to save capture: %s" % absolute_output)
		quit(1)
		return
	print("Saved environment capture: %s" % absolute_output)
	quit(0)


func _argument_value(prefix: String) -> String:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with(prefix):
			return argument.trim_prefix(prefix)
	return ""


func _parse_focus(value: String) -> Vector2:
	var parts := value.split(",")
	if parts.size() != 2:
		return Vector2.INF
	return Vector2(parts[0].to_float(), parts[1].to_float())
