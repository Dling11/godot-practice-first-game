extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")
const RootforgeMenuScene = preload("res://ui/crafting/rootforge_menu.tscn")

const REVIEW_DIR := "res://art_source/review/ui/equipment_progression"


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REVIEW_DIR))
	var backdrop := ColorRect.new()
	backdrop.color = Color("121824")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	player.apply_debug_testing_preset()
	var character_menu := CharacterMenuScene.instantiate() as CharacterMenu
	character_menu.player = player
	root.add_child(character_menu)
	await process_frame
	character_menu.open_menu()
	await process_frame
	await process_frame
	_save_viewport("character_and_bag_compact.png")
	character_menu.close_menu()
	character_menu.queue_free()
	await process_frame

	var rootforge := RootforgeMenuScene.instantiate() as RootforgeMenu
	root.add_child(rootforge)
	await process_frame
	rootforge.open_menu()
	await process_frame
	await process_frame
	_save_viewport("rootforge_compact_formula_icons.png")
	rootforge.close_menu()
	rootforge.queue_free()
	player.queue_free()
	backdrop.queue_free()
	await process_frame
	print("Captured compact equipment UI review images.")
	quit(0)


func _save_viewport(filename: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path("%s/%s" % [REVIEW_DIR, filename]))
	if error != OK:
		push_error("Could not save equipment UI review image: %s" % filename)
