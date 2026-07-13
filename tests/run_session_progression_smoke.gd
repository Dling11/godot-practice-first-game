extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_session := root.get_node("RunSession")
	run_session.reset_run()

	var first_player := PlayerScene.instantiate() as Player
	root.add_child(first_player)
	first_player.set_physics_process(false)
	first_player.progression_component.grant_rewards(50, 4)
	var expected_level := first_player.progression_component.level
	first_player.queue_free()
	await process_frame

	var transitioned_player := PlayerScene.instantiate() as Player
	root.add_child(transitioned_player)
	transitioned_player.set_physics_process(false)
	var progression := transitioned_player.progression_component
	if progression.total_experience != 50 or progression.coins != 4:
		_fail("A replacement player did not inherit the active run's XP and coins.")
		return
	if progression.level != expected_level:
		_fail("A replacement player did not reconstruct the active run's level.")
		return

	run_session.reset_run()
	transitioned_player.queue_free()
	await process_frame
	var restarted_player := PlayerScene.instantiate() as Player
	root.add_child(restarted_player)
	restarted_player.set_physics_process(false)
	if restarted_player.progression_component.total_experience != 0 or restarted_player.progression_component.coins != 0:
		_fail("Resetting the run did not restore level-one progression state.")
		return

	print("Run session progression smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
