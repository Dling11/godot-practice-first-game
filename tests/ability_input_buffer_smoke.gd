extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	var attack := player.attack_component
	var ability := player.ability_1_component
	var observed := {"unsafe_overlap": false}
	attack.phase_changed.connect(func(phase: int, _duration_seconds: float) -> void:
		if phase == MeleeAttackComponent.Phase.ACTIVE and ability.is_casting():
			observed.unsafe_overlap = true
	)

	if not player.request_primary_attack():
		_fail("The normal attack needed for ability-buffer coverage was rejected.")
		return
	if not player.request_ability_1():
		_fail("A ready skill was not buffered during a normal attack.")
		return
	if ability.is_casting():
		_fail("Buffered skill interrupted the live normal attack instead of waiting safely.")
		return
	while not ability.is_casting():
		await physics_frame
	if observed.unsafe_overlap:
		_fail("Buffered skill overlapped the normal attack's damage window.")
		return
	if attack.phase != MeleeAttackComponent.Phase.IDLE:
		_fail("Buffered skill did not replace only the normal attack recovery.")
		return
	if ability.get_cast_direction() != Vector2.DOWN:
		_fail("Buffered skill did not preserve the facing captured at input time.")
		return
	ability.cancel_cast()
	ability._physics_process(ability.cooldown_remaining + 0.1)

	if not player.request_evade(Vector2.RIGHT):
		_fail("Ready player rejected the dash needed for ability-buffer coverage.")
		return
	if not player.request_ability_1():
		_fail("A ready skill was not buffered during the active dash.")
		return
	if ability.is_casting():
		_fail("Buffered skill began before dash invulnerability ended.")
		return
	while evade_is_dashing(player):
		await physics_frame
	if not ability.is_casting() or player.health_component.is_invulnerable:
		_fail("Dash-buffered skill did not begin at the safe vulnerable boundary.")
		return
	if player.request_evade(Vector2.RIGHT):
		_fail("Dash input canceled an active skill instead of respecting its commitment.")
		return

	print("Ability input buffer smoke test passed.")
	quit(0)


func evade_is_dashing(player: Player) -> bool:
	return player.evade_component.is_dashing()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
