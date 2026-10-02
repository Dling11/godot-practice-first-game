extends SceneTree

const SOURCE := "res://art_source/generated/ui/centered_paperdoll_2026_10_02/"
const OUTPUT := "res://assets/ui/inventory/centered_paperdoll_frame.png"

func _initialize() -> void:
	var source := Image.load_from_file(SOURCE + "frame_source.png")
	assert(source != null, "Missing owner-selected Paperdoll frame source")
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x, y)
			source.set_pixel(x, y, Color.TRANSPARENT if color.a < .65 else Color(color.r, color.g, color.b, 1))
	var crop := source.get_used_rect()
	assert(crop.has_area())
	var frame := source.get_region(crop)
	frame.resize(256, 128, Image.INTERPOLATE_NEAREST)
	assert(frame.save_png(OUTPUT) == OK)
	var manifest := FileAccess.open(SOURCE + "normalization.json", FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"source_size": str(source.get_size()), "crop": str(crop), "size": "(256, 128)", "alpha": "binary", "sampling": "nearest", "slice_margin": 16}, "\t"))
	print("PAPERDOLL_FRAME: ", crop, " -> 256x128")
	quit()
