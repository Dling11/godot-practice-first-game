extends SceneTree
func _initialize() -> void:
	var picture := Image.load_from_file("res://assets/characters/playable/king/axe_proof/iron_beard.png")
	picture.resize(440,512,Image.INTERPOLATE_NEAREST)
	picture.save_png("res://art_source/generated/characters/king/axe_combo_v2_2026_10_04/weapon_8x.png")
	quit()
