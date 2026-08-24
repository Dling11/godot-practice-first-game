extends SceneTree

const OUTPUT := "res://assets/characters/enemies/bramble_spitter/bramble_spitter_sprite_frames.tres"
const PROJECTILE_OUTPUT := "res://assets/characters/enemies/bramble_spitter/bramble_thorn_seed_sprite_frames.tres"
const LOCOMOTION := "res://assets/characters/enemies/bramble_spitter/bramble_spitter_locomotion_sheet_48x48.png"
const ATTACK := "res://assets/characters/enemies/bramble_spitter/bramble_spitter_attack_sheet_64x56.png"
const PROJECTILE := "res://assets/characters/enemies/bramble_spitter/bramble_thorn_seed_sheet_24x24.png"
const DIRECTIONS := [&"down", &"left", &"right", &"up"]


func _initialize() -> void:
	var locomotion := load(LOCOMOTION) as Texture2D
	var attack := load(ATTACK) as Texture2D
	var projectile := load(PROJECTILE) as Texture2D
	if locomotion == null or attack == null or projectile == null:
		push_error("Bramble Spitter textures must be imported before building SpriteFrames.")
		quit(1)
		return
	var body_frames := SpriteFrames.new()
	body_frames.remove_animation(&"default")
	for row in DIRECTIONS.size():
		var direction: StringName = DIRECTIONS[row]
		_add(body_frames, &"idle_%s" % direction, locomotion, row, 0, 2, 2.0, true, Vector2i(48, 48))
		_add(body_frames, &"walk_%s" % direction, locomotion, row, 2, 4, 7.0, true, Vector2i(48, 48))
		_add(body_frames, &"hurt_%s" % direction, locomotion, row, 6, 1, 1.0, false, Vector2i(48, 48))
		_add(body_frames, &"dead_%s" % direction, locomotion, row, 7, 1, 1.0, false, Vector2i(48, 48))
		_add(body_frames, &"attack_%s" % direction, attack, row, 0, 8, 10.0, false, Vector2i(64, 56))
	if ResourceSaver.save(body_frames, OUTPUT) != OK:
		push_error("Unable to save Bramble Spitter body SpriteFrames.")
		quit(1)
		return
	var projectile_frames := SpriteFrames.new()
	projectile_frames.remove_animation(&"default")
	_add(projectile_frames, &"flight", projectile, 0, 0, 4, 12.0, true, Vector2i(24, 24))
	_add(projectile_frames, &"impact", projectile, 0, 4, 3, 16.0, false, Vector2i(24, 24))
	if ResourceSaver.save(projectile_frames, PROJECTILE_OUTPUT) != OK:
		push_error("Unable to save Bramble thorn-seed SpriteFrames.")
		quit(1)
		return
	print("Built Bramble Spitter body and thorn-seed SpriteFrames resources.")
	quit(0)


func _add(
	frames: SpriteFrames,
	name: StringName,
	texture: Texture2D,
	row: int,
	first_column: int,
	count: int,
	speed: float,
	loop: bool,
	cell_size: Vector2i
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	for column_offset in count:
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(
			(first_column + column_offset) * cell_size.x,
			row * cell_size.y,
			cell_size.x,
			cell_size.y
		)
		frames.add_frame(name, frame)
