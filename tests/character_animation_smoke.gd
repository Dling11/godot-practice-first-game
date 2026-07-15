extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const EnemyScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
const DamageInfoScript = preload("res://gameplay/combat/damage_info.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player_sheets := [
		["res://assets/characters/playable/alden/alden_idle_sheet_32x32.png", Vector2i(64, 128), Vector2i(32, 32), 2, false],
		["res://assets/characters/playable/alden/alden_walk_sheet_32x32.png", Vector2i(128, 128), Vector2i(32, 32), 4, false],
		["res://assets/characters/playable/alden/alden_attack_body_sheet_48x32.png", Vector2i(144, 128), Vector2i(48, 32), 3, false],
		["res://assets/characters/playable/alden/alden_dash_sheet_48x32.png", Vector2i(144, 128), Vector2i(48, 32), 3, true],
		["res://assets/characters/playable/alden/alden_interact_sheet_48x32.png", Vector2i(96, 128), Vector2i(48, 32), 2, false],
		["res://assets/characters/playable/alden/alden_hurt_sheet_32x32.png", Vector2i(64, 128), Vector2i(32, 32), 2, false],
		["res://assets/characters/playable/alden/alden_defeat_sheet_64x32.png", Vector2i(256, 128), Vector2i(64, 32), 4, true],
	]
	for sheet: Array in player_sheets:
		if not _validate_player_action_sheet(sheet[0], sheet[1], sheet[2], sheet[3], sheet[4]):
			return
	if not _validate_world_weapon("res://assets/items/weapons/world/ashwood_blade_16x24.png"):
		return
	if not _validate_sheet("res://assets/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_sheet_24x32.png"):
		return
	if not _validate_creature_sheet("res://assets/characters/enemies/mireling/mireling_action_sheet_32x32.png", "Mireling"):
		return
	if not _validate_creature_sheet("res://assets/characters/enemies/bramble_spitter/bramble_spitter_action_sheet_32x32.png", "Bramble Spitter"):
		return
	if not _validate_attack_sheet("res://assets/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_sheet_64x48.png", "Forsaken Thrall"):
		return
	var player := PlayerScene.instantiate()
	root.add_child(player)
	player.set_physics_process(false)
	var player_body: AnimatedSprite2D = player.get_node("VisualRoot/Body")
	var player_shadow: Polygon2D = player.get_node("VisualRoot/Shadow")
	var weapon_visual: Node2D = player.get_node("VisualRoot/WeaponVisual")
	var weapon_sprite: Sprite2D = player.get_node("VisualRoot/WeaponVisual/Weapon")
	var swing_trail: Line2D = player.get_node("VisualRoot/SwordSwingTrail")
	var player_collision: CollisionShape2D = player.get_node("CollisionShape2D")
	if player_shadow.position != Vector2(0.0, -2.0) or not player_collision.shape is CircleShape2D:
		_fail("Player shadow/collision is not anchored to the foot plane.")
		return
	if player_body.animation != &"idle_down":
		_fail("Player did not initialize with idle_down.")
		return
	if weapon_sprite.texture == null or weapon_sprite.texture != player.attack_component.weapon.world_texture:
		_fail("Alden's visible Ashwood Blade does not share the runtime weapon definition.")
		return
	if (
		weapon_sprite.position != player.attack_component.weapon.sprite_offset_from_grip
		or not is_equal_approx(weapon_sprite.scale.x, player.attack_component.weapon.world_visual_scale)
	):
		_fail("Alden's visible weapon does not use its data-driven grip offset and scale.")
		return

	player._set_facing_direction(Vector2.RIGHT)
	player.movement_changed.emit(Vector2.RIGHT, true)
	if player_body.animation != &"walk_right":
		_fail("Player did not select walk_right.")
		return
	var idle_weapon_position := weapon_visual.position
	var idle_weapon_rotation := weapon_visual.rotation
	var idle_body_scale := player_body.scale
	if not player.request_primary_attack() or player_body.animation != &"attack_right":
		_fail("Directional Ashwood Blade attack did not select attack_right.")
		return
	var idle_frame := player_body.sprite_frames.get_frame_texture(&"idle_right", 0) as AtlasTexture
	var attack_frame := player_body.sprite_frames.get_frame_texture(&"attack_right", 0) as AtlasTexture
	if (
		idle_frame == null
		or attack_frame == null
		or idle_frame.atlas == attack_frame.atlas
		or attack_frame.region.size != Vector2(48.0, 32.0)
		or player_body.sprite_frames.get_frame_count(&"attack_right") != 3
	):
		_fail("Alden's attack does not use its separate three-frame body sheet.")
		return
	for frame_index in range(3):
		await physics_frame
	if (
		weapon_visual.position == idle_weapon_position
		and is_equal_approx(weapon_visual.rotation, idle_weapon_rotation)
	):
		_fail("The grip-anchored Ashwood Blade did not visibly enter its wind-up.")
		return
	var wind_up_weapon_position := weapon_visual.position
	for frame_index in range(4):
		await physics_frame
	if (
		player_body.animation != &"attack_right"
		or player.attack_component.phase != MeleeAttackComponent.Phase.ACTIVE
		or player_body.frame != 1
		or weapon_visual.position == wind_up_weapon_position
		or not swing_trail.visible
		or player_body.scale != idle_body_scale
	):
		_fail(
			"Alden's full-size body, grip swing, and readable active trail did not align "
			+ "(phase=%s, trail=%s, scale=%s)." % [
				player.attack_component.phase,
				swing_trail.visible,
				player_body.scale,
			]
		)
		return
	player.attack_component.cancel_attack()
	if not player.request_evade(Vector2.LEFT) or player_body.animation != &"dash_left":
		_fail("Directional evade did not select dash_left.")
		return
	if player_body.sprite_frames.get_frame_count(&"dash_left") != 3:
		_fail("Alden's dash does not expose its separate three-frame animation.")
		return
	player.evade_component.cancel_evade()

	var enemy := EnemyScene.instantiate()
	enemy.target = player
	root.add_child(enemy)
	enemy.set_physics_process(false)
	var enemy_body: AnimatedSprite2D = enemy.get_node("VisualPivot/Body")
	var enemy_shadow: Polygon2D = enemy.get_node("Shadow")
	var enemy_collision: CollisionShape2D = enemy.get_node("BodyCollision")
	if enemy_shadow.position != Vector2(0.0, -2.0) or not enemy_collision.shape is CircleShape2D:
		_fail("Thrall shadow/collision is not anchored to the foot plane.")
		return
	enemy.facing_changed.emit(Vector2.LEFT)
	enemy.state_changed.emit(enemy.State.WIND_UP, 0.2)
	if enemy_body.animation != &"attack_left":
		_fail("Thrall wind-up did not select attack_left.")
		return
	if enemy_body.frame != 0:
		_fail("Thrall claw attack did not begin on anticipation frame 0.")
		return
	enemy.state_changed.emit(enemy.State.ACTIVE, 0.12)
	if enemy_body.frame != 2:
		_fail("Thrall claw active window did not begin on slash frame 2.")
		return
	player.health_component.apply_damage(DamageInfoScript.new(1.0, enemy, Vector2.LEFT))
	if player_body.animation != &"hurt_left":
		_fail("Alden did not play the separate directional hurt reaction.")
		return
	for frame_index in range(30):
		await physics_frame
	if player_body.animation != &"walk_left":
		_fail("Alden's hurt reaction did not return to locomotion (animation=%s, frame=%s, playing=%s)." % [player_body.animation, player_body.frame, player_body.is_playing()])
		return
	var health = enemy.get_node("HealthComponent")
	health.apply_damage(DamageInfoScript.new(999.0, player, Vector2.RIGHT))
	if enemy_body.animation != &"dead_left":
		_fail("Thrall defeat did not select dead_left.")
		return

	player.health_component.apply_damage(DamageInfoScript.new(999.0, enemy, Vector2.LEFT))
	if player_body.animation != &"defeat_left":
		_fail("Alden did not begin the staged directional defeat animation.")
		return
	if player_body.sprite_frames.get_frame_count(&"defeat_left") != 4:
		_fail("Alden's defeat does not expose its separate four-frame sequence.")
		return
	for frame_index in range(18):
		await physics_frame
	if player_body.frame < 1:
		_fail("Alden's defeat presentation did not progress beyond the first recoil pose.")
		return
	for frame_index in range(55):
		await physics_frame
	if player.get_node("VisualRoot").modulate.a >= 0.1:
		_fail("Alden's staged defeat did not finish with the presentation fade.")
		return

	print("Character animation smoke test passed.")
	quit(0)


