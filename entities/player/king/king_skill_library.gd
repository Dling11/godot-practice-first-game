class_name KingSkillLibrary
extends Node

## Eight learnable techniques, four equipped slots; persistence stores stable IDs.
signal library_changed
var actor: Player
var preview_rank := -1
var _refresh_pending := false
var _campaign_slots: Array = []
var _collection: CanvasLayer

func _ready() -> void:
	actor = get_parent() as Player
	actor.ready.connect(_bind)

func _bind() -> void:
	for ability in actor.get_all_ability_components():
		if ability is KingOathComponent:
			ability.ability_finished.connect(_finish_refresh)
			ability.phase_changed.connect(actor.get_node("VisualRoot/Body").play_ability_phase)
			ability.strike_started.connect(actor.get_node("VisualRoot/Body").play_oath_strike.bind(ability))
			ability.ability_finished.connect(actor.get_node("VisualRoot/Body").resume_locomotion)
			ability.invulnerability_changed.connect(actor.health_component.set_invulnerable)
	var story := get_node("/root/StoryState")
	story.story_state_changed.connect(refresh)
	refresh()
	var saved: Array = get_node("/root/RunSession").king_skill_slots
	if saved.size()==4 and saved.all(func(id: String) -> bool: return is_learned(id)):
		_apply_slots(saved)

func get_rank() -> int:
	if preview_rank>=0:
		return preview_rank
	var story := get_node("/root/StoryState")
	if story.has_story_flag(&"king_oath_unbound"):
		return 3
	if story.has_story_flag(&"king_oath_ascendant"):
		return 2
	return 1 if story.has_story_flag(&"forest_stage_5_cleared") else 0

func is_learned(id: String) -> bool:
	if id not in KingSkillCatalog.IDS:
		return false
	if preview_rank>=0:
		return true
	var story := get_node("/root/StoryState")
	if id=="griefwake":
		return story.has_story_flag(&"forgotten_grove_completed")
	if id=="oathstorm":
		return story.has_story_flag(&"forest_stage_5_cleared")
	return true

func can_edit() -> bool:
	if actor.is_defeated or actor.is_any_ability_casting() or actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE or actor.evade_component.is_dashing() or actor.is_restrained() or actor.is_in_hit_recovery() or actor._is_targeting_any_ability():
		return false
	var scene := get_tree().current_scene
	var path := scene.scene_file_path if scene!=null else ""
	return path=="res://levels/sanctuary/sanctuary.tscn" or is_lab()

func is_lab() -> bool:
	var node: Node = actor
	while node!=null:
		if node.scene_file_path=="res://levels/combat_lab/combat_lab.tscn":
			return OS.is_debug_build()
		node=node.get_parent()
	return false

func entries() -> Array[AbilityComponent]:
	return actor.get_all_ability_components()

func equip(id: String, slot_number: int) -> bool:
	if not can_edit() or not is_learned(id) or slot_number<1 or slot_number>4:
		return false
	var ids := current_ids()
	var previous := ids.find(id)
	if previous>=0:
		ids[previous]=ids[slot_number-1]
	ids[slot_number-1]=id
	_apply_slots(ids)
	actor._clear_buffered_action()
	if not is_lab() and preview_rank<0:
		get_node("/root/RunSession").king_skill_slots=ids.duplicate()
		get_node("/root/SaveService").save_profile()
	return true

func current_ids() -> Array:
	var ids: Array = []
	for slot in actor.skill_loadout.get_ordered_slots():
		ids.append(String(slot.ability.ability_id) if slot.ability!=null else "")
	return ids

func set_preview_rank(value: int) -> bool:
	if not is_lab() or not can_edit() or value < -1 or value>3:
		return false
	if preview_rank<0 and value>=0:
		_campaign_slots=current_ids()
	preview_rank=value
	if value<0 and not _campaign_slots.is_empty():
		_apply_slots(_campaign_slots)
	refresh()
	return true

func equip_oath_preview() -> bool:
	if not is_lab() or not can_edit():
		return false
	if preview_rank<0:
		_campaign_slots=current_ids()
		preview_rank=0
	refresh()
	_apply_slots(KingOathDefinition.FAMILIES)
	return true

func open_collection() -> void:
	if is_instance_valid(_collection):
		return
	_collection=load("res://ui/skills/king_skill_collection.gd").new()
	_collection.library=self
	add_child(_collection)

func refresh() -> void:
	if actor.is_any_ability_casting():
		_refresh_pending=true
		return
	var ids := current_ids()
	for ability in entries():
		if ability is KingOathComponent:
			var tuning := ability.definition as KingOathDefinition
			ability.definition=tuning.at_rank(get_rank())
			var icon := AtlasTexture.new()
			icon.atlas=load("res://assets/vfx/abilities/king/oath/icons_24.png")
			icon.region=Rect2(tuning.technique*24,0,24,24)
			ability.definition.icon=icon
	_apply_slots(ids)

func _finish_refresh() -> void:
	if _refresh_pending:
		_refresh_pending=false
		refresh.call_deferred()

func _apply_slots(ids: Array) -> void:
	# Preserve sealed legacy slots on actors used by older progression proofs.
	# External slot resources inside an exported array must be duplicated
	# explicitly; mutating them can otherwise change another player's loadout.
	var loadout := SkillLoadoutDefinition.new()
	for slot in actor.skill_loadout.get_ordered_slots():
		loadout.slots.append(slot.duplicate(false))
	for index in mini(ids.size(),4):
		var id: String = ids[index]
		if not is_learned(id):
			continue
		for ability in entries():
			if String(ability.definition.ability_id)==id:
				loadout.get_slot(index+1).ability=ability.definition
				break
	# Shared legacy resource identities are used to resolve slot components.
	for slot in loadout.get_ordered_slots():
		if slot.ability!=null:
			for ability in entries():
				if ability.definition.ability_id==slot.ability.ability_id:
					slot.ability=ability.definition
	actor.skill_loadout=loadout
	actor.skill_loadout_changed.emit()
	library_changed.emit()
