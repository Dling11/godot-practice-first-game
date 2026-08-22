extends SceneTree

const SanctuaryScene = preload("res://levels/sanctuary/sanctuary.tscn")
const REVIEW_DIR := "res://art_source/review/ui/umi_exchange"


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REVIEW_DIR))
	root.get_node("RunSession").update_progression(0, 1250)
	root.get_node("MaterialInventory").reset_inventory()
	root.get_node("MaterialInventory").add_material_batch({
		&"forest_mire_resin": 52,
		&"forest_root_fiber": 40,
		&"forest_husk_heartwood": 6,
		&"forest_living_bark_plate": 3,
	})
	for _index in 20:
		root.get_node("EnemyMemory").record_defeat(&"armored_hog")
	var sanctuary := SanctuaryScene.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	var player := sanctuary.get_node("World/Actors/Player") as Player
	player.set_physics_process(false)
	for _frame in 5:
		await process_frame
	var ui := sanctuary.get_node("UI") as CanvasLayer
	ui.visible = false
	await process_frame
	_save_viewport("umi_sanctuary_placement.png")
	ui.visible = true
	var menu := sanctuary.get_node("UI/UmiExchangeMenu") as UmiExchangeMenu
	menu.open_menu()
	await process_frame
	await process_frame
	_save_viewport("umi_sell_compact.png")
	menu.show_transmute_page()
	await process_frame
	await process_frame
	_save_viewport("umi_reconstruct_compact.png")
	menu.close_menu()
	sanctuary.queue_free()
	await process_frame
	print("Saved Umi placement and compact exchange review captures.")
	quit(0)


func _save_viewport(filename: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path("%s/%s" % [REVIEW_DIR, filename]))
	if error != OK:
		push_error("Could not save Umi review capture: %s" % filename)
