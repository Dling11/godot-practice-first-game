class_name RootforgeMenu
extends Control

## Segment 4 exposes recipe knowledge and current material readiness without
## performing a crafting transaction. The disabled primary action is an honest
## milestone preview, not a hidden mutation path.

signal menu_closed

const ALL_CATEGORIES := -1
const Stage5CoreEquipment: EquipmentCatalogDefinition = preload(
	"res://data/items/equipment/forest/stage_5_core_catalog.tres"
)

@export var catalog: RecipeCatalogDefinition

@onready var material_summary_label: Label = %MaterialSummaryLabel
@onready var recipe_list: VBoxContainer = %RecipeList
@onready var recipe_name_label: Label = %RecipeNameLabel
@onready var recipe_meta_label: Label = %RecipeMetaLabel
@onready var output_preview: Control = %OutputPreview
@onready var output_icon: TextureRect = %OutputIcon
@onready var output_slot_label: Label = %OutputSlotLabel
@onready var output_stats_label: Label = %OutputStatsLabel
@onready var recipe_description_label: Label = %RecipeDescriptionLabel
@onready var recipe_state_label: Label = %RecipeStateLabel
@onready var ingredient_list: VBoxContainer = %IngredientList
@onready var milestone_label: Label = %MilestoneLabel
@onready var primary_action_button: Button = %PrimaryActionButton
@onready var close_button: Button = %CloseButton
@onready var all_filter_button: Button = %AllFilterButton
@onready var weapons_filter_button: Button = %WeaponsFilterButton
@onready var armor_filter_button: Button = %ArmorFilterButton
@onready var accessories_filter_button: Button = %AccessoriesFilterButton

var recipe_buttons: Array[Button] = []
var _button_recipes: Array[RecipeDefinition] = []
var selected_recipe: RecipeDefinition
var _active_category := ALL_CATEGORIES
var _owns_pause := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if catalog == null or not catalog.has_valid_layout():
		push_error("RootforgeMenu requires a valid recipe catalog.")
		return
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	if material_inventory != null:
		material_inventory.material_quantity_changed.connect(_on_material_quantity_changed)
		material_inventory.inventory_reset.connect(_on_material_inventory_reset)
	var recipe_discovery := get_node_or_null("/root/RecipeDiscovery")
	if recipe_discovery != null:
		recipe_discovery.recipe_discovered.connect(_on_recipe_discovered)
		recipe_discovery.discovery_reset.connect(_on_recipe_discovery_reset)
	_build_recipe_list()
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()


func open_menu() -> void:
	if visible:
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	_refresh_all()
	show()
	var first_button := _first_visible_recipe_button()
	if first_button != null:
		first_button.grab_focus()
	else:
		close_button.grab_focus()


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


func set_category_filter(category: int) -> void:
	_active_category = category
	all_filter_button.set_pressed_no_signal(category == ALL_CATEGORIES)
	weapons_filter_button.set_pressed_no_signal(category == RecipeDefinition.CraftingCategory.WEAPON)
	armor_filter_button.set_pressed_no_signal(category == RecipeDefinition.CraftingCategory.ARMOR)
	accessories_filter_button.set_pressed_no_signal(category == RecipeDefinition.CraftingCategory.ACCESSORY)
	for index in mini(recipe_buttons.size(), _button_recipes.size()):
		recipe_buttons[index].visible = (
			category == ALL_CATEGORIES
			or _button_recipes[index].category == category
		)
	var first_button := _first_visible_recipe_button()
	if first_button != null:
		_select_recipe(_button_recipes[recipe_buttons.find(first_button)])
		if visible:
			first_button.grab_focus()
	_refresh_focus()


