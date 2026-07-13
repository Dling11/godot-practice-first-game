extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var run_session := root.get_node("RunSession")
	run_session.reset_run()
	var player := PlayerScene.instantiate() as Player
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(player)
	root.add_child(hud)
	player.set_physics_process(false)
	hud.bind_player(player)
	var progression := player.progression_component
	if progression.level != 1 or progression.coins != 0 or progression.definition.maximum_level != 10:
		_fail("Player progression did not begin as a level-one, zero-coin, level-ten-cap session.")
		return

	progression.grant_rewards(19, 2)
	if progression.level != 1 or progression.total_experience != 19 or progression.coins != 2:
		_fail("XP or coin rewards did not update session state correctly.")
		return
	if hud.get_node("ProgressPanel/Margin/Stack/Header/LevelLabel").text != "LV 1":
		_fail("Progression HUD did not display the current level.")
		return
	progression.grant_rewards(1, 0)
	if progression.level != 2:
		_fail("Crossing the first authored threshold did not level the player.")
		return
	progression.grant_rewards(9999, 0)
	if progression.level != 10:
		_fail("Progression exceeded or failed to reach the level-ten cap.")
		return
	if hud.get_node("ProgressPanel/Margin/Stack/ExperienceLabel").text != "MAX":
		_fail("Progression HUD did not show maximum-level state.")
		return

	run_session.reset_run()
	var reward_player := PlayerScene.instantiate() as Player
	var mireling := MirelingScene.instantiate() as Mireling
	mireling.target = reward_player
	root.add_child(reward_player)
	root.add_child(mireling)
	reward_player.set_physics_process(false)
	var health := mireling.get_node("HealthComponent") as HealthComponent
	health.apply_damage(DamageInfo.new(999.0, reward_player, Vector2.RIGHT))
	await process_frame
	if reward_player.progression_component.total_experience != 8 or reward_player.progression_component.coins != 1:
		_fail("Mireling death did not grant its data-defined 8 XP and 1 coin reward.")
		return

	print("Player progression smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
