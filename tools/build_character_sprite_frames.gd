extends SceneTree

const CELL_SIZE := Vector2i(24, 32)
const DIRECTIONS := ["down", "left", "right", "up"]


func _initialize() -> void:
	var player_error := _build_player_frames()
	var enemy_error := _build_enemy_frames()
	var mireling_error := _build_mireling_frames()
	var bramble_spitter_error := _build_bramble_spitter_frames()
	if player_error != OK or enemy_error != OK or mireling_error != OK or bramble_spitter_error != OK:
		quit(1)
		return
	print("Character SpriteFrames built, including Alden's action-owned presentation.")
	quit(0)


func _build_player_frames() -> Error:
	var idle_texture := load("res://assets/characters/playable/alden/alden_idle_sheet_32x32.png") as Texture2D
	var walk_texture := load("res://assets/characters/playable/alden/alden_walk_sheet_32x32.png") as Texture2D
	var attack_texture := load("res://assets/characters/playable/alden/alden_attack_body_sheet_48x32.png") as Texture2D
	var dash_texture := load("res://assets/characters/playable/alden/alden_dash_sheet_48x32.png") as Texture2D
	var interact_texture := load("res://assets/characters/playable/alden/alden_interact_sheet_48x32.png") as Texture2D
	var hurt_texture := load("res://assets/characters/playable/alden/alden_hurt_sheet_32x32.png") as Texture2D
	var defeat_texture := load("res://assets/characters/playable/alden/alden_defeat_sheet_64x32.png") as Texture2D
	if (
		idle_texture == null
		or walk_texture == null
		or attack_texture == null
		or dash_texture == null
		or interact_texture == null
		or hurt_texture == null
		or defeat_texture == null
	):
		push_error("Every Alden action sheet must be imported before building SpriteFrames.")
		return ERR_CANT_OPEN
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for row in range(4):
		var direction: String = DIRECTIONS[row]
		_add_player_action_animation(frames, "idle_" + direction, idle_texture, row, 2, Vector2i(32, 32), 1.6, true)
		_add_player_action_animation(frames, "walk_" + direction, walk_texture, row, 4, Vector2i(32, 32), 7.0, true)
		_add_player_action_animation(frames, "attack_" + direction, attack_texture, row, 3, Vector2i(48, 32), 1.0, false)
		_add_player_action_animation(frames, "dash_" + direction, dash_texture, row, 3, Vector2i(48, 32), 18.0, false)
		_add_player_action_animation(frames, "interact_" + direction, interact_texture, row, 2, Vector2i(48, 32), 2.0, true)
		_add_player_action_animation(frames, "hurt_" + direction, hurt_texture, row, 2, Vector2i(32, 32), 8.0, false)
		_add_player_action_animation(frames, "defeat_" + direction, defeat_texture, row, 4, Vector2i(64, 32), 5.0, false)
	return ResourceSaver.save(frames, "res://assets/characters/playable/alden/alden_sprite_frames.tres")


func _add_player_action_animation(
	frames: SpriteFrames,
	name: String,
	texture: Texture2D,
	direction_row: int,
	frame_count: int,
	cell_size: Vector2i,
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	for column in frame_count:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2i(Vector2i(column * cell_size.x, direction_row * cell_size.y), cell_size)
		frames.add_frame(name, atlas)


func _build_enemy_frames() -> Error:
	var texture := load("res://assets/characters/enemies/forsaken_thrall/forsaken_thrall_locomotion_sheet_24x32.png") as Texture2D
	var attack_texture := load("res://assets/characters/enemies/forsaken_thrall/forsaken_thrall_claw_attack_sheet_64x48.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for column in range(4):
		var direction: String = DIRECTIONS[column]
		_add_animation(frames, "idle_" + direction, texture, [Vector2i(column, 0)], 1.0, true)
		_add_animation(frames, "walk_" + direction, texture, [Vector2i(column, 0), Vector2i(column, 1)], 4.0, true)
		_add_attack_animation(frames, "attack_" + direction, attack_texture, column)
		_add_animation(frames, "dead_" + direction, texture, [Vector2i(column, 3)], 1.0, false)
	return ResourceSaver.save(frames, "res://assets/characters/enemies/forsaken_thrall/forsaken_thrall_sprite_frames.tres")


func _build_mireling_frames() -> Error:
	var texture := load("res://assets/characters/enemies/mireling/mireling_action_sheet_32x32.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for column in range(4):
		var direction: String = DIRECTIONS[column]
		_add_mireling_animation(frames, "idle_" + direction, texture, column, 0, 1.0, true)
		_add_mireling_animation(frames, "hop_" + direction, texture, column, 1, 4.0, true)
		_add_mireling_animation(frames, "attack_" + direction, texture, column, 2, 1.0, false)
		_add_mireling_animation(frames, "dead_" + direction, texture, column, 3, 1.0, false)
	return ResourceSaver.save(frames, "res://assets/characters/enemies/mireling/mireling_sprite_frames.tres")


func _build_bramble_spitter_frames() -> Error:
	var texture := load("res://assets/characters/enemies/bramble_spitter/bramble_spitter_action_sheet_32x32.png") as Texture2D
	if texture == null:
		push_error("Bramble Spitter runtime atlas must be imported before building SpriteFrames.")
		return ERR_CANT_OPEN
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for column in range(4):
		var direction: String = DIRECTIONS[column]
		_add_32px_animation(frames, "idle_" + direction, texture, [Vector2i(column, 0)], 1.0, true)
		_add_32px_animation(frames, "walk_" + direction, texture, [Vector2i(column, 0), Vector2i(column, 1)], 3.5, true)
		_add_32px_animation(
			frames,
			"attack_" + direction,
			texture,
			[Vector2i(column, 0), Vector2i(column, 1), Vector2i(column, 2)],
			4.0,
			false
		)
		_add_32px_animation(frames, "dead_" + direction, texture, [Vector2i(column, 3)], 1.0, false)
	return ResourceSaver.save(frames, "res://assets/characters/enemies/bramble_spitter/bramble_spitter_sprite_frames.tres")


func _add_mireling_animation(frames: SpriteFrames, name: String, texture: Texture2D, column: int, row: int, speed: float, loop: bool) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	var atlas := AtlasTexture.new()
	atlas.atlas = texture
	atlas.region = Rect2i(column * 32, row * 32, 32, 32)
	frames.add_frame(name, atlas)


func _add_32px_animation(
	frames: SpriteFrames,
	name: String,
	texture: Texture2D,
	cells: Array[Vector2i],
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	for cell in cells:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2i(cell * 32, Vector2i(32, 32))
		frames.add_frame(name, atlas)


func _add_animation(
	frames: SpriteFrames,
	name: String,
	texture: Texture2D,
	cells: Array[Vector2i],
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	for cell in cells:
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2i(cell * CELL_SIZE, CELL_SIZE)
		frames.add_frame(name, atlas)


func _add_attack_animation(
	frames: SpriteFrames,
	name: String,
	texture: Texture2D,
	direction_row: int
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, 1.0)
	frames.set_animation_loop(name, false)
	for column in range(6):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2i(column * 64, direction_row * 48, 64, 48)
		frames.add_frame(name, atlas)
