extends SceneTree

const ForestMaterials: MaterialCatalogDefinition = preload(
	"res://data/items/materials/material_catalog.tres"
)
const ForestRecipes: RecipeCatalogDefinition = preload(
	"res://data/crafting/recipes/recipe_catalog.tres"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ForestMaterials.has_valid_layout() or ForestMaterials.materials.size() != 13:
		_fail("The Forest material catalog did not expose thirteen valid stable definitions.")
		return
	if not ForestRecipes.has_valid_layout() or ForestRecipes.recipes.size() != 4:
		_fail("The Forest recipe catalog did not expose four deterministic recipes.")
		return

	var material_ids := {}
	for material: MaterialDefinition in ForestMaterials.materials:
		if material_ids.has(material.material_id):
			_fail("The Forest material catalog contains a duplicate stable ID.")
			return
		if (
			material.icon == null
			or material.icon.get_width() != 24
			or material.icon.get_height() != 24
		):
			_fail("%s is missing its approved 24x24 icon." % material.display_name)
			return
		material_ids[material.material_id] = true
	for expected_id: StringName in [
		&"forest_mire_resin",
		&"forest_mire_membrane",
		&"forest_root_fiber",
		&"forest_young_heartwood",
		&"forest_forsaken_cloth",
		&"forest_weathered_fittings",
		&"forest_barbed_seed",
		&"forest_thorn_sap",
		&"forest_husk_heartwood",
		&"forest_rootbound_core",
		&"forest_armored_hog_hide",
		&"forest_living_bark_plate",
		&"forest_varkuun_core",
	]:
		if not material_ids.has(expected_id):
			_fail("The Forest material catalog omitted %s." % expected_id)
			return

	var profile_ids := {}
	var enemy_ids := {}
	var drop_profiles: Array[DropProfileDefinition] = [
		preload("res://data/loot/forest/enemies/mireling_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/rootling_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/forsaken_thrall_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/bramble_spitter_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/rootbound_husk_drop_profile.tres"),
		preload("res://data/loot/forest/enemies/armored_hog_drop_profile.tres"),
	]
	for profile: DropProfileDefinition in drop_profiles:
		if (
			not profile.has_valid_layout()
			or profile_ids.has(profile.profile_id)
			or enemy_ids.has(profile.source_enemy_id)
		):
			_fail("An enemy drop profile is invalid or duplicates a stable ID.")
			return
		profile_ids[profile.profile_id] = true
		enemy_ids[profile.source_enemy_id] = true
	var husk_profile: DropProfileDefinition = drop_profiles[4]
	var husk_guarantee_ids := {}
	for entry: MaterialDropEntryDefinition in husk_profile.boss_guarantees:
		husk_guarantee_ids[entry.material.material_id] = true
	if (
		not husk_profile.is_boss_profile
		or husk_profile.boss_guarantees.size() != 2
		or not husk_guarantee_ids.has(&"forest_husk_heartwood")
		or not husk_guarantee_ids.has(&"forest_rootbound_core")
	):
		_fail("The Rootbound Husk does not guarantee both authored boss materials.")
		return

	var loot_table_ids := {}
	var stage_ids := {}
	var loot_tables: Array[LootTableDefinition] = [
		preload("res://data/loot/forest/stages/stage_3_loot_table.tres"),
	]
	for loot_table: LootTableDefinition in loot_tables:
		if (
			not loot_table.has_valid_layout()
			or loot_table_ids.has(loot_table.loot_table_id)
			or stage_ids.has(loot_table.stage_id)
		):
			_fail("A stage loot table is invalid or duplicates a stable ID.")
			return
		loot_table_ids[loot_table.loot_table_id] = true
		stage_ids[loot_table.stage_id] = true
		for raw_recipe_id: String in loot_table.first_clear_recipe_ids:
			if not ForestRecipes.has_recipe(StringName(raw_recipe_id)):
				_fail("A stage loot table references an unknown recipe ID.")
				return
	if not loot_tables[0].first_clear_recipe_ids.is_empty():
		_fail("Stage 3's material-payout Reliquary must not unlock crafting recipes.")
		return

	var duplicate_material_catalog := MaterialCatalogDefinition.new()
	duplicate_material_catalog.materials.append(ForestMaterials.materials[0])
	duplicate_material_catalog.materials.append(ForestMaterials.materials[0])
	if duplicate_material_catalog.has_valid_layout():
		_fail("Material catalog validation accepted a duplicate stable ID.")
		return

	var invalid_stack := MaterialStackDefinition.new()
	invalid_stack.material = ForestMaterials.materials[0]
	invalid_stack.quantity = 0
	if invalid_stack.is_valid():
		_fail("Material stack validation accepted a zero quantity.")
		return

	var invalid_recipe := ForestRecipes.recipes[0].duplicate(true) as RecipeDefinition
	invalid_recipe.ingredients.append(invalid_recipe.ingredients[0])
	if invalid_recipe.is_valid():
		_fail("Recipe validation accepted a duplicate material cost.")
		return

	var duplicate_recipe_catalog := RecipeCatalogDefinition.new()
	duplicate_recipe_catalog.recipes.append(ForestRecipes.recipes[0])
	duplicate_recipe_catalog.recipes.append(ForestRecipes.recipes[0])
	if duplicate_recipe_catalog.has_valid_layout():
		_fail("Recipe catalog validation accepted a duplicate stable ID.")
		return

	print("Material and crafting data smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
