extends SceneTree

const ARENA_PATH := "res://levels/stage_5_boss_test/stage_5_boss_test.tscn"
const STAGE_5_PATH := "res://levels/stage_5/stage_5.tscn"
const STAGE_4_PATH := "res://levels/stage_4/stage_4.tscn"
const TERRAIN_PATH := "res://assets/environment/forest/stage_5/tiles/stage_5_decay_ground_atlas_4x4.png"
const SHRINE_PATH := "res://assets/environment/forest/stage_5/props/stage_5_broken_shrine_320x192.png"
const TALL_TREE_PATH := "res://assets/environment/forest/stage_5/props/stage_5_tall_dead_tree_144x192.png"
const SNAG_PATH := "res://assets/environment/forest/stage_5/props/stage_5_dead_tree_snag_128x160.png"
const FALLEN_LOG_PATH := "res://assets/environment/forest/stage_5/props/stage_5_fallen_log_192x96.png"
const UPROOTED_LOG_PATH := "res://assets/environment/forest/stage_5/props/stage_5_uprooted_log_192x128.png"
const DEAD_ANIMAL_PATH := "res://assets/environment/forest/stage_5/props/stage_5_tiny_carrion_remains_48x32.png"
const EDGE_THICKET_PATH := "res://assets/environment/forest/stage_5/props/stage_5_edge_thicket_256x192.png"
const REJECTED_STUMP_PATH := "res://assets/environment/forest/stage_5/props/stage_5_dead_tree_112x144.png"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _verify_image(TERRAIN_PATH, Vector2i(256, 256), false):
		return
	if not _verify_image(SHRINE_PATH, Vector2i(320, 192), true):
		return
	if not _verify_image(TALL_TREE_PATH, Vector2i(144, 192), true):
		return
	if not _verify_image(SNAG_PATH, Vector2i(128, 160), true):
		return
	if not _verify_image(FALLEN_LOG_PATH, Vector2i(192, 96), true):
		return
	if not _verify_image(UPROOTED_LOG_PATH, Vector2i(192, 128), true):
		return
	if not _verify_image(DEAD_ANIMAL_PATH, Vector2i(48, 32), true):
		return
	if not _verify_image(EDGE_THICKET_PATH, Vector2i(256, 192), true):
		return
	if FileAccess.file_exists(REJECTED_STUMP_PATH):
		_fail("The owner-rejected Stage 5 stump runtime asset was restored.")
		return

	var arena_scene := load(ARENA_PATH) as PackedScene
	var arena := arena_scene.instantiate() if arena_scene != null else null
	if arena == null:
		_fail("Stage 5 environment proof did not instantiate.")
		return
	var ground := arena.get_node_or_null("World/Level/Ground") as TileMapLayer
	if ground == null or ground.layout == null:
		_fail("Stage 5 environment lost its authored ground layout.")
		return
	if ground.layout.map_size != Vector2i(15, 9) or ground.layout.rows.size() != 9:
		_fail("Stage 5 environment ground contract drifted from its authored 15x9 basin.")
		return
	for row in ground.layout.rows:
		if row.length() != 15:
			_fail("Stage 5 environment contains a malformed authored terrain row: %s." % row)
			return
	if arena.get_node_or_null("World/Actors/BrokenShrineNorth") == null:
		_fail("Stage 5 environment lost its dormant broken shrine focal point.")
		return
	for prop_name in ["TallDeadTreeNorthWest", "DeadTreeSnagNorthEast", "FallenLogNorthWest", "FallenLogSouthEast", "UprootedLogWest"]:
		if arena.get_node_or_null("World/Actors/" + prop_name) == null:
			_fail("Stage 5 environment lost authored dead-forest obstacle %s." % prop_name)
			return
	if arena.get_node_or_null("World/NavigationRegion2D") == null:
		_fail("Stage 5 environment lost navigation ownership around its authored obstacles.")
		return
	root.add_child(arena)
	await process_frame
	var player := arena.get_node_or_null("World/Actors/Player") as Player
	var boss := arena.get_node_or_null("World/Actors/Stage5Boss") as Stage5Boss
	if player == null or boss == null:
		_fail("Stage 5 environment proof lost its playable combat actors.")
		return
	boss.set_physics_process(false)
	var start_position := player.global_position
	Input.action_press(&"player_move_right")
	for tick in 20:
		await physics_frame
	Input.action_release(&"player_move_right")
	if player.global_position.x <= start_position.x + 4.0:
		_fail("King cannot traverse the Stage 5 F8 combat rectangle.")
		return
	arena.queue_free()
	await process_frame

	var stage_4_scene := load(STAGE_4_PATH) as PackedScene
	var stage_4 := stage_4_scene.instantiate() if stage_4_scene != null else null
	if stage_4 == null:
		_fail("Stage 4 did not instantiate while checking its existing exit portal.")
		return
	var controller := stage_4.get_node_or_null("GameplayServices/EncounterController")
	if controller == null or controller.portal_target_scene != STAGE_5_PATH:
		_fail("Stage 4's eastern gateway no longer routes into the production Stage 5 scene.")
		return
	var stage_4_ruin := stage_4.get_node_or_null("World/Actors/EastRuin") as Node2D
	var stage_4_exit := stage_4.get_node_or_null("SpawnPoints/StageExit") as Marker2D
	if stage_4_ruin == null or stage_4_ruin.get_node_or_null("Shrine") == null:
		_fail("Stage 4's eastern route marker must share the broken-shrine architecture used by Stage 5.")
		return
	if stage_4_exit == null or not stage_4_exit.position.is_equal_approx(stage_4_ruin.position):
		_fail("Stage 4's clear portal must activate inside its eastern broken gateway.")
		return
	stage_4.free()

	var stage_5_scene := load(STAGE_5_PATH) as PackedScene
	var stage_5 := stage_5_scene.instantiate() if stage_5_scene != null else null
	if stage_5 == null:
		_fail("Production Stage 5 did not instantiate.")
		return
	var production_ground := stage_5.get_node_or_null("World/Level/Ground") as TileMapLayer
	if production_ground == null or production_ground.layout == null or production_ground.layout.map_size != Vector2i(24, 18):
		_fail("Production Stage 5 lost its authored 24x18 scrolling ground.")
		return
	var production_actors := stage_5.get_node_or_null("World/Actors")
	var edge_count := 0
	for child in production_actors.get_children():
		if child.name.begins_with("Edge"):
			edge_count += 1
	if edge_count < 18:
		_fail("Production Stage 5 no longer has a dense authored dead-tree edge wall.")
		return
	for child in production_actors.get_children():
		if not child.name.begins_with("Edge"):
			continue
		var edge_position := (child as Node2D).position
		if edge_position.x > 96.0 and edge_position.x < 1440.0 and edge_position.y > 160.0 and edge_position.y < 1092.0:
			_fail("Stage 5 edge thicket %s drifted into the playable field." % child.name)
			return
	var carcass := stage_5.get_node_or_null("World/Actors/DeadAnimalLandmark")
	if carcass == null or carcass.get_node_or_null("Flies") == null or carcass.get_node("Flies").get_child_count() != 4:
		_fail("Production Stage 5 lost its animated dead-animal landmark.")
		return
	if stage_5.get_node_or_null("World/Actors/ArrivalGateway") == null:
		_fail("Production Stage 5 lost the destination-side eastern gateway.")
		return
	root.add_child(stage_5)
	await process_frame
	var production_player := stage_5.get_node("World/Actors/Player") as Player
	var production_boss := stage_5.get_node("World/Actors/Stage5Boss") as Stage5Boss
	if production_boss.arena_bounds.position.x > 80.0 or production_boss.arena_bounds.position.y > 80.0 or production_boss.arena_bounds.end.x < 1460.0 or production_boss.arena_bounds.end.y < 1080.0:
		_fail("Varkuun remains clamped to the northern basin instead of pursuing across Stage 5 after activation.")
		return
	if production_boss.is_physics_processing() or production_boss.target != null:
		_fail("Production Stage 5 boss activated before King reached its northern basin.")
		return
	var production_start := production_player.global_position
	Input.action_press(&"player_move_up")
	for tick in 20:
		await physics_frame
	Input.action_release(&"player_move_up")
	if production_player.global_position.y >= production_start.y - 4.0:
		_fail("King cannot traverse the production Stage 5 approach.")
		return
	production_player.global_position = Vector2(768, 575)
	await create_timer(1.8).timeout
	if production_boss.target != production_player or not production_boss.is_physics_processing():
		_fail("Production Stage 5 did not activate the boss at the authored basin threshold.")
		return
	var production_flow := stage_5 as Node
	var audio_director := root.get_node_or_null("AudioDirector")
	var expected_boss_music := load("res://assets/audio/music/boss/varkuun_battle_rpg_theme_loop.ogg") as AudioStream
	if production_flow.get("boss_music") != expected_boss_music or audio_director == null or audio_director.music_player.stream != expected_boss_music:
		_fail("Varkuun's entrance did not replace Stage 5 ambience with the active fantasy boss loop.")
		return
	if not is_equal_approx(audio_director.music_player.volume_db, -7.0):
		_fail("Varkuun's boss loop did not receive its dedicated audible encounter level.")
		return

	# Reproduce the reported production wedge: King and Varkuun stand on
	# opposite sides of the carrion landmark. The boss must route around its
	# solid footprint instead of walking directly into it forever.
	var production_carcass := stage_5.get_node("World/Actors/DeadAnimalLandmark") as Node2D
	var unsafe_landing := production_carcass.global_position
	var safe_landing := production_boss.resolve_navigation_safe_position(unsafe_landing)
	if safe_landing.distance_to(unsafe_landing) < 18.0:
		_fail("Varkuun's committed landing resolver still accepts the carcass collision cutout.")
		return
	production_player.global_position = Vector2(600.0, 650.0)
	production_boss.global_position = Vector2(600.0, 820.0)
	production_boss.state = Stage5Boss.State.CHASE
	production_boss._root_ready = false
	production_boss._jump_cooldown = 999.0
	production_boss._attacks_since_jump = 0
	var initial_boss_distance := production_boss.global_position.distance_to(production_player.global_position)
	var largest_lateral_detour := 0.0
	for tick in 210:
		await physics_frame
		largest_lateral_detour = maxf(
			largest_lateral_detour,
			absf(production_boss.global_position.x - 600.0)
		)
	var final_boss_distance := production_boss.global_position.distance_to(production_player.global_position)
	if largest_lateral_detour < 12.0 or final_boss_distance > initial_boss_distance - 55.0:
		_fail(
			"Varkuun remained wedged on the carrion landmark (detour=%.1f distance %.1f -> %.1f)."
			% [largest_lateral_detour, initial_boss_distance, final_boss_distance]
		)
		return
	stage_5.queue_free()
	await process_frame

	print("PASS: Stage 4 routes into the scrolling Stage 5 dead forest with edge thickets, animated carcass, traversal, and gated boss basin.")
	quit(0)


func _verify_image(path: String, expected_size: Vector2i, requires_alpha: bool) -> bool:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty() or image.get_size() != expected_size:
		_fail("Stage 5 environment image has the wrong runtime contract: %s." % path)
		return false
	if requires_alpha and image.detect_alpha() == Image.ALPHA_NONE:
		_fail("Stage 5 prop lost transparency: %s." % path)
		return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
