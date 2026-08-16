class_name SanctuaryFlow
extends Node

@export var player: Player
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu
@export var skillkeeper: DialogueNpc
@export var weapon_merchant: DialogueNpc
@export var rootweaver: DialogueNpc
@export var expedition_altar: ExpeditionAltar
@export var dialogue_panel: DialoguePanel
@export var expedition_menu: ExpeditionMenu
@export var rootforge_menu: RootforgeMenu
@export var admin_panel: Control
@export var admin_lab_button: Button

var _active_dialogue_npc: DialogueNpc
var _show_skill_information_after_dialogue := false
var _show_rootforge_after_dialogue := false


func _unhandled_input(event: InputEvent) -> void:
	if not OS.is_debug_build():
		return
	if event.is_action_pressed("debug_toggle_admin"):
		var admin_state := get_node_or_null("/root/DebugAdminState")
		if admin_state != null:
			var enabled := bool(admin_state.call("toggle"))
			_update_admin_visibility(enabled)
			combat_hud.show_story_message(
				"ADMIN MODE ON  |  COMBAT LAB [F7]" if enabled else "ADMIN MODE OFF",
				2.0
			)
		get_viewport().set_input_as_handled()
		return
	if not _is_admin_enabled():
		return
	if event.is_action_pressed("debug_combat_lab"):
		get_viewport().set_input_as_handled()
		_transition_to("res://levels/combat_lab/combat_lab.tscn")
	elif event.is_action_pressed("debug_stage_5_boss_arena"):
		get_viewport().set_input_as_handled()
		_transition_to("res://levels/stage_5_boss_test/stage_5_boss_test.tscn")


func _ready() -> void:
	if (
		player == null
		or combat_hud == null
		or character_menu == null
		or skillkeeper == null
		or weapon_merchant == null
		or rootweaver == null
		or expedition_altar == null
		or dialogue_panel == null
		or expedition_menu == null
		or rootforge_menu == null
		or admin_panel == null
		or admin_lab_button == null
	):
		push_error("SanctuaryFlow is missing a required hub dependency.")
		return
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		# Defensive rollback for any expedition transition that bypassed the
		# authored chest commit or explicit Abandon flow.
		loot_service.abort_expedition_rewards()
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.remember_story(&"awakened_in_sanctuary")
	var weapon_inventory := get_node_or_null("/root/WeaponInventory")
	if weapon_inventory != null:
		weapon_inventory.weapon_acquired.connect(_on_safe_profile_changed)
		weapon_inventory.weapon_equipped.connect(_on_safe_profile_changed)
	_restore_player_at_sanctuary()
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	skillkeeper.proximity_changed.connect(combat_hud.show_interaction_prompt)
	weapon_merchant.proximity_changed.connect(combat_hud.show_interaction_prompt)
	rootweaver.proximity_changed.connect(combat_hud.show_interaction_prompt)
	expedition_altar.proximity_changed.connect(combat_hud.show_interaction_prompt)
	skillkeeper.dialogue_requested.connect(_on_npc_dialogue_requested.bind(skillkeeper, true, false))
	weapon_merchant.dialogue_requested.connect(_on_npc_dialogue_requested.bind(weapon_merchant, false, false))
	rootweaver.dialogue_requested.connect(_on_npc_dialogue_requested.bind(rootweaver, false, true))
	dialogue_panel.dialogue_closed.connect(_on_dialogue_closed)
	rootforge_menu.menu_closed.connect(rootweaver.restore_prompt)
	admin_lab_button.pressed.connect(_open_combat_lab)
	var admin_state := get_node_or_null("/root/DebugAdminState")
	if admin_state != null:
		admin_state.connect("enabled_changed", _update_admin_visibility)
	_update_admin_visibility(_is_admin_enabled())
	expedition_altar.selection_requested.connect(expedition_menu.open_menu)
	expedition_menu.menu_closed.connect(expedition_altar.restore_prompt)
	combat_hud.show_story_message("SANCTUARY OF THE REMEMBERED VEIL", 2.8)
	_save_profile_at_sanctuary()


func _restore_player_at_sanctuary() -> void:
	## Sanctuary is a recovery checkpoint, including Continue. Heal before the
	## safe-point write so a prior expedition's attrition is not re-saved on boot.
	player.health_component.set_current_health(player.health_component.maximum_health)


func _is_admin_enabled() -> bool:
	var admin_state := get_node_or_null("/root/DebugAdminState")
	return OS.is_debug_build() and admin_state != null and bool(admin_state.get("enabled"))


func _update_admin_visibility(enabled: bool) -> void:
	admin_panel.visible = OS.is_debug_build() and enabled


func _open_combat_lab() -> void:
	if _is_admin_enabled():
		_transition_to("res://levels/combat_lab/combat_lab.tscn")


func _transition_to(scene_path: String) -> void:
	var transition := get_node_or_null("/root/SceneTransition")
	if transition != null:
		transition.call("transition_to", scene_path)


func _on_npc_dialogue_requested(
	speaker: String,
	lines: Array[String],
	portrait: Texture2D,
	npc: DialogueNpc,
	show_skill_information: bool,
	show_rootforge: bool
) -> void:
	_active_dialogue_npc = npc
	_show_skill_information_after_dialogue = show_skill_information
	_show_rootforge_after_dialogue = show_rootforge
	dialogue_panel.show_dialogue(speaker, lines, portrait)


func _on_dialogue_closed(completed: bool) -> void:
	if (
		is_instance_valid(_active_dialogue_npc)
		and not (completed and _show_rootforge_after_dialogue)
	):
		_active_dialogue_npc.restore_prompt()
	_active_dialogue_npc = null
	if completed and _show_skill_information_after_dialogue:
		character_menu.open_skillkeeper_menu()
	elif completed and _show_rootforge_after_dialogue:
		rootforge_menu.open_menu()
	_show_skill_information_after_dialogue = false
	_show_rootforge_after_dialogue = false


func _on_safe_profile_changed(_first: Variant = null, _second: Variant = null) -> void:
	_save_profile_at_sanctuary()


func _save_profile_at_sanctuary() -> void:
	var save_service := get_node_or_null("/root/SaveService")
	if save_service != null:
		save_service.save_profile()
