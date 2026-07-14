class_name CharacterMenu
extends Control

## Paused, read-only character and authored skill-path presentation.

const SkillSlotCardScene = preload("res://ui/skills/skill_slot_card.tscn")

signal menu_closed

@export var player: Player

@onready var level_label: Label = %LevelLabel
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var experience_label: Label = %ExperienceLabel
@onready var coin_label: Label = %CoinLabel
@onready var close_button: Button = %CloseButton
@onready var skills_container: HBoxContainer = %Skills
@onready var skill_detail_label: Label = %SkillDetailLabel

var _owns_pause := false
var _skill_cards: Array[SkillSlotCard] = []


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player == null:
		push_error("CharacterMenu requires a Player reference.")
		return
	var progression := player.progression_component
	progression.progression_changed.connect(_update_progression)
	progression.coins_changed.connect(_update_coins)
	_update_progression(progression.level, progression.total_experience, 0)
	_update_coins(progression.coins)
	_build_skill_cards()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()
		return
	if visible or not event.is_action_pressed("player_character_menu"):
		return
	get_viewport().set_input_as_handled()
	open_menu()


func open_menu() -> void:
	if visible:
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	_focus_default_control()


func close_menu() -> void:
	if not visible:
		return
	hide()
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	menu_closed.emit()


func _exit_tree() -> void:
	if _owns_pause and get_tree() != null:
		get_tree().paused = false


func _update_progression(_level: int, _total_experience: int, _next_level_experience: int) -> void:
	if not is_instance_valid(player):
		return
	var progression := player.progression_component
	level_label.text = "LEVEL %d / %d" % [progression.level, progression.definition.maximum_level]
	if progression.level >= progression.definition.maximum_level:
		experience_bar.max_value = 1.0
		experience_bar.value = 1.0
		experience_label.text = "MAXIMUM LEVEL"
		return
	var required := progression.experience_required_for_current_level()
	experience_bar.max_value = required
	experience_bar.value = progression.experience_into_current_level()
	experience_label.text = "%d / %d XP" % [experience_bar.value, required]


func _update_coins(total_coins: int) -> void:
	coin_label.text = "%d COINS" % total_coins


func _build_skill_cards() -> void:
	for child: Node in skills_container.get_children():
		skills_container.remove_child(child)
		child.queue_free()
	_skill_cards.clear()
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		push_error("CharacterMenu requires a complete four-slot skill loadout.")
		return
	var button_group := ButtonGroup.new()
	button_group.allow_unpress = false
	for slot: SkillSlotDefinition in player.skill_loadout.get_ordered_slots():
		var card := SkillSlotCardScene.instantiate() as SkillSlotCard
		skills_container.add_child(card)
		card.configure(slot)
		card.button_group = button_group
		card.slot_selected.connect(_on_skill_slot_selected)
		_skill_cards.append(card)
	_configure_skill_focus()
	if not _skill_cards.is_empty():
		_skill_cards[0].set_pressed_no_signal(true)
		_on_skill_slot_selected(_skill_cards[0].slot_definition)


func _configure_skill_focus() -> void:
	if _skill_cards.is_empty():
		return
	for index in _skill_cards.size():
		var card := _skill_cards[index]
		var previous := _skill_cards[posmod(index - 1, _skill_cards.size())]
		var next := _skill_cards[(index + 1) % _skill_cards.size()]
		card.focus_neighbor_left = card.get_path_to(previous)
		card.focus_neighbor_right = card.get_path_to(next)
		card.focus_neighbor_top = card.get_path_to(close_button)
		card.focus_neighbor_bottom = card.get_path_to(close_button)
	close_button.focus_neighbor_top = close_button.get_path_to(_skill_cards[-1])
	close_button.focus_neighbor_bottom = close_button.get_path_to(_skill_cards[0])


func _focus_default_control() -> void:
	if not _skill_cards.is_empty():
		_skill_cards[0].grab_focus()
	else:
		close_button.grab_focus()


func _on_skill_slot_selected(definition: SkillSlotDefinition) -> void:
	if definition.is_equipped():
		skill_detail_label.text = "SLOT %d • EQUIPPED • PRESS %d DURING COMBAT" % [
			definition.slot_number,
			definition.slot_number,
		]
	else:
		skill_detail_label.text = "SLOT %d • SEALED • %s" % [
			definition.slot_number,
			definition.unlock_hint,
		]
