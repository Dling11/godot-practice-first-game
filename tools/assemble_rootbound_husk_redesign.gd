extends SceneTree

const WALK_OUTPUT := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_walk_board_source_v4.png"
const ROOT_ATTACK_OUTPUT := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_board_source_v4.png"
const COMPONENT_ROOT := "res://art_source/generated/characters/enemies/rootbound_husk/redesign_v4_components/"
const DIRECTION_BOARD := COMPONENT_ROOT + "rootbound_husk_direction_board.png"
const SIDE_WALK_STRIP := COMPONENT_ROOT + "rootbound_husk_side_walk_strip.png"
const SIDE_CONTACT_B := COMPONENT_ROOT + "rootbound_husk_side_contact_b.png"
const SIDE_PASSING_B := COMPONENT_ROOT + "rootbound_husk_side_passing_b.png"
const ROOT_ATTACK_BOARD := COMPONENT_ROOT + "rootbound_husk_root_attack_body_board.png"
const ROOT_ATTACK_DOWN_ACTIVE_STRIP := COMPONENT_ROOT + "rootbound_husk_root_attack_down_active_strip.png"
const CELL_SIZE := Vector2i(256, 256)
const TARGET_ACTOR_HEIGHT := 220
const MAXIMUM_ACTOR_WIDTH := 232
const FOOT_BASELINE := 240
const UP_ROW_OVERLAP := 80
const ROOT_ATTACK_CELL_OVERLAP := 64


func _initialize() -> void:
	var direction_board := _load_source(DIRECTION_BOARD)
	var side_walk_strip := _load_source(SIDE_WALK_STRIP)
	var side_contact_b := _load_source(SIDE_CONTACT_B)
	var side_passing_b := _load_source(SIDE_PASSING_B)
	var root_attack_board := _load_source(ROOT_ATTACK_BOARD)
	var root_attack_down_active_strip := _load_source(ROOT_ATTACK_DOWN_ACTIVE_STRIP)
	if (
		direction_board == null
		or side_walk_strip == null
		or side_contact_b == null
		or side_passing_b == null
		or root_attack_board == null
		or root_attack_down_active_strip == null
	):
		quit(1)
		return
	var output := Image.create_empty(CELL_SIZE.x * 4, CELL_SIZE.y * 4, false, Image.FORMAT_RGBA8)
	output.fill(Color(1.0, 0.0, 1.0, 1.0))
	var down_actors: Array[Image] = []
	var up_actors: Array[Image] = []
	for column in 4:
		var down_actor := _extract_actor(direction_board, _cell_rect(direction_board, column, 0, 4, 4))
		var up_actor := _extract_actor(
			direction_board,
			_cell_rect(direction_board, column, 3, 4, 4),
			UP_ROW_OVERLAP
		)
		if down_actor == null or up_actor == null:
			quit(1)
			return
		down_actors.append(down_actor)
		up_actors.append(up_actor)
	_place_actor_row(output, down_actors, 0)
	_place_actor_row(output, up_actors, 3)
	var right_actors: Array[Image] = [
		_extract_actor(side_walk_strip, _cell_rect(side_walk_strip, 0, 0, 4, 1)),
		_extract_actor(side_walk_strip, _cell_rect(side_walk_strip, 1, 0, 4, 1)),
		_extract_actor(side_contact_b, Rect2i(Vector2i.ZERO, side_contact_b.get_size())),
		_extract_actor(side_passing_b, Rect2i(Vector2i.ZERO, side_passing_b.get_size())),
	]
	for right_actor in right_actors:
		if right_actor == null:
			quit(1)
			return
	var left_actors: Array[Image] = []
	for right_actor in right_actors:
		var left_actor := right_actor.duplicate()
		left_actor.flip_x()
		left_actors.append(left_actor)
	_place_actor_row(output, left_actors, 1)
	_place_actor_row(output, right_actors, 2)
	var save_error := output.save_png(WALK_OUTPUT)
	if save_error != OK:
		push_error("Unable to save redesigned Rootbound Husk walk source.")
		quit(1)
		return
	print("Assembled redesigned Rootbound Husk walk source: %s" % WALK_OUTPUT)
	var root_attack_output := Image.create_empty(CELL_SIZE.x * 6, CELL_SIZE.y * 4, false, Image.FORMAT_RGBA8)
	root_attack_output.fill(Color(1.0, 0.0, 1.0, 1.0))
	for row in 4:
		var root_attack_actors: Array[Image] = []
		for column in 6:
			var source := root_attack_board
			var source_rect := _cell_rect(root_attack_board, column, row, 6, 4)
			var overlap := ROOT_ATTACK_CELL_OVERLAP
			if row == 0 and column >= 3 and column <= 4:
				source = root_attack_down_active_strip
				source_rect = _cell_rect(root_attack_down_active_strip, column - 3, 0, 2, 1)
				overlap = 1
			var actor := _extract_actor(
				source,
				source_rect,
				overlap
			)
			if actor == null:
				quit(1)
				return
			root_attack_actors.append(actor)
		_place_actor_row(root_attack_output, root_attack_actors, row)
	var root_attack_save_error := root_attack_output.save_png(ROOT_ATTACK_OUTPUT)
	if root_attack_save_error != OK:
		push_error("Unable to save redesigned Rootbound Husk root-attack source.")
		quit(1)
		return
	print("Assembled redesigned Rootbound Husk root-attack source: %s" % ROOT_ATTACK_OUTPUT)
	quit(0)


