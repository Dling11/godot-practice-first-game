extends SceneTree

const SOURCE := "res://art_source/generated/characters/enemies/mireling/final/mireling_action_board_source_v2.png"
const CLEAN_SOURCE := "res://art_source/generated/characters/enemies/mireling/final/mireling_action_board_clean_v2.png"
const OUTPUT := "res://assets/characters/enemies/mireling/mireling_action_sheet_48x32.png"
const CELL_SIZE := Vector2i(48, 32)
const SOURCE_COLUMNS := 8
const SOURCE_ROWS := 4
const TARGET_HEIGHT := 18
const FOOT_BASELINE := 28


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE)
	if source == null or source.is_empty():
		push_error("Unable to load Mireling action source.")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	_remove_chroma_key(source)
	if source.save_png(CLEAN_SOURCE) != OK:
		push_error("Unable to save cleaned Mireling action source.")
		quit(1)
		return
	var output := Image.create_empty(CELL_SIZE.x * SOURCE_COLUMNS, CELL_SIZE.y * SOURCE_ROWS, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	for row in SOURCE_ROWS:
		var actors: Array[Image] = []
		for column in SOURCE_COLUMNS:
			var actor := _extract_actor(source, _source_cell_rect(source, column, row))
			if actor == null:
				quit(1)
				return
			actors.append(actor)
		var scale_factor := _row_scale(actors)
		for column in SOURCE_COLUMNS:
			if not _place_actor(output, actors[column], column, row, scale_factor):
				quit(1)
				return
	_mirror_row(output, 1, 2)
	if output.save_png(OUTPUT) != OK:
		push_error("Unable to save Mireling action runtime sheet.")
		quit(1)
		return
	print("Processed Mireling directional action sheet: %s" % OUTPUT)
	quit(0)


func _remove_chroma_key(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel.r > 0.72 and pixel.g < 0.42 and pixel.b > 0.72:
				image.set_pixel(x, y, Color.TRANSPARENT)
			else:
				pixel.a = 1.0
				image.set_pixel(x, y, pixel)


func _source_cell_rect(source: Image, column: int, row: int) -> Rect2i:
	var left := roundi(float(column) * source.get_width() / float(SOURCE_COLUMNS))
	var right := roundi(float(column + 1) * source.get_width() / float(SOURCE_COLUMNS))
	var top := roundi(float(row) * source.get_height() / float(SOURCE_ROWS))
	var bottom := roundi(float(row + 1) * source.get_height() / float(SOURCE_ROWS))
	return Rect2i(left, top, right - left, bottom - top)


func _extract_actor(source: Image, rect: Rect2i) -> Image:
	var cell := _isolate_largest_component(source.get_region(rect))
	var used_rect := cell.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		push_error("Mireling action source contains an empty cell.")
		return null
	return cell.get_region(used_rect)


func _isolate_largest_component(image: Image) -> Image:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	visited.fill(0)
	var largest: Array[Vector2i] = []
	for y in height:
		for x in width:
			var start := Vector2i(x, y)
			var start_index := y * width + x
			if visited[start_index] == 1 or image.get_pixelv(start).a < 0.5:
				continue
			var pending: Array[Vector2i] = [start]
			var component: Array[Vector2i] = []
			visited[start_index] = 1
			while not pending.is_empty():
				var point: Vector2i = pending.pop_back()
				component.append(point)
				for offset_y in range(-1, 2):
					for offset_x in range(-1, 2):
						if offset_x == 0 and offset_y == 0:
							continue
						var neighbor := point + Vector2i(offset_x, offset_y)
						if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= width or neighbor.y >= height:
							continue
						var neighbor_index := neighbor.y * width + neighbor.x
						if visited[neighbor_index] == 1 or image.get_pixelv(neighbor).a < 0.5:
							continue
						visited[neighbor_index] = 1
						pending.append(neighbor)
			if component.size() > largest.size():
				largest = component
	var isolated := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	isolated.fill(Color.TRANSPARENT)
	for point in largest:
		isolated.set_pixelv(point, image.get_pixelv(point))
	return isolated


func _row_scale(actors: Array[Image]) -> float:
	return float(TARGET_HEIGHT) / float(actors[0].get_height())


func _place_actor(output: Image, actor_source: Image, column: int, row: int, scale_factor: float) -> bool:
	var actor := actor_source.duplicate()
	actor.resize(
		maxi(1, roundi(actor.get_width() * scale_factor)),
		maxi(1, roundi(actor.get_height() * scale_factor)),
		Image.INTERPOLATE_NEAREST
	)
	if actor.get_width() > CELL_SIZE.x - 2 or actor.get_height() > CELL_SIZE.y - 2:
		push_error("Mireling action frame exceeds its 48x32 runtime cell.")
		return false
	var destination := Vector2i(
		column * CELL_SIZE.x + roundi((CELL_SIZE.x - actor.get_width()) * 0.5),
		row * CELL_SIZE.y + FOOT_BASELINE - actor.get_height()
	)
	output.blend_rect(actor, Rect2i(Vector2i.ZERO, actor.get_size()), destination)
	return true


func _mirror_row(image: Image, source_row: int, destination_row: int) -> void:
	for column in SOURCE_COLUMNS:
		var source_rect := Rect2i(Vector2i(column * CELL_SIZE.x, source_row * CELL_SIZE.y), CELL_SIZE)
		var frame := image.get_region(source_rect)
		frame.flip_x()
		image.blit_rect(frame, Rect2i(Vector2i.ZERO, CELL_SIZE), Vector2i(column * CELL_SIZE.x, destination_row * CELL_SIZE.y))
