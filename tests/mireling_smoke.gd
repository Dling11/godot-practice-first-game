extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate()
	var mireling := MirelingScene.instantiate()
	mireling.target = player
	root.add_child(player)
	root.add_child(mireling)
	player.global_position = Vector2(200, 200)
	mireling.global_position = Vector2(222, 200)
	player.set_physics_process(false)
	var player_health: HealthComponent = player.get_node("HealthComponent")
	if mireling.state != Mireling.State.SPAWNING:
		_fail("Mireling did not begin with materialization.")
		return
	for frame in range(120): await physics_frame
	if player_health.current_health >= player_health.maximum_health:
		_fail("Mireling body slam did not damage the player.")
		return
	mireling.set_physics_process(false)
	mireling.global_position = Vector2(225, 200)
	player._set_facing_direction(Vector2.RIGHT)
	var mireling_health: HealthComponent = mireling.get_node("HealthComponent")
	if not player.request_primary_attack():
		_fail("Player attack request was rejected against Mireling.")
		return
	for frame in range(40): await physics_frame
	if mireling_health.current_health > 5.0:
		_fail("Player sword did not deal 25 damage to the 30-health Mireling.")
		return
	print("Mireling smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
