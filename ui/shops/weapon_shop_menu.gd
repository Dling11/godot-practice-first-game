class_name WeaponShopMenu
extends Control

## Orren's data-driven weapon purchase surface. It spends the active player's
## run coins and adds weapons to the shared application-session inventory.

signal menu_closed

@export var player: Player
@export var catalog: WeaponCatalogDefinition

@onready var coin_label: Label = %CoinLabel
@onready var stock_list: VBoxContainer = %StockList
@onready var item_icon: TextureRect = %ItemIcon
@onready var item_name_label: Label = %ItemNameLabel
@onready var requirement_label: Label = %RequirementLabel
@onready var stats_label: Label = %StatsLabel
@onready var lore_label: Label = %LoreLabel
@onready var status_label: Label = %StatusLabel
@onready var buy_button: Button = %BuyButton
@onready var close_button: Button = %CloseButton

var stock_buttons: Array[Button] = []
var _stock_items: Array[EquipmentDefinition] = []
var _selected_item: EquipmentDefinition
var _owns_pause := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player == null or catalog == null or not catalog.has_valid_layout():
		push_error("WeaponShopMenu requires a player and valid weapon catalog.")
		return
	player.progression_component.coins_changed.connect(_on_coins_changed)
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory != null:
		inventory.weapon_acquired.connect(_on_weapon_acquired)
	_build_stock()
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
	_refresh_shop()
	show()
	if not stock_buttons.is_empty():
		stock_buttons[0].grab_focus()
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


func _build_stock() -> void:
	for child in stock_list.get_children():
		stock_list.remove_child(child)
		child.queue_free()
	stock_buttons.clear()
	_stock_items.clear()
	var group := ButtonGroup.new()
	group.allow_unpress = false
	for item: EquipmentDefinition in catalog.weapons:
		if item.purchase_price <= 0:
			continue
		var button := Button.new()
		button.name = "%sStockButton" % String(item.item_id).to_pascal_case()
		button.custom_minimum_size = Vector2(0, 64)
		button.toggle_mode = true
		button.button_group = group
		button.icon = item.icon
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		button.pressed.connect(_select_item.bind(item))
		stock_list.add_child(button)
		stock_buttons.append(button)
		_stock_items.append(item)
	if not _stock_items.is_empty():
		_selected_item = _stock_items[0]
		stock_buttons[0].set_pressed_no_signal(true)
	_configure_focus()
	_refresh_shop()


func _configure_focus() -> void:
	for index in stock_buttons.size():
		var button := stock_buttons[index]
		button.focus_neighbor_top = button.get_path_to(
			close_button if index == 0 else stock_buttons[index - 1]
		)
		button.focus_neighbor_bottom = button.get_path_to(
			buy_button if index == stock_buttons.size() - 1 else stock_buttons[index + 1]
		)
	if not stock_buttons.is_empty():
		buy_button.focus_neighbor_top = buy_button.get_path_to(stock_buttons[-1])
	close_button.focus_neighbor_bottom = (
		close_button.get_path_to(stock_buttons[0]) if not stock_buttons.is_empty() else close_button.get_path()
	)


func _select_item(item: EquipmentDefinition) -> void:
	_selected_item = item
	_refresh_shop()


func _refresh_shop() -> void:
	if player == null:
		return
	coin_label.text = "%d COINS" % player.progression_component.coins
	var inventory := get_node_or_null("/root/WeaponInventory")
	for index in mini(stock_buttons.size(), _stock_items.size()):
		var item := _stock_items[index]
		var owned: bool = inventory != null and inventory.owns_weapon(item.item_id)
		stock_buttons[index].text = "  %s\n  %s • %s" % [
			item.display_name.to_upper(),
			item.get_rarity_name(),
			"OWNED" if owned else "%d COINS" % item.purchase_price,
		]
	if _selected_item == null:
		return
	var owned: bool = inventory != null and inventory.owns_weapon(_selected_item.item_id)
	var compatible := _selected_item.is_compatible_with(player.character_class_id)
	item_icon.texture = _selected_item.icon
	item_name_label.text = _selected_item.display_name.to_upper()
	requirement_label.text = "%s ONLY" % _selected_item.get_class_requirement_text().to_upper()
	requirement_label.add_theme_color_override(
		"font_color", Color("9ab85d") if compatible else Color("c45b50")
	)
	stats_label.text = "POWER %d  •  KNOCKBACK %d" % [
		roundi(_selected_item.weapon_definition.damage),
		roundi(_selected_item.weapon_definition.knockback_strength),
	]
	lore_label.text = _selected_item.lore
	buy_button.disabled = owned or not compatible or player.progression_component.coins < _selected_item.purchase_price
	if owned:
		status_label.text = "OWNED • EQUIP FROM CHARACTER INVENTORY"
		buy_button.text = "ALREADY OWNED"
	elif not compatible:
		status_label.text = "YOUR CURRENT CLASS CANNOT USE THIS WEAPON"
		buy_button.text = "WRONG CLASS"
	elif player.progression_component.coins < _selected_item.purchase_price:
		status_label.text = "NEED %d MORE COINS" % (
			_selected_item.purchase_price - player.progression_component.coins
		)
		buy_button.text = "BUY • %d COINS" % _selected_item.purchase_price
	else:
		status_label.text = "PURCHASE ADDS THIS WEAPON TO YOUR INVENTORY"
		buy_button.text = "BUY • %d COINS" % _selected_item.purchase_price


func purchase_selected() -> bool:
	if _selected_item == null:
		return false
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory == null:
		return false
	var purchased: bool = inventory.try_purchase_weapon(
		_selected_item,
		player.character_class_id,
		player.progression_component
	)
	_refresh_shop()
	return purchased


func _on_coins_changed(_total_coins: int) -> void:
	_refresh_shop()


func _on_weapon_acquired(_item_id: StringName) -> void:
	_refresh_shop()
