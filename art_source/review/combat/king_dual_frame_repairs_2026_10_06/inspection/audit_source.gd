extends "res://tools/build_king_dual_unified.gd"
const REPORT := "res://art_source/review/combat/king_dual_frame_repairs_2026_10_06/inspection/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REPORT))
	for direction in REFERENCES:
		var reference: Resource = load("res://assets/characters/playable/king/"+REFERENCES[direction][0])
		var body: Image = reference.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		refs[direction]=body
		body.save_png(REPORT+direction+"_native.png")
		for y in 128:
			for x in 192:
				var color := body.get_pixel(x,y)
				if color.a>.65 and not palette.has(Color(color.r,color.g,color.b,1)): palette.append(Color(color.r,color.g,color.b,1))
	var raw := extract_bodies(Image.load_from_file(ProjectSettings.globalize_path(RAW+"body_source.png")))
	var density: float = 54.0/raw[0][0].image.get_height()
	var current: Resource = load(OUTPUT+"rising.tres")
	for key in [4,5,6,7,8]:
		var part: Image = raw[1][key].image.duplicate()
		part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),Vector2i((Vector2(96,94)-foot_anchor(part)).round()))
		quantize(body)
		body.save_png(REPORT+"rising_%02d_source.png"%key)
		cel(current,key).save_png(REPORT+"rising_%02d_current.png"%key)
		print("SIDE_KEY ",key," head=",current.identity_regions[key]," main=",current.primary_hands[key]," off=",current.offhand.hands[key])
	view="down"
	identity=refs[view]
	canonical_head=REFERENCES[view][1]
	var rows := extract_bodies(Image.load_from_file(ProjectSettings.globalize_path(UNIFIED+"thrust_source.png")),3)
	var row: Array = rows[1]
	var initial: float = 54.0/row[0].image.get_height()
	var down_density := initial
	var best_error := 999
	for attempt in 121:
		var candidate := initial*(.7+attempt*.005)
		var sample := generated_body(row[0].image,candidate)
		var error := absi(54-sample.body.get_used_rect().size.y)
		if error<best_error: down_density=candidate; best_error=error
		if error==0: break
	current=load(OUTPUT+"down/descending.tres")
	for source_key in range(1,8):
		var part: Image = row[source_key].image.duplicate()
		part.resize(roundi(part.get_width()*down_density),roundi(part.get_height()*down_density),Image.INTERPOLATE_NEAREST)
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),Vector2i((Vector2(96,94)-foot_anchor(part)).round()))
		quantize(body)
		body.save_png(REPORT+"down_%02d_source.png"%source_key)
		var key: int = [0,1,2,3,4,5,7,8][source_key]
		cel(current,key).save_png(REPORT+"down_%02d_current.png"%source_key)
		print("DOWN_KEY ",key," head=",current.identity_regions[key]," raw_scalp=",hair_bounds(body,red_center_y(body)-2)," main=",current.primary_hands[key]," off=",current.offhand.hands[key])
	quit()
