extends SceneTree
func _initialize() -> void:
	for spec in [["rising",8],["scissors",4]]:
		var clip: Resource = load("res://assets/characters/playable/king/dual_twinsteel/"+spec[0]+".tres")
		var key: int = spec[1]
		var image: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
		var seen := {}
		var components := []
		for y in 128:
			for x in 192:
				var seed := Vector2i(x,y)
				if image.get_pixelv(seed).a<.65 or seen.has(seed): continue
				var todo := [seed]
				seen[seed]=true
				var cursor := 0
				var bounds := Rect2i(seed,Vector2i.ONE)
				while cursor<todo.size():
					var point: Vector2i = todo[cursor]
					cursor+=1
					bounds=bounds.expand(point)
					for dy in range(-1,2):
						for dx in range(-1,2):
							var next := point+Vector2i(dx,dy)
							if next.x<0 or next.x>=192 or next.y<0 or next.y>=128 or seen.has(next) or image.get_pixelv(next).a<.65: continue
							seen[next]=true
							todo.append(next)
				components.append({"size":todo.size(),"bounds":var_to_str(bounds)})
		print(spec," ",components)
		image.resize(768,512,Image.INTERPOLATE_NEAREST)
		var bg := Image.create(768,512,false,Image.FORMAT_RGBA8)
		bg.fill(Color("263339"))
		bg.blend_rect(image,Rect2i(0,0,768,512),Vector2i.ZERO)
		bg.save_png("res://art_source/review/combat/king_dual_polish_2026_10_05/"+spec[0]+"_diagnostic.png")
	quit()
