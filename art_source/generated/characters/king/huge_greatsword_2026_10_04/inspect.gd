extends SceneTree
func _initialize() -> void:
	for name in ["weapon","body_1","body_2","slash","impact"]:
		var picture := Image.load_from_file("res://art_source/generated/characters/king/huge_greatsword_2026_10_04/"+name+"_source.png")
		print(name," size=",picture.get_size()," corner alpha=",picture.get_pixel(0,0).a)
		if name.begins_with("body"):
			for index in 16:
				var cell := Vector2i(picture.get_width()/4,picture.get_height()/4)
				var crop := picture.get_region(Rect2i(Vector2i(index%4,index/4)*cell,cell))
				for y in cell.y:
					for x in cell.x:
						if crop.get_pixel(x,y).a<0.65: crop.set_pixel(x,y,Color(0,0,0,0))
				print(index," bounds=",crop.get_used_rect())
	quit()
