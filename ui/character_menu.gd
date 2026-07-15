class_name CharacterMenu
extends Control

## Paused character, authored equipment-preview, and skill-information surface.
## It observes player data; inventory, stats, unlocks, and equipment authority remain external.

const SkillSlotCardScene = preload("res://ui/skills/skill_slot_card.tscn")
const EquipmentItemCardScene = preload("res://ui/equipment/equipment_item_card.tscn")
const EquipmentSlotCardScene = preload("res://ui/equipment/equipment_slot_card.tscn")
const EmptySlotIcon = preload("res://assets/ui/icons/states/icon_slot_locked_16x16.png")

signal menu_closed

@export var player: Player

@onready var level_label: Label = %LevelLabel
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var experience_label: Label = %ExperienceLabel
@onready var coin_label: Label = %CoinLabel
@onready var close_button: Button = %CloseButton
@onready var gear_tab_button: Button = %GearTabButton
@onready var skills_tab_button: Button = %SkillsTabButton
@onready var gear_page: Control = %GearPage
@onready var skills_page: Control = %SkillsPage
@onready var equipment_slots: VBoxContainer = %EquipmentSlots
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var equipment_detail_panel: EquipmentDetailPanel = %EquipmentDetailPanel
@onready var skills_container: HBoxContainer = %Skills
@onready var skill_detail_label: Label = %SkillDetailLabel
@onready var portrait_aura: Polygon2D = %PortraitAura

var _owns_pause := false
var _equipment_cards: Array[EquipmentItemCard] = []
var _equipment_slot_cards: Array[EquipmentSlotCard] = []
var _skill_cards: Array[SkillSlotCard] = []
var _active_page := &"gear"
var _portrait_rotation_tween: Tween
var _portrait_pulse_tween: Tween


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
	_configure_tabs()
	_build_equipment_preview()
	_build_skill_cards()
	_show_page(&"gear", false)
	_start_portrait_aura()
	hide()


func _input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()
		return
	if visible or get_tree().paused or not event.is_action_pressed("player_character_menu"):
		return
	get_viewport().set_input_as_handled()
	open_menu()


func open_menu() -> void:
	if visible or get_tree().paused:
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


func _configure_tabs() -> void:
	var tab_group := ButtonGroup.new()
	tab_group.allow_unpress = false
	gear_tab_button.button_group = tab_group
	skills_tab_button.button_group = tab_group
	gear_tab_button.pressed.connect(_show_page.bind(&"gear", true))
	skills_tab_button.pressed.connect(_show_page.bind(&"skills", true))
	gear_tab_button.focus_neighbor_right = gear_tab_button.get_path_to(skills_tab_button)
	gear_tab_button.focus_neighbor_left = gear_tab_button.get_path_to(skills_tab_button)
	skills_tab_button.focus_neighbor_right = skills_tab_button.get_path_to(gear_tab_button)
	skills_tab_button.focus_neighbor_left = skills_tab_button.get_path_to(gear_tab_button)
	close_button.focus_neighbor_bottom = close_button.get_path_to(gear_tab_button)


func _show_page(page: StringName, focus_content: bool = true) -> void:
	_active_page = page
	var showing_gear := page == &"gear"
	gear_page.visible = showing_gear
	skills_page.visible = not showing_gear
	gear_tab_button.set_pressed_no_signal(showing_gear)
	skills_tab_button.set_pressed_no_signal(not showing_gear)
	_refresh_page_focus_links()
	if focus_content and visible:
		_focus_default_control()


func _refresh_page_focus_links() -> void:
	var first_control: Control
	var last_control: Control
	if _active_page == &"gear" and not _equipment_cards.is_empty():
		first_control = _equipment_cards[0]
		last_control = _equipment_cards[-1]
	elif not _skill_cards.is_empty():
		first_control = _skill_cards[0]
		last_control = _skill_cards[-1]
	else:
		return
	gear_tab_button.focus_neighbor_bottom = gear_tab_button.get_path_to(first_control)
	skills_tab_button.focus_neighbor_bottom = skills_tab_button.get_path_to(first_control)
	close_button.focus_neighbor_top = close_button.get_path_to(last_control)


