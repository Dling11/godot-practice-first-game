extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const CompactOpawFrames = preload("res://assets/characters/playable/opaw/compact_armless/opaw_compact_armless_sprite_frames.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	root.get_node("WeaponInventory").reset_inventory()
	for action_name in ["player_skill_1", "player_skill_2", "player_skill_3", "player_skill_4", "player_character_menu"]:
		if not InputMap.has_action(action_name):
			_fail("Missing input action: %s" % action_name)
			return
	var has_tab_binding := false
	for input_event: InputEvent in InputMap.action_get_events("player_character_menu"):
		if input_event is InputEventKey and input_event.physical_keycode == KEY_TAB:
			has_tab_binding = true
			break
	if not has_tab_binding:
		_fail("Character-menu action is not physically bound to Tab.")
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
	var physical_tab_event := InputEventKey.new()
	physical_tab_event.physical_keycode = KEY_TAB
	physical_tab_event.pressed = true
	Input.parse_input_event(physical_tab_event)
	await process_frame
	physical_tab_event.pressed = false
	Input.parse_input_event(physical_tab_event)
	if not menu.visible or not paused:
		_fail("The live physical Tab event did not open the character menu and pause gameplay.")
		return
	if menu._equipment_cards.size() != 1 or root.gui_get_focus_owner() != menu._equipment_cards[0]:
		_fail("Character menu did not build and focus Opaw's starter armory item.")
		return
	var identity_title: Label = menu.get_node("Panel/Margin/Root/Header/Identity/Title")
	if identity_title.text != "OPAW":
		_fail("Character menu does not present Opaw's approved mortal identity.")
		return
	var preview_body := menu.get_node("Panel/Margin/Root/PageHost/GearPage/Loadout/Portrait/PortraitCanvas/Body") as AnimatedSprite2D
	if preview_body.sprite_frames != CompactOpawFrames:
		_fail("Character menu preview is not using Opaw's active compact armless model.")
		return
	if menu._equipment_slot_cards.size() != 5 or not menu.gear_page.visible or menu.skills_page.visible:
		_fail("Character menu did not open on the five-slot Gear page.")
		return
	if player.weapon_catalog == null or not player.weapon_catalog.has_valid_layout():
		_fail("Player does not expose a valid authored weapon catalog.")
		return
	if menu.equipment_detail_panel.current_definition != player.get_equipped_weapon_item():
		_fail("Character menu did not initially inspect the equipped weapon.")
		return
	if menu.skills_tab_button.get_node_or_null(menu.skills_tab_button.focus_neighbor_bottom) != menu._equipment_cards[0]:
		_fail("Both tab controls must lead into the visible Gear page.")
		return
	menu._equipment_cards[0].pressed.emit()
	if (
		menu.equipment_detail_panel.current_definition == null
		or menu.equipment_detail_panel.current_definition.rarity != EquipmentDefinition.Rarity.WOOD
		or not menu.equipment_detail_panel.state_label.text.contains("ACTIVE COMBAT")
	):
		_fail("Selecting the Ashwood Blade did not update the active equipment detail surface.")
		return
	menu.skills_tab_button.pressed.emit()
	if menu.gear_page.visible or not menu.skills_page.visible or root.gui_get_focus_owner() != menu._skill_cards[0]:
		_fail("Skills tab did not switch pages and focus the first reusable skill control.")
		return
	if menu.gear_tab_button.get_node_or_null(menu.gear_tab_button.focus_neighbor_bottom) != menu._skill_cards[0]:
		_fail("Both tab controls must lead into the visible Active Skills page.")
		return
	if not menu.has_node("Panel/Margin/Root/PageHost/SkillsPage/Skills/Skill4") or not (menu._skill_cards[0] is SkillSlotCard):
		_fail("Character menu did not present all four authored reusable skill slots.")
		return
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		_fail("Player does not expose the shared four-slot loadout definition.")
		return
	if player.skill_loadout.get_slot(1).ability != player.ability_1_component.definition:
		_fail("Piercing Rush gameplay and skill presentation do not share one definition.")
		return
	var f9_event := InputEventAction.new()
	f9_event.action = "debug_max_progression"
	f9_event.pressed = true
	player._unhandled_input(f9_event)
	await process_frame
	if (
		player.skill_loadout.get_slot(2).ability != player.ability_2_component.definition
		or menu._skill_cards[1].slot_definition.ability != player.ability_2_component.definition
		or not menu._skill_cards[1].text.contains("CONSECUTIVE THRUST")
		or menu._equipment_cards.size() != player.weapon_catalog.weapons.size()
	):
		_fail("F9 did not refresh the paused character menu with the complete test skills and gear.")
		return
	if menu._skill_cards[0].get_node_or_null(menu._skill_cards[0].focus_neighbor_right) != menu._skill_cards[1]:
		_fail("Character skill cards do not provide explicit directional focus navigation.")
		return
	var tab_action_event := InputEventAction.new()
	tab_action_event.action = "player_character_menu"
	tab_action_event.pressed = true
	menu._input(tab_action_event)
	if not menu.visible:
		_fail("Tab should open the menu; Esc or the close button should close it.")
		return
	var escape_event := InputEventAction.new()
	escape_event.action = "ui_cancel"
	escape_event.pressed = true
	menu._input(escape_event)
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

	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(hud)
	hud.character_menu_requested.connect(menu.open_menu)
	hud.character_menu_button.pressed.emit()
	if not menu.visible or not paused:
		_fail("The visible HUD character/bag button did not open the menu.")
		return
	menu.close_menu()
	hud.free()

	player.progression_component.grant_rewards(20, 3)
	if menu.level_label.text != "LEVEL 10 / 10" or menu.coin_label.text != "1002 COINS":
		_fail("Character menu did not react to progression changes.")
		return

	print("Character menu smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	paused = false
	push_error(message)
	quit(1)
