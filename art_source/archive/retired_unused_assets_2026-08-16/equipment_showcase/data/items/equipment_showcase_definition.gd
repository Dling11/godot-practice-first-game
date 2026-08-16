class_name EquipmentShowcaseDefinition
extends Resource

## Read-only authored armory preview. This is not inventory or save authority.

@export var equipped_weapon: EquipmentDefinition
@export var featured_items: Array[EquipmentDefinition] = []


func has_valid_layout() -> bool:
	if equipped_weapon == null or not equipped_weapon.is_valid_definition():
		return false
	if featured_items.is_empty():
		return false
	for item: EquipmentDefinition in featured_items:
		if item == null or not item.is_valid_definition():
			return false
	return featured_items.has(equipped_weapon)
