extends SceneTree

const SOURCE := "res://art_source/generated/environment/sanctuary/inhabited_2026_10_01/"
const OUTPUT := "res://assets/environment/sanctuary/inhabited/"
const COURIER_SOURCE := "res://art_source/generated/characters/npcs/courier/inhabited_2026_10_01/"
const COURIER_OUTPUT := "res://assets/characters/npcs/courier/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	DirAccess.make_dir_recursive_absolute(COURIER_OUTPUT)
	var source := Image.load_from_file(SOURCE + "kit_source.png")
	var recipes := [
		["linden", Rect2i(0, 0, 490, 620), Vector2i(128, 160)],
		["cedar", Rect2i(490, 0, 325, 620), Vector2i(112, 176)],
		["anvil_station", Rect2i(815, 240, 365, 380), Vector2i(72, 48)],
		["lectern", Rect2i(1180, 220, 356, 400), Vector2i(48, 44)],
		["wall_horizontal", Rect2i(0, 720, 600, 290), Vector2i(96, 32)],
		["wall_vertical", Rect2i(620, 620, 185, 404), Vector2i(32, 96)],
		["pillar", Rect2i(880, 720, 235, 304), Vector2i(28, 40)],
		["noticeboard", Rect2i(1160, 620, 376, 404), Vector2i(64, 72)],
	]
	var manifest: Array[Dictionary] = []
	for recipe in recipes:
		var clean := _binary(source.get_region(recipe[1]))
		var bounds := clean.get_used_rect()
		var crop := clean.get_region(bounds)
		var limit: Vector2i = recipe[2]
		var ratio := minf(float(limit.x) / bounds.size.x, float(limit.y) / bounds.size.y)
		var size := Vector2i(roundi(bounds.size.x * ratio), roundi(bounds.size.y * ratio))
		if str(recipe[0]).begins_with("wall_"): size = limit
		crop.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
		assert(crop.save_png(OUTPUT + str(recipe[0]) + ".png") == OK)
		manifest.append({"asset": recipe[0], "source_rect": str(recipe[1]), "size": str(size)})
	var file := FileAccess.open(SOURCE + "normalization.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t"))
	_build_courier_idle()
	print("SANCTUARY_LIFE_ART_BUILT: ", manifest)
	quit()

func _build_courier_idle() -> void:
	var source := Image.load_from_file(COURIER_SOURCE + "idle_source.png")
	var poses: Array[Image] = []
	for index in 4:
		var begin := roundi(index * source.get_width() / 4.0)
		var end := roundi((index + 1) * source.get_width() / 4.0)
		poses.append(_binary(source.get_region(Rect2i(begin,0,end-begin,source.get_height()))))
	var factor := 58.0 / poses[0].get_used_rect().size.y
	var atlas := Image.create(384,96,false,Image.FORMAT_RGBA8)
	for index in 4:
		var pose := poses[index]
		pose.resize(roundi(pose.get_width()*factor),roundi(pose.get_height()*factor),Image.INTERPOLATE_NEAREST)
		var bounds := pose.get_used_rect()
		var offset := Vector2i(48-bounds.get_center().x,80-bounds.end.y)
		atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i(index*96,0)+offset)
	assert(atlas.save_png(COURIER_OUTPUT + "idle.png") == OK)

func _binary(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	for pixel_y in image.get_height():
		for pixel_x in image.get_width():
			var color := image.get_pixel(pixel_x, pixel_y)
			image.set_pixel(pixel_x, pixel_y, Color(0,0,0,0) if color.a < .65 else Color(color.r,color.g,color.b,1))
	return image
