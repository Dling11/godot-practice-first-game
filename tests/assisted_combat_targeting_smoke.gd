extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	var hud := HudScene.instantiate() as CombatHUD
	var first := MirelingScene.instantiate() as Mireling
	var second := MirelingScene.instantiate() as Mireling
	first.target = player
	second.target = player
	root.add_child(player)
	root.add_child(first)
	root.add_child(second)
	root.add_child(hud)
	hud.bind_player(player)
	player.global_position = Vector2(100.0, 100.0)
	first.global_position = Vector2(240.0, 100.0)
	second.global_position = Vector2(100.0, 220.0)
	await process_frame
	await physics_frame

	var first_hurtbox := first.get_node("Hurtbox") as HurtboxComponent
	if not player.combat_targeting.select_at_world_position(first_hurtbox.global_position):
		_fail("Click-position picking could not select an alive enemy hurtbox.")
		return
	if player.combat_targeting.target_actor != first or player.combat_targeting.auto_attack_enabled:
		_fail("World clicking did not establish one selected-but-idle target.")
		return
	if not hud.target_panel.visible or hud.target_name_label.text != "MIRELING":
		_fail("The left target panel did not present the selected enemy name and health.")
		return
	if not hud.target_portrait.visible or not hud.enemy_roster_panel.visible:
		_fail("Selected-target portrait or top-right enemy roster did not appear.")
		return
	hud.attack_button.pressed.emit()
	if not player.combat_targeting.auto_attack_enabled:
		_fail("BASIC ATTACK did not explicitly enable selected-target assistance.")
		return
	if player.combat_targeting.get_assisted_move_direction(0.2).dot(Vector2.RIGHT) < 0.9:
		_fail("BASIC ATTACK did not steer toward the selected target.")
		return

	Input.action_press("player_move_left")
	await physics_frame
	Input.action_release("player_move_left")
	if player.velocity.x >= 0.0:
		_fail("Manual WASD did not override assisted pursuit while held.")
		return

	player.global_position = Vector2(194.0, 100.0)
	player.velocity = Vector2.ZERO
	await physics_frame
	if player.facing_direction != Vector2.RIGHT or player.attack_component.phase == MeleeAttackComponent.Phase.IDLE:
		_fail("King did not face and basic-attack the selected enemy in range.")
		return

	if not player.combat_targeting.select_hurtbox(second.get_node("Hurtbox") as HurtboxComponent):
		_fail("A second enemy could not replace the first target.")
		return
	if player.combat_targeting.target_actor != second:
		_fail("Multiple enemies created ambiguous target authority instead of replacing it.")
		return
	second.health_component.apply_damage(DamageInfo.new(999.0, player, Vector2.DOWN))
	await process_frame
	if player.combat_targeting.has_valid_target() or hud.target_panel.visible:
		_fail("Dead target cleanup did not clear targeting and its HUD presentation.")
		return
	player.combat_targeting.request_click_move(Vector2(300.0, 100.0))
	if player.combat_targeting.get_click_move_direction(0.2).dot(Vector2.RIGHT) < 0.9:
		_fail("An empty left-click destination did not produce Dota-style movement intent.")
		return

	if hud.attack_button.size != Vector2(54.0, 48.0) or hud.attack_button.text != "1\nATTACK":
		_fail("The compact numbered Attack control does not retain its authored footprint or label.")
		return
	player.attack_component.cancel_attack()
	hud.attack_button.pressed.emit()
	await physics_frame
	if player.combat_targeting.has_valid_target() or player.attack_component.phase == MeleeAttackComponent.Phase.IDLE:
		_fail("Attack with no selection did not swing freely without auto-acquiring an enemy.")
		return

	player.attack_component.cancel_attack()
	first.global_position = Vector2(600.0, 100.0)
	if not player.combat_targeting.select_hurtbox(first.get_node("Hurtbox") as HurtboxComponent):
		_fail("The distant target could not be selected for the assist-radius check.")
		return
	hud.attack_button.pressed.emit()
	if player.combat_targeting.auto_attack_enabled or player.attack_component.phase == MeleeAttackComponent.Phase.IDLE:
		_fail("A distant selected enemy forced pathing instead of allowing a free swing.")
		return

	player.attack_component.cancel_attack()
	first.global_position = Vector2(240.0, 100.0)
	if not player.combat_targeting.select_at_world_position(first.global_position, true):
		_fail("Double-click-style selection could not engage an enemy.")
		return
	if not player.combat_targeting.auto_attack_enabled:
		_fail("Double-click-style selection did not enable auto-attack pursuit.")
		return
	player.combat_targeting.request_click_move(Vector2(320.0, 100.0))
	if player.combat_targeting.has_valid_target() or player.combat_targeting.auto_attack_enabled:
		_fail("Ground clicking did not clear selection and auto attack.")
		return

	print("Assisted combat targeting smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	Input.action_release("player_move_left")
	push_error(message)
	quit(1)
