extends SceneTree

const SOURCE := "res://art_source/generated/ui/slim_runic_hp_2026_10_02/"
const OUTPUT := "res://assets/ui/player_readability/slim_runic_hp.png"
const SIZE := Vector2i(248,38)

func _initialize() -> void:
	var source := Image.load_from_file(SOURCE+"frame_source.png")
	assert(source != null,"Missing Slim Runic source")
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x,y)
			source.set_pixel(x,y,Color.TRANSPARENT if color.a < .65 else Color(color.r,color.g,color.b,1))
	var crop := source.get_used_rect()
	assert(crop.has_area(),"Empty Slim Runic source")
	var image := source.get_region(crop)
	image.resize(SIZE.x,SIZE.y,Image.INTERPOLATE_NEAREST)
	assert(image.save_png(OUTPUT) == OK)
	var manifest := FileAccess.open(SOURCE+"normalization.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"source_size":str(source.get_size()),"crop":str(crop),"size":str(SIZE),"alpha":"binary","sampling":"nearest","label_rect":"(66,3,116,13)","fill_rect":"(17,20,214,9)"},"\t"))
	print("SLIM_RUNIC_HP_ART: ",crop," -> ",SIZE)
	quit()