func _build_recipe_list() -> void:
	for child in recipe_list.get_children():
		recipe_list.remove_child(child)
		child.queue_free()
	recipe_buttons.clear()
	_button_recipes.clear()
	var group := ButtonGroup.new()
	group.allow_unpress = false
	for recipe: RecipeDefinition in catalog.recipes:
		var button := Button.new()
		button.name = "%sRecipeButton" % String(recipe.recipe_id).to_pascal_case()
		button.custom_minimum_size = Vector2(0, 42)
		button.toggle_mode = true
		button.button_group = group
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.text = "  TIER %d  •  %s\n  %s" % [
			recipe.tier,
			_category_name(recipe.category),
			recipe.display_name.to_upper(),
		]
		button.tooltip_text = recipe.description
		button.pressed.connect(_select_recipe.bind(recipe))
		recipe_list.add_child(button)
		recipe_buttons.append(button)
		_button_recipes.append(recipe)
	if not _button_recipes.is_empty():
		selected_recipe = _button_recipes[0]
		recipe_buttons[0].set_pressed_no_signal(true)
	set_category_filter(ALL_CATEGORIES)


func _select_recipe(recipe: RecipeDefinition) -> void:
	selected_recipe = recipe
	for index in mini(recipe_buttons.size(), _button_recipes.size()):
		recipe_buttons[index].set_pressed_no_signal(_button_recipes[index] == recipe)
	_refresh_recipe_detail()


func _refresh_all() -> void:
	_refresh_material_summary()
	_refresh_recipe_buttons()
	_refresh_recipe_detail()


func _refresh_material_summary() -> void:
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	var material_catalog: MaterialCatalogDefinition = preload(
		"res://data/items/materials/material_catalog.tres"
	)
	var owned_kinds := 0
	var total_units := 0
	if material_inventory != null:
		for material: MaterialDefinition in material_catalog.materials:
			var quantity: int = material_inventory.get_quantity(material.material_id)
			if quantity > 0:
				owned_kinds += 1
				total_units += quantity
	material_summary_label.text = "MATERIAL POUCH  •  %d KINDS  •  %d UNITS" % [
		owned_kinds,
		total_units,
	]


func _refresh_recipe_buttons() -> void:
	var recipe_discovery := get_node_or_null("/root/RecipeDiscovery")
	for index in mini(recipe_buttons.size(), _button_recipes.size()):
		var recipe := _button_recipes[index]
		var remembered: bool = (
			recipe_discovery != null
			and recipe_discovery.is_recipe_discovered(recipe.recipe_id)
		)
		recipe_buttons[index].text = "  TIER %d  •  %s  •  %s\n  %s" % [
			recipe.tier,
			_category_name(recipe.category),
			"REMEMBERED" if remembered else "SEALED",
			recipe.display_name.to_upper(),
		]


func _refresh_recipe_detail() -> void:
	if selected_recipe == null:
		return
	recipe_name_label.text = selected_recipe.display_name.to_upper()
	recipe_meta_label.text = "FOREST  •  TIER %d  •  %s" % [
		selected_recipe.tier,
		_category_name(selected_recipe.category),
	]
	var output := Stage5CoreEquipment.find_item(selected_recipe.output_id)
	output_preview.visible = output != null
	if output != null:
		output_icon.texture = output.icon
		output_slot_label.text = "%s  •  %s" % [
			output.get_slot_name().to_upper(),
			output.get_rarity_name(),
		]
		output_stats_label.text = output.get_stat_summary()
	recipe_description_label.text = selected_recipe.description
	var recipe_discovery := get_node_or_null("/root/RecipeDiscovery")
	var remembered: bool = (
		recipe_discovery != null
		and recipe_discovery.is_recipe_discovered(selected_recipe.recipe_id)
	)
	recipe_state_label.text = (
		"BLUEPRINT REMEMBERED  •  RECIPE PREVIEW"
		if remembered
		else "BLUEPRINT NOT REMEMBERED  •  RECIPE PREVIEW"
	)
	recipe_state_label.add_theme_color_override(
		"font_color",
		Color("9ab85d") if remembered else Color("c58bd8")
	)
	_rebuild_ingredient_rows()
	var seal_text := _required_seal_text(selected_recipe.category)
	if _is_debug_crafting_preset_active():
		milestone_label.text = "F9 TEST READY\nMATERIALS • BLUEPRINT • SEAL SATISFIED"
		primary_action_button.text = "DEBUG READY • ITEM GRANTED"
	else:
		milestone_label.text = "%s\nCRAFTING TRANSACTION NOT YET ENABLED" % seal_text
		primary_action_button.text = seal_text
	primary_action_button.disabled = true


