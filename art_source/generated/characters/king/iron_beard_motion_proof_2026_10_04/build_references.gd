extends SceneTree

const ROOT := "res://art_source/generated/characters/king/iron_beard_motion_proof_2026_10_04/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT + "references"))
	var base := "res://art_source/generated/characters/king/equipment_design_v2_2026_10_04/"
	var axe := Image.load_from_file(base + "axe/source.png")
	assert(axe.get_region(Rect2i(0, 0, 512, 704)).save_png(ROOT + "references/iron_beard.png") == OK)
	var armor := Image.load_from_file(base + "armor/source.png")
	assert(armor.get_region(Rect2i(224, 40, 320, 480)).save_png(ROOT + "references/light_leather_king.png") == OK)
	print("IRON_BEARD_REFERENCES unchanged source windows extracted")
	quit()
