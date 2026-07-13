extends SceneTree

const SanctuaryScene = preload("res://levels/sanctuary/sanctuary.tscn")

const RUNTIME_SPRITES := {
	"res://assets/environment/sanctuary/landmarks/angel_portal_fountain_256x240.png": Vector2i(256, 240),
	"res://assets/environment/sanctuary/buildings/mushroom_dwelling_128x192.png": Vector2i(128, 192),
	"res://assets/environment/sanctuary/buildings/merchant_hall_176x192.png": Vector2i(176, 192),
	"res://assets/environment/sanctuary/shops/weapon_stall_128x96.png": Vector2i(128, 96),
	"res://assets/environment/sanctuary/props/sanctuary_tree_broad_96x120.png": Vector2i(96, 120),
	"res://assets/environment/sanctuary/props/sanctuary_tree_tall_96x120.png": Vector2i(96, 120),
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x80.png": Vector2i(192, 80),
	"res://assets/characters/npcs/weapon_merchant/weapon_merchant_idle_sheet_48x72.png": Vector2i(192, 72),
	"res://assets/environment/sanctuary/tiles/sanctuary_ground_atlas_64x64.png": Vector2i(256, 320),
}

const MINIMUM_OPAQUE_PIXELS := {
	"res://assets/environment/sanctuary/buildings/mushroom_dwelling_128x192.png": 14000,
	"res://assets/environment/sanctuary/buildings/merchant_hall_176x192.png": 21000,
	"res://assets/environment/sanctuary/shops/weapon_stall_128x96.png": 7000,
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x80.png": 6100,
	"res://assets/characters/npcs/weapon_merchant/weapon_merchant_idle_sheet_48x72.png": 2400,
}

