class_name KingSkillCatalog
extends RefCounted

const LEGACY := [preload("res://data/abilities/king/echoing_sever.tres"),preload("res://data/abilities/king/riftbreak.tres"),preload("res://data/abilities/king/sovereign_pursuit.tres"),preload("res://data/abilities/king/king_skill_4.tres")]
const IDS := ["echoing_sever","riftbreak","sovereign_pursuit","king_skill_4","crosscut_advance","griefwake","starfall_step","oathstorm"]

static func valid_slots(value: Variant) -> bool:
	if not value is Array or value.size() not in [0, 4, SkillLoadoutDefinition.SLOT_COUNT]:
		return false
	var used := {}
	for id: Variant in value:
		if id is String and id.is_empty():
			continue
		if not id is String or id not in IDS or used.has(id):
			return false
		used[id]=true
	return true

static func expanded_slots(value: Array) -> Array:
	var result := value.duplicate()
	while result.size() < SkillLoadoutDefinition.SLOT_COUNT:
		result.append("")
	return result
