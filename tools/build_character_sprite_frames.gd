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
	print("24x32 character SpriteFrames built.")
	quit(0)


func _build_player_frames() -> Error:
	var texture := load("res://assets/characters/sprites_24x32/player_sheet_24x32.png") as Texture2D
	var attack_texture := load("res://assets/characters/sprites_24x32/player_attack_sheet_64x48.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for column in range(4):
		var direction: String = DIRECTIONS[column]
		_add_animation(frames, "idle_" + direction, texture, [Vector2i(column, 0)], 1.0, true)
		_add_animation(frames, "walk_" + direction, texture, [Vector2i(column, 0), Vector2i(column, 1)], 5.0, true)
		_add_attack_animation(frames, "attack_" + direction, attack_texture, column)
		_add_animation(frames, "dash_" + direction, texture, [Vector2i(column, 3)], 1.0, false)
	return ResourceSaver.save(frames, "res://assets/characters/sprites_24x32/player_frames.tres")


func _build_enemy_frames() -> Error:
	var texture := load("res://assets/characters/sprites_24x32/thrall_sheet_24x32.png") as Texture2D
	var attack_texture := load("res://assets/characters/sprites_24x32/thrall_claw_attack_sheet_64x48.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for column in range(4):
		var direction: String = DIRECTIONS[column]
		_add_animation(frames, "idle_" + direction, texture, [Vector2i(column, 0)], 1.0, true)
		_add_animation(frames, "walk_" + direction, texture, [Vector2i(column, 0), Vector2i(column, 1)], 4.0, true)
		_add_attack_animation(frames, "attack_" + direction, attack_texture, column)
		_add_animation(frames, "dead_" + direction, texture, [Vector2i(column, 3)], 1.0, false)
	return ResourceSaver.save(frames, "res://assets/characters/sprites_24x32/thrall_frames.tres")


func _build_mireling_frames() -> Error:
	var texture := load("res://assets/characters/mireling/mireling_sheet_32x32.png") as Texture2D
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	for column in range(4):
		var direction: String = DIRECTIONS[column]
		_add_mireling_animation(frames, "idle_" + direction, texture, column, 0, 1.0, true)
		_add_mireling_animation(frames, "hop_" + direction, texture, column, 1, 4.0, true)
		_add_mireling_animation(frames, "attack_" + direction, texture, column, 2, 1.0, false)
		_add_mireling_animation(frames, "dead_" + direction, texture, column, 3, 1.0, false)
	return ResourceSaver.save(frames, "res://assets/characters/mireling/mireling_frames.tres")


func _build_bramble_spitter_frames() -> Error:
	var texture := load("res://assets/characters/bramble_spitter/bramble_spitter_sheet_32x32.png") as Texture2D
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
	return ResourceSaver.save(frames, "res://assets/characters/bramble_spitter/bramble_spitter_frames.tres")


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
