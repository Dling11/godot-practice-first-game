extends SceneTree

const Stage3Scene = preload("res://levels/stage_3/stage_3.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Stage3Scene.instantiate()
	var controller: EncounterController = stage.get_node("GameplayServices/EncounterController")
	root.add_child(stage)
	var ground := stage.get_node("World/Level/Ground") as TileMapLayer
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
		_fail("Stage 3's 24x14 corrupted TileMap did not populate completely.")
		return
	var arena_seal := stage.get_node_or_null("World/Actors/RootboundArenaSeal") as StaticBody2D
	if arena_seal == null or not arena_seal.has_node("NavigationCutout"):
		_fail("Stage 3 lost its colliding, navigation-aware arena landmark.")
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
