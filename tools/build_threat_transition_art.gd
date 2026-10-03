extends SceneTree

## Technical normalization only: imagegen supplies every authored frame.
const PORTAL_SOURCE := "res://art_source/generated/environment/portals/threat_family_2026_10_03/"
const UI_SOURCE := "res://art_source/generated/ui/quiet_transition_2026_10_03/"
const PORTAL_OUTPUT := "res://assets/environment/portals/threat_family/"
const UI_OUTPUT := "res://assets/ui/quiet_transition/"
const KEYS := ["calm", "ominous", "grasp", "maw", "divine", "unknowable"]
var manifest: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_build")

func _normalize(key: String, source_path: String, output: String, canvas: Vector2i, limit: Vector2i, baseline: int) -> void:
	var source := Image.load_from_file(source_path)
	assert(source != null, source_path)
	source.convert(Image.FORMAT_RGBA8)
	var cells: Array[Image] = []
	var union := Rect2i()
	for index in 8:
		var left := floori(float(index % 4) * source.get_width() / 4)
		var top := floori(float(index / 4) * source.get_height() / 2)
		var right := floori(float(index % 4 + 1) * source.get_width() / 4)
		var bottom := floori(float(index / 4 + 1) * source.get_height() / 2)
		var cell := source.get_region(Rect2i(left, top, right-left, bottom-top))
		assert(cell.get_pixel(0, 0).a < .7, "Source lacks transparent cell margin: " + key)
		for y in cell.get_height():
			for x in cell.get_width():
				var color := cell.get_pixel(x, y)
				cell.set_pixel(x, y, Color.TRANSPARENT if color.a < .7 else Color(color.r, color.g, color.b, 1))
		var used := cell.get_used_rect()
		union = used if index == 0 else union.merge(used)
		cells.append(cell)
	var ratio := minf(float(limit.x) / union.size.x, float(limit.y) / union.size.y)
	var native_size := Vector2i(roundi(union.size.x * ratio), roundi(union.size.y * ratio))
	var atlas := Image.create(canvas.x * 8, canvas.y, false, Image.FORMAT_RGBA8)
	# One union and origin for the entire loop preserves animated pose offsets.
	var origin := Vector2i((canvas.x-native_size.x)/2, baseline-native_size.y)
	for index in 8:
		var image := cells[index].get_region(union)
		image.resize(native_size.x, native_size.y, Image.INTERPOLATE_NEAREST)
		atlas.blit_rect(image, Rect2i(Vector2i.ZERO, native_size), origin+Vector2i(index*canvas.x, 0))
	assert(atlas.save_png(output+key+".png") == OK)
	manifest.append({"key": key, "source_union": str(union), "native_size": str(native_size), "origin": str(origin), "scale": ratio, "frames": 8})

func _frames(key: String, output: String, canvas: Vector2i, speed: float) -> void:
	var frames := SpriteFrames.new()
	frames.rename_animation(&"default", &"active")
	frames.set_animation_speed(&"active", speed)
	for index in 8:
		var texture := AtlasTexture.new()
		texture.atlas = load(output+key+".png")
		texture.region = Rect2(index*canvas.x, 0, canvas.x, canvas.y)
		frames.add_frame(&"active", texture)
	assert(ResourceSaver.save(frames, output+key+"_frames.tres") == OK)

func _build() -> void:
	DirAccess.make_dir_recursive_absolute(PORTAL_OUTPUT)
	DirAccess.make_dir_recursive_absolute(UI_OUTPUT)
	if "--frames-only" not in OS.get_cmdline_user_args():
		for key: String in KEYS:
			_normalize(key, PORTAL_SOURCE+key+"_source.png", PORTAL_OUTPUT, Vector2i(192,160), Vector2i(172,132), 151)
		_normalize("seal", UI_SOURCE+"loading_seal_source.png", UI_OUTPUT, Vector2i(112,112), Vector2i(96,96), 104)
		var background := Image.load_from_file(UI_SOURCE+"loading_background_source.png")
		background.resize(960, 540, Image.INTERPOLATE_NEAREST)
		assert(background.save_png(UI_OUTPUT+"background.png") == OK)
		FileAccess.open(PORTAL_SOURCE+"normalization.json", FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
	if "--art-only" not in OS.get_cmdline_user_args():
		for key: String in KEYS:
			_frames(key, PORTAL_OUTPUT, Vector2i(192,160), 8.0)
		_frames("seal", UI_OUTPUT, Vector2i(112,112), 7.0)
	print("THREAT_TRANSITION_ART: six 8-frame portal loops, seal and generic backdrop")
	quit()
