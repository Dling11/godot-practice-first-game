extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const PauseMenuScene = preload("res://ui/pause_menu.tscn")
const OpawTest = preload("res://tests/support/opaw_test_configuration.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	OpawTest.apply(player)
	var hud := HudScene.instantiate() as CombatHUD
	var pause_menu := PauseMenuScene.instantiate() as PauseMenu
	root.add_child(player)
	root.add_child(hud)
	root.add_child(pause_menu)
	hud.bind_player(player)
	await process_frame

	if hud.options_button.text != "MENU  [ESC]":
		_fail("The top-right pause entry is not labeled as the compact Menu action.")
		return
	var tray := hud.get_node("ActionTray") as Control
	var dash_rect := hud.dash_slot.get_global_rect()
	var skill_rect := hud.get_skill_slot(1).get_global_rect()
	var last_skill_rect := hud.get_skill_slot(4).get_global_rect()
	var tray_rect := tray.get_global_rect()
	if (
		dash_rect.end.x > skill_rect.position.x
		or skill_rect.position.x - dash_rect.end.x < 16.0
		or not tray_rect.encloses(dash_rect)
		or not tray_rect.encloses(skill_rect)
		or not tray_rect.encloses(last_skill_rect)
		or hud.dash_slot.size != Vector2(52.0, 48.0)
	):
		_fail("Dash is not visibly separated from Skill 1 or an action escapes the tray.")
		return

	hud.options_button.pressed.emit()
	if not pause_menu.visible or not paused:
		_fail("The top-right Menu button did not open the shared pause menu.")
		return
	pause_menu.close_menu()

	hud.dash_slot.activation_button.pressed.emit()
	if (
		not player.evade_component.is_dashing()
		or not hud.dash_slot.activation_button.disabled
		or hud.dash_slot.state_label.text == "READY"
	):
		_fail("The clickable dash HUD control did not start dash and display its cooldown.")
		return
	player.evade_component.cancel_evade()
	if hud.dash_slot.activation_button.disabled or hud.dash_slot.state_label.text != "READY":
		_fail("The dash HUD control did not return to Ready after cancellation.")
		return

	var restraint_source := Node.new()
	root.add_child(restraint_source)
	if not player.try_begin_root_restraint(restraint_source, 5):
		_fail("HUD test could not begin the reusable root restraint.")
		return
	if hud.dash_slot.key_label.text != "TAP" or hud.dash_slot.state_label.text != "BREAK 0/5":
		_fail("Root restraint did not convert the visible Dash slot into its tap indicator.")
		return
	for press in range(5):
		hud.dash_slot.activation_button.pressed.emit()
	if player.is_restrained() or hud.dash_slot.key_label.text != "SPC" or hud.dash_slot.state_label.text != "READY":
		_fail("Five visible Dash-slot taps did not restore UI: restrained=%s key=%s state=%s" % [player.is_restrained(), hud.dash_slot.key_label.text, hud.dash_slot.state_label.text])
		return
	player.evade_component._cooldown_time_remaining = 0.6
	hud.dash_slot.show_restraint_progress(5, 5)
	hud.dash_slot.clear_restraint_progress()
	if not hud.dash_slot.activation_button.disabled or hud.dash_slot.state_label.text == "READY":
		_fail("Clearing restraint presentation discarded the Dash action's real cooldown state.")
		return
	player.evade_component.cancel_evade()

	var debug_event := InputEventAction.new()
	debug_event.action = "debug_max_progression"
	debug_event.pressed = true
	player._unhandled_input(debug_event)
	var skill_two := hud.get_skill_slot(2)
	skill_two.activation_button.pressed.emit()
	if not player.ability_2_component.is_casting() or player.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
		_fail("Clicking a skill HUD slot did not cast only the skill.")
		return

	print("HUD action controls smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	paused = false
	push_error(message)
	quit(1)
