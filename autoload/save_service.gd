extends Node

## Versioned profile-schema coordinator. This first Segment 1 slice composes
## validated snapshots only; disk writes and title-screen Continue follow later.

signal profile_restored(safe_scene_path: String)

const PROFILE_VERSION := 1
const DEFAULT_SAFE_SCENE := "res://levels/sanctuary/sanctuary.tscn"


func create_profile_snapshot(safe_scene_path := DEFAULT_SAFE_SCENE) -> Dictionary:
	if not _has_core_authorities():
		push_error("SaveService requires RunSession, StoryState, and WeaponInventory.")
		return {}
	if safe_scene_path.is_empty() or not ResourceLoader.exists(safe_scene_path):
		push_error("SaveService requires an existing safe scene path.")
		return {}
	return {
		"version": PROFILE_VERSION,
		"safe_scene_path": safe_scene_path,
		"run_session": RunSession.create_snapshot(),
		"story_state": StoryState.create_snapshot(),
		"weapon_inventory": WeaponInventory.create_snapshot(),
		"extensions": {
			"material_inventory": {},
			"recipe_discovery": {},
			"stage_claims": {},
			"regional_progress": {},
		},
	}


func can_restore_profile(snapshot: Dictionary) -> bool:
	if not _has_core_authorities() or snapshot.get("version", -1) != PROFILE_VERSION:
		return false
	var safe_scene_path: Variant = snapshot.get("safe_scene_path")
	var run_snapshot: Variant = snapshot.get("run_session")
	var story_snapshot: Variant = snapshot.get("story_state")
	var weapon_snapshot: Variant = snapshot.get("weapon_inventory")
	var extensions: Variant = snapshot.get("extensions", {})
	return (
		safe_scene_path is String
		and not String(safe_scene_path).is_empty()
		and String(safe_scene_path).ends_with(".tscn")
		and ResourceLoader.exists(String(safe_scene_path))
		and run_snapshot is Dictionary
		and story_snapshot is Dictionary
		and weapon_snapshot is Dictionary
		and extensions is Dictionary
		and RunSession.can_restore_snapshot(run_snapshot)
		and StoryState.can_restore_snapshot(story_snapshot)
		and WeaponInventory.can_restore_snapshot(weapon_snapshot)
	)


func restore_profile(snapshot: Dictionary) -> bool:
	if not can_restore_profile(snapshot):
		return false
	# All sections validate before mutation, preventing partial restoration.
	RunSession.restore_snapshot(snapshot["run_session"])
	StoryState.restore_snapshot(snapshot["story_state"])
	WeaponInventory.restore_snapshot(snapshot["weapon_inventory"])
	var safe_scene_path := String(snapshot["safe_scene_path"])
	profile_restored.emit(safe_scene_path)
	return true


func _has_core_authorities() -> bool:
	return (
		get_node_or_null("/root/RunSession") != null
		and get_node_or_null("/root/StoryState") != null
		and get_node_or_null("/root/WeaponInventory") != null
	)
