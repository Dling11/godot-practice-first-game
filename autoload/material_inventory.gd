extends Node

## Mutable material ownership. Definitions remain immutable resources; this
## authority owns quantities and explicit snapshots but never performs file I/O.

signal material_quantity_changed(material_id: StringName, quantity: int)
signal inventory_reset

const MaterialCatalog: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const SNAPSHOT_VERSION := 1
const MAX_MATERIAL_QUANTITY := 999999

var _quantities: Dictionary = {}


func reset_inventory() -> void:
	_quantities.clear()
	inventory_reset.emit()


func get_quantity(material_id: StringName) -> int:
	return int(_quantities.get(material_id, 0))


func has_material(material_id: StringName, quantity: int = 1) -> bool:
	return quantity > 0 and get_quantity(material_id) >= quantity


func add_material(material_id: StringName, quantity: int) -> bool:
	if (
		not MaterialCatalog.has_material(material_id)
		or quantity <= 0
		or get_quantity(material_id) > MAX_MATERIAL_QUANTITY - quantity
	):
		return false
	var updated_quantity := get_quantity(material_id) + quantity
	_quantities[material_id] = updated_quantity
	material_quantity_changed.emit(material_id, updated_quantity)
	return true


func remove_material(material_id: StringName, quantity: int) -> bool:
	if quantity <= 0 or not has_material(material_id, quantity):
		return false
	var updated_quantity := get_quantity(material_id) - quantity
	if updated_quantity == 0:
		_quantities.erase(material_id)
	else:
		_quantities[material_id] = updated_quantity
	material_quantity_changed.emit(material_id, updated_quantity)
	return true


func create_snapshot() -> Dictionary:
	var quantities := {}
	var material_ids := PackedStringArray()
	for raw_material_id: Variant in _quantities:
		material_ids.append(String(raw_material_id))
	material_ids.sort()
	for raw_material_id: String in material_ids:
		var material_id := StringName(raw_material_id)
		quantities[raw_material_id] = get_quantity(material_id)
	return {
		"version": SNAPSHOT_VERSION,
		"quantities": quantities,
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	var raw_quantities: Variant = snapshot.get("quantities")
	if not (raw_quantities is Dictionary):
		return false
	for raw_material_id: Variant in raw_quantities:
		if not (raw_material_id is String or raw_material_id is StringName):
			return false
		var material_id := StringName(String(raw_material_id))
		var raw_quantity: Variant = raw_quantities[raw_material_id]
		if (
			material_id.is_empty()
			or not MaterialCatalog.has_material(material_id)
			or not _is_positive_integer(raw_quantity)
			or int(raw_quantity) > MAX_MATERIAL_QUANTITY
		):
			return false
	return true


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	_quantities.clear()
	var raw_quantities: Dictionary = snapshot["quantities"]
	for raw_material_id: Variant in raw_quantities:
		var material_id := StringName(String(raw_material_id))
		_quantities[material_id] = int(raw_quantities[raw_material_id])
	inventory_reset.emit()
	for raw_material_id: Variant in _quantities:
		var material_id := StringName(String(raw_material_id))
		material_quantity_changed.emit(material_id, get_quantity(material_id))
	return true


func _is_positive_integer(value: Variant) -> bool:
	if value is int:
		return value > 0
	if value is float:
		return is_finite(value) and value > 0.0 and value == floor(value)
	return false
