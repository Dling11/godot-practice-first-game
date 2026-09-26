extends SceneTree

## Render every installed frame, with a fixed origin and foot baseline for review.
const OUT := "res://art_source/review/characters/king/polish_2026_09_13/"
const FRAMES = preload("res://assets/characters/playable/king/greatsword/king_greatsword_sprite_frames.tres")

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var report: Array = []
	for direction in ["down", "left", "right", "up"]:
		var board := Image.create(768, 13 * 64, false, Image.FORMAT_RGBA8)
		board.fill(Color("263139"))
		var row := 0
		for key in ["idle", "walk", "attack", "return_cut", "heavy_cleave", "echoing_sever", "riftbreak", "sovereign_pursuit", "worldsplitter", "dash", "hurt", "defeat", "interact"]:
			var name: StringName = key + "_" + direction
			for column in FRAMES.get_frame_count(name):
				var texture := FRAMES.get_frame_texture(name, column) as AtlasTexture
				var cell := texture.atlas.get_image().get_region(texture.region)
				var bounds := cell.get_used_rect()
				assert(bounds.position.x > 0 and bounds.position.y > 0 and bounds.end.x < 96 and bounds.end.y < 64, name + " clipped " + str(column))
				report.append({"animation":name, "frame":column, "bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]})
				for x in 96:
					board.set_pixel(column*96+x,row*64+48,Color("466055"))
				for y in 64:
					board.set_pixel(column*96+48,row*64+y,Color("354250"))
				board.blend_rect(cell,Rect2i(0,0,96,64),Vector2i(column*96,row*64))
			row += 1
		board.resize(1536,1664,Image.INTERPOLATE_NEAREST)
		board.save_png(OUT+direction+"_all_frames.png")
	FileAccess.open(OUT+"frame_bounds.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t"))
	var walk := Image.create(48*4,36*4,false,Image.FORMAT_RGBA8)
	walk.fill(Color("263139"))
	for row in 4:
		for column in 4:
			var texture := FRAMES.get_frame_texture("walk_"+["down","left","right","up"][row],column) as AtlasTexture
			var cell := texture.atlas.get_image().get_region(texture.region)
			walk.blend_rect(cell,Rect2i(24,16,48,36),Vector2i(column*48,row*36))
	walk.resize(1152,864,Image.INTERPOLATE_NEAREST)
	walk.save_png(OUT+"walk_detail_6x.png")
	print("KING_FRAME_AUDIT: ", report.size(), " frames checked; four complete direction boards rendered")
	quit()
