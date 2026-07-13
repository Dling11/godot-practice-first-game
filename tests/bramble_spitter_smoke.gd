extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const SpitterScene = preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var world := Node2D.new()
	var projectiles := Node2D.new()
	var player := PlayerScene.instantiate()
	var spitter := SpitterScene.instantiate() as BrambleSpitter
	world.add_child(projectiles)
	world.add_child(player)
	spitter.target = player
	spitter.set_projectile_parent(projectiles)
	world.add_child(spitter)
	root.add_child(world)
	player.global_position = Vector2(140.0, 200.0)
	spitter.global_position = Vector2(80.0, 200.0)
	player.set_physics_process(false)
	var body := spitter.get_node("Visual/Body") as AnimatedSprite2D
	if body.sprite_frames.get_frame_texture(&"idle_down", 0) == null:
		_fail("Bramble Spitter body animation has no atlas texture.")
		return
	if body.sprite_frames.get_frame_count(&"attack_down") != 3:
		_fail("Bramble Spitter attack must contain charge, compression, and spit frames.")
		return

	var telegraph := {"seen": false, "target": Vector2.ZERO, "visible": false}
	spitter.shot_telegraphed.connect(func(global_target: Vector2, _duration: float) -> void:
		telegraph.seen = true
		telegraph.target = global_target
		telegraph.visible = spitter.get_node("TargetMarker").visible
	)
	var firing_feedback := {"seen": false, "flash_visible": false}
	spitter.shot_fired.connect(func(_direction: Vector2) -> void:
		firing_feedback.seen = true
		firing_feedback.flash_visible = spitter.get_node("MuzzleFlash").visible
	)
	var close_retreat_seen := false
	for frame in range(300):
		await physics_frame
		var offset: Vector2 = player.global_position - spitter.global_position
		if spitter.state == BrambleSpitter.State.POSITIONING and offset.length() < spitter.minimum_attack_range and spitter.velocity.length() > 1.0:
			close_retreat_seen = true
			if spitter.facing_direction.dot(offset.normalized()) < 0.8:
				_fail("Bramble Spitter faced away from the player while creating ranged space.")
				return
		if telegraph.seen:
			break
	if not telegraph.seen:
		_fail("Bramble Spitter did not telegraph its first shot (state=%s, distance=%.2f)." % [spitter.State.keys()[spitter.state], spitter.global_position.distance_to(player.global_position)])
		return
	if not close_retreat_seen:
		_fail("Bramble Spitter close-range retreat regression was not exercised.")
		return
	if telegraph.target.distance_to(player.global_position) > 0.1:
		_fail("Bramble Spitter did not snapshot the player's target position.")
		return
	if not telegraph.visible:
		_fail("Bramble Spitter red ground target marker was not visible.")
		return

	# Moving after the tell must not redirect the already committed shot.
	player.global_position.y -= 60.0
	for frame in range(85):
		await physics_frame
	var player_health := player.get_node("HealthComponent") as HealthComponent
	if player_health.current_health < player_health.maximum_health:
		_fail("A perpendicular dodge did not evade the committed seed shot.")
		return
	if spitter.state == BrambleSpitter.State.WIND_UP:
		_fail("Bramble Spitter never left its wind-up state.")
		return
	if not firing_feedback.seen or not firing_feedback.flash_visible:
		_fail("Bramble Spitter firing event did not show its muzzle flash.")
		return

	spitter.set_physics_process(false)
	var impact_seen := {"value": false}
	projectiles.child_entered_tree.connect(func(child: Node) -> void:
		if child.name == "BrambleSeedImpact":
			impact_seen.value = true
	)
	var projectile := spitter.projectile_scene.instantiate() as HostileProjectile
	projectiles.add_child(projectile)
	projectile.global_position = player.global_position - Vector2(45.0, 0.0)
	projectile.launch(Vector2.RIGHT, 8.0, spitter)
	for frame in range(35):
		await physics_frame
	if not is_equal_approx(player_health.current_health, player_health.maximum_health - 8.0):
		_fail("Bramble seed projectile did not apply exactly 8 damage through the hurtbox contract.")
		return
	if not impact_seen.value:
		_fail("Bramble seed did not create its impact feedback.")
		return
	print("Bramble Spitter smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
