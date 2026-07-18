extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	var controller: EncounterController = arena.get_node("GameplayServices/EncounterController")
	controller.auto_start = false
	controller.inter_wave_delay = 0.5
	for resource in controller.waves:
		var wave := resource as EncounterWaveDefinition
		wave.spawn_interval = 0.1
		wave.reinforcement_delay = 0.25
	var expected_spawns := 0
	for resource in controller.waves:
		expected_spawns += (resource as EncounterWaveDefinition).total_enemy_count()
	var state := {"spawned": 0, "max_active": 0, "cleared": false}
	controller.enemy_spawned.connect(func(_position: Vector2) -> void:
		state.spawned += 1
	)
	controller.stage_cleared.connect(func() -> void: state.cleared = true)
	root.add_child(arena)
	controller.start_encounter()
	var deadline := Time.get_ticks_msec() + 12000
	while not state.cleared and Time.get_ticks_msec() < deadline:
		await process_frame
		state.max_active = maxi(state.max_active, controller._active_enemies)
		for actor in controller.actors.get_children():
			if actor != controller.player and actor.get("target") == controller.player:
				actor.queue_free()
	if not state.cleared:
		_fail("Queued reinforcement encounter did not reach its exit portal in time.")
		return
	if state.spawned != expected_spawns:
		_fail("Reinforcement queue spawned %d enemies, expected %d." % [state.spawned, expected_spawns])
		return
	if state.max_active > controller.max_active_enemies:
		_fail("Reinforcement queue exceeded the configured active-enemy cap.")
		return
	print("Encounter reinforcement smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
