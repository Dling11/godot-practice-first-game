extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")
const ConsecutiveThrust = preload("res://data/abilities/opaw/warrior/consecutive_thrust.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	await process_frame
	if player.can_awaken_skill_2():
		_fail("Consecutive Thrust became eligible below its Level 3 milestone.")
		return
	player.progression_component.grant_rewards(400, 0)
	if player.progression_component.level != 3 or not player.can_awaken_skill_2():
		_fail("Level 3 did not make Consecutive Thrust eligible for Eira awakening.")
		return

	var menu := CharacterMenuScene.instantiate() as CharacterMenu
	menu.player = player
	root.add_child(menu)
	await process_frame
	menu.open_skillkeeper_menu()
	var slot_two_card: SkillSlotCard
	for card: SkillSlotCard in menu._skill_cards:
		if card.slot_definition.slot_number == 2:
			slot_two_card = card
			break
	if slot_two_card == null:
		_fail("Eira's skill service did not show Opaw's second skill path.")
		return
	slot_two_card.pressed.emit()
	if menu.awaken_button.disabled or menu.awaken_button.text != "AWAKEN SKILL  •  FREE":
		_fail("Eira did not present a clear free Awaken Skill action at Level 3.")
		return
	menu.awaken_button.pressed.emit()
	if (
		player.skill_loadout.get_slot(2).ability != ConsecutiveThrust
		or not root.get_node("StoryState").has_story_flag(&"opaw_consecutive_thrust_awakened")
	):
		_fail("Eira's Awaken Skill action did not unlock and remember Consecutive Thrust.")
		return
	menu.close_menu()

	var replacement := PlayerScene.instantiate() as Player
	root.add_child(replacement)
	replacement.set_physics_process(false)
	await process_frame
	if replacement.skill_loadout.get_slot(2).ability != ConsecutiveThrust:
		_fail("Awakened Consecutive Thrust did not survive a scene-style Player replacement.")
		return

	print("Eira skill awakening smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	paused = false
	push_error(message)
	quit(1)
