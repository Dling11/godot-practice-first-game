extends SceneTree
func _initialize() -> void:
	for name in ["sweep","rise","meteor","turn"]:
		var clip: Resource = load("res://assets/characters/playable/king/huge_greatsword_proof/"+name+".tres")
		var image: Image = clip.body_atlas.get_image()
		for index in 8:
			for hand in ["primary_hands","secondary_hands"]:
				var point: Vector2i = Vector2i(clip.get(hand)[index])+Vector2i(index%4,index/4)*Vector2i(192,128)
				if image.get_pixelv(point).a>0: continue
				var nearest := Vector2i.ZERO
				var distance := 999.0
				for y in range(-10,11):
					for x in range(-10,11):
						var offset := Vector2i(x,y)
						if image.get_pixelv(point+offset).a>0 and Vector2(offset).length()<distance:
							nearest = offset
							distance = Vector2(offset).length()
				print(name,"/",index," ",hand," point=",point," nearest=",nearest," distance=",distance)
	quit()
