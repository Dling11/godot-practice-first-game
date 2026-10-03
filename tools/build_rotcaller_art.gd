extends SceneTree

## Offline technical normalization; authored poses come from imagegen.
const SOURCE := "res://art_source/generated/characters/enemies/rotcaller_v2_2026_10_03/"
const OUTPUT := "res://assets/characters/enemies/rotcaller/"
var manifest: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_build")

func _cell(source: Image, column: int, row: int, columns: int, rows: int) -> Image:
	var left := floori(float(column)*source.get_width()/columns)
	var top := floori(float(row)*source.get_height()/rows)
	var right := floori(float(column+1)*source.get_width()/columns)
	var bottom := floori(float(row+1)*source.get_height()/rows)
	var image := source.get_region(Rect2i(left,top,right-left,bottom-top))
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x,y)
			image.set_pixel(x,y,Color.TRANSPARENT if color.a < .7 else Color(color.r,color.g,color.b,1))
	return image.get_region(image.get_used_rect())

func _build() -> void:
	var walk := Image.load_from_file(SOURCE+"walk_source.png")
	var frontback := Image.load_from_file(SOURCE+"frontback_source.png")
	var opposite := Image.load_from_file(SOURCE+"opposite_south_source.png")
	var actions := Image.load_from_file("res://art_source/generated/characters/enemies/rotcaller_2026_10_03/actions_source.png")
	var walk_cells: Array[Image] = []
	var action_cells: Array[Image] = []
	var heights: Array[int] = []
	var action_heights: Array[int] = []
	for row in 4:
		for col in 4:
			var image := _cell(walk,col,row,4,4)
			if row == 0: image = _cell(frontback,col,0,4,2) if col < 2 else _cell(opposite,col-2,0,2,1)
			if row == 2: image = _cell(frontback,col,1,4,2)
			walk_cells.append(image)
			if row in [1,3]: heights.append(image.get_height())
			var pose := _cell(actions,col,row,4,4)
			action_cells.append(pose)
			if col == 2: action_heights.append(pose.get_height())
	heights.sort()
	action_heights.sort()
	var walk_ratio := 40.0/heights[heights.size()/2]
	# A separate source-resolution factor keeps recovery bodies at walk height.
	var action_ratio := 40.0/action_heights[2]
	var frontback_ratio := 40.0/float(walk_cells[0].get_height())
	var opposite_ratio := 40.0/float(walk_cells[2].get_height())
	for spec in [["walk",walk_cells,walk_ratio],["actions",action_cells,action_ratio]]:
		var atlas := Image.create(256,256,false,Image.FORMAT_RGBA8)
		for index in 16:
			var image: Image = spec[1][index]
			var ratio: float = spec[2]
			if spec[0] == "walk":
				if index in [0,1] or index in [8,9,10,11]: ratio = frontback_ratio
				elif index in [2,3]: ratio = opposite_ratio
			image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_NEAREST)
			assert(image.get_height() <= 56 and image.get_width() <= 64,"Rotcaller pose exceeds its native canvas")
			var origin := Vector2i(index%4*64+(64-image.get_width())/2,index/4*64+56-image.get_height())
			atlas.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),origin)
			manifest.append({"sheet":spec[0],"row":index/4,"column":index%4,"native_size":str(image.get_size()),"origin":str(origin),"scale":ratio})
		assert(atlas.save_png(OUTPUT+spec[0]+".png") == OK)
	FileAccess.open(SOURCE+"normalization.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
	if not "--art-only" in OS.get_cmdline_user_args(): _save_frames()
	print("ROTCaller_ART: 32 poses, 64px canvas, 40px walk height")
	quit()

func _save_frames() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in 4:
		var suffix: String = ["south","east","north","west"][row]
		for action: String in ["idle","walk","windup","release","recovery","death"]:
			var name := StringName(action+"_"+suffix)
			frames.add_animation(name)
			frames.set_animation_loop(name,action == "walk")
			frames.set_animation_speed(name,5.0 if action == "windup" else 8.0)
			if action == "windup":
				var anticipation := AtlasTexture.new()
				anticipation.atlas = load(OUTPUT+"walk.png")
				anticipation.region = Rect2(0,row*64,64,64)
				frames.add_frame(name,anticipation)
			var columns: Array = [0,1,2,3] if action == "walk" else [0 if action in ["idle","windup"] else (1 if action == "release" else (2 if action == "recovery" else 3))]
			for column: int in columns:
				var texture := AtlasTexture.new()
				texture.atlas = load(OUTPUT+("walk.png" if action in ["idle","walk"] else "actions.png"))
				texture.region = Rect2(column*64,row*64,64,64)
				frames.add_frame(name,texture)
	assert(ResourceSaver.save(frames,OUTPUT+"rotcaller_frames.tres") == OK)
