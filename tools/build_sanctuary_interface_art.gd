extends SceneTree

const SOURCE := "res://art_source/generated/"

func _initialize() -> void:
	var output := "res://assets/environment/sanctuary/orthographic/"
	DirAccess.make_dir_recursive_absolute(output)
	var manifest: Array[Dictionary] = []
	for recipe in [["nema",Vector2i(200,160)],["umi",Vector2i(176,156)]]:
		var source := _binary(Image.load_from_file(SOURCE+"environment/sanctuary/orthographic_2026_10_01/"+recipe[0]+"_source.png"))
		var crop := source.get_region(source.get_used_rect())
		var limit: Vector2i = recipe[1]
		var ratio := minf(float(limit.x)/crop.get_width(),float(limit.y)/crop.get_height())
		crop.resize(roundi(crop.get_width()*ratio),roundi(crop.get_height()*ratio),Image.INTERPOLATE_NEAREST)
		assert(crop.save_png(output+recipe[0]+".png") == OK)
		manifest.append({"asset":recipe[0],"size":str(crop.get_size())})
	var ui_output := "res://assets/ui/sanctuary_theme/"
	DirAccess.make_dir_recursive_absolute(ui_output)
	var frame := Image.load_from_file(SOURCE+"ui/sanctuary_theme_2026_10_01/frame_source.png")
	# Remove the generated presentation surround; preserve the rectangular frame itself.
	frame = frame.get_region(Rect2i(24,84,1488,816))
	frame.resize(288,160,Image.INTERPOLATE_NEAREST)
	assert(_binary(frame).save_png(ui_output+"panel.png") == OK)
	var paper := Image.load_from_file(SOURCE+"ui/sanctuary_theme_2026_10_01/map_source.png")
	paper.resize(384,256,Image.INTERPOLATE_NEAREST)
	assert(_binary(paper).save_png(ui_output+"map_paper.png") == OK)
	manifest.append({"asset":"panel","size":"288x160","source_crop":"24,84,1488,816","slice":"40,32,40,32"})
	manifest.append({"asset":"map_paper","size":"384x256"})
	var file := FileAccess.open(SOURCE+"ui/sanctuary_theme_2026_10_01/normalization.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))
	print("SANCTUARY_INTERFACE_ART: ",manifest)
	quit()

func _binary(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			image.set_pixel(x,y,Color(0,0,0,0) if c.a < .65 else Color(c.r,c.g,c.b,1))
	return image
