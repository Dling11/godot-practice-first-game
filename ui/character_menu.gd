class_name CharacterMenu
extends Control

## Paused Character & Bag and Skills surface. WeaponInventory and
## MaterialInventory own mutable state; this menu only selects, presents, and
## requests safe equips.

const SkillSlotCardScene = preload("res://ui/skills/skill_slot_card.tscn")
const InventorySlotButtonScene = preload("res://ui/inventory/inventory_slot_button.tscn")
const EquipmentSlotCardScene = preload("res://ui/equipment/equipment_slot_card.tscn")
const EmptySlotIcon = preload("res://assets/ui/icons/states/icon_slot_locked_16x16.png")
const MaterialCatalog: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const Stage5CoreEquipment: EquipmentCatalogDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core_catalog.tres"
)
const BAG_CAPACITY := 24
const BAG_COLUMNS := 12
const EQUIPMENT_SLOT_NAMES := [
	"Head",
	"Weapon Essence",
	"Plate",
	"Gloves",
	"Leggings",
	"Boots",
	"Bracer",
	"Amulet",
	"Ring",
	"Talisman",
]
const EQUIPMENT_SLOT_POSITIONS := [
	Vector2(93, 0),
	Vector2(245, 0),
	Vector2(93, 34),
	Vector2(93, 68),
	Vector2(93, 102),
	Vector2(93, 136),
	Vector2(397, 0),
	Vector2(397, 42),
	Vector2(397, 84),
	Vector2(397, 126),
]
const EQUIPMENT_SLOT_TYPES := [
	EquipmentDefinition.Slot.HEAD,
	EquipmentDefinition.Slot.WEAPON,
	EquipmentDefinition.Slot.PLATE,
	EquipmentDefinition.Slot.GLOVES,
	EquipmentDefinition.Slot.LEGGINGS,
	EquipmentDefinition.Slot.BOOTS,
	EquipmentDefinition.Slot.BRACER,
	EquipmentDefinition.Slot.AMULET,
	EquipmentDefinition.Slot.RING,
	EquipmentDefinition.Slot.TALISMAN,
]
const WEAPON_ESSENCE_SLOT_INDEX := 1
const FUTURE_SKILL_TIERS := [
	{
		"node_name": "UltimateSlot",
		"display_name": "Ultimate",
		"description": "A future high-power skill tier. No ability or input is assigned yet.",
	},
	{
		"node_name": "RealityBreakingSlot",
		"display_name": "Reality Breaking",
		"description": "A future finisher tier beyond Ultimate. No ability or input is assigned yet.",
	},
]

signal menu_closed
signal skill_awakened(skill_name: String)

@export var player: Player

@onready var level_label: Label = %LevelLabel
@onready var vitality_label: Label = %VitalityLabel
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var experience_label: Label = %ExperienceLabel
@onready var coin_label: Label = %CoinLabel
@onready var close_button: Button = %CloseButton
@onready var gear_tab_button: Button = %GearTabButton
@onready var skills_tab_button: Button = %SkillsTabButton
@onready var gear_page: Control = %GearPage
@onready var skills_page: Control = %SkillsPage
@onready var equipment_slots: Control = %EquipmentSlots
@onready var inventory_grid: GridContainer = %InventoryGrid
@onready var equipment_detail_panel: EquipmentDetailPanel = %EquipmentDetailPanel
@onready var bag_capacity_label: Label = %BagCapacityLabel
@onready var bag_empty_label: Label = %BagEmptyLabel
@onready var all_filter_button: Button = %AllFilterButton
@onready var equipment_filter_button: Button = %EquipmentFilterButton
@onready var materials_filter_button: Button = %MaterialsFilterButton
@onready var consumables_filter_button: Button = %ConsumablesFilterButton
@onready var key_filter_button: Button = %KeyFilterButton
@onready var sort_button: Button = %SortButton
@onready var skills_container: HBoxContainer = %Skills
@onready var skill_detail_label: Label = %SkillDetailLabel
@onready var awaken_button: Button = %AwakenButton
@onready var portrait_aura: Polygon2D = %PortraitAura
@onready var weapon_preview: Sprite2D = %WeaponPreview
@onready var attack_label: Label = %AttackLabel