func _build_equipment_preview() -> void:
	_clear_children(equipment_slots)
	_clear_children(inventory_grid)
	_equipment_cards.clear()
	_equipment_slot_cards.clear()
	if player.equipment_showcase == null or not player.equipment_showcase.has_valid_layout():
		push_error("CharacterMenu requires a valid equipment showcase definition.")
		return
	var equipped_weapon := player.equipment_showcase.equipped_weapon
	for slot_name in ["Weapon", "Armor", "Gloves", "Boots", "Accessory"]:
		var slot_card := EquipmentSlotCardScene.instantiate() as EquipmentSlotCard
		equipment_slots.add_child(slot_card)
		slot_card.configure(slot_name, equipped_weapon if slot_name == "Weapon" else null, EmptySlotIcon)
		_equipment_slot_cards.append(slot_card)

	var item_group := ButtonGroup.new()
	item_group.allow_unpress = false
	for item: EquipmentDefinition in player.equipment_showcase.featured_items:
		var card := EquipmentItemCardScene.instantiate() as EquipmentItemCard
		inventory_grid.add_child(card)
		var equipped := item == equipped_weapon
		card.configure(item, equipped)
		card.button_group = item_group
		card.item_selected.connect(_on_equipment_selected)
		_equipment_cards.append(card)
	_configure_equipment_focus()
	if not _equipment_cards.is_empty():
		_equipment_cards[0].set_pressed_no_signal(true)
		_on_equipment_selected(_equipment_cards[0].definition)


func _configure_equipment_focus() -> void:
	for index in _equipment_cards.size():
		var card := _equipment_cards[index]
		var row := index / 2
		var row_start := row * 2
		var row_count := mini(2, _equipment_cards.size() - row_start)
		var column := index - row_start
		var left_index := row_start + posmod(column - 1, row_count)
		var right_index := row_start + ((column + 1) % row_count)
		var up_index := index - 2
		var down_index := index + 2
		card.focus_neighbor_left = card.get_path_to(_equipment_cards[left_index])
		card.focus_neighbor_right = card.get_path_to(_equipment_cards[right_index])
		card.focus_neighbor_top = (
			card.get_path_to(_equipment_cards[up_index])
			if up_index >= 0
			else card.get_path_to(gear_tab_button)
		)
		card.focus_neighbor_bottom = (
			card.get_path_to(_equipment_cards[down_index])
			if down_index < _equipment_cards.size()
			else card.get_path_to(close_button)
		)
	gear_tab_button.focus_neighbor_bottom = gear_tab_button.get_path_to(_equipment_cards[0])
	skills_tab_button.focus_neighbor_bottom = skills_tab_button.get_path_to(_equipment_cards[0])


func _on_equipment_selected(definition: EquipmentDefinition) -> void:
	if definition == null or player.equipment_showcase == null:
		return
	equipment_detail_panel.configure(
		definition,
		definition == player.equipment_showcase.equipped_weapon
	)


func _build_skill_cards() -> void:
	_clear_children(skills_container)
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
		card.focus_neighbor_top = card.get_path_to(skills_tab_button)
		card.focus_neighbor_bottom = card.get_path_to(close_button)
	skills_tab_button.focus_neighbor_bottom = skills_tab_button.get_path_to(_skill_cards[0])
	close_button.focus_neighbor_top = close_button.get_path_to(_skill_cards[-1])


func _focus_default_control() -> void:
	if _active_page == &"gear" and not _equipment_cards.is_empty():
		_equipment_cards[0].grab_focus()
	elif not _skill_cards.is_empty():
		_skill_cards[0].grab_focus()
	else:
		close_button.grab_focus()


func _on_skill_slot_selected(definition: SkillSlotDefinition) -> void:
	if definition.is_equipped():
		skill_detail_label.text = "%s\n%s\nSLOT %d • EQUIPPED • PRESS %d DURING COMBAT" % [
			definition.get_display_name().to_upper(),
			definition.get_description(),
			definition.slot_number,
			definition.slot_number,
		]
	else:
		skill_detail_label.text = "%s\n%s\nSLOT %d • SEALED • %s" % [
			definition.get_display_name().to_upper(),
			definition.get_description(),
			definition.slot_number,
			definition.unlock_hint,
		]


func _start_portrait_aura() -> void:
	if _portrait_rotation_tween != null:
		_portrait_rotation_tween.kill()
	if _portrait_pulse_tween != null:
		_portrait_pulse_tween.kill()
	_portrait_rotation_tween = create_tween().set_loops()
	_portrait_rotation_tween.tween_property(portrait_aura, "rotation", TAU, 8.0).from(0.0)
	_portrait_pulse_tween = create_tween().set_loops()
	_portrait_pulse_tween.tween_property(portrait_aura, "modulate:a", 0.28, 1.2).from(0.72).set_trans(Tween.TRANS_SINE)
	_portrait_pulse_tween.tween_property(portrait_aura, "modulate:a", 0.72, 1.4).set_trans(Tween.TRANS_SINE)


func _clear_children(container: Node) -> void:
	for child: Node in container.get_children():
		container.remove_child(child)
		child.queue_free()
