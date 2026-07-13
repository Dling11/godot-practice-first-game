extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	var controller: EncounterController = arena.get_node("GameplayServices/EncounterController")
	controller.auto_start = false
	root.add_child(arena)
	if controller.waves.size() != 3:
		_fail("Stage 1 must contain exactly three waves.")
		return
	if controller.inter_wave_delay < 2.0:
		_fail("Inter-wave recovery is too short to provide a readable breathing window.")
		return
	for index in range(controller.waves.size()):
		var wave := controller.waves[index] as EncounterWaveDefinition
		var enemy_count := wave.mireling_count + wave.thrall_count + wave.bramble_spitter_count
		if enemy_count < 1 or enemy_count > 4:
			_fail("Wave %d must contain between one and four enemies." % [index + 1])
			return
	var final_wave := controller.waves[2] as EncounterWaveDefinition
	if final_wave.bramble_spitter_count != 1:
		_fail("Wave 3 must introduce exactly one Bramble Spitter.")
		return
	var clear_state := {"emitted": false}
	controller.stage_cleared.connect(func() -> void: clear_state.emitted = true)
	controller._spawn_portal()
	await process_frame
	if not clear_state.emitted:
		_fail("Clearing the final wave did not emit stage completion.")
		return
	if arena.get_node("World/Effects").get_child_count() != 1:
		_fail("Stage completion did not create exactly one exit portal.")
		return
	print("Encounter wave structure smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