var _owns_pause := false
var _inventory_slots: Array[InventorySlotButton] = []
var _selectable_inventory_slots: Array[InventorySlotButton] = []
var _equipment_cards: Array[InventorySlotButton] = []
var _material_cards: Array[InventorySlotButton] = []
var _equipment_slot_cards: Array[EquipmentSlotCard] = []
var _skill_cards: Array[SkillSlotCard] = []
var _future_skill_cards: Array[SkillSlotCard] = []
var _active_page := &"gear"
var _active_inventory_filter := &"all"
var _inventory_sort_mode := &"slot"
var _portrait_rotation_tween: Tween
var _portrait_pulse_tween: Tween
var _selected_equipment: EquipmentDefinition
var _selected_material: MaterialDefinition
var _skillkeeper_service_active := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player == null:
		push_error("CharacterMenu requires a Player reference.")
		return
	var progression := player.progression_component
	progression.progression_changed.connect(_update_progression)
	progression.coins_changed.connect(_update_coins)
	player.health_component.health_changed.connect(_update_vitality)
	player.skill_loadout_changed.connect(_on_skill_loadout_changed)
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	if material_inventory != null:
		material_inventory.material_quantity_changed.connect(_on_material_quantity_changed)
		material_inventory.inventory_reset.connect(_on_material_inventory_reset)
	var gear_inventory := get_node_or_null("/root/GearInventory")
	if gear_inventory != null:
		gear_inventory.gear_acquired.connect(_on_gear_inventory_changed.unbind(1))
		gear_inventory.gear_equipped.connect(_on_gear_inventory_changed.unbind(3))
		gear_inventory.inventory_reset.connect(_on_gear_inventory_changed)
	_update_progression(progression.level, progression.total_experience, 0)
	_update_coins(progression.coins)
	_update_vitality(
		player.health_component.current_health,
		player.health_component.maximum_health
	)
	_configure_tabs()
	_configure_inventory_filters()
	sort_button.pressed.connect(_cycle_inventory_sort)
	equipment_detail_panel.equip_requested.connect(_on_equipment_equip_requested)
	awaken_button.pressed.connect(_on_awaken_button_pressed)
	_build_character_bag()
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
	_build_character_bag()
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	show()
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	_focus_default_control()


func open_skillkeeper_menu() -> void:
	if visible or get_tree().paused:
		return
	_skillkeeper_service_active = true
	_show_page(&"skills", false)
	open_menu()


func close_menu() -> void:
	if not visible:
		return
	hide()
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	_skillkeeper_service_active = false
	awaken_button.hide()
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


func _update_vitality(current: float, maximum: float) -> void:
	vitality_label.text = "HP %d/%d" % [ceili(current), ceili(maximum)]


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


func _configure_inventory_filters() -> void:
	var filter_group := ButtonGroup.new()
	filter_group.allow_unpress = false
	var filters := {
		all_filter_button: &"all",
		equipment_filter_button: &"equipment",
		materials_filter_button: &"materials",
		consumables_filter_button: &"consumables",
		key_filter_button: &"key",
	}
	for button: Button in filters:
		button.button_group = filter_group
		button.pressed.connect(_set_inventory_filter.bind(filters[button]))
	all_filter_button.set_pressed_no_signal(true)


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


func _set_inventory_filter(filter_name: StringName) -> void:
	if _active_inventory_filter == filter_name:
		return
	_active_inventory_filter = filter_name
	_build_inventory_grid()
	if visible and _active_page == &"gear":
		_focus_default_control()


func _refresh_page_focus_links() -> void:
	var first_control: Control
	var last_control: Control
	if _active_page == &"gear" and not _selectable_inventory_slots.is_empty():
		first_control = _selectable_inventory_slots[0]
		last_control = _selectable_inventory_slots[-1]
	elif not _skill_cards.is_empty():
		first_control = _skill_cards[0]
		last_control = _skill_cards[-1]
	else:
		return
	gear_tab_button.focus_neighbor_bottom = gear_tab_button.get_path_to(first_control)
	skills_tab_button.focus_neighbor_bottom = skills_tab_button.get_path_to(first_control)
	close_button.focus_neighbor_top = close_button.get_path_to(last_control)


func _build_character_bag() -> void:
	_build_equipment_slots()
	_build_inventory_grid()


