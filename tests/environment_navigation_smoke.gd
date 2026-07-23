extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	arena.get_node("GameplayServices/EncounterController").auto_start = false
	root.add_child(arena)
	var player = arena.get_node("World/Actors/Player")
	var ground = arena.get_node("World/Level/Ground")
	var actors = arena.get_node("World/Actors")
	var navigation_region = arena.get_node("World/NavigationRegion2D")

	player.set_physics_process(false)
	for frame in range(2):
		await physics_frame

	if ground.get_used_cells().size() != 540:
		_fail("Authored Stage 1 TileMapLayer did not populate the expected 540 cells.")
		return
	if ground.layout == null or ground.layout.resource_path != "res://data/environment/layouts/stage_1_forest_ground.tres":
		_fail("Stage 1 is not using its authored forest ground layout resource.")
		return
	if ground.tile_set.resource_path != "res://assets/environment/forest/shared/tiles/verdant_forest_ground_tileset.tres":
		_fail("Stage 1 is not using the organized shared-forest TileSet.")
		return
	if not actors.y_sort_enabled:
		_fail("Actors and environment props are not under a Y-sorted owner.")
		return
	if arena.has_node("World/Actors/TrainingTarget"):
		_fail("Training target is still present in the playable level.")
		return

	var navigation_map: RID = navigation_region.get_world_2d().get_navigation_map()
	var path := PackedVector2Array()
	for attempt in range(30):
		path = NavigationServer2D.map_get_path(
			navigation_map,
			Vector2(390.0, 660.0),
			Vector2(390.0, 1010.0),
			true,
			1
		)
		if not path.is_empty():
			break
		await physics_frame
	if path.size() < 3:
		_fail("Navigation path did not route around the authored southwest tree cutout.")
		return
	var tree_cutout := Rect2(352.0, 787.0, 77.0, 30.0)
	var closest_lateral_clearance := INF
	for point in path:
		if tree_cutout.has_point(point):
			_fail("Navigation path entered the tree cutout at %s." % point)
			return
		if point.y >= 775.0 and point.y <= 835.0:
			closest_lateral_clearance = minf(closest_lateral_clearance, absf(point.x - 390.0))
	if closest_lateral_clearance < 28.0 or closest_lateral_clearance > 40.0:
		_fail("Tree route does not match the authored multi-shape footprint; received %s px." % closest_lateral_clearance)
		return

	if not arena.has_node("World/Actors/WestGateShrine") or not arena.has_node("World/Actors/EastGateShrine"):
		_fail("Stage 1's paired shrine-gate landmarks are missing.")
		return
	if arena.has_node("World/Actors/RuinedStatueNorth"):
		_fail("Stage 1 still contains the old arbitrarily placed north statue.")
		return

	print("Environment/navigation smoke test passed. Authored path points: %d, tree clearance: %.1f px" % [path.size(), closest_lateral_clearance])
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
