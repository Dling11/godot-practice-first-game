extends SceneTree

const SanctuaryScene = preload("res://levels/sanctuary/sanctuary.tscn")

const RUNTIME_SPRITES := {
	"res://assets/environment/sanctuary/landmarks/angel_expedition_portal_192x192.png": Vector2i(192, 192),
	"res://assets/environment/sanctuary/landmarks/angel_expedition_portal_ground_192x192.png": Vector2i(192, 192),
	"res://assets/environment/sanctuary/landmarks/divine_fountain_112x96.png": Vector2i(112, 96),
	"res://assets/environment/sanctuary/buildings/skillkeeper_lodge_128x192.png": Vector2i(128, 192),
	"res://assets/environment/sanctuary/buildings/armskeeper_workshop_176x192.png": Vector2i(176, 192),
	"res://assets/environment/sanctuary/shops/armskeeper_cart_128x96.png": Vector2i(128, 96),
	"res://assets/environment/sanctuary/props/sanctuary_tree_broad_96x120.png": Vector2i(96, 120),
	"res://assets/environment/sanctuary/props/sanctuary_tree_tall_96x120.png": Vector2i(96, 120),
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x48.png": Vector2i(192, 48),
	"res://assets/characters/npcs/armskeeper/armskeeper_idle_sheet_48x48.png": Vector2i(192, 48),
	"res://assets/environment/sanctuary/tiles/sanctuary_ground_atlas_64x64.png": Vector2i(256, 320),
}

const MINIMUM_OPAQUE_PIXELS := {
	"res://assets/environment/sanctuary/landmarks/angel_expedition_portal_192x192.png": 7000,
	"res://assets/environment/sanctuary/landmarks/angel_expedition_portal_ground_192x192.png": 900,
	"res://assets/environment/sanctuary/landmarks/divine_fountain_112x96.png": 3500,
	"res://assets/environment/sanctuary/buildings/skillkeeper_lodge_128x192.png": 6000,
	"res://assets/environment/sanctuary/buildings/armskeeper_workshop_176x192.png": 10000,
	"res://assets/environment/sanctuary/shops/armskeeper_cart_128x96.png": 4000,
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x48.png": 1000,
	"res://assets/characters/npcs/armskeeper/armskeeper_idle_sheet_48x48.png": 1000,
}

