class_name KingSkillCatalog
extends RefCounted

const LEGACY := [preload("res://data/abilities/king/echoing_sever.tres"),preload("res://data/abilities/king/riftbreak.tres"),preload("res://data/abilities/king/sovereign_pursuit.tres"),preload("res://data/abilities/king/king_skill_4.tres")]
const IDS := ["echoing_sever","riftbreak","sovereign_pursuit","king_skill_4","crosscut_advance","griefwake","starfall_step","oathstorm"]

static func valid_slots(value: Variant) -> bool:
	if not value is Array or (value.size()!=0 and value.size()!=4):
		return false
	var used := {}
	for id: Variant in value:
		if not id is String or id not in IDS or used.has(id):
			return false
		used[id]=true
	return true
