extends "res://tools/build_king_axe_cardinal.gd"

func _initialize() -> void:
	if "--neck" in OS.get_cmdline_user_args():
		var helper := preload("res://tools/king_native_identity.gd").new()
		for view in ["up","down"]:
			var cells := helper.sheet_cells(Image.load_from_file("res://art_source/generated/characters/king/axe_identity_lock_2026_10_07/"+view+"_source.png"),5,8)
			for spec in [[0,2],[2,4],[3,5]]:
				var cel: Image = cells[spec[0]][spec[1]].image
				print(view,spec," size ",cel.get_size()," neck ",helper.neck(cel))
				cel.resize(cel.get_width()*4,cel.get_height()*4,Image.INTERPOLATE_NEAREST)
				cel.save_png("res://art_source/review/combat/king_axe_identity_lock_2026_10_07/neck_"+view+str(spec[0])+str(spec[1])+".png")
		quit(); return
	if "--pose" in OS.get_cmdline_user_args():
		for spec in [["axe_identity_lock/down/slam",5,"slam"],["axe_identity_lock/down/spin",6,"spin"],["dual_identity_lock/down/diagonal",2,"dual_wind"],["dual_identity_lock/down/rising_cross",4,"dual_cross"]]:
			var clip: Resource = load("res://assets/characters/playable/king/"+spec[0]+".tres")
			var key: int = spec[1]
			var body: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			print(spec," head ",clip.identity_regions[key]," hand ",clip.primary_hands[key])
			for y in 128:
				for x in 192:
					var c := body.get_pixel(x,y)
					body.set_pixel(x,y,Color("263339").lerp(Color(c.r,c.g,c.b,1),c.a))
			body.resize(768,512,Image.INTERPOLATE_NEAREST)
			body.save_png("res://art_source/review/combat/king_axe_identity_lock_2026_10_07/"+spec[2]+"_body_debug.png")
		quit(); return
	var image := Image.load_from_file("res://art_source/generated/characters/king/axe_identity_lock_2026_10_07/down_source.png")
	print("SOURCE ", image.get_size(), " corners ", image.get_pixel(0,0), " gap ", image.get_pixel(180,210))
	var masked: Image = image.duplicate()
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			if c.a<.90 or (c.g>c.r*1.4 and c.b>c.r*1.4) or (c.r>c.g*1.5 and c.b>c.g*1.5): masked.set_pixel(x,y,Color.TRANSPARENT)
	var identity := preload("res://tools/king_native_identity.gd").new()
	var rows := identity.sheet_cells(image,5,8)
	print("DENSITY ", identity.density(rows[0][0].image,"down"))
	for row in rows: print("ROW ", row.size(), " sizes ", row.map(func(c: Dictionary) -> Vector2i: return c.image.get_size()), " grips ", row.map(func(c: Dictionary) -> Dictionary: return identity.axe_guide(c)))
	masked.save_png("res://art_source/generated/characters/king/axe_identity_lock_2026_10_07/down_body_source.png")
	quit()
