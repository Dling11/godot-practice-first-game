extends SceneTree

## Converts the approved generated Sanctuary direction board into hard-pixel runtime
## assets. Crop rectangles are source-space contracts; runtime scenes never load the
## generated board directly.

const SOURCE_PATH := "res://art_source/generated/environment/sanctuary/sanctuary_direction_board_source.png"
const CLEAR := Color(0, 0, 0, 0)
const VOID_INK := Color("090b10")
const TILE_SIZE := 64

const PROP_CROPS := {
	"res://assets/environment/sanctuary/landmarks/angel_portal_fountain_256x240.png": {
		"rect": Rect2i(438, 8, 506, 470),
		"canvas": Vector2i(256, 240),
		"scale": 0.5,
		"keep_largest": true,
		"global_key": true,
	},
	"res://assets/environment/sanctuary/buildings/mushroom_dwelling_128x192.png": {
		"rect": Rect2i(944, 8, 248, 382),
		"canvas": Vector2i(128, 192),
		"scale": 0.5,
	},
	"res://assets/environment/sanctuary/buildings/merchant_hall_176x192.png": {
		"rect": Rect2i(1200, 6, 332, 384),
		"canvas": Vector2i(176, 192),
		"scale": 0.49,
	},
	"res://assets/environment/sanctuary/shops/weapon_stall_128x96.png": {
		"rect": Rect2i(1072, 394, 218, 174),
		"canvas": Vector2i(128, 96),
		"scale": 0.52,
	},
	"res://assets/environment/sanctuary/props/sanctuary_tree_broad_96x120.png": {
		"rect": Rect2i(1168, 776, 130, 160),
		"canvas": Vector2i(96, 120),
		"scale": 0.72,
		"keep_largest": true,
	},
	"res://assets/environment/sanctuary/props/sanctuary_tree_tall_96x120.png": {
		"rect": Rect2i(1292, 776, 138, 164),
		"canvas": Vector2i(96, 120),
		"scale": 0.68,
		"keep_largest": true,
	},
}

const CHARACTER_CROPS := {
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x80.png": {
		# Preserve source-space air around the staff and book. The old crop began
		# and ended on live silhouette pixels, so its hard outline clipped both.
		"rect": Rect2i(962, 410, 100, 164),
		"cell": Vector2i(48, 80),
		"scale": 0.46,
		"pulse": "violet",
	},
	"res://assets/characters/npcs/weapon_merchant/weapon_merchant_idle_sheet_48x72.png": {
		# Orren's left shoulder/hand begins just outside the former x=1288 crop.
		# End at x=1329 to retain his right arm plus outline while excluding the
		# first disconnected pixels of the nearby stall lantern.
		"rect": Rect2i(1284, 432, 45, 136),
		"cell": Vector2i(48, 72),
		"scale": 0.46,
		"keep_largest": true,
		"pulse": "gold",
	},
}


func _initialize() -> void:
	var source := Image.new()
	var source_error := source.load(ProjectSettings.globalize_path(SOURCE_PATH))
	if source_error != OK:
		push_error("Could not load Sanctuary direction board (error %d)." % source_error)
		quit(1)
		return
	if source.get_size() != Vector2i(1536, 1024):
		push_error("Sanctuary direction board changed size; crop contracts require review.")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)

	for output_path: String in PROP_CROPS:
		var spec: Dictionary = PROP_CROPS[output_path]
		var sprite := _extract_sprite(
			source,
			spec.rect as Rect2i,
			spec.canvas as Vector2i,
			float(spec.scale),
			bool(spec.get("keep_largest", false)),
			bool(spec.get("global_key", false))
		)
		if not _save(sprite, output_path):
			return

	for output_path: String in CHARACTER_CROPS:
		var spec: Dictionary = CHARACTER_CROPS[output_path]
		var base := _extract_sprite(
			source,
			spec.rect as Rect2i,
			spec.cell as Vector2i,
			float(spec.scale),
			bool(spec.get("keep_largest", false)),
			bool(spec.get("global_key", false))
		)
		var sheet := _build_idle_sheet(base, String(spec.pulse))
		if not _save(sheet, output_path):
			return

	var tile_atlas := _build_ground_atlas()
	if not _save(tile_atlas, "res://assets/environment/sanctuary/tiles/sanctuary_ground_atlas_64x64.png"):
		return
	print("Processed Sanctuary direction board into %d runtime assets." % (PROP_CROPS.size() + CHARACTER_CROPS.size() + 1))
	quit(0)


