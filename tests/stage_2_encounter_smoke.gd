extends SceneTree

const Stage2Scene = preload("res://levels/stage_2/stage_2.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Stage2Scene.instantiate()
	var controller: EncounterController = stage.get_node("GameplayServices/EncounterController")
	root.add_child(stage)
	var ground := stage.get_node("World/Level/Ground") as TileMapLayer
	var navigation_region := stage.get_node("World/NavigationRegion2D") as NavigationRegion2D
	var actors := stage.get_node("World/Actors") as Node2D
	if controller.auto_start:
		_fail("Stage 2 must delay combat until its arrival lore has been presented.")
		return
	if controller.waves.size() != 2:
		_fail("Stage 2 must use exactly two introductory waves.")
		return
	var first_wave := controller.waves[0] as EncounterWaveDefinition
	var second_wave := controller.waves[1] as EncounterWaveDefinition
	if first_wave.mireling_count != 2 or first_wave.bramble_spitter_count != 0:
		_fail("Stage 2 Wave 1 must remain a Mireling-only warm-up.")
		return
	if second_wave.mireling_count != 1 or second_wave.bramble_spitter_count != 1:
		_fail("Stage 2 Wave 2 must introduce one Spitter alongside one familiar enemy.")
		return
	if ground.map_size != Vector2i(24, 14) or not actors.y_sort_enabled:
		_fail("Stage 2 grove layout or Y-sorted actor ownership is not configured.")
		return
	for frame in range(3):
		await physics_frame
	if ground.get_used_cells().size() != 336:
		_fail("Stage 2 ground did not populate the expected 24x14 tile area.")
		return
	var navigation_map := navigation_region.get_world_2d().get_navigation_map()
	var path := PackedVector2Array()
	for attempt in range(30):
		path = NavigationServer2D.map_get_path(navigation_map, Vector2(768, 760), Vector2(768, 150), true, 1)
		if path.size() >= 2:
			break
		await physics_frame
	if path.size() < 2:
		_fail("Stage 2 navigation does not connect the arrival and exit spaces.")
		return
	if stage.has_node("UI/Placeholder"):
		_fail("Stage 2 still contains its placeholder presentation.")
		return
	print("Stage 2 encounter smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
