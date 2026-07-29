extends Node

## Runtime loot authority. It resolves immutable drop/clear tables, commits
## quantities through MaterialInventory, and exposes presentation-only signals.

signal material_granted(
	material: MaterialDefinition,
	quantity: int,
	source_kind: StringName
)
signal stage_reward_granted(result: Dictionary)

var _random := RandomNumberGenerator.new()
var _expedition_active := false
var _expedition_material_snapshot: Dictionary = {}
var _expedition_loot_state_snapshot: Dictionary = {}
var _expedition_recipe_snapshot: Dictionary = {}


func _ready() -> void:
	_random.randomize()


func configure_seed_for_testing(seed_value: int) -> void:
	_random.seed = seed_value


func begin_expedition() -> bool:
	if _expedition_active:
		return false
	_expedition_material_snapshot = MaterialInventory.create_snapshot()
	_expedition_loot_state_snapshot = _loot_state().create_snapshot()
	_expedition_recipe_snapshot = RecipeDiscovery.create_snapshot()
	_expedition_active = true
	return true


func commit_expedition_rewards() -> void:
	_clear_expedition_tracking()


func abort_expedition_rewards() -> bool:
	if not _expedition_active:
		return false
	var material_restored := MaterialInventory.restore_snapshot(
		_expedition_material_snapshot
	)
	var loot_state_restored: bool = _loot_state().restore_snapshot(
		_expedition_loot_state_snapshot
	)
	var recipes_restored := RecipeDiscovery.restore_snapshot(
		_expedition_recipe_snapshot
	)
	_clear_expedition_tracking()
	return material_restored and loot_state_restored and recipes_restored


func reset_expedition_tracking() -> void:
	_clear_expedition_tracking()


func has_active_expedition() -> bool:
	return _expedition_active


func resolve_enemy_drops(profile: DropProfileDefinition) -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	if profile == null or not profile.has_valid_layout():
		return result
	_append_resolved_entries(result, profile.guaranteed_common)
	_append_resolved_entries(result, profile.optional_secondary)
	_append_resolved_entries(result, profile.rare_drops)
	_append_resolved_entries(result, profile.boss_guarantees)
	return _combine_material_stacks(result)


func grant_material(
	material: MaterialDefinition,
	quantity: int,
	source_kind: StringName
) -> bool:
	if material == null or not material.is_valid() or quantity <= 0:
		return false
	if not MaterialInventory.add_material(material.material_id, quantity):
		return false
	material_granted.emit(material, quantity, source_kind)
	return true


func claim_stage_reward(table: LootTableDefinition) -> Dictionary:
	var failed := {"success": false}
	if table == null or not table.has_valid_layout():
		return failed

	var is_first_clear: bool = not _loot_state().has_first_clear_claim(
		table.first_clear_claim_id
	)
	var resolved: Array[Dictionary] = []
	var guaranteed: Array[MaterialStackDefinition] = (
		table.first_clear_guarantees
		if is_first_clear
		else table.replay_guarantees
	)
	for stack: MaterialStackDefinition in guaranteed:
		resolved.append({
			"material": stack.material,
			"quantity": stack.quantity,
		})
	_append_resolved_entries(resolved, table.optional_rewards)
	resolved = _combine_material_stacks(resolved)

	var quantities := {}
	for stack: Dictionary in resolved:
		var material := stack["material"] as MaterialDefinition
		quantities[material.material_id] = int(stack["quantity"])
	if not MaterialInventory.add_material_batch(quantities):
		return failed

	var discovered_recipe_ids := PackedStringArray()
	var discovery_ids := PackedStringArray()
	var key_item_ids := PackedStringArray()
	if is_first_clear:
		for raw_recipe_id: String in table.first_clear_recipe_ids:
			var recipe_id := StringName(raw_recipe_id)
			RecipeDiscovery.discover_recipe(recipe_id)
			discovered_recipe_ids.append(raw_recipe_id)
		for raw_discovery_id: String in table.first_clear_discovery_ids:
			var discovery_id := StringName(raw_discovery_id)
			StoryState.record_discovery(discovery_id)
			discovery_ids.append(raw_discovery_id)
		for raw_item_id: String in table.first_clear_key_item_ids:
			var item_id := StringName(raw_item_id)
			StoryState.grant_key_item(item_id)
			key_item_ids.append(raw_item_id)
		if not _loot_state().claim_first_clear(table.first_clear_claim_id):
			push_error("LootService could not record a validated first-clear claim.")
			return failed

	for stack: Dictionary in resolved:
		var material := stack["material"] as MaterialDefinition
		material_granted.emit(material, int(stack["quantity"]), &"stage_chest")

	var result := {
		"success": true,
		"stage_id": table.stage_id,
		"first_clear": is_first_clear,
		"materials": resolved,
		"recipe_ids": discovered_recipe_ids,
		"discovery_ids": discovery_ids,
		"key_item_ids": key_item_ids,
	}
	commit_expedition_rewards()
	stage_reward_granted.emit(result)
	return result


func _append_resolved_entries(
	result: Array[Dictionary],
	entries: Array[MaterialDropEntryDefinition]
) -> void:
	for entry: MaterialDropEntryDefinition in entries:
		if entry == null or not entry.is_valid() or not _roll_entry(entry):
			continue
		result.append({
			"material": entry.material,
			"quantity": _random.randi_range(
				entry.minimum_quantity,
				entry.maximum_quantity
			),
		})


func _roll_entry(entry: MaterialDropEntryDefinition) -> bool:
	if entry.is_guaranteed():
		return true
	var forced := false
	if not entry.bad_luck_protection_key.is_empty():
		forced = (
			_loot_state().get_bad_luck_misses(entry.bad_luck_protection_key) + 1
			>= entry.guaranteed_after_misses
		)
	var succeeded := forced or _random.randf() <= entry.chance
	if not entry.bad_luck_protection_key.is_empty():
		_loot_state().record_bad_luck_result(
			entry.bad_luck_protection_key,
			succeeded
		)
	return succeeded


func _combine_material_stacks(stacks: Array[Dictionary]) -> Array[Dictionary]:
	var quantities := {}
	var materials := {}
	for stack: Dictionary in stacks:
		var material := stack.get("material") as MaterialDefinition
		var quantity := int(stack.get("quantity", 0))
		if material == null or quantity <= 0:
			continue
		materials[material.material_id] = material
		quantities[material.material_id] = (
			int(quantities.get(material.material_id, 0)) + quantity
		)
	var material_ids := PackedStringArray()
	for raw_material_id: Variant in quantities:
		material_ids.append(String(raw_material_id))
	material_ids.sort()
	var result: Array[Dictionary] = []
	for raw_material_id: String in material_ids:
		var material_id := StringName(raw_material_id)
		result.append({
			"material": materials[material_id],
			"quantity": int(quantities[material_id]),
		})
	return result


func _clear_expedition_tracking() -> void:
	_expedition_active = false
	_expedition_material_snapshot = {}
	_expedition_loot_state_snapshot = {}
	_expedition_recipe_snapshot = {}


func _loot_state() -> Node:
	return get_node("/root/LootState")
