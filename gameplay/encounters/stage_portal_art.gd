class_name StagePortalArt
extends RefCounted

const FAMILY := [
	preload("res://assets/environment/portals/threat_family/calm_frames.tres"),
	preload("res://assets/environment/portals/threat_family/ominous_frames.tres"),
	preload("res://assets/environment/portals/threat_family/grasp_frames.tres"),
	preload("res://assets/environment/portals/threat_family/divine_frames.tres"),
	preload("res://assets/environment/portals/threat_family/unknowable_frames.tres"),
]
const MAW := preload("res://assets/environment/portals/threat_family/maw_frames.tres")

static func frames_for(tier: int, boss_variant: int = 0) -> SpriteFrames:
	if tier == 2 and boss_variant == 1:
		return MAW
	return FAMILY[clampi(tier, 0, FAMILY.size()-1)]
