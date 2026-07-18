extends SceneTree

## Converts Opaw's compact armless action sources into deterministic,
## binary-alpha runtime art. Gameplay scenes never load generation sources.

const CHARACTER_SOURCE_ROOT := "res://art_source/generated/characters/playable/opaw/compact_armless"
const CHARACTER_OUTPUT_ROOT := "res://assets/characters/playable/opaw/compact_armless"
const CHARACTER_DIRECTION_ROWS := 4
const CHARACTER_CELL_SIZE := Vector2i(32, 32)
const CHARACTER_ACTION_CELL_SIZE := Vector2i(48, 32)
const CHARACTER_DEFEAT_CELL_SIZE := Vector2i(64, 32)
const CHARACTER_STANDING_WIDTH := 18
const CHARACTER_STANDING_HEIGHT := 27
const CHARACTER_CELL_PADDING := 2
const SOURCE_CELL_EXPANSION_RATIO := 0.08
const COMPONENT_JOIN_RATIO := 0.06
const COMPONENT_NEIGHBORS := [
	Vector2i(-1, -1),
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(-1, 1),
	Vector2i(0, 1),
	Vector2i(1, 1),
]

const CHARACTER_ACTIONS := [
	{
		"name": "idle",
		"source": "opaw_compact_armless_idle_source.png",
		"clean": "opaw_compact_armless_idle_clean.png",
		"output": "opaw_compact_armless_idle_sheet_32x32.png",
		"columns": 2,
		"cell_size": CHARACTER_CELL_SIZE,
	},
	{
		"name": "walk",
		"source": "opaw_compact_armless_walk_source.png",
		"clean": "opaw_compact_armless_walk_clean.png",
		"output": "opaw_compact_armless_walk_sheet_32x32.png",
		"columns": 4,
		"cell_size": CHARACTER_CELL_SIZE,
	},
	{
		"name": "attack_body",
		"source": "opaw_compact_armless_attack_body_source.png",
		"clean": "opaw_compact_armless_attack_body_clean.png",
		"output": "opaw_compact_armless_attack_body_sheet_48x32.png",
		"columns": 3,
		"cell_size": CHARACTER_ACTION_CELL_SIZE,
	},
	{
		"name": "dash",
		"source": "opaw_compact_armless_dash_source.png",
		"clean": "opaw_compact_armless_dash_clean.png",
		"output": "opaw_compact_armless_dash_sheet_48x32.png",
		"columns": 3,
		"cell_size": CHARACTER_ACTION_CELL_SIZE,
	},
	{
		"name": "interact",
		"source": "opaw_compact_armless_interact_source.png",
		"clean": "opaw_compact_armless_interact_clean.png",
		"output": "opaw_compact_armless_interact_sheet_48x32.png",
		"columns": 2,
		"cell_size": CHARACTER_ACTION_CELL_SIZE,
	},
	{
		"name": "hurt",
		"source": "opaw_compact_armless_hurt_source.png",
		"clean": "opaw_compact_armless_hurt_clean.png",
		"output": "opaw_compact_armless_hurt_sheet_32x32.png",
		"columns": 2,
		"cell_size": CHARACTER_CELL_SIZE,
	},
	{
		"name": "defeat",
		"source": "opaw_compact_armless_defeat_source.png",
		"clean": "opaw_compact_armless_defeat_clean.png",
		"output": "opaw_compact_armless_defeat_sheet_64x32.png",
		"columns": 4,
		"cell_size": CHARACTER_DEFEAT_CELL_SIZE,
	},
]

const WEAPON_SOURCE_PATH := "res://art_source/generated/items/weapons/ashwood_blade/ashwood_blade_source.png"
const WEAPON_CLEAN_PATH := "res://art_source/generated/items/weapons/ashwood_blade/ashwood_blade_clean.png"
const WEAPON_WORLD_PATH := "res://assets/items/weapons/world/ashwood_blade_16x24.png"
const WEAPON_ICON_PATH := "res://assets/items/weapons/icons/ashwood_blade_64x64.png"

