class_name KingSkillLibrary
extends Node

## Learnable techniques and ten equipped slots; persistence stores stable IDs.
signal library_changed
var actor: Player
var _collection: CanvasLayer

func _ready() -> void:
	actor = get_parent() as Player
	actor.ready.connect(_bind)

func _bind() -> void:
	refresh()
	var saved: Array = get_node("/root/RunSession").king_skill_slots
	if not saved.is_empty() and KingSkillCatalog.valid_slots(saved):
		var normalized := KingSkillCatalog.expanded_slots(saved)
		_apply_slots(normalized)
		get_node("/root/RunSession").king_skill_slots = normalized

func is_learned(id: String) -> bool:
	if id not in KingSkillCatalog.IDS:
		return false
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
	if not can_edit() or (not id.is_empty() and not is_learned(id)) or slot_number<1 or slot_number>SkillLoadoutDefinition.SLOT_COUNT:
		return false
	var ids := current_ids()
	var previous := ids.find(id)
	if previous>=0 and not id.is_empty():
		ids[previous]=ids[slot_number-1]
	ids[slot_number-1]=id
	_apply_slots(ids)
	actor._clear_buffered_action()
	if not is_lab():
		get_node("/root/RunSession").king_skill_slots=ids.duplicate()
		get_node("/root/SaveService").save_profile()
	return true

func current_ids() -> Array:
	var ids: Array = []
	for slot in actor.skill_loadout.get_ordered_slots():
		ids.append(String(slot.ability.ability_id) if slot.ability!=null else "")
	return ids

func equip_core_kit() -> bool:
	if not can_edit():
		return false
	var ids := current_ids()
	for index in 4:
		var id: String = KingSkillCatalog.IDS[index]
		var previous := ids.find(id)
		if previous>=4:
			ids[previous]=""
		ids[index]=id if is_learned(id) else ""
	_apply_slots(ids)
	actor._clear_buffered_action()
	if not is_lab():
		get_node("/root/RunSession").king_skill_slots=ids.duplicate()
		get_node("/root/SaveService").save_profile()
	return true

func open_collection() -> void:
	if is_instance_valid(_collection):
		return
	_collection=load("res://ui/skills/king_skill_collection.gd").new()
	_collection.library=self
	add_child(_collection)

func refresh() -> void:
	_apply_slots(current_ids())

func _apply_slots(ids: Array) -> void:
	# Preserve sealed legacy slots on actors used by older progression proofs.
	# External slot resources inside an exported array must be duplicated
	# explicitly; mutating them can otherwise change another player's loadout.
	var loadout := SkillLoadoutDefinition.new()
	for slot in actor.skill_loadout.get_ordered_slots():
		loadout.slots.append(slot.duplicate(false))
	while loadout.slots.size()<SkillLoadoutDefinition.SLOT_COUNT:
		var empty := SkillSlotDefinition.new()
		empty.slot_number=loadout.slots.size()+1
		empty.input_action=StringName("player_skill_%d" % empty.slot_number)
		empty.locked_title="Empty slot"
		empty.locked_description="Equip a learned technique in Sanctuary."
		empty.unlock_hint="EMPTY"
		loadout.slots.append(empty)
	var expanded := KingSkillCatalog.expanded_slots(ids)
	for index in SkillLoadoutDefinition.SLOT_COUNT:
		var id: String = expanded[index]
		loadout.get_slot(index+1).ability=null
		if id.is_empty() or not is_learned(id):
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