func _validate_sheet(path: String) -> bool:
	var texture := load(path) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != Vector2i(96, 128):
		_fail("Invalid 24x32 sheet dimensions: %s" % path)
		return false
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("Sheet contains non-binary alpha at %s,%s: %s" % [x, y, path])
				return false
	return true


func _validate_player_action_sheet(
	path: String,
	expected_size: Vector2i,
	cell_size: Vector2i,
	frame_count: int,
	allows_low_pose: bool
) -> bool:
	var texture := load(path) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != expected_size:
		_fail("Invalid Alden action sheet dimensions: %s" % path)
		return false
	var colors: Dictionary = {}
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a != 0.0 and color.a != 1.0:
				_fail("Alden action sheet contains non-binary alpha at %s,%s: %s" % [x, y, path])
				return false
			if color.a == 1.0:
				colors[color.to_rgba32()] = true
	if colors.size() > 17:
		_fail("Alden action sheet exceeds its seventeen-color runtime palette: %s" % path)
		return false
	for row in range(4):
		for column in frame_count:
			var cell := image.get_region(Rect2i(
				Vector2i(column * cell_size.x, row * cell_size.y),
				cell_size
			))
			var bounds := cell.get_used_rect()
			if bounds.size == Vector2i.ZERO:
				_fail("Alden action frame %s,%s is empty: %s" % [column, row, path])
				return false
			if bounds.end.y != cell_size.y:
				_fail("Alden action frame lost its foot baseline at %s,%s (%s): %s" % [column, row, bounds, path])
				return false
			if column == 0 and bounds.size != Vector2i(18, 27):
				_fail("Alden reference pose is not the canonical 18x27 scale at row %s: %s" % [row, path])
				return false
			if not allows_low_pose and bounds.size.y < 19:
				_fail("Alden action pose became visually miniature at %s,%s: %s" % [column, row, path])
				return false
	return true


