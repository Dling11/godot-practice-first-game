extends SceneTree

const SanctuaryScene = preload("res://levels/sanctuary/sanctuary.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var sanctuary := SanctuaryScene.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	var player := sanctuary.get_node("World/Actors/Player") as Player
	player.set_physics_process(false)
	for frame in 4:
		await process_frame
	var ui := sanctuary.get_node("UI") as CanvasLayer
	ui.visible = false
	await process_frame
	if not _save_viewport("res://art_source/review/rootweaver_sanctuary_service_review.png"):
		return
	ui.visible = true
	await process_frame
	var menu := sanctuary.get_node("UI/RootforgeMenu") as RootforgeMenu
	menu.open_menu()
	await process_frame
	await process_frame
	if not _save_viewport("res://art_source/review/rootforge_menu_review.png"):
		return
	print("Saved Rootweaver Sanctuary and Rootforge menu review captures.")
	quit(0)


func _save_viewport(path: String) -> bool:
	var image := root.get_viewport().get_texture().get_image()
	if image == null:
		push_error("Could not read the Rootweaver review viewport.")
		quit(1)
		return false
	var absolute_path := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var error := image.save_png(absolute_path)
	if error == OK:
		return true
	push_error("Could not save Rootweaver review capture: %s" % path)
	quit(1)
	return false
