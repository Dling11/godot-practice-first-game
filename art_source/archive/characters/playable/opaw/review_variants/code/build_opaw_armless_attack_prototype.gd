extends SceneTree

## Normalizes the review-only image-generated armless attack board onto Opaw's
## existing 3x4 attack grid. It never overwrites the active or handless sheets.

const SOURCE_PATH := "res://art_source/generated/characters/playable/opaw/variants/armless/opaw_armless_attack_body_source.png"
const CLEAN_PATH := "res://art_source/generated/characters/playable/opaw/variants/armless/opaw_armless_attack_body_clean.png"
const OUTPUT_PATH := "res://assets/characters/playable/opaw/variants/armless/opaw_armless_attack_body_sheet_48x32.png"
const SMALL_FEET_SOURCE_PATH := "res://art_source/generated/characters/playable/opaw/variants/armless_small_feet/opaw_armless_small_feet_attack_body_source.png"
const SMALL_FEET_CLEAN_PATH := "res://art_source/generated/characters/playable/opaw/variants/armless_small_feet/opaw_armless_small_feet_attack_body_clean.png"
const SMALL_FEET_OUTPUT_PATH := "res://assets/characters/playable/opaw/variants/armless_small_feet/opaw_armless_small_feet_attack_body_sheet_48x32.png"
const COLUMNS := 3
const ROWS := 4
const CELL_SIZE := Vector2i(48, 32)
const REFERENCE_SIZE := Vector2(18.0, 27.0)

const PALETTE := [
	Color("090b10"), Color("171a1f"), Color("2b3036"),
	Color("3d2b21"), Color("6f4329"), Color("a96e42"),
	Color("d99b63"), Color("f0c38b"), Color("f5d09a"),
	Color("1d2b22"), Color("263a2b"), Color("365a3b"),
	Color("56754a"), Color("5b241e"), Color("843329"),
	Color("b84a35"), Color("c58a3e"),
]


func _initialize() -> void:
	if not _build_variant(SOURCE_PATH, CLEAN_PATH, OUTPUT_PATH, "armless"):
		quit(1)
		return
	if not _build_variant(
		SMALL_FEET_SOURCE_PATH,
		SMALL_FEET_CLEAN_PATH,
		SMALL_FEET_OUTPUT_PATH,
		"armless small-feet"
	):
		quit(1)
		return
	print("Built both Opaw armless attack prototypes without changing active art.")
	quit(0)


func _build_variant(source_path: String, clean_path: String, output_path: String, label: String) -> bool:
	var source := Image.load_from_file(source_path)
	if source == null or source.is_empty():
		push_error("Unable to load %s Opaw source board." % label)
		return false
	var clean := source.duplicate()
	_remove_white_board(clean)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_path.get_base_dir()))
	if clean.save_png(clean_path) != OK:
		push_error("Unable to save %s Opaw clean board." % label)
		return false

	var output := Image.create_empty(COLUMNS * CELL_SIZE.x, ROWS * CELL_SIZE.y, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	for row in ROWS:
		var reference := _source_cell(clean, 0, row)
		var reference_bounds := reference.get_used_rect()
		if reference_bounds.size.x <= 0 or reference_bounds.size.y <= 0:
			push_error("%s Opaw row %s has no reference pose." % [label, row])
			return false
		var scale := Vector2(
			REFERENCE_SIZE.x / reference_bounds.size.x,
			REFERENCE_SIZE.y / reference_bounds.size.y
		)
		for column in COLUMNS:
			var cell := _source_cell(clean, column, row)
			var bounds := cell.get_used_rect()
			if bounds.size.x <= 0 or bounds.size.y <= 0:
				push_error("%s Opaw frame %s,%s is empty." % [label, column, row])
				return false
			var content := cell.get_region(bounds)
			var target_size := Vector2i(
				maxi(1, roundi(content.get_width() * scale.x)),
				maxi(1, roundi(content.get_height() * scale.y))
			)
			var fit := minf(1.0, minf(46.0 / target_size.x, 32.0 / target_size.y))
			target_size = Vector2i(maxi(1, roundi(target_size.x * fit)), maxi(1, roundi(target_size.y * fit)))
			content.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)
			_quantize(content)
			var origin := Vector2i(column * CELL_SIZE.x, row * CELL_SIZE.y)
			var destination := origin + Vector2i(
				int((CELL_SIZE.x - target_size.x) / 2.0),
				CELL_SIZE.y - target_size.y
			)
			output.blit_rect(content, Rect2i(Vector2i.ZERO, target_size), destination)
	if output.save_png(output_path) != OK:
		push_error("Unable to save %s Opaw attack prototype." % label)
		return false
	return true


func _source_cell(image: Image, column: int, row: int) -> Image:
	var left := roundi(float(column) * image.get_width() / COLUMNS)
	var right := roundi(float(column + 1) * image.get_width() / COLUMNS)
	var top := roundi(float(row) * image.get_height() / ROWS)
	var bottom := roundi(float(row + 1) * image.get_height() / ROWS)
	return image.get_region(Rect2i(left, top, right - left, bottom - top))


func _remove_white_board(image: Image) -> void:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.s < 0.16 and color.v > 0.70:
				image.set_pixel(x, y, Color.TRANSPARENT)
			else:
				color.a = 1.0
				image.set_pixel(x, y, color)


func _quantize(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var closest: Color = PALETTE[0]
			var distance := INF
			for candidate: Color in PALETTE:
				var delta := Vector3(color.r - candidate.r, color.g - candidate.g, color.b - candidate.b)
				if delta.length_squared() < distance:
					distance = delta.length_squared()
					closest = candidate
			closest.a = 1.0
			image.set_pixel(x, y, closest)
