class_name SanctuaryGround
extends TileMapLayer

## Paints the compact hub from dedicated Sanctuary grass and sixteen reusable
## cardinal path transitions. Layout remains authored; tile selection is derived.

@export var map_size := Vector2i(18, 12)


func _ready() -> void:
	if tile_set == null or not get_used_cells().is_empty():
		return
	var path_cells := _build_path_cells()
	var random := RandomNumberGenerator.new()
	random.seed = 20260714
	for y in range(map_size.y):
		for x in range(map_size.x):
			var cell := Vector2i(x, y)
			if path_cells.has(cell):
				set_cell(cell, 0, _path_atlas_coordinate(cell, path_cells))
				continue
			var roll := random.randi_range(0, 23)
			var atlas_coordinate := Vector2i.ZERO
			if roll == 0:
				atlas_coordinate = Vector2i(1, 0)
			elif roll == 1:
				atlas_coordinate = Vector2i(2, 0)
			elif roll == 2:
				atlas_coordinate = Vector2i(3, 0)
			set_cell(cell, 0, atlas_coordinate)


func _build_path_cells() -> Dictionary:
	var cells := {}
	# The even-width hub centers its landmarks between columns 8 and 9. Keep
	# both columns paved so the portal, fountain, and south entrance share one
	# visually centered avenue instead of leaning one tile to the right.
	for y in range(4, map_size.y):
		cells[Vector2i(8, y)] = true
		cells[Vector2i(9, y)] = true

	# One restrained east-west lane connects the service areas without turning
	# the whole middle of the garden into pavement.
	for x in range(3, 15):
		cells[Vector2i(x, 7)] = true

	# Compact aprons frame the portal stairs and fountain without replacing the
	# garden with a large paved block. The one-cell service approaches align to
	# their door centers; the east bay grounds Orren's cart.
	for cell in [
		Vector2i(7, 4), Vector2i(10, 4),
		Vector2i(7, 6), Vector2i(8, 6), Vector2i(9, 6), Vector2i(10, 6),
		Vector2i(3, 5), Vector2i(3, 6), Vector2i(3, 7),
		Vector2i(14, 5), Vector2i(14, 6), Vector2i(14, 7),
		Vector2i(12, 8), Vector2i(13, 8),
	]:
		cells[cell] = true
	return cells


func _path_atlas_coordinate(cell: Vector2i, path_cells: Dictionary) -> Vector2i:
	var mask := 0
	if path_cells.has(cell + Vector2i.UP):
		mask |= 1
	if path_cells.has(cell + Vector2i.RIGHT):
		mask |= 2
	if path_cells.has(cell + Vector2i.DOWN):
		mask |= 4
	if path_cells.has(cell + Vector2i.LEFT):
		mask |= 8
	return Vector2i(mask % 4, 1 + mask / 4)
