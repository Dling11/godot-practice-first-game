extends SceneTree

const Stage3Scene = preload("res://levels/stage_3/stage_3.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Stage3Scene.instantiate()
	var controller: EncounterController = stage.get_node("GameplayServices/EncounterController")
	root.add_child(stage)
	var ground := stage.get_node("World/Level/Ground") as TileMapLayer
	var navigation_region := stage.get_node("World/NavigationRegion2D") as NavigationRegion2D
	if controller.auto_start or controller.waves.size() != 2:
		_fail("Stage 3 must wait for arrival lore and retain its authored two-wave structure.")
		return
	var brood_wave := controller.waves[0] as EncounterWaveDefinition
	if brood_wave.rootling_count != 10 or brood_wave.total_enemy_count() != 10:
		_fail("Stage 3's approach must tell the Husk-brood story with ten Rootlings.")
		return
	var boss_wave := controller.waves[1] as EncounterWaveDefinition
	if boss_wave.rootbound_husk_count != 1 or boss_wave.total_enemy_count() != 1:
		_fail("Stage 3's finale must be a solo Rootbound Husk encounter.")
		return
	if controller.rootbound_husk_scene == null or controller.max_active_enemies != 4:
		_fail("Stage 3 lost its Husk scene or the shared four-enemy cap.")
		return
	if controller.portal_target_scene != "res://levels/sanctuary/sanctuary.tscn":
		_fail("Stage 3's post-mini-boss portal must return to Sanctuary.")
		return
	if (
		controller.completion_reward_mode
			!= EncounterController.CompletionRewardMode.STAGE_CHEST
		or controller.reward_chest_scene == null
		or controller.stage_loot_table == null
		or controller.reward_chest_tier
			!= StageRewardChest.ChestTier.ROOTBOUND_RELIQUARY
	):
		_fail("Stage 3 must gate its return portal behind the authored clear chest.")
		return
	if 2 not in controller.gated_wave_numbers:
		_fail("Stage 3 must gate the solo Husk until its skippable introduction closes.")
		return
	if stage.get("dialogue_panel") == null or stage.get("rootbound_husk_portrait") == null:
		_fail("Stage 3 lost its dialogue panel or Rootbound Husk portrait.")
		return
	if ground.layout == null or ground.layout.resource_path != "res://data/environment/layouts/stage_3_rootbound_ground.tres":
		_fail("Stage 3 is not using its authored Rootbound Hollow ground layout.")
		return
	if ground.tile_set.resource_path != "res://assets/environment/forest/rootbound_hollow/tiles/rootbound_ground_tileset.tres":
		_fail("Stage 3 is not using the organized Rootbound Hollow TileSet.")
		return
	if ground.get_used_cells().size() != 336:
		_fail("Stage 3's 24x14 decaying-forest TileMap did not populate completely.")
		return
	var corrupted_cells := 0
	var living_cells := 0
	for cell in ground.get_used_cells():
		match ground.get_cell_source_id(cell):
			0:
				corrupted_cells += 1
			1:
				living_cells += 1
	var corruption_ratio := float(corrupted_cells) / float(ground.get_used_cells().size())
	if corruption_ratio < 0.4 or corruption_ratio > 0.5:
		_fail("Stage 3 corruption must cover 40-50%% of the map; received %.2f%%." % (corruption_ratio * 100.0))
		return
	if living_cells + corrupted_cells != 336:
		_fail("Stage 3 contains cells outside its living-forest and Rootbound terrain sources.")
		return
	var arena_seal := stage.get_node_or_null("World/Actors/RootboundArenaSeal") as StaticBody2D
	if arena_seal == null or not arena_seal.has_node("NavigationCutout"):
		_fail("Stage 3 lost its colliding, navigation-aware arena landmark.")
		return
	if not is_equal_approx(navigation_region.navigation_agent_radius, 20.0):
		_fail("Stage 3 navigation is not baked for the Rootbound Husk's large footprint.")
		return
	var navigation_map := navigation_region.get_world_2d().get_navigation_map()
	var seal_route := PackedVector2Array()
	for attempt in range(30):
		seal_route = NavigationServer2D.map_get_path(
			navigation_map,
			Vector2(768.0, 150.0),
			Vector2(768.0, 760.0),
			true,
			1
		)
		if seal_route.size() >= 3:
			break
		await physics_frame
	if seal_route.size() < 3:
		_fail("The Husk cannot obtain a route around the central Rootbound seal.")
		return
	var husk_clearance := Rect2(591.5, 202.0, 345.0, 88.0).grow(16.0)
	for point_index in range(seal_route.size() - 1):
		var start := seal_route[point_index]
		var finish := seal_route[point_index + 1]
		var sample_count := maxi(ceili(start.distance_to(finish) / 4.0), 1)
		for sample_index in range(sample_count + 1):
			var sample := start.lerp(finish, float(sample_index) / float(sample_count))
			if husk_clearance.has_point(sample):
				_fail("The Husk route clips its body into the central seal at %s." % sample)
				return
	var dialogue := stage.get("dialogue_panel") as DialoguePanel
	var skipped := [false]
	dialogue.dialogue_closed.connect(func(completed: bool) -> void: skipped[0] = not completed, CONNECT_ONE_SHOT)
	dialogue.show_dialogue(
		"ROOTBOUND HUSK",
		["The roots remember."],
		stage.get("rootbound_husk_portrait") as Texture2D
	)
	if not paused or not dialogue.visible or not dialogue.portrait.visible:
		_fail("Portrait dialogue did not pause safely or present the configured face.")
		return
	dialogue.close_dialogue(false)
	if paused or not skipped[0]:
		_fail("Skipping the Husk introduction did not resume gameplay cleanly.")
		return
	var miniboss_music: AudioStream = stage.get_node("GameplayServices/MinibossMusicTrigger").miniboss_music
	if miniboss_music == null or miniboss_music.resource_path != "res://assets/audio/music/miniboss/rootbound_husk_basilisk_miniboss_loop.ogg":
		_fail("Stage 3 mini-boss music is not configured.")
		return
	print("Stage 3 encounter smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