const CHARACTER_FRAME_SIZES := {
	"res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x80.png": Vector2i(48, 80),
	"res://assets/characters/npcs/weapon_merchant/weapon_merchant_idle_sheet_48x72.png": Vector2i(48, 72),
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
				if path.contains("weapon_merchant") and _count_opaque_components(frame) != 1:
					_fail("Weapon merchant crop contains a disconnected neighboring prop fragment.")
					return
	var sanctuary := SanctuaryScene.instantiate()
	root.add_child(sanctuary)
	current_scene = sanctuary
	await process_frame
	await process_frame
	var player := sanctuary.get_node("World/Actors/Player") as Player
	var hud := sanctuary.get_node("UI/CombatHUD") as CombatHUD
	var character_menu := sanctuary.get_node("UI/CharacterMenu") as CharacterMenu
	var skillkeeper := sanctuary.get_node("World/Actors/Skillkeeper") as DialogueNpc
	var merchant := sanctuary.get_node("World/Actors/WeaponMerchant") as DialogueNpc
	var altar := sanctuary.get_node("World/Actors/ExpeditionAltar") as ExpeditionAltar
	var dialogue := sanctuary.get_node("UI/DialoguePanel") as DialoguePanel
	var menu := sanctuary.get_node("UI/ExpeditionMenu") as ExpeditionMenu
	var ground := sanctuary.get_node("World/Level/Ground") as SanctuaryGround
	for building_name in ["MushroomDwelling", "MerchantHall"]:
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
	if sanctuary.has_node("World/Actors/DivineFountain"):
		_fail("The superseded prototype fountain is still instantiated in Sanctuary.")
		return
	var skillkeeper_sprite := skillkeeper.get_node("Sprite") as AnimatedSprite2D
	var merchant_sprite := merchant.get_node("Sprite") as AnimatedSprite2D
	if not skillkeeper_sprite.is_playing() or skillkeeper_sprite.sprite_frames.get_frame_count("idle") != 4:
		_fail("Skillkeeper Eira does not have the required four-frame idle state.")
		return
	if not merchant_sprite.is_playing() or merchant_sprite.sprite_frames.get_frame_count("idle") != 4:
		_fail("Armskeeper Orren does not have the required four-frame idle state.")
		return
	if altar.rune_orbit == null or altar.portal_glow == null or altar.water_glint == null:
		_fail("The angel portal is missing portal, rune, or fountain-water idle presentation.")
		return
	for collision_name in [
		"FountainCollision",
		"WestPortalPillarCollision",
		"EastPortalPillarCollision",
		"PortalBackstopCollision",
		"WestStatueCollision",
		"EastStatueCollision",
	]:
		if not altar.has_node("MonumentBody/%s" % collision_name):
			_fail("The angel portal is missing walkable-pavement collision separation: %s" % collision_name)
			return
	if altar.has_node("MonumentBody/PortalCollision"):
		_fail("A solid collision still blocks the glowing portal doorway.")
		return
	var fountain_collision := altar.get_node("MonumentBody/FountainCollision") as CollisionPolygon2D
	if fountain_collision == null or fountain_collision.polygon.size() < 12:
		_fail("The portal fountain does not have its authored walk-around footprint.")
		return
	var trigger := altar.get_node("Trigger") as CollisionShape2D
	if not trigger.shape is RectangleShape2D or (trigger.shape as RectangleShape2D).size.x > 56.0:
		_fail("The expedition prompt is not restricted to the portal threshold.")
		return
	var trigger_size := (trigger.shape as RectangleShape2D).size
	var trigger_bounds := Rect2(-trigger_size * 0.5, trigger_size)
	if (
		not trigger_bounds.has_point(Vector2(0, -126) - trigger.position)
		or trigger_bounds.has_point(Vector2(0, -24) - trigger.position)
	):
		_fail("The expedition trigger does not isolate the doorway from the courtyard.")
		return
	if not _portal_approach_is_clear(altar):
		_fail("The authored fountain-side route into the portal threshold is obstructed.")
		return
	for path_cell in [Vector2i(3, 5), Vector2i(3, 6), Vector2i(14, 5), Vector2i(14, 6)]:
		if ground.get_cell_source_id(path_cell) < 0:
			_fail("A side-building pavement connection is missing at %s." % path_cell)
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
	await process_frame
	var escape := InputEventAction.new()
	escape.action = "ui_cancel"
	escape.pressed = true
	dialogue._unhandled_input(escape)
	if dialogue.visible or character_menu.visible or paused:
		_fail("Esc did not cancel Eira's dialogue without opening another modal.")
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
		_fail("The Awakened menu has no top-right mouse close button.")
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
	if dialogue.visible or paused:
		_fail("Completing merchant dialogue did not restore Sanctuary control.")
		return
	merchant._on_body_exited(player)

	altar._on_body_entered(player)
	if not hud.interaction_label.text.contains("CHOOSE EXPEDITION"):
		_fail("Approaching the angel portal did not show its expedition prompt.")
		return
	altar._unhandled_input(interact)
	if not menu.visible or not paused:
		_fail("Angel portal interaction did not open its paused destination menu.")
		return
	if menu.first_expedition_scene != "res://levels/test_arena/test_arena.tscn":
		_fail("The first available Sanctuary expedition is not Stage 1.")
		return
	menu.close_menu()
	if menu.visible or paused:
		_fail("Closing expedition selection did not restore Sanctuary control.")
		return
	print("Sanctuary hub smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _count_opaque_components(image: Image) -> int:
	var visited := PackedByteArray()
	visited.resize(image.get_width() * image.get_height())
	var component_count := 0
	for y in image.get_height():
		for x in image.get_width():
			var start_index := y * image.get_width() + x
			if visited[start_index] == 1 or image.get_pixel(x, y).a < 0.999:
				continue
			component_count += 1
			var stack: Array[Vector2i] = [Vector2i(x, y)]
			while not stack.is_empty():
				var point: Vector2i = stack.pop_back()
				var index := point.y * image.get_width() + point.x
				if visited[index] == 1:
					continue
				visited[index] = 1
				if image.get_pixelv(point).a < 0.999:
					continue
				for offset in [
					Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
					Vector2i(-1, 0), Vector2i(1, 0),
					Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
				]:
					var neighbor: Vector2i = point + offset
					if neighbor.x >= 0 and neighbor.y >= 0 and neighbor.x < image.get_width() and neighbor.y < image.get_height():
						stack.append(neighbor)
	return component_count


func _portal_approach_is_clear(altar: ExpeditionAltar) -> bool:
	var footprint := CircleShape2D.new()
	footprint.radius = 6.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = footprint
	query.collision_mask = 1
	query.collide_with_areas = false
	query.collide_with_bodies = true
	var right_route: Array[Vector2] = [
		Vector2(0, -24),
		Vector2(62, -36),
		Vector2(62, -72),
		Vector2(44, -94),
		Vector2(44, -105),
		Vector2(12, -110),
		Vector2(12, -118),
		Vector2(0, -130),
	]
	for side_sign in [-1.0, 1.0]:
		for segment_index in range(right_route.size() - 1):
			var start := right_route[segment_index] * Vector2(side_sign, 1.0)
			var end := right_route[segment_index + 1] * Vector2(side_sign, 1.0)
			var sample_count := maxi(1, ceili(start.distance_to(end) / 4.0))
			for sample_index in range(sample_count + 1):
				var local_point := start.lerp(end, float(sample_index) / float(sample_count))
				query.transform = Transform2D(0.0, altar.global_position + local_point)
				if not altar.get_world_2d().direct_space_state.intersect_shape(query, 1).is_empty():
					return false
	return true
