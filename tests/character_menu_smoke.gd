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
	var tab_event := InputEventAction.new()
	tab_event.action = "player_character_menu"
	tab_event.pressed = true
	menu._unhandled_input(tab_event)
	if not menu.visible or not paused:
		_fail("Tab did not open the character menu and pause gameplay.")
		return
	if menu._skill_cards.size() != 4 or root.gui_get_focus_owner() != menu._skill_cards[0]:
		_fail("Character menu did not build and focus its reusable four-slot skill controls.")
		return
	if not menu.has_node("Panel/Margin/Root/Skills/Skill4") or not (menu._skill_cards[0] is SkillSlotCard):
		_fail("Character menu did not present all four authored reusable skill slots.")
		return
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		_fail("Player does not expose the shared four-slot loadout definition.")
		return
	if player.skill_loadout.get_slot(1).ability != player.ability_1_component.definition:
		_fail("Sweeping Cut gameplay and skill presentation do not share one definition.")
		return
	if menu._skill_cards[0].get_node_or_null(menu._skill_cards[0].focus_neighbor_right) != menu._skill_cards[1]:
		_fail("Character skill cards do not provide explicit directional focus navigation.")
		return
	menu._unhandled_input(tab_event)
	if not menu.visible:
		_fail("Tab should open the menu; Esc or the close button should close it.")
		return
	var escape_event := InputEventAction.new()
	escape_event.action = "ui_cancel"
	escape_event.pressed = true
	menu._unhandled_input(escape_event)
	if menu.visible or paused:
		_fail("Esc did not close the character menu and resume gameplay.")
		return
	menu.open_menu()
	menu._skill_cards[1].pressed.emit()
	if not menu.skill_detail_label.text.contains("SLOT 2"):
		_fail("Selecting a reusable skill card did not update the information surface.")
		return
	menu.close_button.pressed.emit()
	if menu.visible or paused:
		_fail("The mouse/keyboard close control did not close the character menu.")
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
