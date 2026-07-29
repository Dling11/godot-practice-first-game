extends SceneTree

const MaterialCatalog: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const RootlingProfile: DropProfileDefinition = preload(
	"res://data/loot/forest/enemies/rootling_drop_profile.tres"
)
const HuskProfile: DropProfileDefinition = preload(
	"res://data/loot/forest/enemies/rootbound_husk_drop_profile.tres"
)
const Stage1Table: LootTableDefinition = preload(
	"res://data/loot/forest/stages/stage_1_loot_table.tres"
)
const Stage2Table: LootTableDefinition = preload(
	"res://data/loot/forest/stages/stage_2_loot_table.tres"
)
const ChestScene = preload("res://gameplay/loot/stage_reward_chest.tscn")
const Stage1Scene = preload("res://levels/test_arena/test_arena.tscn")
const Stage2Scene = preload("res://levels/stage_2/stage_2.tscn")
const Stage3Scene = preload("res://levels/stage_3/stage_3.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_reset_loot_state()
	var loot_state := root.get_node("LootState")
	var loot_service := root.get_node("LootService")
	var material_inventory := root.get_node("MaterialInventory")
	var recipe_discovery := root.get_node("RecipeDiscovery")

	for material: MaterialDefinition in MaterialCatalog.materials:
		if (
			material.icon == null
			or material.icon.get_width() != 24
			or material.icon.get_height() != 24
		):
			_fail("%s does not own an approved 24x24 runtime icon." % material.display_name)
			return

	var enemy_scene_paths := [
		"res://entities/enemies/mireling/mireling.tscn",
		"res://entities/enemies/rootling/rootling.tscn",
		"res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn",
		"res://entities/enemies/bramble_spitter/bramble_spitter.tscn",
		"res://entities/enemies/rootbound_husk/rootbound_husk.tscn",
	]
	for scene_path: String in enemy_scene_paths:
		var packed_enemy_scene := load(scene_path) as PackedScene
		var enemy: Node = packed_enemy_scene.instantiate()
		var rewards := enemy.get_node("EnemyRewardComponent") as EnemyRewardComponent
		if rewards.drop_profile == null or not rewards.drop_profile.has_valid_layout():
			_fail("%s has no valid runtime drop profile." % scene_path)
			return
		enemy.free()

	for scene: PackedScene in [Stage1Scene, Stage2Scene, Stage3Scene]:
		var stage := scene.instantiate()
		var controller := stage.get_node(
			"GameplayServices/EncounterController"
		) as EncounterController
		if (
			controller.reward_chest_scene == null
			or controller.stage_loot_table == null
			or not controller.stage_loot_table.has_valid_layout()
		):
			_fail("A playable Forest stage has no configured clear chest/table.")
			return
		stage.free()

	loot_state.record_bad_luck_result(&"forest_young_heartwood_misses", false)
	loot_state.record_bad_luck_result(&"forest_young_heartwood_misses", false)
	loot_state.record_bad_luck_result(&"forest_young_heartwood_misses", false)
	loot_service.configure_seed_for_testing(20260729)
	var rootling_drops: Array[Dictionary] = loot_service.resolve_enemy_drops(
		RootlingProfile
	)
	if (
		_quantity_for(rootling_drops, &"forest_root_fiber") < 1
		or _quantity_for(rootling_drops, &"forest_young_heartwood") != 1
		or loot_state.get_bad_luck_misses(&"forest_young_heartwood_misses") != 0
	):
		_fail("Guaranteed Rootling loot or bad-luck protection did not resolve.")
		return
	var husk_drops: Array[Dictionary] = loot_service.resolve_enemy_drops(HuskProfile)
	if _quantity_for(husk_drops, &"forest_rootbound_core") < 1:
		_fail("The Rootbound Husk did not resolve its guaranteed boss core.")
		return

	_reset_loot_state()
	material_inventory.add_material(&"forest_root_fiber", 5)
	if not loot_service.begin_expedition():
		_fail("LootService could not capture an expedition reward baseline.")
		return
	loot_state.record_bad_luck_result(&"forest_mire_membrane_misses", false)
	loot_service.grant_material(
		MaterialCatalog.find_material(&"forest_mire_resin"),
		2,
		&"enemy_drop"
	)
	if (
		not loot_service.abort_expedition_rewards()
		or material_inventory.get_quantity(&"forest_root_fiber") != 5
		or material_inventory.get_quantity(&"forest_mire_resin") != 0
		or loot_state.get_bad_luck_misses(&"forest_mire_membrane_misses") != 0
	):
		_fail("Abandoning an expedition did not roll uncommitted loot back.")
		return

	_reset_loot_state()
	loot_service.begin_expedition()
	loot_service.configure_seed_for_testing(91)
	var first_clear: Dictionary = loot_service.claim_stage_reward(Stage1Table)
	if (
		not bool(first_clear.get("success", false))
		or not bool(first_clear.get("first_clear", false))
		or material_inventory.get_quantity(&"forest_root_fiber") < 4
		or material_inventory.get_quantity(&"forest_mire_resin") < 3
		or material_inventory.get_quantity(&"forest_forsaken_cloth") < 2
		or not recipe_discovery.is_recipe_discovered(&"forest_rootfiber_wraps")
		or not recipe_discovery.is_recipe_discovered(&"forest_mireward_charm")
		or not loot_state.has_first_clear_claim(Stage1Table.first_clear_claim_id)
		or loot_service.has_active_expedition()
	):
		_fail("Stage I first-clear rewards did not commit materials, recipes, and claim.")
		return

	var fiber_before_replay: int = material_inventory.get_quantity(&"forest_root_fiber")
	loot_service.begin_expedition()
	loot_service.configure_seed_for_testing(92)
	var replay: Dictionary = loot_service.claim_stage_reward(Stage1Table)
	if (
		not bool(replay.get("success", false))
		or bool(replay.get("first_clear", true))
		or material_inventory.get_quantity(&"forest_root_fiber") < fiber_before_replay + 2
		or not (replay.get("recipe_ids", PackedStringArray()) as PackedStringArray).is_empty()
	):
		_fail("A replay chest repeated first-clear rewards or omitted replay guarantees.")
		return

	_reset_loot_state()
	loot_service.begin_expedition()
	var chest := ChestScene.instantiate() as StageRewardChest
	chest.configure(Stage2Table)
	root.add_child(chest)
	await process_frame
	var chest_result := chest.claim_for_testing()
	if (
		not bool(chest_result.get("success", false))
		or chest.chest_sprite.texture != chest.open_texture
		or material_inventory.get_quantity(&"forest_barbed_seed") < 3
	):
		_fail("The stage-clear chest did not visibly open and grant its table.")
		return

	var loot_snapshot: Dictionary = loot_state.create_snapshot()
	loot_state.reset_state()
	if (
		not loot_state.restore_snapshot(loot_snapshot)
		or not loot_state.has_first_clear_claim(Stage2Table.first_clear_claim_id)
	):
		_fail("LootState did not persist and reconstruct stage claims.")
		return

	print("Loot resolution, pickup art, chest, rollback, and claim smoke test passed.")
	quit(0)


func _quantity_for(stacks: Array[Dictionary], material_id: StringName) -> int:
	for stack: Dictionary in stacks:
		var material := stack.get("material") as MaterialDefinition
		if material != null and material.material_id == material_id:
			return int(stack.get("quantity", 0))
	return 0


func _reset_loot_state() -> void:
	root.get_node("LootService").reset_expedition_tracking()
	root.get_node("MaterialInventory").reset_inventory()
	root.get_node("RecipeDiscovery").reset_discoveries()
	root.get_node("LootState").reset_state()


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
