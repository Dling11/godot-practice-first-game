class_name OpawTestConfiguration
extends RefCounted

const Frames = preload("res://assets/characters/playable/opaw/compact_armless/opaw_compact_armless_sprite_frames.tres")
const StartingLoadout = preload("res://data/skills/opaw_starting_loadout.tres")
const DebugLoadout = preload("res://data/skills/opaw_debug_test_loadout.tres")


static func apply(player: Player) -> void:
	player.character_id = &"opaw"
	player.skill_loadout = StartingLoadout
	player.awakened_skill_loadout = DebugLoadout
	player.debug_test_skill_loadout = DebugLoadout
	player.get_node("VisualRoot/Body").sprite_frames = Frames
	player.get_node("VisualRoot/WeaponVisual").show_weapon_sprite = true
	player.get_node("VisualRoot/WeaponVisual/Weapon").visible = true

