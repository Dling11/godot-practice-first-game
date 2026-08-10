extends SceneTree

const SHEET_PATH := "res://assets/characters/playable/king/king_idle_sheet_64x64.png"
const OUTPUT_PATH := "res://assets/characters/playable/king/king_idle_sprite_frames.tres"
const CELL_SIZE := Vector2i(64, 64)
const DIRECTIONS := [&"down", &"left", &"right", &"up"]
const FRAME_COUNT := 4
const IDLE_FPS := 3.0


func _initialize() -> void:
	var texture := load(SHEET_PATH) as Texture2D
	if texture == null:
		push_error("King idle sheet must be imported before SpriteFrames can be built.")
		quit(1)
		return

	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	for row in DIRECTIONS.size():
		var animation_name := StringName("idle_" + String(DIRECTIONS[row]))
		frames.add_animation(animation_name)
		frames.set_animation_speed(animation_name, IDLE_FPS)
		frames.set_animation_loop(animation_name, true)
		for column in FRAME_COUNT:
			var atlas := AtlasTexture.new()
			atlas.atlas = texture
			atlas.region = Rect2i(column * CELL_SIZE.x, row * CELL_SIZE.y, CELL_SIZE.x, CELL_SIZE.y)
			frames.add_frame(animation_name, atlas)

	var error := ResourceSaver.save(frames, OUTPUT_PATH)
	if error != OK:
		push_error("Could not save King idle SpriteFrames: %s" % error_string(error))
		quit(1)
		return

	print("King idle SpriteFrames built: %s" % OUTPUT_PATH)
	quit(0)
