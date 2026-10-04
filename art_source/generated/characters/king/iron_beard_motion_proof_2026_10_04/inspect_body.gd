extends SceneTree
func _initialize() -> void:
	var source := Image.load_from_file("res://art_source/generated/characters/king/iron_beard_motion_proof_2026_10_04/body_source.png")
	print("BODY_SIZE ", source.get_size())
	var cell := Vector2i(source.get_width()/4, source.get_height()/2)
	for index in 8:
		var crop := source.get_region(Rect2i(Vector2i(index%4, index/4)*cell, cell))
		for y in crop.get_height():
			for x in crop.get_width():
				var color := crop.get_pixel(x,y)
				color.a = 1 if color.a >= .65 else 0
				crop.set_pixel(x,y,color)
		print("POSE ",index," bounds=",crop.get_used_rect())
	quit()