func _build_equipment_slots() -> void:
	_clear_children(equipment_slots)
	_equipment_slot_cards.clear()
	if player.weapon_catalog == null or not player.weapon_catalog.has_valid_layout():
		push_error("CharacterMenu requires a valid weapon catalog definition.")
		return
	var equipped_weapon := player.get_equipped_weapon_item()
	for index in EQUIPMENT_SLOT_NAMES.size():
		var slot_type: EquipmentDefinition.Slot = EQUIPMENT_SLOT_TYPES[index]
		var equipped_item := (
			equipped_weapon
			if slot_type == EquipmentDefinition.Slot.WEAPON
			else player.get_equipped_gear(slot_type)
		)
		var slot_card := EquipmentSlotCardScene.instantiate() as EquipmentSlotCard
		equipment_slots.add_child(slot_card)
		slot_card.position = EQUIPMENT_SLOT_POSITIONS[index]
		slot_card.size = Vector2(110, 31)
		slot_card.configure(
			EQUIPMENT_SLOT_NAMES[index],
			slot_type,
			equipped_item,
			EmptySlotIcon
		)
		slot_card.equipment_dropped.connect(_on_equipment_equip_requested)
		_equipment_slot_cards.append(slot_card)


func _build_inventory_grid() -> void:
	_clear_children(inventory_grid)
	_inventory_slots.clear()
	_selectable_inventory_slots.clear()
	_equipment_cards.clear()
	_material_cards.clear()
	if player.weapon_catalog == null or not player.weapon_catalog.has_valid_layout():
		return
	var button_group := ButtonGroup.new()
	button_group.allow_unpress = false
	var weapon_inventory := get_node_or_null("/root/WeaponInventory")
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	var selected_slot: InventorySlotButton
	var owned_equipment := _get_sorted_owned_equipment(weapon_inventory)

	if _active_inventory_filter in [&"all", &"equipment"]:
		for item: EquipmentDefinition in owned_equipment:
			var slot := _create_inventory_slot(button_group)
			var equipped := _is_equipment_equipped(item)
			slot.configure_equipment(
				item,
				equipped,
				item.is_compatible_with(player.character_class_id)
			)
			slot.equipment_selected.connect(_on_equipment_selected)
			_equipment_cards.append(slot)
			if item == _selected_equipment or (
				_selected_equipment == null and equipped
			):
				selected_slot = slot

	if _active_inventory_filter in [&"all", &"materials"] and material_inventory != null:
		var sorted_materials := _get_sorted_owned_materials(material_inventory)
		for material: MaterialDefinition in sorted_materials:
			var quantity: int = int(material_inventory.get_quantity(material.material_id))
			if quantity <= 0:
				continue
			var slot := _create_inventory_slot(button_group)
			slot.configure_material(material, quantity)
			slot.material_selected.connect(_on_material_selected)
			_material_cards.append(slot)
			if material == _selected_material:
				selected_slot = slot

	var visible_item_count := _selectable_inventory_slots.size()
	for _index in range(visible_item_count, BAG_CAPACITY):
		var empty_slot := InventorySlotButtonScene.instantiate() as InventorySlotButton
		inventory_grid.add_child(empty_slot)
		empty_slot.configure_empty()
		_inventory_slots.append(empty_slot)

	bag_capacity_label.text = "BAG  %d / %d" % [owned_equipment.size(), BAG_CAPACITY]
	bag_empty_label.visible = visible_item_count == 0
	bag_empty_label.text = _get_empty_filter_message()
	if selected_slot == null and not _selectable_inventory_slots.is_empty():
		selected_slot = _selectable_inventory_slots[0]
	if selected_slot != null:
		selected_slot.set_pressed_no_signal(true)
		if selected_slot.kind == InventorySlotButton.Kind.EQUIPMENT:
			_on_equipment_selected(selected_slot.equipment_definition)
		elif selected_slot.kind == InventorySlotButton.Kind.MATERIAL:
			_on_material_selected(selected_slot.material_definition)
	elif player.get_equipped_weapon_item() != null:
		_refresh_equipment_detail(player.get_equipped_weapon_item())
	_configure_inventory_focus()
	_refresh_page_focus_links()


func _create_inventory_slot(button_group: ButtonGroup) -> InventorySlotButton:
	var slot := InventorySlotButtonScene.instantiate() as InventorySlotButton
	inventory_grid.add_child(slot)
	slot.button_group = button_group
	_inventory_slots.append(slot)
	_selectable_inventory_slots.append(slot)
	return slot


func _get_sorted_owned_equipment(weapon_inventory: Node) -> Array[EquipmentDefinition]:
	var result: Array[EquipmentDefinition] = []
	if weapon_inventory != null:
		for item: EquipmentDefinition in player.weapon_catalog.weapons:
			if weapon_inventory.owns_weapon(item.item_id):
				result.append(item)
	var gear_inventory := get_node_or_null("/root/GearInventory")
	if gear_inventory != null:
		result.append_array(gear_inventory.get_owned_items())
	result.sort_custom(_equipment_sort_less)
	return result


