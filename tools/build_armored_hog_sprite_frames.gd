extends SceneTree

const OUTPUT := "res://assets/characters/enemies/stage_4_armored_hog/armored_hog_sprite_frames.tres"
const LOCOMOTION := "res://assets/characters/enemies/stage_4_armored_hog/armored_hog_locomotion_sheet_64x48.png"
const CHARGE := "res://assets/characters/enemies/stage_4_armored_hog/armored_hog_charge_sheet_64x48.png"
const REACTION := "res://assets/characters/enemies/stage_4_armored_hog/armored_hog_reaction_sheet_64x48.png"
const DIRECTIONS := [&"down", &"left", &"right", &"up"]


func _initialize() -> void:
	var locomotion := load(LOCOMOTION) as Texture2D
	var charge := load(CHARGE) as Texture2D
	var reaction := load(REACTION) as Texture2D
	if locomotion == null or charge == null or reaction == null:
		push_error("Armored Hog textures must be imported before building SpriteFrames.")
		quit(1)
		return
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in DIRECTIONS.size():
		var direction: StringName = DIRECTIONS[row]
		_add(frames, &"idle_%s" % direction, locomotion, row, 0, 1, 1.0, true)
		_add(frames, &"walk_%s" % direction, locomotion, row, 0, 4, 7.0, true)
		_add(frames, &"brace_%s" % direction, charge, row, 0, 3, 7.5, false)
		_add(frames, &"charge_%s" % direction, charge, row, 3, 2, 12.0, true)
		_add(frames, &"crash_%s" % direction, charge, row, 5, 1, 1.0, false)
		_add(frames, &"hurt_%s" % direction, reaction, row, 0, 2, 12.0, false)
		_add(frames, &"dazed_%s" % direction, reaction, row, 2, 1, 1.0, true)
		_add(frames, &"dead_%s" % direction, reaction, row, 3, 3, 8.5, false)
	var error := ResourceSaver.save(frames, OUTPUT)
	if error != OK:
		push_error("Unable to save Armored Hog SpriteFrames: %s" % error_string(error))
		quit(1)
		return
	print("Built Armored Hog SpriteFrames resource with 32 named animations.")
	quit(0)


func _add(
	frames: SpriteFrames,
	name: StringName,
	texture: Texture2D,
	row: int,
	first_column: int,
	count: int,
	speed: float,
	loop: bool
) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	for column_offset in count:
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2((first_column + column_offset) * 64, row * 48, 64, 48)
		frames.add_frame(name, frame)
