extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TargetScene = preload("res://entities/training/training_target.tscn")
const EnemyScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
const SweepingCutDefinition = preload("res://data/abilities/sweeping_cut.tres")
const SweepingCutSlot = preload("res://data/skills/slots/opaw_sweeping_cut_slot.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	var target_upper := TargetScene.instantiate()
	var target_lower := TargetScene.instantiate()
	root.add_child(player)
	root.add_child(target_upper)
	root.add_child(target_lower)
	player.global_position = Vector2(100.0, 100.0)
	target_upper.global_position = Vector2(128.0, 90.0)
	target_lower.global_position = Vector2(128.0, 110.0)
	player.set_physics_process(false)
	player._set_facing_direction(Vector2.RIGHT)

	if SweepingCutSlot.ability != SweepingCutDefinition:
		_fail("Preserved Sweeping Cut slot no longer references its ability data.")
		return
	if player.skill_loadout.get_slot(1).ability == SweepingCutDefinition:
		_fail("Sweeping Cut unexpectedly remained in Opaw's active slot 1.")
		return

	var ability := player.ability_1_component
	ability.definition = SweepingCutDefinition
	var upper_health := target_upper.get_node("HealthComponent") as HealthComponent
	var lower_health := target_lower.get_node("HealthComponent") as HealthComponent
	var knockback_hits := {"count": 0}
	upper_health.damaged.connect(func(info: DamageInfo) -> void:
		if is_equal_approx(info.knockback_strength, 90.0):
			knockback_hits.count += 1
	)
	lower_health.damaged.connect(func(info: DamageInfo) -> void:
		if is_equal_approx(info.knockback_strength, 90.0):
			knockback_hits.count += 1
	)

	if not ability.request_cast(Vector2.RIGHT, player.attack_component.weapon.damage):
		_fail("Preserved Sweeping Cut could not cast through the reusable ability component.")
		return
	if (
		not player.get_node("AbilityPivot/SweepingCutVisual").visible
		or player.get_node("AbilityPivot/PiercingRushVisual").visible
	):
		_fail("Preserved Sweeping Cut did not select only its sweep presentation.")
		return
	if player.request_primary_attack() or player.request_evade(Vector2.RIGHT):
		_fail("Attack or evade was accepted during preserved Sweeping Cut.")
		return

	for frame in range(45):
		await physics_frame
	if not is_equal_approx(upper_health.current_health, 80.0):
		_fail("Preserved Sweeping Cut did not deal one fixed 20-damage hit to the upper target.")
		return
	if not is_equal_approx(lower_health.current_health, 80.0):
		_fail("Preserved Sweeping Cut did not deal one fixed 20-damage hit to the lower target.")
		return
	if knockback_hits.count != 2:
		_fail("Preserved Sweeping Cut did not retain its pushback metadata.")
		return
	if ability.is_casting() or ability.is_ready():
		_fail("Preserved Sweeping Cut did not finish cleanly into cooldown.")
		return

	ability._physics_process(ability.cooldown_remaining + 0.1)
	if not ability.is_ready():
		_fail("Preserved Sweeping Cut did not return from cooldown.")
		return
	if not await _test_knockback_response(player):
		return
	print("Unequipped Sweeping Cut reuse smoke test passed.")
	quit(0)


func _test_knockback_response(player: Player) -> bool:
	var enemy := EnemyScene.instantiate() as ForsakenThrall
	enemy.target = player
	root.add_child(enemy)
	player.global_position = Vector2(500.0, 500.0)
	enemy.global_position = Vector2(500.0, 500.0)
	enemy._finish_spawn()
	var start_x := enemy.global_position.x
	enemy.health_component.apply_damage(DamageInfo.new(1.0, player, Vector2.RIGHT, 90.0))
	for frame in range(3):
		await physics_frame
	if enemy.global_position.x <= start_x:
		_fail("Enemy movement authority did not apply preserved Sweeping Cut pushback.")
		return false
	enemy.queue_free()
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