func _get_sorted_owned_materials(material_inventory: Node) -> Array[MaterialDefinition]:
	var result: Array[MaterialDefinition] = []
	for material: MaterialDefinition in MaterialCatalog.materials:
		if material_inventory.get_quantity(material.material_id) > 0:
			result.append(material)
	result.sort_custom(_material_sort_less.bind(material_inventory))
	return result


func _equipment_sort_less(a: EquipmentDefinition, b: EquipmentDefinition) -> bool:
	match _inventory_sort_mode:
		&"name":
			return a.display_name.naturalnocasecmp_to(b.display_name) < 0
		&"rarity":
			if a.rarity != b.rarity:
				return a.rarity > b.rarity
		&"quantity":
			pass
	if a.slot != b.slot:
		return a.slot < b.slot
	return a.display_name.naturalnocasecmp_to(b.display_name) < 0


func _material_sort_less(a: MaterialDefinition, b: MaterialDefinition, inventory: Node) -> bool:
	match _inventory_sort_mode:
		&"name":
			return a.display_name.naturalnocasecmp_to(b.display_name) < 0
		&"rarity":
			if a.rarity != b.rarity:
				return a.rarity > b.rarity
		&"quantity":
			var a_quantity: int = inventory.get_quantity(a.material_id)
			var b_quantity: int = inventory.get_quantity(b.material_id)
			if a_quantity != b_quantity:
				return a_quantity > b_quantity
	if a.material_family != b.material_family:
		return a.material_family < b.material_family
	return a.display_name.naturalnocasecmp_to(b.display_name) < 0


func _cycle_inventory_sort() -> void:
	var modes: Array[StringName] = [&"slot", &"name", &"rarity", &"quantity"]
	_inventory_sort_mode = modes[(modes.find(_inventory_sort_mode) + 1) % modes.size()]
	sort_button.text = "SORT: %s" % String(_inventory_sort_mode).to_upper()
	_build_inventory_grid()


func _is_equipment_equipped(item: EquipmentDefinition) -> bool:
	if item == null:
		return false
	if item.slot == EquipmentDefinition.Slot.WEAPON:
		return player.get_equipped_weapon_item() == item
	return player.get_equipped_gear(item.slot) == item


func _get_empty_filter_message() -> String:
	match _active_inventory_filter:
		&"materials":
			return "NO MATERIALS COLLECTED • MONSTER DROPS ARRIVE WITH STAGE LOOT"
		&"consumables":
			return "CONSUMABLE POUCH NOT YET UNLOCKED"
		&"key":
			return "NO KEY ITEMS"
	return "NO ITEMS IN THIS VIEW"


func _configure_inventory_focus() -> void:
	if _selectable_inventory_slots.is_empty():
		return
	for index in _selectable_inventory_slots.size():
		var slot := _selectable_inventory_slots[index]
		var row := index / BAG_COLUMNS
		var row_start := row * BAG_COLUMNS
		var row_count := mini(
			BAG_COLUMNS,
			_selectable_inventory_slots.size() - row_start
		)
		var column := index - row_start
		var left_index := row_start + posmod(column - 1, row_count)
		var right_index := row_start + ((column + 1) % row_count)
		var up_index := index - BAG_COLUMNS
		var down_index := index + BAG_COLUMNS
		slot.focus_neighbor_left = slot.get_path_to(_selectable_inventory_slots[left_index])
		slot.focus_neighbor_right = slot.get_path_to(_selectable_inventory_slots[right_index])
		slot.focus_neighbor_top = (
			slot.get_path_to(_selectable_inventory_slots[up_index])
			if up_index >= 0
			else slot.get_path_to(all_filter_button)
		)
		slot.focus_neighbor_bottom = (
			slot.get_path_to(_selectable_inventory_slots[down_index])
			if down_index < _selectable_inventory_slots.size()
			else slot.get_path_to(close_button)
		)


func _on_equipment_selected(definition: EquipmentDefinition) -> void:
	if definition == null or player.weapon_catalog == null:
		return
	_selected_equipment = definition
	_selected_material = null
	_refresh_equipment_detail(definition)


func _on_material_selected(definition: MaterialDefinition) -> void:
	if definition == null:
		return
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	if material_inventory == null:
		return
	_selected_material = definition
	_selected_equipment = null
	equipment_detail_panel.configure_material(
		definition,
		material_inventory.get_quantity(definition.material_id)
	)


func _on_equipment_equip_requested(definition: EquipmentDefinition) -> void:
	if definition == null or not definition.is_compatible_with(player.character_class_id):
		return
	if player.equip_owned_equipment(definition):
		_selected_equipment = definition
		_selected_material = null
		_build_equipment_slots()
		_build_inventory_grid()


