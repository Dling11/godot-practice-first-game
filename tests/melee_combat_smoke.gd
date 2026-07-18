extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TrainingTargetScene = preload("res://entities/training/training_target.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate()
	var target := TrainingTargetScene.instantiate()
	root.add_child(player)
	root.add_child(target)
	player.global_position = Vector2(100.0, 100.0)
	target.global_position = Vector2(130.0, 100.0)
	player.set_physics_process(false)
	player._set_facing_direction(Vector2.RIGHT)

	var attack_component = player.get_node("MeleeAttackComponent")
	var health_component = target.get_node("HealthComponent")
	var received_knockback := {"strength": 0.0}
	health_component.damaged.connect(func(info: DamageInfo) -> void:
		received_knockback.strength = info.knockback_strength
	)
	if not attack_component.request_attack(Vector2.RIGHT):
		_fail("The first sword attack request was rejected.")
		return

	for frame in range(40):
		await physics_frame

	if not is_equal_approx(health_component.current_health, 75.0):
		_fail("Expected one 25-damage sword hit; health was %s." % health_component.current_health)
		return
	if not is_equal_approx(received_knockback.strength, 48.0):
		_fail("Ashwood Blade did not deliver its configured light knockback.")
		return
	if attack_component.phase != attack_component.Phase.IDLE:
		_fail("Sword attack did not return to IDLE.")
		return

	print("Melee combat smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
