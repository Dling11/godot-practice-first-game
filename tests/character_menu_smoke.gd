extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	for action_name in ["player_skill_1", "player_skill_2", "player_skill_3", "player_skill_4", "player_character_menu"]:
		if not InputMap.has_action(action_name):
			_fail("Missing input action: %s" % action_name)
			return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	var menu := CharacterMenuScene.instantiate() as CharacterMenu
	menu.player = player
	root.add_child(menu)
	await process_frame

	if menu.visible:
		_fail("Character menu should begin hidden.")
		return
	menu.open_menu()
	if not menu.visible or not paused:
		_fail("Opening the character menu did not display it and pause gameplay.")
		return
	if not menu.has_node("Panel/Margin/Root/Skills/Skill4"):
		_fail("Character menu did not present all four authored skill slots.")
		return
	menu.close_menu()
	if menu.visible or paused:
		_fail("Closing the character menu did not resume gameplay.")
		return

	player.progression_component.grant_rewards(20, 3)
	if menu.level_label.text != "LEVEL 2 / 10" or menu.coin_label.text != "3 COINS":
		_fail("Character menu did not react to progression changes.")
		return

	print("Character menu smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	paused = false
	push_error(message)
	quit(1)
