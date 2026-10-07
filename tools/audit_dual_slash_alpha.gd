extends SceneTree
func _initialize() -> void:
	for filename in ["fx_source.png","fx_clean_source.png"]:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://art_source/generated/characters/king/dual_polish_2026_10_05/"+filename))
		var values := []
		for point in [Vector2i(0,0),Vector2i(40,150),Vector2i(370,200),Vector2i(750,20),Vector2i(1120,800)]: values.append({"point":var_to_str(point),"rgba":var_to_str(image.get_pixelv(point))})
		print(filename," ",values)
		var bg := Image.create(image.get_width(),image.get_height(),false,Image.FORMAT_RGBA8)
		bg.fill(Color("263339"))
		bg.blend_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),Vector2i.ZERO)
		bg.save_png("res://art_source/review/combat/king_dual_polish_2026_10_05/"+filename)
	quit()
