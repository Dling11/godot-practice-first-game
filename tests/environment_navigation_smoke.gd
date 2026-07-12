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
		_fail("Expanded TileMapLayer did not populate the expected 540 cells.")
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
			Vector2(960.0, 120.0),
			Vector2(960.0, 880.0),
			true,
			1
		)
		if not path.is_empty():
			break
		await physics_frame
	if path.size() < 3:
		_fail("Navigation path did not route around the central tree cutout.")
		return
	var tree_cutout := Rect2(926.0, 573.0, 78.0, 40.0)
	var closest_lateral_clearance := INF
	for point in path:
		if tree_cutout.has_point(point):
			_fail("Navigation path entered the tree cutout at %s." % point)
			return
		if point.y >= 565.0 and point.y <= 630.0:
			closest_lateral_clearance = minf(closest_lateral_clearance, absf(point.x - 960.0))
	if closest_lateral_clearance < 28.0 or closest_lateral_clearance > 40.0:
		_fail("Tree route does not match the authored multi-shape footprint; received %s px." % closest_lateral_clearance)
		return

	print("Environment/navigation smoke test passed. Path points: %d, tree clearance: %.1f px" % [path.size(), closest_lateral_clearance])
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
