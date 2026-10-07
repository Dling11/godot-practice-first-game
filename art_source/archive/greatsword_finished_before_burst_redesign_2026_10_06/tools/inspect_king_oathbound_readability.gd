extends "res://tools/build_king_oathbound_greatsword.gd"

## Offline comparison of raw registered bodies against the installed atlases.
const REVIEW := "res://art_source/review/combat/king_greatsword_readability_2026_10_05/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REVIEW))
	for direction in ["up","side"]:
		var idle: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres" if direction=="side" else "res://assets/characters/playable/king/greatsword_cardinal/up/idle.tres")
		var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var rows := extract_bodies(Image.load_from_file(SOURCE+direction+"_body_source.png"))
		var enlarged_reference := carry.duplicate()
		enlarged_reference.resize(768,512,Image.INTERPOLATE_NEAREST)
		enlarged_reference.save_png(REVIEW+direction+"_reference.png")
		var density: float = float(carry.get_used_rect().size.y)/float(rows[0][0].image.get_height())
		palette.clear()
		color_cache.clear()
		for y in 128:
			for x in 192:
				var c := carry.get_pixel(x,y)
				if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
		for cut in 5:
			if rows[cut].size()==11: rows[cut].remove_at(8)
			var gallery := Image.create(1440,576,false,Image.FORMAT_RGBA8)
			gallery.fill(Color("202b30"))
			var installed := Image.load_from_file(DEST+direction+"/"+NAMES[cut]+"_body.png")
			for key in 10:
				var raw: Image = rows[cut][key].image.duplicate()
				raw.resize(roundi(raw.get_width()*density),roundi(raw.get_height()*density),Image.INTERPOLATE_NEAREST)
				var offset := Vector2i((foot_anchor(carry)-foot_anchor(raw)).round())
				var registered := Image.create(192,128,false,Image.FORMAT_RGBA8)
				registered.blit_rect(raw,Rect2i(Vector2i.ZERO,raw.get_size()),offset)
				quantize(registered)
				for version in 2:
					var sample := registered if version==0 else installed.get_region(Rect2i(key%4*192,key/4*128,192,128))
					var enlarged := sample.get_region(Rect2i(60,16,72,96))
					enlarged.resize(144,192,Image.INTERPOLATE_NEAREST)
					gallery.blend_rect(enlarged,Rect2i(Vector2i.ZERO,enlarged.get_size()),Vector2i(key*144,version*288))
			gallery.save_png(REVIEW+direction+"_"+NAMES[cut]+"_body_comparison.png")
	# Side gait comparison, carry at left and all eight running cels alongside.
	var gallery := Image.create(1296,192,false,Image.FORMAT_RGBA8)
	gallery.fill(Color("202b30"))
	var after := OS.get_cmdline_user_args().has("--after")
	for key in 9:
		var path := "res://assets/characters/playable/king/greatsword_confidence_v2/"+("idle" if key==0 else "greatsword_run")+"_body.png"
		if after and key>0: path = "res://assets/characters/playable/king/greatsword_readability/side/run_body.png"
		var texture: Texture2D = load(path)
		var pose := maxi(0,key-1)
		var sample := texture.get_image().get_region(Rect2i(pose%4*192+60,pose/4*128+16,72,96))
		sample.resize(144,192,Image.INTERPOLATE_NEAREST)
		gallery.blend_rect(sample,Rect2i(Vector2i.ZERO,sample.get_size()),Vector2i(key*144,0))
	gallery.save_png(REVIEW+("side_carry_run_after.png" if after else "side_carry_run_before.png"))
	quit()