func _extract_sprite(
	source: Image,
	crop_rect: Rect2i,
	canvas_size: Vector2i,
	scale: float,
	keep_largest: bool,
	global_key: bool
) -> Image:
	var crop := source.get_region(crop_rect)
	_clear_connected_background(crop)
	if global_key:
		_clear_keyed_background(crop)
	if keep_largest:
		_keep_largest_component(crop)
	_add_hard_outline(crop)
	var used_rect := _alpha_used_rect(crop)
	if used_rect.size == Vector2i.ZERO:
		return _new_image(canvas_size.x, canvas_size.y)
	var trimmed := crop.get_region(used_rect)
	var scaled_size := Vector2i(
		maxi(1, roundi(trimmed.get_width() * scale)),
		maxi(1, roundi(trimmed.get_height() * scale))
	)
	var fit_scale := minf(
		float(canvas_size.x - 2) / float(scaled_size.x),
		float(canvas_size.y - 2) / float(scaled_size.y)
	)
	if fit_scale < 1.0:
		scaled_size = Vector2i(
			maxi(1, floori(scaled_size.x * fit_scale)),
			maxi(1, floori(scaled_size.y * fit_scale))
		)
	trimmed.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_NEAREST)
	var canvas := _new_image(canvas_size.x, canvas_size.y)
	var destination := Vector2i((canvas_size.x - scaled_size.x) / 2, canvas_size.y - scaled_size.y)
	canvas.blit_rect(trimmed, Rect2i(Vector2i.ZERO, scaled_size), destination)
	return canvas


func _clear_connected_background(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var background_seeds: Array[Color] = [
		image.get_pixel(0, 0),
		image.get_pixel(width - 1, 0),
		image.get_pixel(0, height - 1),
		image.get_pixel(width - 1, height - 1),
	]
	var visited := PackedByteArray()
	visited.resize(width * height)
	var stack: Array[Vector2i] = []
	for x in range(width):
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, height - 1))
	for y in range(1, height - 1):
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(width - 1, y))
	while not stack.is_empty():
		var point: Vector2i = stack.pop_back()
		var index: int = point.y * width + point.x
		if visited[index] == 1:
			continue
		visited[index] = 1
		if not _matches_crop_background(image.get_pixelv(point), background_seeds):
			continue
		image.set_pixelv(point, CLEAR)
		if point.x > 0:
			stack.append(point + Vector2i.LEFT)
		if point.x + 1 < width:
			stack.append(point + Vector2i.RIGHT)
		if point.y > 0:
			stack.append(point + Vector2i.UP)
		if point.y + 1 < height:
			stack.append(point + Vector2i.DOWN)


func _matches_crop_background(color: Color, background_seeds: Array[Color]) -> bool:
	for seed: Color in background_seeds:
		var red_difference := color.r - seed.r
		var green_difference := color.g - seed.g
		var blue_difference := color.b - seed.b
		var distance_squared := (
			red_difference * red_difference
			+ green_difference * green_difference
			+ blue_difference * blue_difference
		)
		if distance_squared <= 0.0009:
			return true
	return false


func _is_board_background(color: Color) -> bool:
	return color.r < 0.13 and color.g < 0.12 and color.b < 0.18 and color.get_luminance() < 0.09


func _clear_keyed_background(image: Image) -> void:
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if _is_board_background(image.get_pixel(x, y)):
				image.set_pixel(x, y, CLEAR)