const CHARACTER_PALETTE := [
	Color("090b10"),
	Color("171a1f"),
	Color("2b3036"),
	Color("3d2b21"),
	Color("6f4329"),
	Color("a96e42"),
	Color("d99b63"),
	Color("f0c38b"),
	Color("f5d09a"),
	Color("1d2b22"),
	Color("263a2b"),
	Color("365a3b"),
	Color("56754a"),
	Color("5b241e"),
	Color("843329"),
	Color("b84a35"),
	Color("c58a3e"),
]

const WEAPON_PALETTE := [
	Color("090b10"),
	Color("24150e"),
	Color("422516"),
	Color("6a3d20"),
	Color("8f5728"),
	Color("b97a36"),
	Color("d69a4a"),
	Color("efc16f"),
]


func _initialize() -> void:
	if not _process_character_actions():
		quit(1)
		return
	print("Processed Opaw's compact armless runtime action sheets.")
	quit(0)


func _process_character_actions() -> bool:
	for action: Dictionary in CHARACTER_ACTIONS:
		if not _process_character_action(action):
			return false
	return true


func _process_character_action(action: Dictionary) -> bool:
	var source_path := "%s/%s" % [CHARACTER_SOURCE_ROOT, action.source]
	var source := Image.load_from_file(source_path)
	if source == null or source.is_empty():
		return _fail("Unable to load Opaw %s source: %s" % [action.name, source_path])

	var clean := source.duplicate()
	_remove_chroma(clean)
	var clean_path := "%s/%s" % [CHARACTER_SOURCE_ROOT, action.clean]
	var clean_error: Error = clean.save_png(clean_path)
	if clean_error != OK:
		return _fail("Unable to save Opaw %s clean source: %s" % [action.name, error_string(clean_error)])

	var columns: int = action.columns
	var cell_size: Vector2i = action.cell_size
	var output := Image.create_empty(
		columns * cell_size.x,
		CHARACTER_DIRECTION_ROWS * cell_size.y,
		false,
		Image.FORMAT_RGBA8
	)
	output.fill(Color.TRANSPARENT)

	for row in CHARACTER_DIRECTION_ROWS:
		var reference_cell := _get_source_cell(clean, columns, CHARACTER_DIRECTION_ROWS, 0, row)
		if action.name in ["attack_body", "dash"] and _touches_source_crop_edge(reference_cell):
			return _fail("Opaw %s row %s reference touches its source crop edge." % [action.name, row])
		var reference_bounds := reference_cell.get_used_rect()
		if reference_bounds.size.x <= 0 or reference_bounds.size.y <= 0:
			return _fail("Opaw %s row %s has an empty reference frame." % [action.name, row])
		# Both axes derive from the same standing reference for this direction.
		# This keeps animation frames at one pixel scale while preventing profile
		# directions from becoming visibly smaller than front/back silhouettes.
		var sequence_scale := Vector2(
			float(CHARACTER_STANDING_WIDTH) / float(reference_bounds.size.x),
			float(CHARACTER_STANDING_HEIGHT) / float(reference_bounds.size.y)
		)
		for column in columns:
			var cell := _get_source_cell(clean, columns, CHARACTER_DIRECTION_ROWS, column, row)
			if action.name in ["attack_body", "dash"] and _touches_source_crop_edge(cell):
				return _fail("Opaw %s frame %s,%s touches its source crop edge." % [action.name, column, row])
			var normalized := _normalize_character_cell_at_scale(cell, sequence_scale, cell_size)
			if normalized == null or normalized.is_empty():
				return _fail("Opaw %s source frame %s,%s is empty." % [action.name, column, row])
			var origin := Vector2i(column * cell_size.x, row * cell_size.y)
			var destination := origin + Vector2i(
				int((cell_size.x - normalized.get_width()) / 2.0),
				cell_size.y - normalized.get_height()
			)
			output.blit_rect(
				normalized,
				Rect2i(Vector2i.ZERO, normalized.get_size()),
				destination
			)

	var output_path := "%s/%s" % [CHARACTER_OUTPUT_ROOT, action.output]
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_path.get_base_dir()))
	var output_error := output.save_png(output_path)
	if output_error != OK:
		return _fail("Unable to save Opaw %s runtime sheet: %s" % [action.name, error_string(output_error)])
	return true


