extends "res://tools/build_king_dual_twinsteel_cardinal.gd"

func _initialize() -> void:
	for direction in ["side","up","down"]:
		var folder: String = OUTPUT+("" if direction=="side" else direction+"/")
		for label in CUTS+["idle","run"]:
			var clip: Resource = load(folder+label+".tres")
			var samples := []
			for key in clip.pose_count:
				var body: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
				var head := hair_bounds(body,red_center_y(body)-2)
				samples.append({"key":key,"height":body.get_used_rect().size.y,"width":body.get_used_rect().size.x,"head":var_to_str(head),"registered_head":var_to_str(clip.identity_regions[key])})
			print(direction+"/"+label+" "+JSON.stringify(samples))
	quit()