func _keep_largest_component(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var largest_component: Array[Vector2i] = []
	for y in range(height):
		for x in range(width):
			var start_index := y * width + x
			if visited[start_index] == 1 or image.get_pixel(x, y).a <= 0.5:
				continue
			var component: Array[Vector2i] = []
			var stack: Array[Vector2i] = [Vector2i(x, y)]
			while not stack.is_empty():
				var point: Vector2i = stack.pop_back()
				var index := point.y * width + point.x
				if visited[index] == 1:
					continue
				visited[index] = 1
				if image.get_pixelv(point).a <= 0.5:
					continue
				component.append(point)
				for offset in [
					Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
					Vector2i(-1, 0), Vector2i(1, 0),
					Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
				]:
					var neighbor: Vector2i = point + offset
					if neighbor.x >= 0 and neighbor.y >= 0 and neighbor.x < width and neighbor.y < height:
						stack.append(neighbor)
			if component.size() > largest_component.size():
				largest_component = component
	var keep := PackedByteArray()
	keep.resize(width * height)
	for point: Vector2i in largest_component:
		keep[point.y * width + point.x] = 1
	for y in range(height):
		for x in range(width):
			if image.get_pixel(x, y).a > 0.5 and keep[y * width + x] == 0:
				image.set_pixel(x, y, CLEAR)


func _add_hard_outline(image: Image) -> void:
	var source := image.duplicate()
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if source.get_pixel(x, y).a > 0.5:
				image.set_pixel(x, y, _opaque(source.get_pixel(x, y)))
				continue
			var touches_sprite := false
			for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor: Vector2i = Vector2i(x, y) + offset
				if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= image.get_width() or neighbor.y >= image.get_height():
					continue
				if source.get_pixelv(neighbor).a > 0.5:
					touches_sprite = true
					break
			if touches_sprite:
				image.set_pixel(x, y, VOID_INK)


func _alpha_used_rect(image: Image) -> Rect2i:
	var minimum := Vector2i(image.get_width(), image.get_height())
	var maximum := Vector2i(-1, -1)
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			if image.get_pixel(x, y).a <= 0.5:
				continue
			minimum.x = mini(minimum.x, x)
			minimum.y = mini(minimum.y, y)
			maximum.x = maxi(maximum.x, x)
			maximum.y = maxi(maximum.y, y)
	if maximum.x < minimum.x:
		return Rect2i()
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)


func _build_idle_sheet(base: Image, pulse_kind: String) -> Image:
	var sheet := _new_image(base.get_width() * 4, base.get_height())
	var pulse_strengths := [0.88, 1.0, 1.12, 1.0]
	for frame in range(4):
		var frame_image := base.duplicate()
		for y in range(frame_image.get_height()):
			for x in range(frame_image.get_width()):
				var color: Color = frame_image.get_pixel(x, y)
				if color.a < 0.5 or not _is_pulse_color(color, pulse_kind):
					continue
				var strength: float = pulse_strengths[frame]
				color.r = clampf(color.r * strength, 0.0, 1.0)
				color.g = clampf(color.g * strength, 0.0, 1.0)
				color.b = clampf(color.b * strength, 0.0, 1.0)
				frame_image.set_pixel(x, y, _opaque(color))
		sheet.blit_rect(
			frame_image,
			Rect2i(Vector2i.ZERO, frame_image.get_size()),
			Vector2i(frame * base.get_width(), 0)
		)
	return sheet


func _is_pulse_color(color: Color, pulse_kind: String) -> bool:
	if pulse_kind == "violet":
		return color.b > color.g * 1.12 and color.r > color.g * 0.92 and color.b > 0.28
	return color.r > 0.45 and color.g > 0.28 and color.r > color.b * 1.2


func _build_ground_atlas() -> Image:
	var grass_tiles: Array[Image] = []
	for variant in range(4):
		grass_tiles.append(_build_grass_tile(variant))
	var cobble := _build_cobble_pattern()
	var atlas := _new_image(TILE_SIZE * 4, TILE_SIZE * 5)
	for variant in range(4):
		atlas.blit_rect(
			grass_tiles[variant],
			Rect2i(0, 0, TILE_SIZE, TILE_SIZE),
			Vector2i(variant * TILE_SIZE, 0)
		)
	for mask in range(16):
		var tile := _build_path_tile(grass_tiles[0], cobble, mask)
		var atlas_position := Vector2i(mask % 4, 1 + mask / 4) * TILE_SIZE
		atlas.blit_rect(tile, Rect2i(0, 0, TILE_SIZE, TILE_SIZE), atlas_position)
	return atlas


