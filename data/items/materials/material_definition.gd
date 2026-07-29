class_name MaterialDefinition
extends Resource

## Immutable identity and presentation metadata for one crafting material.

enum MaterialFamily {
	VIAL,
	HIDE,
	FIBER_BUNDLE,
	PLATE_CHITIN,
	ORE_FITTING,
	SEED_CRYSTAL,
	CORE,
	RELIC,
	ORGANIC_TISSUE,
	HEARTWOOD,
}

enum MaterialRarity {
	COMMON,
	UNCOMMON,
	RARE,
	BOSS,
}

@export var material_id: StringName
@export var display_name := ""
@export_multiline var description := ""
@export var region_id: StringName
@export var material_family := MaterialFamily.ORGANIC_TISSUE
@export var rarity := MaterialRarity.COMMON
@export var icon: Texture2D
@export var crafting_tags := PackedStringArray()
@export_multiline var source_lore := ""


func is_valid() -> bool:
	if (
		material_id.is_empty()
		or display_name.strip_edges().is_empty()
		or description.strip_edges().is_empty()
		or region_id.is_empty()
		or material_family < MaterialFamily.VIAL
		or material_family > MaterialFamily.HEARTWOOD
		or rarity < MaterialRarity.COMMON
		or rarity > MaterialRarity.BOSS
	):
		return false
	var seen_tags := {}
	for raw_tag: String in crafting_tags:
		var tag := StringName(raw_tag.strip_edges())
		if tag.is_empty() or seen_tags.has(tag):
			return false
		seen_tags[tag] = true
	return true


func get_family_name() -> String:
	return MaterialFamily.keys()[material_family].capitalize().replace("_", " ")


func get_family_glyph() -> String:
	match material_family:
		MaterialFamily.VIAL:
			return "V"
		MaterialFamily.HIDE:
			return "H"
		MaterialFamily.FIBER_BUNDLE:
			return "F"
		MaterialFamily.PLATE_CHITIN:
			return "P"
		MaterialFamily.ORE_FITTING:
			return "O"
		MaterialFamily.SEED_CRYSTAL:
			return "S"
		MaterialFamily.CORE:
			return "C"
		MaterialFamily.RELIC:
			return "R"
		MaterialFamily.ORGANIC_TISSUE:
			return "T"
		MaterialFamily.HEARTWOOD:
			return "W"
	return "?"


func get_rarity_name() -> String:
	return MaterialRarity.keys()[rarity].capitalize()


func get_rarity_color() -> Color:
	match rarity:
		MaterialRarity.COMMON:
			return Color("87927f")
		MaterialRarity.UNCOMMON:
			return Color("81aa68")
		MaterialRarity.RARE:
			return Color("6ba3ce")
		MaterialRarity.BOSS:
			return Color("c58bd8")
	return Color.WHITE
