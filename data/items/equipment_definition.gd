class_name EquipmentDefinition
extends Resource

## Immutable identity and presentation contract for one equipment item.
## Combat modifiers remain intentionally absent until stat authority is approved.

enum Slot {
	WEAPON,
	ARMOR,
	GLOVES,
	BOOTS,
	ACCESSORY,
}

enum Rarity {
	A_GRADE = 0,
	S_GRADE = 1,
	LEGENDARY = 2,
	MYTHIC = 3,
	WOOD = 4,
	STONE = 5,
	IRON = 6,
	RARE = 7,
}

@export var item_id: StringName
@export var display_name := "Equipment"
@export var slot := Slot.WEAPON
@export var rarity := Rarity.A_GRADE
@export var icon: Texture2D
@export_range(0, 999, 1) var preview_power := 0
@export_multiline var lore := ""
@export var synergy_name := "Skill Synergy"
@export_multiline var synergy_description := ""


func get_slot_name() -> String:
	return Slot.keys()[slot].capitalize()


func get_rarity_name() -> String:
	match rarity:
		Rarity.A_GRADE:
			return "A GRADE"
		Rarity.S_GRADE:
			return "S GRADE"
		Rarity.LEGENDARY:
			return "LEGENDARY"
		Rarity.MYTHIC:
			return "MYTHIC"
		Rarity.WOOD:
			return "WOOD"
		Rarity.STONE:
			return "STONEBOUND"
		Rarity.IRON:
			return "IRON"
		Rarity.RARE:
			return "RARE"
	return "UNKNOWN"


func get_rarity_color() -> Color:
	match rarity:
		Rarity.A_GRADE:
			return Color("66a4d8")
		Rarity.S_GRADE:
			return Color("9b71d0")
		Rarity.LEGENDARY:
			return Color("d6c171")
		Rarity.MYTHIC:
			return Color("f0e5d2")
		Rarity.WOOD:
			return Color("b97a36")
		Rarity.STONE:
			return Color("858b86")
		Rarity.IRON:
			return Color("b5bdc2")
		Rarity.RARE:
			return Color("66a4d8")
	return Color.WHITE


func is_valid_definition() -> bool:
	return not item_id.is_empty() and not display_name.is_empty() and icon != null