func _get_source_cell(image: Image, columns: int, rows: int, column: int, row: int) -> Image:
	# Image-generation sources do not always use dimensions evenly divisible by
	# the requested grid, and a pose may cross an ideal boundary by a few pixels.
	# Expand around the ideal cell, then retain the connected actor nearest that
	# cell instead of trimming valid head/weapon-side pixels with a fixed inset.
	var left := roundi(float(column) * image.get_width() / float(columns))
	var right := roundi(float(column + 1) * image.get_width() / float(columns))
	var top := roundi(float(row) * image.get_height() / float(rows))
	var bottom := roundi(float(row + 1) * image.get_height() / float(rows))
	var cell_size := Vector2i(right - left, bottom - top)
	var expansion := Vector2i(
		maxi(2, roundi(cell_size.x * SOURCE_CELL_EXPANSION_RATIO)),
		maxi(2, roundi(cell_size.y * SOURCE_CELL_EXPANSION_RATIO))
	)
	var expanded_position := Vector2i(
		maxi(0, left - expansion.x),
		maxi(0, top - expansion.y)
	)
	var expanded_end := Vector2i(
		mini(image.get_width(), right + expansion.x),
		mini(image.get_height(), bottom + expansion.y)
	)
	var expanded := image.get_region(Rect2i(expanded_position, expanded_end - expanded_position))
	var expected_center := Vector2(
		(left + right) * 0.5 - expanded_position.x,
		(top + bottom) * 0.5 - expanded_position.y
	)
	return _isolate_actor_components(expanded, expected_center)


func _touches_source_crop_edge(cell: Image) -> bool:
	var bounds := cell.get_used_rect()
	if bounds.size == Vector2i.ZERO:
		return false
	return (
		bounds.position.x <= 0
		or bounds.position.y <= 0
		or bounds.end.x >= cell.get_width()
		or bounds.end.y >= cell.get_height()
	)


func _isolate_actor_components(image: Image, expected_center: Vector2) -> Image:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var components: Array[Dictionary] = []

	for y in height:
		for x in width:
			var start_index := y * width + x
			if visited[start_index] != 0 or image.get_pixel(x, y).a < 0.5:
				continue
			var queue: Array[Vector2i] = [Vector2i(x, y)]
			var pixels: Array[Vector2i] = []
			var queue_index := 0
			var minimum := Vector2i(x, y)
			var maximum := Vector2i(x, y)
			visited[start_index] = 1
			while queue_index < queue.size():
				var point: Vector2i = queue[queue_index]
				queue_index += 1
				pixels.append(point)
				minimum.x = mini(minimum.x, point.x)
				minimum.y = mini(minimum.y, point.y)
				maximum.x = maxi(maximum.x, point.x)
				maximum.y = maxi(maximum.y, point.y)
				for offset: Vector2i in COMPONENT_NEIGHBORS:
					var neighbor := point + offset
					if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= width or neighbor.y >= height:
						continue
					var neighbor_index := neighbor.y * width + neighbor.x
					if visited[neighbor_index] != 0:
						continue
					visited[neighbor_index] = 1
					if image.get_pixelv(neighbor).a >= 0.5:
						queue.append(neighbor)
			var bounds := Rect2i(minimum, maximum - minimum + Vector2i.ONE)
			components.append({
				"pixels": pixels,
				"bounds": bounds,
				"center": Vector2(bounds.get_center()),
				"count": pixels.size(),
			})

	if components.is_empty():
		return image

	var primary_index := 0
	var primary_score := -INF
	for component_index in components.size():
		var component: Dictionary = components[component_index]
		var center_distance_squared := (component.center as Vector2).distance_squared_to(expected_center)
		var score: float = float(component.count) - center_distance_squared * 0.1
		if score > primary_score:
			primary_score = score
			primary_index = component_index

	var isolated := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	isolated.fill(Color.TRANSPARENT)
	var primary_bounds: Rect2i = components[primary_index].bounds
	var join_distance := maxi(4, roundi(mini(width, height) * COMPONENT_JOIN_RATIO))
	var join_area := primary_bounds.grow(join_distance)
	for component_index in components.size():
		var component: Dictionary = components[component_index]
		if component_index != primary_index and not join_area.intersects(component.bounds):
			continue
		for point: Vector2i in component.pixels:
			isolated.set_pixelv(point, image.get_pixelv(point))
	return isolated


