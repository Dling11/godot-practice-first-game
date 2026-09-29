extends SceneTree

const SOURCE := "res://art_source/generated/environment/sanctuary/orren_workshop_2026_09_30/"
const CHARACTER := "res://assets/characters/npcs/armskeeper/renewal/"
const ENVIRONMENT := "res://assets/environment/sanctuary/refuge_review/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(CHARACTER)
	var source := Image.load_from_file(SOURCE+"idle_readable_source.png")
	var frames: Array[Image] = []
	for index in 8:
		var begin := Vector2i(roundi(index%4*source.get_width()/4.0),roundi(index/4*source.get_height()/2.0))
		var end := Vector2i(roundi((index%4+1)*source.get_width()/4.0),roundi((index/4+1)*source.get_height()/2.0))
		frames.append(_largest(_binary(source.get_region(Rect2i(begin,end-begin)))))
	var scale_factor := 60.0/frames[0].get_used_rect().size.y
	var atlas := Image.create(384,192,false,Image.FORMAT_RGBA8)
	var manifest: Array[Dictionary] = []
	for index in 8:
		var frame := frames[index]
		frame.resize(roundi(frame.get_width()*scale_factor),roundi(frame.get_height()*scale_factor),Image.INTERPOLATE_NEAREST)
		frame = _largest(frame)
		var bounds := frame.get_used_rect()
		var foot_bounds := frame.get_region(Rect2i(0,bounds.end.y-8,frame.get_width(),8)).get_used_rect()
		var foot_x := foot_bounds.position.x+foot_bounds.size.x/2
		var offset := Vector2i(48-foot_x,80-bounds.end.y)
		atlas.blit_rect(frame,Rect2i(Vector2i.ZERO,frame.get_size()),Vector2i(index%4,index/4)*96+offset)
		manifest.append({"frame":index,"bounds":str(Rect2i(bounds.position+offset,bounds.size)),"foot_y":80,"shared_scale":scale_factor})
	assert(atlas.save_png(CHARACTER+"idle_work_v2.png") == OK)
	var portrait := Image.load_from_file(SOURCE+"portrait_source.png")
	portrait.resize(96,96,Image.INTERPOLATE_NEAREST)
	portrait = _binary(portrait)
	assert(portrait.save_png(CHARACTER+"portrait.png") == OK)
	var building := _binary(Image.load_from_file(SOURCE+"workshop_source.png"))
	var bounds := building.get_used_rect()
	var crop := building.get_region(bounds)
	var ratio := 240.0/crop.get_width()
	var door_x := roundi((building.get_width()*.394-bounds.position.x)*ratio)
	crop.resize(240,roundi(crop.get_height()*ratio),Image.INTERPOLATE_NEAREST)
	var canvas := Image.create(320,224,false,Image.FORMAT_RGBA8)
	canvas.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),Vector2i(160-door_x,208-crop.get_height()))
	assert(canvas.save_png(ENVIRONMENT+"orren_workshop.png") == OK)
	var output := FileAccess.open(SOURCE+"normalization_readable.json",FileAccess.WRITE)
	output.store_string(JSON.stringify(manifest,"\t"))
	print("ORREN_REVIEW_BUILT: ",manifest)
	quit()

func _binary(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			if c.a < .65: c = Color(0,0,0,0)
			else: c.a = 1.0
			image.set_pixel(x,y,c)
	return image

func _largest(image: Image) -> Image:
	var visited := PackedByteArray()
	visited.resize(image.get_width()*image.get_height())
	var largest: Array[Vector2i] = []
	for y in image.get_height():
		for x in image.get_width():
			var start := Vector2i(x,y)
			if visited[y*image.get_width()+x] or image.get_pixelv(start).a == 0.0: continue
			var component: Array[Vector2i] = [start]
			visited[y*image.get_width()+x] = 1
			var cursor := 0
			while cursor < component.size():
				var point := component[cursor]
				cursor += 1
				for dy in range(-1,2):
					for dx in range(-1,2):
						var neighbor := point+Vector2i(dx,dy)
						if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= image.get_width() or neighbor.y >= image.get_height(): continue
						var key := neighbor.y*image.get_width()+neighbor.x
						if visited[key] or image.get_pixelv(neighbor).a == 0.0: continue
						visited[key] = 1
						component.append(neighbor)
			if component.size() > largest.size(): largest = component
	var clean := Image.create(image.get_width(),image.get_height(),false,Image.FORMAT_RGBA8)
	for pixel in largest: clean.set_pixelv(pixel,image.get_pixelv(pixel))
	return clean
