extends SceneTree

## Builds a review-only handless Opaw variant from the approved runtime sheets.
## The active sheets remain untouched. The largest connected skin region in
## each cell is the head; smaller disconnected skin regions are exposed hands
## and are recolored as closed sleeve ends without changing motion or scale.

const SOURCE_ROOT := "res://assets/characters/playable/opaw"
const OUTPUT_ROOT := "res://assets/characters/playable/opaw/variants/handless"
const ROWS := 4
const NEIGHBORS := [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]
const ACTIONS := [
	{"source": "opaw_idle_sheet_32x32.png", "output": "opaw_handless_idle_sheet_32x32.png", "columns": 2, "cell_width": 32},
	{"source": "opaw_walk_sheet_32x32.png", "output": "opaw_handless_walk_sheet_32x32.png", "columns": 4, "cell_width": 32},
	{"source": "opaw_attack_body_sheet_48x32.png", "output": "opaw_handless_attack_body_sheet_48x32.png", "columns": 3, "cell_width": 48},
	{"source": "opaw_dash_sheet_48x32.png", "output": "opaw_handless_dash_sheet_48x32.png", "columns": 3, "cell_width": 48},
	{"source": "opaw_interact_sheet_48x32.png", "output": "opaw_handless_interact_sheet_48x32.png", "columns": 2, "cell_width": 48},
	{"source": "opaw_hurt_sheet_32x32.png", "output": "opaw_handless_hurt_sheet_32x32.png", "columns": 2, "cell_width": 32},
	{"source": "opaw_defeat_sheet_64x32.png", "output": "opaw_handless_defeat_sheet_64x32.png", "columns": 4, "cell_width": 64},
]

const SKIN_COLORS := [
	Color("d99b63"),
	Color("f0c38b"),
	Color("f5d09a"),
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_ROOT))
	var removed_pixel_count := 0
	for action: Dictionary in ACTIONS:
		var image := Image.load_from_file("%s/%s" % [SOURCE_ROOT, action.source])
		if image == null or image.is_empty():
			push_error("Unable to load Opaw sheet: %s" % action.source)
			quit(1)
			return
		for row in ROWS:
			for column in int(action.columns):
				removed_pixel_count += _cover_cell_hands(
					image,
					Rect2i(column * int(action.cell_width), row * 32, int(action.cell_width), 32)
				)
		var output_path := "%s/%s" % [OUTPUT_ROOT, action.output]
		if image.save_png(output_path) != OK:
			push_error("Unable to save handless Opaw sheet: %s" % output_path)
			quit(1)
			return
	if removed_pixel_count <= 0:
		push_error("Handless Opaw build did not find any exposed-hand pixels.")
		quit(1)
		return
	print("Built handless Opaw review variant; covered %s exposed-hand pixels." % removed_pixel_count)
	quit(0)


func _cover_cell_hands(image: Image, cell: Rect2i) -> int:
	var visited := {}
	var components: Array[Array] = []
	for local_y in cell.size.y:
		for local_x in cell.size.x:
			var point := cell.position + Vector2i(local_x, local_y)
			if visited.has(point) or not _is_skin(image.get_pixelv(point)):
				continue
			var pixels: Array[Vector2i] = []
			var queue: Array[Vector2i] = [point]
			visited[point] = true
			var queue_index := 0
			while queue_index < queue.size():
				var current := queue[queue_index]
				queue_index += 1
				pixels.append(current)
				for offset: Vector2i in NEIGHBORS:
					var neighbor := current + offset
					if not cell.has_point(neighbor) or visited.has(neighbor):
						continue
					visited[neighbor] = true
					if _is_skin(image.get_pixelv(neighbor)):
						queue.append(neighbor)
			components.append(pixels)
	if components.size() <= 1:
		return 0
	components.sort_custom(func(a: Array, b: Array) -> bool: return a.size() > b.size())
	var covered := 0
	for component_index in range(1, components.size()):
		for point: Vector2i in components[component_index]:
			var source := image.get_pixelv(point)
			var sleeve := Color("56754a")
			if source.get_luminance() < 0.68:
				sleeve = Color("263a2b")
			elif source.get_luminance() < 0.82:
				sleeve = Color("365a3b")
			image.set_pixelv(point, sleeve)
			covered += 1
	return covered


func _is_skin(color: Color) -> bool:
	if color.a < 0.5:
		return false
	for candidate: Color in SKIN_COLORS:
		if Vector3(color.r - candidate.r, color.g - candidate.g, color.b - candidate.b).length_squared() < 0.002:
			return true
	return false
