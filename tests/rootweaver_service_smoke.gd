extends SceneTree

const SanctuaryScene = preload("res://levels/sanctuary/sanctuary.tscn")

const ACTOR_SHEET := "res://assets/characters/npcs/rootweaver/rootweaver_nema_service_sheet_48x48.png"
const PORTRAIT := "res://assets/characters/npcs/rootweaver/rootweaver_nema_portrait_96x96.png"
const ROOTFORGE := "res://assets/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_176x144.png"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _validate_runtime_image(ACTOR_SHEET, Vector2i(192, 96)):
		return
	if not _validate_runtime_image(PORTRAIT, Vector2i(96, 96)):
		return
	if not _validate_runtime_image(ROOTFORGE, Vector2i(176, 144)):
		return
	var actor_image := (load(ACTOR_SHEET) as Texture2D).get_image()
	for row in 2:
		for column in 4:
			var frame := actor_image.get_region(Rect2i(
				Vector2i(column * 48, row * 48),
				Vector2i(48, 48)
			))
			var used_rect := frame.get_used_rect()
			if (
				used_rect.position.x < 4
				or used_rect.end.x > 44
				or used_rect.end.y != 44
				or used_rect.size.y < 32
				or used_rect.size.y > 41
			):
				_fail(
					"Rootweaver actor frame %d/%d lost its complete-boots or safe-margin contract: %s."
					% [row, column, used_rect]
				)
				return

	var frames := load(
		"res://assets/characters/npcs/rootweaver/rootweaver_nema_sprite_frames.tres"
	) as SpriteFrames
	if (
		frames == null
		or frames.get_frame_count(&"idle") != 4
		or frames.get_frame_count(&"work") != 4
		or not frames.get_animation_loop(&"idle")
		or frames.get_animation_loop(&"work")
	):
		_fail("Rootweaver SpriteFrames does not expose the required idle/work contract.")
		return

	var sanctuary := SanctuaryScene.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	await process_frame
	await process_frame

	var player := sanctuary.get_node("World/Actors/Player") as Player
	var hud := sanctuary.get_node("UI/CombatHUD") as CombatHUD
	var dialogue := sanctuary.get_node("UI/DialoguePanel") as DialoguePanel
	var rootweaver := sanctuary.get_node("World/Actors/Rootweaver") as DialogueNpc
	var rootforge := sanctuary.get_node("World/Actors/LivingRootforge") as StaticBody2D
	var menu := sanctuary.get_node("UI/RootforgeMenu") as RootforgeMenu
	if (
		rootweaver == null
		or rootforge == null
		or menu == null
		or rootweaver.dialogue_portrait == null
		or rootweaver.speaker_name != "ROOTWEAVER NEMA"
		or rootweaver.dialogue_lines.size() != 3
	):
		_fail("Nema's Sanctuary identity or service wiring is incomplete.")
		return
	if rootforge.position != Vector2(240, 610) or rootweaver.position != Vector2(342, 630):
		_fail("Nema or the Living Rootforge drifted from the approved west-mid service bay.")
		return
	if (
		rootweaver.position.x <= rootforge.position.x
		or absf(rootweaver.position.y - rootforge.position.y) > 32.0
	):
		_fail("Nema is no longer working from the Rootforge's screen-right side.")
		return
	var expedition_altar := sanctuary.get_node("World/Actors/ExpeditionAltar") as Node2D
	if expedition_altar.position.y >= rootforge.position.y:
		_fail("The expedition portal is no longer the north/top Sanctuary landmark.")
		return
	if (
		rootforge.get_node_or_null("RearCollision") == null
		or rootforge.get_node_or_null("AnvilCollision") == null
		or rootforge.position.x + 88.0 >= player.position.x - 6.0
	):
		_fail("The Living Rootforge no longer preserves collision or the central Sanctuary avenue.")
		return

	var actor := rootweaver.get_node("Sprite") as AnimatedSprite2D
	var work_idle := rootweaver.get_node("WorkIdle") as RootweaverWorkIdle
	if actor == null or work_idle == null or work_idle.actor != actor:
		_fail("Nema is missing her event-driven work presentation.")
		return
	work_idle._begin_work()
	if actor.animation != &"work":
		_fail("Nema's timed work presentation did not enter the work animation.")
		return
	work_idle._finish_work()
	if actor.animation != &"idle":
		_fail("Nema's work presentation did not return to idle.")
		return

	if menu.catalog == null or menu.recipe_buttons.size() != 8:
		_fail("The Rootforge preview did not build six Stage V and two future accessory recipes.")
		return
	var material_inventory: Node = root.get_node_or_null("MaterialInventory")
	var recipe_discovery: Node = root.get_node_or_null("RecipeDiscovery")
	var materials_before: Dictionary = (
		material_inventory.create_snapshot() if material_inventory != null else {}
	)
	var discoveries_before: Dictionary = (
		recipe_discovery.create_snapshot() if recipe_discovery != null else {}
	)

	var interact := InputEventAction.new()
	interact.action = "player_interact"
	interact.pressed = true
	rootweaver._on_body_entered(player)
	if not hud.interaction_panel.visible or not hud.interaction_label.text.contains("ROOTFORGE"):
		_fail("Approaching Nema did not expose the Living Rootforge prompt.")
		return
	rootweaver._unhandled_input(interact)
	if (
		not dialogue.visible
		or not paused
		or not dialogue.portrait.visible
		or dialogue.portrait.texture != rootweaver.dialogue_portrait
	):
		_fail("Nema's interaction did not open paused portrait dialogue.")
		return
	dialogue.advance()
	dialogue.advance()
	dialogue.advance()
	if (
		dialogue.visible
		or not menu.visible
		or not paused
		or menu.primary_action_button == null
		or not menu.primary_action_button.disabled
		or not menu.milestone_label.text.contains("BLUEPRINT SEALED")
	):
		_fail("Completing Nema's dialogue did not open the gated Rootforge crafting surface.")
		return
	if menu.ingredient_list.get_child_count() < 2:
		_fail("The Rootforge preview does not expose recipe ingredient readiness.")
		return
	if (
		not menu.output_preview.visible
		or menu.output_icon.texture == null
		or not menu.output_stats_label.text.contains("SKILL POWER 38")
		or not menu.output_stats_label.text.contains("+13 SKILL POWER")
	):
		_fail("The Rootforge did not present the selected Stage V output icon and real stat preview.")
		return
	for button: Button in menu.recipe_buttons:
		var formula_icon := button.get_node_or_null("FormulaIcon") as TextureRect
		if formula_icon == null or formula_icon.texture == null or formula_icon.size != Vector2(24, 24):
			_fail("A compact Forest formula row is missing its right-side output icon.")
			return
	menu.set_category_filter(RecipeDefinition.CraftingCategory.ARMOR)
	var visible_armor_count := 0
	for button: Button in menu.recipe_buttons:
		if button.visible:
			visible_armor_count += 1
	if visible_armor_count != 5:
		_fail("The Rootforge did not expose all five Stage V armor recipes.")
		return
	menu.set_category_filter(RecipeDefinition.CraftingCategory.ACCESSORY)
	var visible_recipe_count := 0
	for button: Button in menu.recipe_buttons:
		if button.visible:
			visible_recipe_count += 1
	if visible_recipe_count != 2 or not menu.primary_action_button.text.contains("STAGE VIII ACCESSORY SEAL"):
		_fail("The Rootforge accessory filter or milestone label is incorrect.")
		return
	if (
		material_inventory != null
		and material_inventory.create_snapshot() != materials_before
	):
		_fail("Opening or inspecting the Rootforge preview changed material ownership.")
		return
	if (
		recipe_discovery != null
		and recipe_discovery.create_snapshot() != discoveries_before
	):
		_fail("Opening or inspecting the Rootforge preview changed recipe discovery.")
		return
	menu.close_button.pressed.emit()
	if menu.visible or paused or not hud.interaction_panel.visible:
		_fail("Closing the Rootforge did not restore Sanctuary control and Nema's prompt.")
		return
	var story_state := root.get_node("StoryState")
	story_state.record_discovery(&"forest_core_gear_crafting")
	story_state.grant_key_item(&"forest_core_gear_seal")
	var craft_recipe := menu.catalog.find_recipe(&"forest_stage_5_varkuun_edge")
	var craft_costs := {}
	for ingredient: MaterialStackDefinition in craft_recipe.ingredients:
		craft_costs[ingredient.material.material_id] = ingredient.quantity
	if not material_inventory.add_material_batch(craft_costs):
		_fail("Could not seed the Rootforge's real Varkuun Edge costs.")
		return
	menu.open_menu()
	menu._select_recipe(craft_recipe)
	if menu.primary_action_button.disabled or not menu.primary_action_button.text.contains("CRAFT VARKUUN EDGE"):
		_fail("The Stage V discovery, seal, and ingredients did not enable the Rootforge action.")
		return
	menu.primary_action_button.pressed.emit()
	if (
		not root.get_node("WeaponInventory").owns_weapon(craft_recipe.output_id)
		or not menu.milestone_label.text.contains("CRAFTED VARKUUN EDGE")
		or not menu.primary_action_button.disabled
	):
		_fail("The Rootforge button did not complete and lock the real Varkuun Edge transaction.")
		return
	menu.close_menu()
	player.apply_debug_testing_preset()
	menu.open_menu()
	if (
		not menu.milestone_label.text.contains("F9 TEST READY")
		or not menu.primary_action_button.text.contains("ALREADY OWNED")
		or not root.get_node("StoryState").has_key_item(&"forest_core_gear_seal")
	):
		_fail("F9 did not satisfy the Stage V Rootforge ownership gates for debug testing.")
		return
	menu.close_menu()

	print("Rootweaver Sanctuary service smoke test passed.")
	quit(0)


func _validate_runtime_image(path: String, expected_size: Vector2i) -> bool:
	var texture := load(path) as Texture2D
	if texture == null or texture.get_size() != Vector2(expected_size):
		_fail("Rootweaver runtime image has an invalid size: %s" % path)
		return false
	var image := texture.get_image()
	var opaque_pixels := 0
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a
			if alpha > 0.001 and alpha < 0.999:
				_fail("Rootweaver runtime image contains soft alpha: %s" % path)
				return false
			if alpha >= 0.999:
				opaque_pixels += 1
	if opaque_pixels < 300:
		_fail("Rootweaver runtime image lost required content: %s" % path)
		return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
