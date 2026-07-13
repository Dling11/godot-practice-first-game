class_name SanctuaryFlow
extends Node

@export var player: Player
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu
@export var skillkeeper: DialogueNpc
@export var weapon_merchant: DialogueNpc
@export var expedition_altar: ExpeditionAltar
@export var dialogue_panel: DialoguePanel
@export var expedition_menu: ExpeditionMenu

var _active_dialogue_npc: DialogueNpc
var _show_skill_information_after_dialogue := false


func _ready() -> void:
	if (
		player == null
		or combat_hud == null
		or character_menu == null
		or skillkeeper == null
		or weapon_merchant == null
		or expedition_altar == null
		or dialogue_panel == null
		or expedition_menu == null
	):
		push_error("SanctuaryFlow is missing a required hub dependency.")
		return
	combat_hud.bind_player(player)
	skillkeeper.proximity_changed.connect(combat_hud.show_interaction_prompt)
	weapon_merchant.proximity_changed.connect(combat_hud.show_interaction_prompt)
	expedition_altar.proximity_changed.connect(combat_hud.show_interaction_prompt)
	skillkeeper.dialogue_requested.connect(_on_npc_dialogue_requested.bind(skillkeeper, true))
	weapon_merchant.dialogue_requested.connect(_on_npc_dialogue_requested.bind(weapon_merchant, false))
	dialogue_panel.dialogue_closed.connect(_on_dialogue_closed)
	expedition_altar.selection_requested.connect(expedition_menu.open_menu)
	expedition_menu.menu_closed.connect(expedition_altar.restore_prompt)
	combat_hud.show_story_message("SANCTUARY OF THE REMEMBERED VEIL", 2.8)


func _on_npc_dialogue_requested(
	speaker: String,
	lines: Array[String],
	npc: DialogueNpc,
	show_skill_information: bool
) -> void:
	_active_dialogue_npc = npc
	_show_skill_information_after_dialogue = show_skill_information
	dialogue_panel.show_dialogue(speaker, lines)


func _on_dialogue_closed(completed: bool) -> void:
	if is_instance_valid(_active_dialogue_npc):
		_active_dialogue_npc.restore_prompt()
	_active_dialogue_npc = null
	if completed and _show_skill_information_after_dialogue:
		character_menu.open_menu()
	_show_skill_information_after_dialogue = false
