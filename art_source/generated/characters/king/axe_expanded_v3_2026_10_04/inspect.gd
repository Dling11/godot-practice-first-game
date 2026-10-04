extends SceneTree
func _initialize() -> void:
	for name in ["carry","actions","trail"]:
		var image := Image.load_from_file("res://art_source/generated/characters/king/axe_expanded_v3_2026_10_04/"+name+"_source.png")
		print(name," size=",image.get_size()," corner=",image.get_pixel(0,0)," center=",image.get_pixel(image.get_width()/8,image.get_height()/4))
	quit()