const CHARACTER_FRAME_SIZES := {
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x48.png": Vector2i(48, 48),
	"res://assets/characters/npcs/armskeeper/armskeeper_idle_sheet_48x48.png": Vector2i(48, 48),
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	for path: String in RUNTIME_SPRITES:
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != Vector2(RUNTIME_SPRITES[path]):
			_fail("Sanctuary runtime sprite has an invalid size: %s" % path)
			return
		var image := texture.get_image()
		var opaque_pixels := 0
		for y in image.get_height():
			for x in image.get_width():
				var alpha := image.get_pixel(x, y).a
				if alpha > 0.001 and alpha < 0.999:
					_fail("Sanctuary runtime sprite contains soft alpha: %s" % path)
					return
				if alpha >= 0.999:
					opaque_pixels += 1
		if path in MINIMUM_OPAQUE_PIXELS and opaque_pixels < MINIMUM_OPAQUE_PIXELS[path]:
			_fail("Sanctuary crop lost required sprite structure: %s" % path)
			return
		if path in CHARACTER_FRAME_SIZES:
			var frame_size: Vector2i = CHARACTER_FRAME_SIZES[path]
			for frame_index in 4:
				var frame := image.get_region(Rect2i(
					Vector2i(frame_index * frame_size.x, 0),
					frame_size
				))
				var used_rect := frame.get_used_rect()
				if used_rect.position.x < 1 or used_rect.end.x > frame_size.x - 1:
					_fail("Sanctuary NPC silhouette touches a frame edge: %s" % path)
					return
				if used_rect.size.y < 24 or used_rect.size.y > 42:
					_fail("Compact Sanctuary NPC no longer matches Opaw's body-scale language: %s" % path)
					return
	var sanctuary := SanctuaryScene.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	await process_frame
	await process_frame
	var player := sanctuary.get_node("World/Actors/Player") as Player
	var player_body := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	var hud := sanctuary.get_node("UI/CombatHUD") as CombatHUD
	var character_menu := sanctuary.get_node("UI/CharacterMenu") as CharacterMenu
	var skillkeeper := sanctuary.get_node("World/Actors/Skillkeeper") as DialogueNpc
	var merchant := sanctuary.get_node("World/Actors/WeaponMerchant") as DialogueNpc
	var altar := sanctuary.get_node("World/Actors/ExpeditionAltar") as ExpeditionAltar
	var fountain := sanctuary.get_node("World/Actors/DivineFountain") as DivineFountain
	var dialogue := sanctuary.get_node("UI/DialoguePanel") as DialoguePanel
	var menu := sanctuary.get_node("UI/ExpeditionMenu") as ExpeditionMenu
	var weapon_shop := sanctuary.get_node("UI/WeaponShopMenu") as WeaponShopMenu
	var ground := sanctuary.get_node("World/Level/Ground") as SanctuaryGround
	for building_name in ["SkillkeeperLodge", "ArmskeeperWorkshop"]:
		var building_collision := sanctuary.get_node("World/Actors/%s/Collision" % building_name) as CollisionPolygon2D
		if building_collision == null or building_collision.polygon.size() < 4:
			_fail("Sanctuary building does not expose an editable collision polygon: %s" % building_name)
			return
	if ground.tile_set.resource_path != "res://assets/environment/sanctuary/tiles/sanctuary_ground_tileset.tres":
		_fail("Sanctuary still reuses a combat-stage ground tileset.")
		return
	if ground.get_used_cells().size() != 216:
		_fail("Sanctuary dedicated ground did not fill its authored 18x12 map.")
		return
	var lodge := sanctuary.get_node("World/Actors/SkillkeeperLodge") as Node2D
	var workshop := sanctuary.get_node("World/Actors/ArmskeeperWorkshop") as Node2D
	var cart := sanctuary.get_node("World/Actors/ArmskeeperCart") as Node2D
	if lodge.position.x != ground.map_to_local(Vector2i(3, 6)).x:
		_fail("The skill lodge door is not centered on its pavement approach.")
		return
	if workshop.position.x != ground.map_to_local(Vector2i(14, 6)).x:
		_fail("The arms workshop door is not centered on its pavement approach.")
		return
	var cart_bay_center_x := (
		ground.map_to_local(Vector2i(12, 8)).x
		+ ground.map_to_local(Vector2i(13, 8)).x
	) * 0.5
	if cart.position.x != cart_bay_center_x:
		_fail("The Armskeeper cart is not centered on its two-cell pavement bay.")
		return
	if fountain == null:
		_fail("The standalone divine fountain is not instantiated in Sanctuary.")
		return
	var skillkeeper_sprite := skillkeeper.get_node("Sprite") as AnimatedSprite2D
	var merchant_sprite := merchant.get_node("Sprite") as AnimatedSprite2D
	if not skillkeeper_sprite.is_playing() or skillkeeper_sprite.sprite_frames.get_frame_count("idle") != 4:
		_fail("Skillkeeper Eira does not have the required four-frame idle state.")
		return
	if not merchant_sprite.is_playing() or merchant_sprite.sprite_frames.get_frame_count("idle") != 4:
		_fail("Armskeeper Orren does not have the required four-frame idle state.")
		return
	for npc: DialogueNpc in [skillkeeper, merchant]:
		var breath := npc.get_node_or_null("IdleBreath") as NpcIdleBreath
		var npc_sprite := npc.get_node("Sprite") as AnimatedSprite2D
		var npc_collision := npc.get_node("Body/Collision") as CollisionShape2D
		if breath == null or breath.visual != npc_sprite or breath.wait_time > 0.25:
			_fail("Sanctuary NPC is missing its reusable pixel-stepped idle breath: %s" % npc.name)
			return
		var starting_visual_position := npc_sprite.position
		var starting_collision_position := npc_collision.position
		breath._advance_phase()
		if absf(npc_sprite.position.y - starting_visual_position.y) > 1.0 or not is_equal_approx(npc_sprite.position.x, starting_visual_position.x):
			_fail("Sanctuary NPC idle breath does not use restrained integer-pixel motion: %s" % npc.name)
			return
		if npc_collision.position != starting_collision_position:
			_fail("Sanctuary NPC idle presentation moved gameplay collision: %s" % npc.name)
			return
	if altar.rune_orbit == null or altar.portal_glow == null:
		_fail("The angel portal is missing its portal or rune idle presentation.")
		return
	var portal_ground := altar.get_node_or_null("GroundSprite") as Sprite2D
	var portal_structure := altar.get_node_or_null("Sprite") as Sprite2D
	if portal_ground == null or portal_structure == null:
		_fail("The portal is missing its separate ground and Y-sorted structure layers.")
		return
	if portal_ground.z_index >= portal_structure.z_index or portal_structure.z_index != 0:
		_fail("Portal stairs are not behind the player or the structure is not participating in Y-sort.")
		return
	if altar.front_depth_area == null:
		_fail("The portal has no front approach depth area.")
		return
	altar._on_front_depth_body_entered(player)
	if portal_structure.z_index != -1:
		_fail("The player is still rendered behind the portal while approaching its trigger.")
		return
	altar._on_front_depth_body_exited(player)
	if portal_structure.z_index != 0:
		_fail("The portal structure did not restore normal Y-sorting after the player left its trigger.")
		return
	if fountain.water_glint == null or fountain.fountain_glow == null:
		_fail("The standalone fountain is missing its water presentation.")
		return
	for collision_name in [
		"WestGuardianCollision",
		"EastGuardianCollision",
		"PortalBackstopCollision",
	]:
		if not altar.has_node("MonumentBody/%s" % collision_name):
			_fail("The angel portal is missing authored doorway collision: %s" % collision_name)
			return
	if altar.has_node("MonumentBody/FountainCollision"):
		_fail("Fountain collision still belongs to the portal instead of its standalone scene.")
		return
	if altar.has_node("MonumentBody/PortalCollision"):
		_fail("A solid collision still blocks the glowing portal doorway.")
		return
	var fountain_collision := fountain.get_node("Collision") as CollisionPolygon2D
	if fountain_collision == null or fountain_collision.polygon.size() < 12:
		_fail("The standalone fountain does not have its authored walk-around footprint.")
		return
	var trigger := altar.get_node("Trigger") as CollisionShape2D
	if not trigger.shape is RectangleShape2D or (trigger.shape as RectangleShape2D).size.x > 56.0:
		_fail("The expedition prompt is not restricted to the portal threshold.")
		return
	var trigger_size := (trigger.shape as RectangleShape2D).size
	var trigger_bounds := Rect2(-trigger_size * 0.5, trigger_size)
	var front_depth_shape := altar.get_node("FrontDepthArea/Collision") as CollisionShape2D
	if not front_depth_shape.shape is RectangleShape2D:
		_fail("The portal front-depth zone has no editable rectangle shape.")
		return
	var front_depth_size := (front_depth_shape.shape as RectangleShape2D).size
	var front_depth_bounds := Rect2(
		altar.front_depth_area.position - front_depth_size * 0.5,
		front_depth_size
	)
	var trigger_world_bounds := Rect2(trigger.position - trigger_size * 0.5, trigger_size)
	if front_depth_bounds.end.y < trigger_world_bounds.end.y + 40.0:
		_fail("The portal front-depth zone does not begin early enough to protect the player's head.")
		return
	if front_depth_bounds.position.x > -88.0 or front_depth_bounds.end.x < 88.0:
		_fail("The portal front-depth zone does not protect both guardian sides.")
		return
	if (
		not trigger_bounds.has_point(Vector2(0, -72) - trigger.position)
		or trigger_bounds.has_point(Vector2(0, -10) - trigger.position)
	):
		_fail("The expedition trigger does not isolate the doorway from the courtyard.")
		return
	var landmark_spacing := fountain.position.y - altar.position.y
	if landmark_spacing < 140.0 or landmark_spacing > 170.0:
		_fail("Portal and fountain do not have a believable independent courtyard gap.")
		return
	if not _portal_approach_is_clear(altar, fountain):
		_fail("The authored walk-around route to the portal's front interaction point is obstructed.")
		return
	var required_path_cells := [
		Vector2i(8, 4), Vector2i(9, 4),
		Vector2i(8, 11), Vector2i(9, 11),
		Vector2i(3, 5), Vector2i(3, 6),
		Vector2i(14, 5), Vector2i(14, 6),
		Vector2i(7, 6), Vector2i(10, 6),
		Vector2i(12, 8), Vector2i(13, 8),
	]
	for path_cell in required_path_cells:
		if ground.get_cell_atlas_coords(path_cell).y <= 0:
			_fail("An aligned Sanctuary pavement connection is missing at %s." % path_cell)
			return
	for grass_cell in [
		Vector2i(4, 6), Vector2i(5, 6), Vector2i(6, 6),
		Vector2i(11, 6), Vector2i(12, 6), Vector2i(13, 6),
		Vector2i(7, 8), Vector2i(10, 8),
	]:
		if ground.get_cell_atlas_coords(grass_cell).y != 0:
			_fail("A service courtyard expanded into its intended garden break at %s." % grass_cell)
			return

	var interact := InputEventAction.new()
	interact.action = "player_interact"
	interact.pressed = true
	skillkeeper._on_body_entered(player)
	if not hud.interaction_panel.visible or not hud.interaction_label.text.contains("SKILLS"):
		_fail("Approaching Eira did not show the shared skillkeeper prompt.")
		return
	skillkeeper._unhandled_input(interact)
	if not dialogue.visible or not paused:
		_fail("Skillkeeper interaction did not open and safely pause dialogue.")
		return
	var eira_direction := (skillkeeper.global_position - player.global_position).normalized()
	if (
		player.facing_direction.dot(eira_direction) < 0.999
		or not String(player_body.animation).begins_with("interact_")
	):
		_fail("Opaw did not face Eira and enter the directional interaction pose.")
		return
	await process_frame
	var escape := InputEventAction.new()
	escape.action = "ui_cancel"
	escape.pressed = true
	dialogue._unhandled_input(escape)
	if dialogue.visible or character_menu.visible or paused:
		_fail("Esc did not cancel Eira's dialogue without opening another modal.")
		return
	if not String(player_body.animation).begins_with("idle_"):
		_fail("Opaw did not resume directional locomotion after dialogue closed.")
		return
	skillkeeper._unhandled_input(interact)
	if not dialogue.visible or not paused:
		_fail("Skillkeeper dialogue could not be reopened after Esc cancellation.")
		return
	dialogue.advance()
	dialogue.advance()
	dialogue.advance()
	if dialogue.visible or not character_menu.visible or not paused:
		_fail("Completing Eira's dialogue did not open the existing skill-information menu.")
		return
	if not character_menu.has_node("CloseButton"):
		_fail("Opaw's character menu has no top-right mouse close button.")
		return
	character_menu.close_menu()
	if character_menu.visible or paused:
		_fail("Closing skill information did not restore Sanctuary control.")
		return
	skillkeeper._on_body_exited(player)

	merchant._on_body_entered(player)
	if not hud.interaction_label.text.contains("WEAPONS"):
		_fail("Approaching Orren did not show the shared weapon-browsing prompt.")
		return
	merchant._unhandled_input(interact)
	if not dialogue.visible or not paused:
		_fail("Weapon merchant interaction did not open dialogue.")
		return
	dialogue.advance()
	dialogue.advance()
	dialogue.advance()
	if dialogue.visible or not weapon_shop.visible or not paused:
		_fail("Completing Orren's dialogue did not open the paused weapon shop.")
		return
	if weapon_shop.stock_buttons.size() != 1 or weapon_shop.catalog.find_weapon(&"weapon_iron_sword") == null:
		_fail("Orren's shop does not expose the authored Iron Sword stock.")
		return
	weapon_shop.close_button.pressed.emit()
	if weapon_shop.visible or paused:
		_fail("Closing Orren's shop did not restore Sanctuary control.")
		return
	merchant._on_body_exited(player)

	altar._on_body_entered(player)
	if not hud.interaction_label.text.contains("CHOOSE EXPEDITION"):
		_fail("The physically reachable front interaction point did not present the expedition prompt.")
		return
	altar._unhandled_input(interact)
	if not menu.visible or not paused:
		_fail("Angel portal interaction did not open its paused destination menu.")
		return
	if (
		menu.expeditions.is_empty()
		or menu.expeditions[0].destination_scene != "res://levels/test_arena/test_arena.tscn"
	):
		_fail("The first available Sanctuary expedition is not Stage 1.")
		return
	if menu.route_buttons.size() != 3 or menu.first_expedition_button.disabled:
		_fail("The expedition menu did not build one available and two sealed data-driven routes.")
		return
	if (
		not menu.route_buttons[1].disabled
		or not menu.route_buttons[1].tooltip_text.contains("BOSS: Thornbound Warden")
		or not menu.route_buttons[2].disabled
	):
		_fail("Future expedition buttons do not expose their authored access requirements.")
		return
	if root.gui_get_focus_owner() != menu.first_expedition_button:
		_fail("Expedition selection did not establish keyboard/gamepad focus.")
		return
	if menu.first_expedition_button.get_node_or_null(menu.first_expedition_button.focus_neighbor_bottom) != menu.close_button:
		_fail("Expedition selection does not provide an explicit directional focus loop.")
		return
	menu.close_button.pressed.emit()
	if menu.visible or paused:
		_fail("The mouse/keyboard expedition close control did not restore Sanctuary control.")
		return
	print("Sanctuary hub smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _portal_approach_is_clear(altar: ExpeditionAltar, fountain: DivineFountain) -> bool:
	var footprint := CircleShape2D.new()
	footprint.radius = 6.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = footprint
	query.collision_mask = 1
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var right_route: Array[Vector2] = [
		fountain.global_position + Vector2(0, 48),
		fountain.global_position + Vector2(64, 32),
		fountain.global_position + Vector2(64, -34),
		fountain.global_position + Vector2(56, -62),
		altar.global_position + Vector2(28, 10),
		altar.global_position + Vector2(12, -24),
		altar.global_position + Vector2(0, -52),
		altar.global_position + Vector2(0, -53),
	]
	for side_sign in [-1.0, 1.0]:
		for segment_index in range(right_route.size() - 1):
			var start := right_route[segment_index]
			var end := right_route[segment_index + 1]
			start.x = fountain.global_position.x + (start.x - fountain.global_position.x) * side_sign
			end.x = fountain.global_position.x + (end.x - fountain.global_position.x) * side_sign
			var sample_count := maxi(1, ceili(start.distance_to(end) / 4.0))
			for sample_index in range(sample_count + 1):
				var local_point := start.lerp(end, float(sample_index) / float(sample_count))
				query.transform = Transform2D(0.0, local_point)
				if not altar.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
					return false
	return true
