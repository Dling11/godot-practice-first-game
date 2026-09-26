extends SceneTree

## Deterministic import of generated artwork: matte removal, fixed body scale,
## complete connected-island extraction, grounded origin, and atlas packing.
const SOURCE := "res://art_source/generated/characters/king/greatsword_2026_09_12/"
const POLISH := "res://art_source/generated/characters/king/polish_2026_09_13/"
const OUT := "res://assets/characters/playable/king/greatsword/"
const REVIEW := "res://art_source/review/characters/king/polish_2026_09_13/"
const CELL := Vector2i(96,64)
var _report: Dictionary = {}

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	DirAccess.make_dir_recursive_absolute(REVIEW)
	if "--frames-only" in OS.get_cmdline_user_args():
		_frames()
		quit()
		return
	var boards: Dictionary = {}
	for key in ["gait","slash","return","cleave","pursuit","command","reactions","front_right_step","up_combat"]:
		boards[key] = _body_board(key,4 if key == "gait" else (1 if key == "front_right_step" else 8),1 if key == "front_right_step" else 3)
	boards.slash[2] = boards.up_combat[0]
	boards["return"][2] = boards.up_combat[1]
	boards.cleave[2] = boards.up_combat[2]
	boards.sweep = _body_board("sweep",8,3)
	# Reject a missing-blade recovery drawing and the source's edge-touching
	# final guard. Return to the same approved idle instead of installing either.
	for row in 3:
		boards.sweep[row][6] = boards.reactions[row][0]
		boards.sweep[row][7] = boards.reactions[row][0]
	# The original back-facing defeat ended on an accidentally front-facing
	# drawing. Hold its complete back-facing kneel through the settle instead.
	boards.reactions[2][7] = boards.reactions[2][6]
	var gait: Array = boards.gait
	var corrected_gait := _body_board("gait_polish",4,3)
	gait[0] = corrected_gait[0]
	gait[2] = corrected_gait[2]
	var actions := {"walk":[gait,[0,1,2,3]],"idle":[boards.reactions,[0,1]],"attack":[boards.slash,range(8)],"return_cut":[boards["return"],range(8)],"heavy_cleave":[boards.sweep,range(8)],"echoing_sever":[boards.slash,range(8)],"riftbreak":[boards.cleave,range(8)],"sovereign_pursuit":[boards.pursuit,range(8)],"worldsplitter":[boards.command,range(8)],"dash":[boards.reactions,[2,3]],"hurt":[boards.reactions,[4,5]],"defeat":[boards.reactions,[6,7]],"interact":[boards.reactions,[0,1]]}
	var review := Image.create(96*8,64*actions.size(),false,Image.FORMAT_RGBA8)
	review.fill(Color("263139"))
	var review_row := 0
	for key: String in actions:
		var frames: Array = actions[key][0]
		var indices: Array = actions[key][1]
		var atlas := Image.create(96*indices.size(),64*4,false,Image.FORMAT_RGBA8)
		for row in 4:
			for column in indices.size():
				var cell: Image = frames[[0,1,1,2][row]][indices[column]].duplicate()
				if row == 1:
					cell.flip_x()
				atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,CELL),Vector2i(column*96,row*64))
		atlas.save_png(OUT+"king_"+key+"_96x64.png")
		review.blend_rect(atlas,Rect2i(0,0,indices.size()*96,64),Vector2i(0,review_row*64))
		review_row += 1
	review.resize(review.get_width()*2,review.get_height()*2,Image.INTERPOLATE_NEAREST)
	review.save_png(REVIEW+"down_actions_2x.png")
	FileAccess.open(REVIEW+"import_measurements.json",FileAccess.WRITE).store_string(JSON.stringify(_report,"\t"))
	print("KING_BODY_ATLASES_BUILT: complete islands; 27px standing body; 96x64 padded cells; foot y48")
	quit()

