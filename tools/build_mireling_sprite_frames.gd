extends SceneTree

const OUTPUT := "res://assets/characters/enemies/mireling/mireling_sprite_frames.tres"
const ACTION_TEXTURE := "res://assets/characters/enemies/mireling/mireling_action_sheet_48x32.png"
const WALK_TEXTURE := "res://assets/characters/enemies/mireling/mireling_walk_sheet_32x32.png"
const DIRECTIONS := [&"down", &"left", &"right", &"up"]


func _initialize() -> void:
	var action_texture := load(ACTION_TEXTURE) as Texture2D
	var walk_texture := load(WALK_TEXTURE) as Texture2D
	if action_texture == null or walk_texture == null:
		push_error("Mireling textures must be imported before building SpriteFrames.")
		quit(1)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for direction_index in DIRECTIONS.size():
		var direction: StringName = DIRECTIONS[direction_index]
		_add_walk_frame(frames, &"idle_%s" % direction, walk_texture, direction_index, 0)
		_add_walk_animation(frames, &"hop_%s" % direction, walk_texture, direction_index)
		_add_action_animation(frames, &"attack_%s" % direction, action_texture, direction_index, 0, 4, 3.0)
		_add_action_animation(frames, &"dead_%s" % direction, action_texture, direction_index, 4, 4, 12.0)
	var save_error := ResourceSaver.save(frames, OUTPUT)
	if save_error != OK:
		push_error("Unable to save Mireling SpriteFrames.")
		quit(1)
		return
	print("Built Mireling SpriteFrames resource.")
	quit(0)


func _add_walk_frame(
	frames: SpriteFrames,
	animation_name: StringName,
	texture: Texture2D,
	row: int,
	column: int
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 1.0)
	frames.set_animation_loop(animation_name, true)
	var frame := AtlasTexture.new()
	frame.atlas = texture
	frame.region = Rect2(column * 32, row * 32, 32, 32)
	frames.add_frame(animation_name, frame)


func _add_action_animation(
	frames: SpriteFrames,
	animation_name: StringName,
	texture: Texture2D,
	row: int,
	first_column: int,
	frame_count: int,
	speed: float
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, speed)
	frames.set_animation_loop(animation_name, false)
	for frame_index in frame_count:
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2((first_column + frame_index) * 48, row * 32, 48, 32)
		frames.add_frame(animation_name, frame)


func _add_walk_animation(
	frames: SpriteFrames,
	animation_name: StringName,
	texture: Texture2D,
	row: int
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, 7.0)
	frames.set_animation_loop(animation_name, true)
	for column in 4:
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(column * 32, row * 32, 32, 32)
		frames.add_frame(animation_name, frame)
