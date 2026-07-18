extends Node

## Application-session weapon ownership and per-character equipped choices.
## Disk persistence is intentionally deferred; a new journey resets this state.

signal weapon_acquired(item_id: StringName)
signal weapon_equipped(character_id: StringName, item_id: StringName)
signal inventory_reset

const OpawCatalog: WeaponCatalogDefinition = preload("res://data/items/opaw_weapon_catalog.tres")

var _owned_weapon_ids: Dictionary = {}
var _equipped_weapon_ids: Dictionary = {}


func _ready() -> void:
	reset_inventory()


func reset_inventory() -> void:
	_owned_weapon_ids.clear()
	_equipped_weapon_ids.clear()
	_register_default(&"opaw", OpawCatalog)
	inventory_reset.emit()


func owns_weapon(item_id: StringName) -> bool:
	return _owned_weapon_ids.has(item_id)


func acquire_weapon(item: EquipmentDefinition) -> bool:
	if item == null or not item.is_equippable_weapon() or owns_weapon(item.item_id):
		return false
	_owned_weapon_ids[item.item_id] = true
	weapon_acquired.emit(item.item_id)
	return true


func get_equipped_weapon_id(character_id: StringName, fallback_item_id: StringName) -> StringName:
	var item_id: StringName = _equipped_weapon_ids.get(character_id, fallback_item_id)
	return item_id if owns_weapon(item_id) else fallback_item_id


func try_purchase_weapon(
	item: EquipmentDefinition,
	character_class_id: StringName,
	progression: PlayerProgressionComponent
) -> bool:
	if (
		item == null
		or progression == null
		or not item.is_equippable_weapon()
		or item.purchase_price <= 0
		or owns_weapon(item.item_id)
		or not item.is_compatible_with(character_class_id)
	):
		return false
	# Reserve ownership before spending because coins_changed listeners run
	# synchronously and may refresh or retry the shop during this transaction.
	_owned_weapon_ids[item.item_id] = true
	if not progression.spend_coins(item.purchase_price):
		_owned_weapon_ids.erase(item.item_id)
		return false
	weapon_acquired.emit(item.item_id)
	return true


func equip_weapon(
	character_id: StringName,
	character_class_id: StringName,
	item: EquipmentDefinition
) -> bool:
	if (
		item == null
		or not item.is_equippable_weapon()
		or not owns_weapon(item.item_id)
		or not item.is_compatible_with(character_class_id)
	):
		return false
	_equipped_weapon_ids[character_id] = item.item_id
	weapon_equipped.emit(character_id, item.item_id)
	return true


func _register_default(character_id: StringName, catalog: WeaponCatalogDefinition) -> void:
	if catalog == null or not catalog.has_valid_layout():
		push_error("WeaponInventory requires a valid default weapon catalog.")
		return
	_owned_weapon_ids[catalog.default_weapon.item_id] = true
	_equipped_weapon_ids[character_id] = catalog.default_weapon.item_id
