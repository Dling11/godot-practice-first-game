extends SceneTree

const Stage3Scene = preload("res://levels/stage_3/stage_3.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var stage := Stage3Scene.instantiate()
	var controller: EncounterController = stage.get_node("GameplayServices/EncounterController")
	root.add_child(stage)
	if controller.auto_start or controller.waves.size() != 2:
		_fail("Stage 3 must wait for arrival lore and retain its authored two-wave structure.")
		return
	var boss_wave := controller.waves[1] as EncounterWaveDefinition
	if boss_wave.rootbound_husk_count != 1 or boss_wave.total_enemy_count() != 1:
		_fail("Stage 3's finale must be a solo Rootbound Husk encounter.")
		return
	if controller.rootbound_husk_scene == null or controller.max_active_enemies != 4:
		_fail("Stage 3 lost its Husk scene or the shared four-enemy cap.")
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