func _refresh_equipment_presentation(selected: EquipmentDefinition) -> void:
	var equipped := player.get_equipped_weapon_item()
	if equipped == null:
		return
	for card: InventorySlotButton in _equipment_cards:
		card.configure_equipment(
			card.equipment_definition,
			_is_equipment_equipped(card.equipment_definition),
			card.equipment_definition.is_compatible_with(player.character_class_id)
		)
		card.set_pressed_no_signal(card.equipment_definition == selected)
	if _equipment_slot_cards.size() > WEAPON_ESSENCE_SLOT_INDEX:
		_equipment_slot_cards[WEAPON_ESSENCE_SLOT_INDEX].configure(
			"Weapon Essence",
			EquipmentDefinition.Slot.WEAPON,
			equipped,
			EmptySlotIcon
		)
	weapon_preview.texture = equipped.weapon_definition.world_texture
	weapon_preview.position = equipped.weapon_definition.sprite_offset_from_grip
	attack_label.text = "MOUSE: %s" % equipped.display_name.to_upper()
	_refresh_equipment_detail(selected)


func _refresh_equipment_detail(selected: EquipmentDefinition) -> void:
	var equipped := player.get_equipped_weapon_item()
	if equipped == null or selected == null:
		return
	weapon_preview.texture = equipped.weapon_definition.world_texture
	weapon_preview.position = equipped.weapon_definition.sprite_offset_from_grip
	attack_label.text = "MOUSE: %s" % equipped.display_name.to_upper()
	equipment_detail_panel.configure(
		selected,
		_is_equipment_equipped(selected),
		selected.is_compatible_with(player.character_class_id)
	)


func _on_material_quantity_changed(
	_material_id: StringName,
	_quantity: int
) -> void:
	if visible:
		_build_inventory_grid()


func _on_material_inventory_reset() -> void:
	_selected_material = null
	if visible:
		_build_inventory_grid()


func _on_gear_inventory_changed() -> void:
	if visible:
		_build_character_bag()


func _build_skill_cards() -> void:
	_clear_children(skills_container)
	_skill_cards.clear()
	_future_skill_cards.clear()
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
	for tier: Dictionary in FUTURE_SKILL_TIERS:
		var preview := SkillSlotCardScene.instantiate() as SkillSlotCard
		skills_container.add_child(preview)
		preview.configure_locked_preview(
			tier["node_name"],
			tier["display_name"],
			tier["description"]
		)
		_future_skill_cards.append(preview)
	_configure_skill_focus()
	if not _skill_cards.is_empty():
		_skill_cards[0].set_pressed_no_signal(true)
		_on_skill_slot_selected(_skill_cards[0].slot_definition)


func _on_skill_loadout_changed() -> void:
	_build_character_bag()
	_build_skill_cards()
	if visible:
		_refresh_page_focus_links()


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
	if _active_page == &"gear" and not _selectable_inventory_slots.is_empty():
		_selectable_inventory_slots[0].grab_focus()
	elif not _skill_cards.is_empty():
		_skill_cards[0].grab_focus()
	else:
		close_button.grab_focus()


func _on_skill_slot_selected(definition: SkillSlotDefinition) -> void:
	_selected_skill = definition
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
	_refresh_awaken_button()


var _selected_skill: SkillSlotDefinition


func _refresh_awaken_button() -> void:
	awaken_button.visible = _skillkeeper_service_active
	if not awaken_button.visible or _selected_skill == null:
		return
	if _selected_skill.is_equipped():
		awaken_button.disabled = true
		awaken_button.text = "SKILL AWAKENED"
	elif _selected_skill.slot_number != 2:
		awaken_button.disabled = true
		awaken_button.text = "PATH NOT YET AUTHORED"
	elif player.progression_component.level < 3:
		awaken_button.disabled = true
		awaken_button.text = "REQUIRES LEVEL 3"
	else:
		awaken_button.disabled = false
		awaken_button.text = "AWAKEN SKILL  •  FREE"


func _on_awaken_button_pressed() -> void:
	if _selected_skill == null or _selected_skill.slot_number != 2:
		return
	if not player.awaken_skill_2():
		return
	for card: SkillSlotCard in _skill_cards:
		if card.slot_definition.slot_number == 2:
			card.set_pressed_no_signal(true)
			_on_skill_slot_selected(card.slot_definition)
			break
	skill_awakened.emit("CONSECUTIVE THRUST")


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