func _normalize_character_cell_at_scale(cell: Image, scale: Vector2, cell_size: Vector2i) -> Image:
	var used_rect := cell.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return null
	var content := cell.get_region(used_rect)
	var target_size := Vector2i(
		maxi(1, roundi(content.get_width() * scale.x)),
		maxi(1, roundi(content.get_height() * scale.y))
	)
	var content_limit := cell_size - Vector2i(CHARACTER_CELL_PADDING, 0)
	if target_size.x > content_limit.x or target_size.y > content_limit.y:
		var fit_scale := minf(
			float(content_limit.x) / float(target_size.x),
			float(content_limit.y) / float(target_size.y)
		)
		target_size = Vector2i(
			maxi(1, roundi(target_size.x * fit_scale)),
			maxi(1, roundi(target_size.y * fit_scale))
		)
	content.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)
	_quantize(content, CHARACTER_PALETTE)
	return content


func _process_weapon() -> bool:
	var source := Image.load_from_file(WEAPON_SOURCE_PATH)
	if source == null or source.is_empty():
		return _fail("Unable to load Ashwood Blade source: %s" % WEAPON_SOURCE_PATH)
	var clean := source.duplicate()
	_remove_chroma(clean)
	var used_rect: Rect2i = clean.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		return _fail("Ashwood Blade source contains no opaque weapon pixels.")
	var clean_error: Error = clean.save_png(WEAPON_CLEAN_PATH)
	if clean_error != OK:
		return _fail("Unable to save Ashwood Blade clean source: %s" % error_string(clean_error))
	var cropped: Image = clean.get_region(used_rect)
	if not _save_weapon_variant(cropped, Vector2i(16, 24), Vector2i(14, 22), WEAPON_WORLD_PATH):
		return false
	if not _save_weapon_variant(cropped, Vector2i(64, 64), Vector2i(38, 56), WEAPON_ICON_PATH):
		return false
	return true


func _save_weapon_variant(source: Image, canvas_size: Vector2i, content_limit: Vector2i, path: String) -> bool:
	var content := source.duplicate()
	var scale := minf(
		float(content_limit.x) / float(content.get_width()),
		float(content_limit.y) / float(content.get_height())
	)
	var target_size := Vector2i(
		maxi(1, roundi(content.get_width() * scale)),
		maxi(1, roundi(content.get_height() * scale))
	)
	content.resize(target_size.x, target_size.y, Image.INTERPOLATE_NEAREST)
	_quantize(content, WEAPON_PALETTE)
	var output := Image.create_empty(canvas_size.x, canvas_size.y, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	var destination := Vector2i(
		int((canvas_size.x - target_size.x) / 2.0),
		int((canvas_size.y - target_size.y) / 2.0)
	)
	output.blit_rect(content, Rect2i(Vector2i.ZERO, target_size), destination)
	var output_error := output.save_png(path)
	if output_error != OK:
		return _fail("Unable to save weapon variant %s: %s" % [path, error_string(output_error)])
	return true


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
	return (
		color.r > 0.7
		and color.g < 0.42
		and color.b > 0.68
		and color.r + color.b > color.g * 2.8
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
				var delta := Vector3(
					color.r - candidate.r,
					color.g - candidate.g,
					color.b - candidate.b
				)
				var distance := delta.length_squared()
				if distance < closest_distance:
					closest = candidate
					closest_distance = distance
			closest.a = 1.0
			image.set_pixel(x, y, closest)


func _fail(message: String) -> bool:
	push_error(message)
	return false
