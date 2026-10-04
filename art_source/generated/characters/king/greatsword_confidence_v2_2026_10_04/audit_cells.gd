extends SceneTree
func _initialize() -> void:
	var image := Image.load_from_file("res://assets/characters/playable/king/huge_greatsword_proof/swing.png")
	for index in 4:
		var cell := image.get_region(Rect2i(index*256,512,256,256))
		print("METEOR ",index," used=",cell.get_used_rect())
	quit()
