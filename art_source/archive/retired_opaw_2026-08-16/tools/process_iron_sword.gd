extends SceneTree

## Converts the preserved generated Iron Sword source into the two pixel-safe
## runtime textures used by inventory UI and the detached player weapon visual.

const SOURCE_PATH := "res://art_source/generated/items/weapons/iron_sword/iron_sword_clean.png"
const ICON_PATH := "res://assets/items/weapons/icons/iron_sword_64x64.png"
const WORLD_PATH := "res://assets/items/weapons/world/iron_sword_16x24.png"

const PALETTE: Array[Color] = [
	Color("17171b"),
	Color("303139"),
	Color("565963"),
	Color("858994"),
	Color("b7bac2"),
	Color("e8e9e6"),
	Color("4a2b20"),
	Color("75452e"),
	Color("a36342"),
	Color("725628"),
	Color("ad8338"),
	Color("e1bb63"),
]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		_fail("Unable to load Iron Sword source: %s" % SOURCE_PATH)
		return
	if source.get_format() != Image.FORMAT_RGBA8:
		source.convert(Image.FORMAT_RGBA8)

	var used_rect := source.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		_fail("Iron Sword source does not contain visible pixels.")
		return

	var cropped := source.get_region(used_rect)
	_make_runtime_texture(cropped, Vector2i(64, 64), Vector2i(18, 58), ICON_PATH)
	_make_runtime_texture(cropped, Vector2i(16, 24), Vector2i(8, 22), WORLD_PATH)
	print("Processed Iron Sword into 64x64 inventory and 16x24 world textures.")
	quit(0)


func _make_runtime_texture(source: Image, canvas_size: Vector2i, content_size: Vector2i, output_path: String) -> void:
	var resized := source.duplicate()
	resized.resize(content_size.x, content_size.y, Image.INTERPOLATE_NEAREST)
	_quantize_and_harden_alpha(resized)

	var canvas := Image.create_empty(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	var destination := Vector2i(
		(canvas_size.x - resized.get_width()) / 2,
		(canvas_size.y - resized.get_height()) / 2
	)
	canvas.blit_rect(resized, Rect2i(Vector2i.ZERO, resized.get_size()), destination)
	var error := canvas.save_png(output_path)
	if error != OK:
		_fail("Unable to save %s: %s" % [output_path, error_string(error)])


func _quantize_and_harden_alpha(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var closest := PALETTE[0]
			var closest_distance := INF
			for candidate in PALETTE:
				var delta := Vector3(color.r - candidate.r, color.g - candidate.g, color.b - candidate.b)
				var distance := delta.length_squared()
				if distance < closest_distance:
					closest = candidate
					closest_distance = distance
			closest.a = 1.0
			image.set_pixel(x, y, closest)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
