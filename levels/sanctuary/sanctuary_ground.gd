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
	for y in range(4, map_size.y):
		cells[Vector2i(9, y)] = true
	for x in range(3, 15):
		cells[Vector2i(x, 7)] = true
	for cell in [
		Vector2i(7, 4), Vector2i(8, 4), Vector2i(9, 4), Vector2i(10, 4),
		Vector2i(7, 5), Vector2i(8, 5), Vector2i(9, 5), Vector2i(10, 5),
		Vector2i(8, 6), Vector2i(9, 6), Vector2i(10, 6),
		Vector2i(3, 5), Vector2i(3, 6), Vector2i(3, 7),
		Vector2i(14, 5), Vector2i(14, 6), Vector2i(14, 7),
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