func _validate_world_weapon(path: String) -> bool:
	var texture := load(path) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != Vector2i(16, 24):
		_fail("Ashwood Blade world art is not 16x24.")
		return false
	if image.get_used_rect().size == Vector2i.ZERO:
		_fail("Ashwood Blade world art is empty.")
		return false
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("Ashwood Blade world art contains non-binary alpha.")
				return false
	return true


func _validate_attack_sheet(path: String, actor_name: String) -> bool:
	var texture := load(path) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != Vector2i(384, 192):
		_fail("Invalid %s 64x48 attack sheet dimensions." % actor_name)
		return false
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("%s attack sheet contains non-binary alpha at %s,%s." % [actor_name, x, y])
				return false
	for row in range(4):
		for column in range(6):
			var bounds := image.get_region(Rect2i(column * 64, row * 48, 64, 48)).get_used_rect()
			if bounds.end.y != 40 or bounds.size.y < 29:
				_fail("%s attack frame %s,%s violates shared scale/baseline." % [actor_name, column, row])
				return false
	return true


func _validate_creature_sheet(path: String, actor_name: String) -> bool:
	var texture := load(path) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != Vector2i(128, 128):
		_fail("Invalid %s 32x32 action sheet dimensions." % actor_name)
		return false
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("%s action sheet contains non-binary alpha at %s,%s." % [actor_name, x, y])
				return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