func _body_board(key: String, columns: int, rows: int) -> Array:
	var image := Image.load_from_file(_source_path(key))
	image.convert(Image.FORMAT_RGBA8)
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width*height)
	for y in height:
		for x in width:
			var c := image.get_pixel(x,y)
			if c.r > .06 and c.b > .06 and c.r > c.g*1.6 and c.b > c.g*1.6:
				image.set_pixel(x,y,Color.TRANSPARENT)
				visited[y*width+x] = 1
	var islands: Array = []
	for row in rows:
		var group: Array = []
		group.resize(columns)
		islands.append(group)
	for start in width*height:
		if visited[start] != 0:
			continue
		var queue := PackedInt32Array([start])
		visited[start] = 1
		var cursor := 0
		var bounds := Rect2i(start%width,start/width,1,1)
		while cursor < queue.size():
			var index := queue[cursor]
			cursor += 1
			var p := Vector2i(index%width,index/width)
			bounds = bounds.expand(p)
			for delta in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				var next: Vector2i = p + delta
				if next.x < 0 or next.x >= width or next.y < 0 or next.y >= height:
					continue
				var n := next.y*width+next.x
				if visited[n] == 0:
					visited[n] = 1
					queue.append(n)
		if queue.size() < 200:
			continue
		bounds.size += Vector2i.ONE
		# The standing head/torso is near the cell center. Assign by island
		# center; all connected weapon pixels remain in the original island.
		var row := clampi(int(bounds.get_center().y*rows/height),0,rows-1)
		var col := clampi(int(bounds.get_center().x*columns/width),0,columns-1)
		if islands[row][col] != null and islands[row][col].pixels.size() > queue.size():
			continue
		islands[row][col] = {"pixels":queue,"bounds":bounds}
	var result: Array = []
	var measurements: Array = []
	for row in rows:
		var frames: Array = []
		var first: Dictionary = islands[row][0]
		var rest_boot := _boot_y(image,first)
		var head_top: int = [134,456,777][row] if key == "up_combat" else first.bounds.position.y
		var factor: float = 27.0 / (rest_boot-head_top+1)
		for col in columns:
			var island: Dictionary = islands[row][col]
			var bounds: Rect2i = island.bounds
			var boot := _boot_y(image,island)
			var center_x := (col+.5)*width/columns
			if key == "front_right_step":
				center_x = 594.0
			var cut := Image.create(bounds.size.x,bounds.size.y,false,Image.FORMAT_RGBA8)
			for index: int in island.pixels:
				var p := Vector2i(index%width,index/width)
				cut.set_pixelv(p-bounds.position,image.get_pixelv(p))
			cut.resize(maxi(1,roundi(bounds.size.x*factor)),maxi(1,roundi(bounds.size.y*factor)),Image.INTERPOLATE_NEAREST)
			var dest := Vector2i(48+roundi((bounds.position.x-center_x)*factor),48-roundi((boot-bounds.position.y+1)*factor))
			assert(dest.x>0 and dest.y>0 and dest.x+cut.get_width()<96 and dest.y+cut.get_height()<64,"Clipped source: "+key+str(row)+str(col))
			var cell := Image.create(96,64,false,Image.FORMAT_RGBA8)
			cell.blit_rect(cut,Rect2i(Vector2i.ZERO,cut.get_size()),dest)
			frames.append(cell)
			measurements.append({"row":row,"column":col,"scale":factor,"boot_source_y":boot,"source_bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"native_bounds":[dest.x,dest.y,cut.get_width(),cut.get_height()]})
		result.append(frames)
	_report[key] = measurements
	return result

func _source_path(key: String) -> String:
	return (POLISH if key in ["sweep","gait_polish"] else SOURCE)+key+".png"

func _boot_y(image: Image, island: Dictionary) -> int:
	var bounds: Rect2i = island.bounds
	var lowest := bounds.position.y
	for index: int in island.pixels:
		var p := Vector2i(index%image.get_width(),index/image.get_width())
		if p.y < bounds.position.y + bounds.size.y*.65:
			continue
		var c := image.get_pixelv(p)
		if c.r>.12 and c.r>c.g*1.15 and c.r<c.g*2.8 and c.g>c.b*1.25:
			lowest = maxi(lowest,p.y)
	return mini(bounds.end.y-1,lowest+maxi(2,roundi(bounds.size.y*.02)))

func _frames() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for key in ["walk","idle","attack","return_cut","heavy_cleave","echoing_sever","riftbreak","sovereign_pursuit","worldsplitter","dash","hurt","defeat","interact"]:
		var texture := load(OUT+"king_"+key+"_96x64.png") as Texture2D
		var count := texture.get_width()/96
		for row in 4:
			var name: StringName = key+"_"+["down","left","right","up"][row]
			frames.add_animation(name)
			frames.set_animation_loop(name,key in ["idle","walk"])
			frames.set_animation_speed(name,8.0 if key == "walk" else (2.0 if key == "idle" else 10.0))
			for column in count:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(column*96,row*64,96,64)
				frames.add_frame(name,atlas)
	ResourceSaver.save(frames,OUT+"king_greatsword_sprite_frames.tres")
	var walk := Image.load_from_file(OUT+"king_walk_96x64.png")
	walk.resize(walk.get_width()*3,walk.get_height()*3,Image.INTERPOLATE_NEAREST)
	walk.save_png(REVIEW+"walk_all_directions_3x.png")
	print("KING_SPRITE_FRAMES_BUILT")
