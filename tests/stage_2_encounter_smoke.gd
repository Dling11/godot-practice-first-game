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
	if controller.waves.size() != 7:
		_fail("Stage 2 must use seven authored Grove waves.")
		return
	if controller.max_active_enemies != 4:
		_fail("Stage 2 must retain the validated four-enemy active cap.")
		return
	if controller.portal_target_scene != "res://levels/stage_3/stage_3.tscn":
		_fail("Stage 2's clear portal must continue directly into Stage 3.")
		return
	var first_wave := controller.waves[0] as EncounterWaveDefinition
	var second_wave := controller.waves[1] as EncounterWaveDefinition
	var rootling_lesson := controller.waves[2] as EncounterWaveDefinition
	var final_wave := controller.waves[6] as EncounterWaveDefinition
	if first_wave.mireling_count != 3 or first_wave.bramble_spitter_count != 0:
		_fail("Stage 2 Wave 1 must remain a Mireling-only warm-up.")
		return
	if second_wave.mireling_count != 2 or second_wave.bramble_spitter_count != 1:
		_fail("Stage 2 Wave 2 must introduce one Spitter alongside familiar enemies.")
		return
	if rootling_lesson.mireling_count != 2 or rootling_lesson.rootling_count != 1 or rootling_lesson.bramble_spitter_count != 1:
		_fail("Stage 2 Wave 3 must introduce Rootling alongside the Grove's ranged pressure.")
		return
	if (
		final_wave.mireling_count != 2
		or final_wave.rootling_count != 1
		or final_wave.thrall_count != 2
		or final_wave.bramble_spitter_count != 2
	):
		_fail("Stage 2 finale must combine all learned roles in a seven-enemy endurance wave.")
		return
	if final_wave.total_enemy_count() != 7 or final_wave.reinforcement_delay < 0.5:
		_fail("Stage 2 finale must use controlled reinforcements rather than an oversized crowd.")
		return
	if controller.thrall_scene == null:
		_fail("Stage 2 finale is missing its configured Forsaken Thrall scene.")
		return
	if controller.rootling_scene == null:
		_fail("Stage 2 Rootling waves require the dedicated Rootling scene.")
		return
	if ground.map_size != Vector2i(24, 14) or not actors.y_sort_enabled:
		_fail("Stage 2 grove layout or Y-sorted actor ownership is not configured.")
		return
	if ground.layout == null or ground.layout.resource_path != "res://data/environment/layouts/stage_2_forest_ground.tres":
		_fail("Stage 2 is not using its authored forest ground layout resource.")
		return
	if not stage.has_node("World/Actors/BrokenHeart"):
		_fail("Stage 2's central Broken Heart landmark is missing.")
		return
	if stage.has_node("World/Actors/WestThornShrine") or stage.has_node("World/Actors/EastThornShrine"):
		_fail("Stage 2 still contains the arbitrary duplicate side statues.")
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