func _load_source(path: String) -> Image:
	var source := Image.load_from_file(path)
	if source == null or source.is_empty():
		push_error("Unable to load Rootbound Husk redesign source: %s" % path)
		return null
	return source


func _cell_rect(source: Image, column: int, row: int, columns: int, rows: int) -> Rect2i:
	var left := roundi(float(column) * source.get_width() / float(columns))
	var right := roundi(float(column + 1) * source.get_width() / float(columns))
	var top := roundi(float(row) * source.get_height() / float(rows))
	var bottom := roundi(float(row + 1) * source.get_height() / float(rows))
	return Rect2i(left, top, right - left, bottom - top)


func _extract_actor(source: Image, source_rect: Rect2i, overlap_pixels := 0) -> Image:
	var source_bounds := Rect2i(Vector2i.ZERO, source.get_size())
	var capture_rect := source_rect.grow(overlap_pixels).intersection(source_bounds)
	var actor := source.get_region(capture_rect)
	actor.convert(Image.FORMAT_RGBA8)
	for y in actor.get_height():
		for x in actor.get_width():
			var pixel := actor.get_pixel(x, y)
			if pixel.r > 0.72 and pixel.g < 0.42 and pixel.b > 0.72:
				actor.set_pixel(x, y, Color.TRANSPARENT)
			else:
				pixel.a = 1.0
				actor.set_pixel(x, y, pixel)
	if overlap_pixels > 0:
		actor = _isolate_largest_component(actor)
	var used_rect := actor.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		push_error("A Rootbound Husk redesign source cell is empty.")
		return null
	return actor.get_region(used_rect)


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


func _place_actor_row(output: Image, actors: Array[Image], row: int) -> void:
	var shared_height := TARGET_ACTOR_HEIGHT
	for actor in actors:
		shared_height = mini(
			shared_height,
			floori(float(MAXIMUM_ACTOR_WIDTH * actor.get_height()) / float(actor.get_width()))
		)
	for column in actors.size():
		_place_actor(output, actors[column], column, row, shared_height)


func _place_actor(
	output: Image,
	source_actor: Image,
	column: int,
	row: int,
	target_height: int
) -> void:
	var actor := source_actor.duplicate()
	var scale_factor := float(target_height) / float(actor.get_height())
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
