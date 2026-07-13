extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const EnemyScene = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
const DamageInfoScript = preload("res://gameplay/combat/damage_info.gd")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not _validate_sheet("res://assets/characters/awakened/awakened_locomotion_sheet_24x32.png"):
		return
	if not _validate_sheet("res://assets/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_sheet_24x32.png"):
		return
	if not _validate_creature_sheet("res://assets/characters/enemies/mireling/mireling_action_sheet_32x32.png", "Mireling"):
		return
	if not _validate_creature_sheet("res://assets/characters/enemies/bramble_spitter/bramble_spitter_action_sheet_32x32.png", "Bramble Spitter"):
		return
	if not _validate_attack_sheet("res://assets/characters/awakened/awakened_sword_attack_sheet_64x48.png", "The Awakened"):
		return
	if not _validate_attack_sheet("res://assets/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_sheet_64x48.png", "Forsaken Thrall"):
		return
	var player := PlayerScene.instantiate()
	root.add_child(player)
	player.set_physics_process(false)
	var player_body: AnimatedSprite2D = player.get_node("Body")
	var player_shadow: Polygon2D = player.get_node("Shadow")
	var player_collision: CollisionShape2D = player.get_node("CollisionShape2D")
	if player_shadow.position != Vector2(0.0, -2.0) or not player_collision.shape is CircleShape2D:
		_fail("Player shadow/collision is not anchored to the foot plane.")
		return
	if player_body.animation != &"idle_down":
		_fail("Player did not initialize with idle_down.")
		return

	player._set_facing_direction(Vector2.RIGHT)
	player.movement_changed.emit(Vector2.RIGHT, true)
	if player_body.animation != &"walk_right":
		_fail("Player did not select walk_right.")
		return
	if not player.request_primary_attack() or player_body.animation != &"attack_right":
		_fail("Directional sword attack did not select attack_right.")
		return
	if player_body.frame != 0:
		_fail("Authored sword attack did not begin on anticipation frame 0.")
		return
	for frame_index in range(6):
		await physics_frame
	if player_body.frame < 2 or player_body.frame > 3:
		_fail("Authored sword attack did not advance to its active frames.")
		return
	player.attack_component.cancel_attack()
	if not player.request_evade(Vector2.LEFT) or player_body.animation != &"dash_left":
		_fail("Directional evade did not select dash_left.")
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
	var health = enemy.get_node("HealthComponent")
	health.apply_damage(DamageInfoScript.new(999.0, player, Vector2.RIGHT))
	if enemy_body.animation != &"dead_left":
		_fail("Thrall defeat did not select dead_left.")
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
