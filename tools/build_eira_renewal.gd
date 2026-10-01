extends SceneTree

## Offline normalization only. Runtime service and animation authority remain separate.
const SOURCE := "res://art_source/generated/characters/npcs/eira/renewal_2026_10_01/"
const OUTPUT := "res://assets/characters/npcs/skillkeeper/renewal/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var source := Image.load_from_file(SOURCE + "idle_source.png")
	assert(source.get_width() % 4 == 0 and source.get_height() % 2 == 0)
	var cell := Vector2i(source.get_width() / 4, source.get_height() / 2)
	var frames: Array[Image] = []
	for index in 8:
		frames.append(_binary(source.get_region(Rect2i(Vector2i(index % 4, index / 4) * cell, cell))))
	var factor := 60.0 / frames[0].get_used_rect().size.y
	var atlas := Image.create(384, 192, false, Image.FORMAT_RGBA8)
	var manifest: Array[Dictionary] = []
	for index in 8:
		var frame := frames[index]
		frame.resize(roundi(cell.x * factor), roundi(cell.y * factor), Image.INTERPOLATE_NEAREST)
		var bounds := frame.get_used_rect()
		var feet := frame.get_region(Rect2i(0, bounds.end.y - 8, frame.get_width(), 8)).get_used_rect()
		var offset := Vector2i(48 - feet.position.x - feet.size.x / 2, 80 - bounds.end.y)
		var registered := Rect2i(bounds.position + offset, bounds.size)
		assert(registered.position.x > 4 and registered.end.x < 92)
		assert(registered.end.y == 80 and registered.size.y >= 58 and registered.size.y <= 62)
		atlas.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), Vector2i(index % 4, index / 4) * 96 + offset)
		manifest.append({"frame": index, "bounds": str(registered), "foot_y": 80, "shared_scale": factor})
	assert(atlas.save_png(OUTPUT + "idle_read.png") == OK)
	var portrait := Image.load_from_file(SOURCE + "portrait_source.png")
	portrait.resize(96, 96, Image.INTERPOLATE_NEAREST)
	assert(_binary(portrait).save_png(OUTPUT + "portrait.png") == OK)
	var file := FileAccess.open(SOURCE + "normalization.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t"))
	print("EIRA_RENEWAL_BUILT: ", manifest)
	quit()

func _binary(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			color = Color(0, 0, 0, 0) if color.a < .65 else Color(color.r, color.g, color.b, 1)
			image.set_pixel(x, y, color)
	return image
