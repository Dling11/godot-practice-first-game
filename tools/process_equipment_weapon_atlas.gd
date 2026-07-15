extends SceneTree

## Converts the preserved generated 2x2 weapon board into four pixel-safe,
## binary-alpha 64x64 inventory icons. Runtime art never loads the source board.

const SOURCE_PATH := "res://art_source/generated/items/weapons/equipment_weapon_atlas_source.png"
const CLEAN_PATH := "res://art_source/generated/items/weapons/equipment_weapon_atlas_clean.png"
const OUTPUT_DIRECTORY := "res://assets/items/weapons/icons"
const OUTPUT_SIZE := Vector2i(64, 64)

const OUTPUT_NAMES := [
	"wayfarers_iron_64x64.png",
	"gloamfang_64x64.png",
	"sunroot_oath_64x64.png",
	"veilrender_64x64.png",
]

const PALETTES := [
	[
		Color("11131a"), Color("242832"), Color("3b4149"), Color("596069"),
		Color("7c858b"), Color("aab0ac"), Color("d9ddce"), Color("f3f0de"),
		Color("33241f"), Color("583b2a"), Color("81593b"), Color("365a3b"),
		Color("5f8f47"), Color("9ab85d"),
	],
	[
		Color("090b10"), Color("171821"), Color("282a35"), Color("414451"),
		Color("656976"), Color("9596a0"), Color("d9ddce"), Color("392b55"),
		Color("593d82"), Color("765aa3"), Color("9b71d0"), Color("c29af2"),
	],
	[
		Color("17140f"), Color("34291b"), Color("5a4324"), Color("84622e"),
		Color("aa813c"), Color("d6a94e"), Color("d6c171"), Color("f0d991"),
		Color("fff2c7"), Color("365a3b"), Color("5f8f47"), Color("91ad55"),
		Color("d9ddce"),
	],
	[
		Color("130f12"), Color("32252a"), Color("624047"), Color("8d2631"),
		Color("c43d47"), Color("e4685f"), Color("805f45"), Color("b08c62"),
		Color("d6c171"), Color("d9cdb8"), Color("eee5d2"), Color("fff8df"),
	],
]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		_fail("Unable to load generated equipment weapon atlas: %s" % SOURCE_PATH)
		return
	if source.get_width() % 2 != 0 or source.get_height() % 2 != 0:
		_fail("Equipment weapon atlas must divide into an exact 2x2 grid.")
		return

	var clean := source.duplicate()
	_remove_chroma(clean)
	var clean_error: Error = clean.save_png(CLEAN_PATH)
	if clean_error != OK:
		_fail("Unable to preserve the cleaned equipment atlas: %s" % error_string(clean_error))
		return

	var cell_size := Vector2i(source.get_width() / 2, source.get_height() / 2)
	for index in OUTPUT_NAMES.size():
		var coordinate := Vector2i(index % 2, index / 2)
		var icon := source.get_region(Rect2i(coordinate * cell_size, cell_size))
		_remove_chroma(icon)
		icon.resize(OUTPUT_SIZE.x, OUTPUT_SIZE.y, Image.INTERPOLATE_NEAREST)
		_quantize(icon, PALETTES[index])
		var output_path: String = "%s/%s" % [OUTPUT_DIRECTORY, OUTPUT_NAMES[index]]
		var output_error: Error = icon.save_png(output_path)
		if output_error != OK:
			_fail("Unable to save equipment icon %s: %s" % [output_path, error_string(output_error)])
			return

	print("Processed equipment weapon atlas into four 64x64 runtime icons.")
	quit(0)


func _remove_chroma(image: Image) -> void:
	if image.get_format() != Image.FORMAT_RGBA8:
		image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if _is_chroma(color):
				image.set_pixel(x, y, Color.TRANSPARENT)
			else:
				color.a = 1.0
				image.set_pixel(x, y, color)


func _is_chroma(color: Color) -> bool:
	# The generated source uses a flat magenta key. The wider second clause
	# removes antialiased key spill without erasing crimson or violet details.
	return (
		color.r > 0.9 and color.g < 0.18 and color.b > 0.9
	) or (
		color.r > 0.78 and color.g < 0.34 and color.b > 0.72
	)


func _quantize(image: Image, palette: Array) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var closest: Color = palette[0]
			var closest_distance := INF
			for candidate: Color in palette:
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
