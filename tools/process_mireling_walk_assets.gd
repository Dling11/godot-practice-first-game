extends SceneTree

const SOURCE := "res://art_source/generated/characters/enemies/mireling/final/mireling_walk_board_source_v2.png"
const CLEAN_SOURCE := "res://art_source/generated/characters/enemies/mireling/final/mireling_walk_board_clean_v2.png"
const OUTPUT := "res://assets/characters/enemies/mireling/mireling_walk_sheet_32x32.png"
const CELL_SIZE := Vector2i(32, 32)
const TARGET_HEIGHT := 18
const FOOT_BASELINE := 28


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE)
	if source == null or source.is_empty():
		push_error("Unable to load Mireling walk source.")
		quit(1)
		return
	source.convert(Image.FORMAT_RGBA8)
	_remove_chroma_key(source)
	if source.save_png(CLEAN_SOURCE) != OK:
		push_error("Unable to save cleaned Mireling walk source.")
		quit(1)
		return
	var output := Image.create_empty(CELL_SIZE.x * 4, CELL_SIZE.y * 4, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	for row in 4:
		var actors: Array[Image] = []
		for column in 4:
			var actor := _extract_actor(source, _source_cell_rect(source, column, row))
			if actor == null:
				quit(1)
				return
			actors.append(actor)
		var reference_height := actors[0].get_height()
		var scale_factor := float(TARGET_HEIGHT) / float(reference_height)
		for column in 4:
			_place_actor(output, actors[column], column, row, scale_factor)
	_mirror_row(output, 1, 2)
	if output.save_png(OUTPUT) != OK:
		push_error("Unable to save Mireling walk runtime sheet.")
		quit(1)
		return
	print("Processed Mireling directional walk sheet: %s" % OUTPUT)
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
	var left := roundi(float(column) * source.get_width() / 4.0)
	var right := roundi(float(column + 1) * source.get_width() / 4.0)
	var top := roundi(float(row) * source.get_height() / 4.0)
	var bottom := roundi(float(row + 1) * source.get_height() / 4.0)
	return Rect2i(left, top, right - left, bottom - top)


func _extract_actor(source: Image, rect: Rect2i) -> Image:
	var cell := source.get_region(rect)
	var used_rect := cell.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		push_error("Mireling walk source contains an empty cell.")
		return null
	return cell.get_region(used_rect)


func _place_actor(
	output: Image,
	actor_source: Image,
	column: int,
	row: int,
	scale_factor: float
) -> void:
	var actor := actor_source.duplicate()
	actor.resize(
		maxi(1, roundi(actor.get_width() * scale_factor)),
		maxi(1, roundi(actor.get_height() * scale_factor)),
		Image.INTERPOLATE_NEAREST
	)
	var destination := Vector2i(
		column * CELL_SIZE.x + roundi((CELL_SIZE.x - actor.get_width()) * 0.5),
		row * CELL_SIZE.y + FOOT_BASELINE - actor.get_height()
	)
	output.blend_rect(actor, Rect2i(Vector2i.ZERO, actor.get_size()), destination)


func _mirror_row(image: Image, source_row: int, destination_row: int) -> void:
	for column in 4:
		var source_rect := Rect2i(Vector2i(column * CELL_SIZE.x, source_row * CELL_SIZE.y), CELL_SIZE)
		var frame := image.get_region(source_rect)
		frame.flip_x()
		image.blit_rect(frame, Rect2i(Vector2i.ZERO, CELL_SIZE), Vector2i(column * CELL_SIZE.x, destination_row * CELL_SIZE.y))
