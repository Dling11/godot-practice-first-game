extends SceneTree

const SHEET_PATH := "res://assets/characters/playable/king/simple_reboot/king_simple_locomotion_sheet_48x32.png"
const FRAMES_PATH := "res://assets/characters/playable/king/simple_reboot/king_simple_sprite_frames.tres"
const PREVIEW_PATH := "res://entities/player/king/king_simple_locomotion_preview.tscn"
const DIRECTIONS := [&"down", &"left", &"right", &"up"]


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var texture := load(SHEET_PATH) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != Vector2i(192, 128):
		_fail("King's simple locomotion sheet is not an exact 4x4 atlas of 48x32 cells.")
		return
	for y in range(image.get_height()):
		for x in range(image.get_width()):
			var alpha := image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("King's runtime sheet contains non-binary alpha at %s,%s." % [x, y])
				return

	var frames := load(FRAMES_PATH) as SpriteFrames
	if frames == null:
		_fail("King's simple SpriteFrames resource did not load.")
		return
	for direction in DIRECTIONS:
		var idle_name := StringName("idle_%s" % direction)
		var walk_name := StringName("walk_%s" % direction)
		if not frames.has_animation(idle_name) or frames.get_frame_count(idle_name) != 1:
			_fail("King is missing exact one-frame %s." % idle_name)
			return
		if not frames.has_animation(walk_name) or frames.get_frame_count(walk_name) != 4:
			_fail("King is missing exact four-frame %s." % walk_name)
			return
		if not is_equal_approx(frames.get_animation_speed(walk_name), 8.0):
			_fail("King's %s playback speed drifted from 8 FPS." % walk_name)
			return

	var preview_scene := load(PREVIEW_PATH) as PackedScene
	var preview := preview_scene.instantiate() if preview_scene != null else null
	if preview == null:
		_fail("King's isolated locomotion preview did not instantiate.")
		return
	root.add_child(preview)
	await process_frame
	for node_name in [&"Down", &"Left", &"Right", &"Up"]:
		var sprite := preview.get_node_or_null(NodePath(String(node_name))) as AnimatedSprite2D
		if sprite == null or not sprite.is_playing():
			_fail("King preview direction %s is absent or not animating." % node_name)
			return
	preview.queue_free()
	print("King simple locomotion asset smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
