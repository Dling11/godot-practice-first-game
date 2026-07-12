extends SceneTree

const ArenaScene = preload("res://levels/test_arena/test_arena.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var arena := ArenaScene.instantiate()
	var controller: EncounterController = arena.get_node("GameplayServices/EncounterController")
	controller.auto_start = false
	root.add_child(arena)
	var effects: Node2D = arena.get_node("World/Effects")
	for frame in range(2): await physics_frame
	controller._spawn_enemy(controller.mireling_scene)
	await physics_frame
	if effects.get_child_count() != 1 or not effects.get_child(0) is SummonEffect:
		_fail("Encounter spawn did not create one reusable summon effect.")
		return
	var effect := effects.get_child(0) as SummonEffect
	if effect.lightning.points.size() != 7:
		_fail("Summon lightning did not build its readable segmented strike.")
		return
	for frame in range(55): await physics_frame
	if is_instance_valid(effect):
		_fail("Summon effect did not clean itself up after presentation.")
		return
	if effects.get_child_count() != 0:
		_fail("Summon effect left presentation nodes behind.")
		return
	print("Summon effect smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