func _rebuild_ingredient_rows() -> void:
	for child in ingredient_list.get_children():
		ingredient_list.remove_child(child)
		child.queue_free()
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	for ingredient: MaterialStackDefinition in selected_recipe.ingredients:
		var owned := 0
		if material_inventory != null:
			owned = material_inventory.get_quantity(ingredient.material.material_id)
		var row := HBoxContainer.new()
		row.custom_minimum_size = Vector2(0, 36)
		row.add_theme_constant_override("separation", 8)
		var icon := TextureRect.new()
		icon.custom_minimum_size = Vector2(32, 32)
		icon.texture = ingredient.material.icon
		icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		icon.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		row.add_child(icon)
		var name_label := Label.new()
		name_label.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		name_label.text = ingredient.material.display_name.to_upper()
		name_label.add_theme_font_size_override("font_size", 9)
		row.add_child(name_label)
		var quantity_label := Label.new()
		quantity_label.text = "%d / %d" % [owned, ingredient.quantity]
		quantity_label.add_theme_font_size_override("font_size", 10)
		quantity_label.add_theme_color_override(
			"font_color",
			Color("9ab85d") if owned >= ingredient.quantity else Color("c96a5c")
		)
		row.add_child(quantity_label)
		ingredient_list.add_child(row)


func _refresh_focus() -> void:
	var visible_buttons: Array[Button] = []
	for button: Button in recipe_buttons:
		if button.visible:
			visible_buttons.append(button)
	for index in visible_buttons.size():
		var button := visible_buttons[index]
		button.focus_neighbor_top = button.get_path_to(
			close_button if index == 0 else visible_buttons[index - 1]
		)
		button.focus_neighbor_bottom = button.get_path_to(
			close_button if index == visible_buttons.size() - 1 else visible_buttons[index + 1]
		)
	if not visible_buttons.is_empty():
		close_button.focus_neighbor_bottom = close_button.get_path_to(visible_buttons[0])
		close_button.focus_neighbor_top = close_button.get_path_to(visible_buttons[-1])


func _first_visible_recipe_button() -> Button:
	for button: Button in recipe_buttons:
		if button.visible:
			return button
	return null


func _category_name(category: int) -> String:
	return RecipeDefinition.CraftingCategory.keys()[category].capitalize().to_upper()


func _required_seal_text(category: int) -> String:
	if category == RecipeDefinition.CraftingCategory.ACCESSORY:
		return "STAGE VIII ACCESSORY SEAL REQUIRED"
	return "STAGE V CORE GEAR SEAL REQUIRED"


func _is_debug_crafting_preset_active() -> bool:
	if not OS.is_debug_build():
		return false
	var save_service := get_node_or_null("/root/SaveService")
	var story_state := get_node_or_null("/root/StoryState")
	return (
		save_service != null
		and save_service.is_autosave_suppressed_for_debug()
		and story_state != null
		and story_state.has_key_item(&"forest_core_gear_seal")
	)


func _on_material_quantity_changed(_material_id: StringName, _quantity: int) -> void:
	_refresh_material_summary()
	_refresh_recipe_detail()


func _on_material_inventory_reset() -> void:
	_refresh_material_summary()
	_refresh_recipe_detail()


func _on_recipe_discovered(_recipe_id: StringName) -> void:
	_refresh_recipe_buttons()
	_refresh_recipe_detail()


func _on_recipe_discovery_reset() -> void:
	_refresh_recipe_buttons()
	_refresh_recipe_detail()
