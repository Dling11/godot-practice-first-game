extends SceneTree

const SOURCE := "res://art_source/generated/ui/portrait_link_2026_10_02/"
const OUTPUT := "res://assets/ui/player_readability/portrait_link.png"
const SIZE := Vector2i(300,96)

func _initialize() -> void:
	var source := Image.load_from_file(SOURCE+"frame_source.png")
	assert(source != null,"Missing Portrait Link source")
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x,y)
			source.set_pixel(x,y,Color.TRANSPARENT if color.a < .65 else Color(color.r,color.g,color.b,1))
	var crop := source.get_used_rect()
	assert(crop.has_area(),"Empty Portrait Link source")
	var image := source.get_region(crop)
	image.resize(SIZE.x,SIZE.y,Image.INTERPOLATE_NEAREST)
	assert(image.save_png(OUTPUT) == OK)
	var manifest := FileAccess.open(SOURCE+"normalization.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"source_size":str(source.get_size()),"crop":str(crop),"size":str(SIZE),"alpha":"binary","sampling":"nearest","label_rects":{"hp":"(128,14,118,12)","xp":"(128,54,118,12)","level":"(20,80,36,13)"},"fill_rects":{"hp":"(86,32,193,11)","xp":"(86,70,193,12)"}},"\t"))
	print("PORTRAIT_LINK_ART: ",crop," -> ",SIZE)
	quit()
