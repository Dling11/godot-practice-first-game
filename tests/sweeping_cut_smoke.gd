extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TargetScene = preload("res://entities/training/training_target.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const EnemyScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	var target_upper := TargetScene.instantiate()
	var target_lower := TargetScene.instantiate()
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(player)
	root.add_child(target_upper)
	root.add_child(target_lower)
	root.add_child(hud)
	player.global_position = Vector2(100.0, 100.0)
	target_upper.global_position = Vector2(128.0, 90.0)
	target_lower.global_position = Vector2(128.0, 110.0)
	player.set_physics_process(false)
	player._set_facing_direction(Vector2.RIGHT)
	hud.bind_player(player)
	await process_frame
	var skill_bar := hud.get_node("SkillBar") as Control
	var skill_rect := skill_bar.get_global_rect()
	if skill_rect.size.x < 140.0 or skill_rect.position.y < 450.0 or skill_rect.end.x > 960.0:
		_fail("The skill bar is not visibly laid out inside the gameplay viewport.")
		return

	var ability := player.ability_1_component
	var upper_health := target_upper.get_node("HealthComponent") as HealthComponent
	var lower_health := target_lower.get_node("HealthComponent") as HealthComponent
	var knockback_hits := {"count": 0}
	upper_health.damaged.connect(func(info: DamageInfo) -> void:
		if is_equal_approx(info.knockback_strength, 90.0): knockback_hits.count += 1
	)
	lower_health.damaged.connect(func(info: DamageInfo) -> void:
		if is_equal_approx(info.knockback_strength, 90.0): knockback_hits.count += 1
	)

	if not player.request_ability_1():
		_fail("Sweeping Cut request was rejected while ready.")
		return
	if player.request_primary_attack() or player.request_evade(Vector2.RIGHT):
		_fail("Attack or evade was accepted during Sweeping Cut.")
		return
	if hud.ability_panel.modulate == Color.WHITE:
		_fail("Ability HUD did not enter cooldown presentation.")
		return
	if not hud.ability_panel.is_visible_in_tree() or not hud.has_node("SkillBar/Skill4"):
		_fail("The reusable four-slot skill bar is not visibly composed in the HUD.")
		return
	if hud.ability_panel.state_label.text != "2.5":
		_fail("Ability HUD did not show the initial numeric cooldown.")
		return

	for frame in range(45):
		await physics_frame
	if not is_equal_approx(upper_health.current_health, 80.0):
		_fail("Sweeping Cut did not deal one 20-damage hit to the upper target.")
		return
	if not is_equal_approx(lower_health.current_health, 80.0):
		_fail("Sweeping Cut did not deal one 20-damage hit to the lower target.")
		return
	if knockback_hits.count != 2:
		_fail("Sweeping Cut did not deliver pushback metadata to both targets.")
		return
	if ability.is_casting() or player.request_ability_1():
		_fail("Sweeping Cut did not finish cleanly or ignored its cooldown.")
		return

	ability._physics_process(ability.cooldown_remaining + 0.1)
	if not ability.is_ready() or hud.ability_panel.modulate != Color.WHITE:
		_fail("Sweeping Cut or its HUD did not return to ready state.")
		return
	if hud.ability_panel.state_label.text != "READY":
		_fail("Ability HUD did not restore its READY label.")
		return
	if not await _test_knockback_response(player):
		return
	print("Sweeping Cut smoke test passed.")
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
		_fail("Enemy movement authority did not apply Sweeping Cut pushback.")
		return false
	enemy.queue_free()
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