func _build_grass_tile(variant: int) -> Image:
	var tile := _new_image(TILE_SIZE, TILE_SIZE)
	tile.fill(Color("557f3b"))
	var random := RandomNumberGenerator.new()
	random.seed = 20260714 + variant * 101
	var tuft_colors := [Color("426b35"), Color("67934a"), Color("739c50"), Color("365a3b")]
	for tuft in range(74):
		var position := Vector2i(random.randi_range(2, 61), random.randi_range(2, 61))
		var color: Color = tuft_colors[random.randi_range(0, tuft_colors.size() - 1)]
		tile.set_pixelv(position, color)
		if tuft % 3 == 0:
			tile.set_pixelv(position + Vector2i(1, -1), color)
	if variant == 1:
		_add_flower_clusters(tile, Color("d6c171"), 4, random)
	elif variant == 2:
		_add_flower_clusters(tile, Color("9a72bd"), 5, random)
	elif variant == 3:
		_add_flower_clusters(tile, Color("d9ddce"), 3, random)
	return tile


func _add_flower_clusters(tile: Image, color: Color, count: int, random: RandomNumberGenerator) -> void:
	for cluster in range(count):
		var position := Vector2i(random.randi_range(5, 58), random.randi_range(5, 58))
		tile.set_pixelv(position, color)
		tile.set_pixelv(position + Vector2i.RIGHT, color.darkened(0.18))
		tile.set_pixelv(position + Vector2i.DOWN, Color("365a3b"))


func _build_cobble_pattern() -> Image:
	var tile := _new_image(TILE_SIZE, TILE_SIZE)
	var grout := Color("303832")
	tile.fill(grout)
	var stone_colors := [Color("777568"), Color("878476"), Color("686c62"), Color("918b78")]
	for row in range(8):
		var offset := 4 if row % 2 == 1 else 0
		for column in range(-1, 9):
			var origin := Vector2i(column * 8 + offset, row * 8)
			var stone: Color = stone_colors[posmod(row * 3 + column, stone_colors.size())]
			_fill_wrapped(tile, Rect2i(origin + Vector2i(1, 1), Vector2i(6, 6)), stone)
			_fill_wrapped(tile, Rect2i(origin + Vector2i(2, 2), Vector2i(4, 1)), stone.lightened(0.16))
			_fill_wrapped(tile, Rect2i(origin + Vector2i(2, 6), Vector2i(4, 1)), stone.darkened(0.23))
			_set_wrapped(tile, origin + Vector2i(1, 1), grout)
			_set_wrapped(tile, origin + Vector2i(6, 1), grout)
			_set_wrapped(tile, origin + Vector2i(1, 6), grout)
			_set_wrapped(tile, origin + Vector2i(6, 6), grout)
	return tile


func _build_path_tile(grass: Image, cobble: Image, neighbor_mask: int) -> Image:
	var tile := grass.duplicate()
	for y in range(TILE_SIZE):
		for x in range(TILE_SIZE):
			var inside := x >= 11 and x <= 52 and y >= 11 and y <= 52
			if neighbor_mask & 1 and x >= 11 and x <= 52 and y < 12:
				inside = true
			if neighbor_mask & 2 and x > 51 and y >= 11 and y <= 52:
				inside = true
			if neighbor_mask & 4 and x >= 11 and x <= 52 and y > 51:
				inside = true
			if neighbor_mask & 8 and x < 12 and y >= 11 and y <= 52:
				inside = true
			if neighbor_mask & 1 and neighbor_mask & 8 and x < 12 and y < 12:
				inside = true
			if neighbor_mask & 1 and neighbor_mask & 2 and x > 51 and y < 12:
				inside = true
			if neighbor_mask & 4 and neighbor_mask & 8 and x < 12 and y > 51:
				inside = true
			if neighbor_mask & 4 and neighbor_mask & 2 and x > 51 and y > 51:
				inside = true
			if inside:
				tile.set_pixel(x, y, _opaque(cobble.get_pixel(x, y)))
	return tile


func _fill_wrapped(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			_set_wrapped(image, Vector2i(x, y), color)


func _set_wrapped(image: Image, point: Vector2i, color: Color) -> void:
	image.set_pixel(posmod(point.x, image.get_width()), posmod(point.y, image.get_height()), color)


func _new_image(width: int, height: int) -> Image:
	var image := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	image.fill(CLEAR)
	return image


func _opaque(color: Color) -> Color:
	return Color(color.r, color.g, color.b, 1.0)


func _save(image: Image, path: String) -> bool:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error == OK:
		return true
	push_error("Could not save Sanctuary runtime asset %s (error %d)." % [path, error])
	quit(1)
	return false
