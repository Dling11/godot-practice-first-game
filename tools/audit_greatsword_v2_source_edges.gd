extends SceneTree

## Offline alpha-island audit. Does not modify runtime assets.
const DEST := "res://assets/characters/playable/king/greatsword_front_combo_preview/"
const OUT := "res://art_source/review/combat/king_greatsword_v2_rear_cleanup_2026_10_07/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var raw := Image.load_from_file("res://art_source/generated/characters/king/greatsword_v2_polish_2026_10_07/slash_source.png")
	for y in raw.get_height():
		for x in raw.get_width():
			var c := raw.get_pixel(x,y)
			if c.a<.65 or c.b-c.r>.25 or c.g-c.r>.25: raw.set_pixel(x,y,Color.TRANSPARENT)
	for region in [Rect2i(0,332,raw.get_width(),318),Rect2i(0,901,raw.get_width(),raw.get_height()-901)]:
		var parts := components(raw.get_region(region))
		print("SOURCE_FX y=",region.position.y," ",JSON.stringify(parts.filter(func(part: Dictionary) -> bool: return part.pixels>200)))
	var report: Array[Dictionary] = []
	for name in ["front_body","return_body","jump_body","return_hands","jump_hands","slash","landing"]:
		var source := Image.new()
		source.load_png_from_buffer(FileAccess.get_file_as_bytes(DEST+name+".png"))
		var cell_size := Vector2i(192,192 if name in ["slash","landing"] else 128)
		for row in source.get_height()/cell_size.y:
			for column in 4:
				var cell := source.get_region(Rect2i(Vector2i(column,row)*cell_size,cell_size))
				var islands := components(cell)
				report.append({"asset":name,"row":row,"column":column,"islands":islands})
				if name=="slash" and row in [1,3]:
					cell.resize(768,768,Image.INTERPOLATE_NEAREST)
					cell.save_png(OUT+"audit_slash_%d_%d.png"%[row,column])
	FileAccess.open(OUT+"alpha_islands.json",FileAccess.WRITE).store_string(JSON.stringify(report,"\t")+"\n")
	for entry in report:
		var edge: Array = entry.islands.filter(func(part: Dictionary) -> bool:
			var rect: Rect2i = str_to_var(part.bounds)
			return rect.position.x<32 or rect.end.x>160)
		if not edge.is_empty(): print(entry.asset," ",entry.row,"/",entry.column," edge ",JSON.stringify(edge))
	_compose_directional_contacts()
	quit()

func _compose_directional_contacts() -> void:
	# Compare actual renderer captures; never modify source/runtime artwork.
	var folder := "res://art_source/review/combat/king_greatsword_v2_vertical_impact_gameplay_2026_10_07/"
	var composite := Image.create(720,480,false,Image.FORMAT_RGBA8)
	for index in 2:
		var direction: String = ["up","down"][index]
		var file: String = ["frame_044.png","frame_045.png"][index]
		var path := folder+direction+"/motion_frames/"+file
		if not FileAccess.file_exists(path): return
		var image := Image.new()
		image.load_png_from_buffer(FileAccess.get_file_as_bytes(path))
		composite.blit_rect(image,Rect2i(300,40,360,480),Vector2i(index*360,0))
	composite.save_png(folder+"vertical_jump_contacts.png")

static func components(cell: Image) -> Array[Dictionary]:
	var width := cell.get_width()
	var height := cell.get_height()
	var seen := PackedByteArray()
	seen.resize(width*height)
	var result: Array[Dictionary] = []
	for seed in width*height:
		if seen[seed] or cell.get_pixel(seed%width,seed/width).a<.65: continue
		seen[seed] = 1
		var todo := PackedInt32Array([seed])
		var low := Vector2i(seed%width,seed/width)
		var high := low
		var cursor := 0
		while cursor<todo.size():
			var id := todo[cursor]
			cursor += 1
			var point := Vector2i(id%width,id/width)
			low = low.min(point)
			high = high.max(point)
			for dy in range(-1,2):
				for dx in range(-1,2):
					var next := point+Vector2i(dx,dy)
					if next.x<0 or next.x>=width or next.y<0 or next.y>=height: continue
					var index := next.y*width+next.x
					if seen[index] or cell.get_pixelv(next).a<.65: continue
					seen[index] = 1
					todo.append(index)
		result.append({"pixels":todo.size(),"bounds":var_to_str(Rect2i(low,high-low+Vector2i.ONE))})
	result.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.pixels>b.pixels)
	return result
