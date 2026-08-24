extends SceneTree

const OUTPUT := "res://assets/characters/enemies/stage_6_crag_bear/crag_bear_sprite_frames.tres"
const LOCOMOTION := "res://assets/characters/enemies/stage_6_crag_bear/crag_bear_locomotion_sheet_64x48.png"
const BASIC_ATTACK := "res://assets/characters/enemies/stage_6_crag_bear/crag_bear_basic_attack_v2_sheet_96x64.png"
const GROUND_SLAM := "res://assets/characters/enemies/stage_6_crag_bear/crag_bear_body_slam_v2_sheet_96x80.png"
const REACTION := "res://assets/characters/enemies/stage_6_crag_bear/crag_bear_reaction_sheet_64x48.png"
const DIRECTIONS := [&"down", &"left", &"right", &"up"]


func _initialize() -> void:
	var locomotion := load(LOCOMOTION) as Texture2D
	var basic_attack := load(BASIC_ATTACK) as Texture2D
	var ground_slam := load(GROUND_SLAM) as Texture2D
	var reaction := load(REACTION) as Texture2D
	if locomotion == null or basic_attack == null or ground_slam == null or reaction == null:
		push_error("Crag Bear textures must be imported before building SpriteFrames.")
		quit(1)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in DIRECTIONS.size():
		var direction: StringName = DIRECTIONS[row]
		_add(frames, &"idle_%s" % direction, locomotion, row, 0, 1, 1.0, true, Vector2i(64, 48))
		_add(frames, &"walk_%s" % direction, locomotion, row, 0, 4, 7.0, true, Vector2i(64, 48))
		_add(frames, &"attack_%s" % direction, basic_attack, row, 0, 8, 10.0, false, Vector2i(96, 64))
		_add(frames, &"slam_%s" % direction, ground_slam, row, 0, 8, 8.0, false, Vector2i(96, 80))
		_add(frames, &"hurt_%s" % direction, reaction, row, 0, 2, 12.0, false, Vector2i(64, 48))
		_add(frames, &"dead_%s" % direction, reaction, row, 2, 4, 7.0, false, Vector2i(64, 48))
	var error := ResourceSaver.save(frames, OUTPUT)
	if error != OK:
		push_error("Unable to save Crag Bear SpriteFrames: %s" % error_string(error))
		quit(1)
		return
	print("Built Crag Bear SpriteFrames resource with 24 named animations.")
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
