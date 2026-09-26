extends "res://tools/build_king_greatsword_assets.gd"

const OATH_SOURCE := "res://art_source/generated/characters/king/unwritten_oath_2026_09_13/"
const OATH_OUT := "res://assets/vfx/abilities/king/oath/"

func _source_path(key: String) -> String:
	return OATH_SOURCE+key+".png"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OATH_OUT)
	if "--frames-only" in OS.get_cmdline_user_args():
		var frames := load(OUT+"king_greatsword_sprite_frames.tres").duplicate(true) as SpriteFrames
		var texture := load(OUT+"king_oath_spin_96x64.png") as Texture2D
		for row in 4:
			var action: StringName = "oath_spin_"+["down","left","right","up"][row]
			frames.add_animation(action)
			frames.set_animation_loop(action,false)
			for col in 8:
				var atlas := AtlasTexture.new()
				atlas.atlas=texture
				atlas.region=Rect2(col*96,row*64,96,64)
				frames.add_frame(action,atlas)
		ResourceSaver.save(frames,OUT+"king_oath_sprite_frames.tres")
		quit()
		return
	var body := _body_board("spin",8,3)
	var sheet := Image.create(768,256,false,Image.FORMAT_RGBA8)
	for row in 4:
		for col in 8:
			var cell: Image = body[[0,1,1,2][row]][col].duplicate()
			if row==1:
				cell.flip_x()
			sheet.blit_rect(cell,Rect2i(0,0,96,64),Vector2i(col*96,row*64))
	sheet.save_png(OUT+"king_oath_spin_96x64.png")
	for key in ["storm","fracture"]:
		var source := Image.load_from_file(OATH_SOURCE+key+".png")
		source.convert(Image.FORMAT_RGBA8)
		for y in source.get_height():
			for x in source.get_width():
				var c := source.get_pixel(x,y)
				if maxf(c.r,maxf(c.g,c.b))<.10:
					source.set_pixel(x,y,Color.TRANSPARENT)
		var atlas := Image.create(768,768,false,Image.FORMAT_RGBA8)
		for row in 4:
			for col in 4:
				var size := source.get_width()/4
				var cell := source.get_region(Rect2i(col*size,row*size,size,size))
				cell.resize(192,192,Image.INTERPOLATE_NEAREST)
				atlas.blit_rect(cell,Rect2i(0,0,192,192),Vector2i(col*192,row*192))
		atlas.save_png(OATH_OUT+key+"_192.png")
	if FileAccess.file_exists(OATH_SOURCE+"icons.png"):
		var icons := Image.load_from_file(OATH_SOURCE+"icons.png")
		icons.convert(Image.FORMAT_RGBA8)
		var atlas := Image.create(96,24,false,Image.FORMAT_RGBA8)
		for i in 4:
			var size := icons.get_width()/2
			var cell := icons.get_region(Rect2i((i%2)*size,(i/2)*size,size,size))
			cell.resize(24,24,Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(cell,Rect2i(0,0,24,24),Vector2i(i*24,0))
		atlas.save_png(OATH_OUT+"icons_24.png")
	FileAccess.open(OATH_SOURCE+"import_measurements.json",FileAccess.WRITE).store_string(JSON.stringify(_report,"\t"))
	print("KING_OATH_ASSETS_BUILT")
	quit()
