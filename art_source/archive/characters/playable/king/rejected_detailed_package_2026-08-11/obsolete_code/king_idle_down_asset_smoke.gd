extends SceneTree

const SHEET_PATH := "res://assets/characters/playable/king/idle/king_idle_down_sheet_64x64.png"
const FRAMES_PATH := "res://assets/characters/playable/king/idle/king_idle_down_sprite_frames.tres"
const PREVIEW_PATH := "res://entities/player/king/king_idle_down_preview.tscn"
const CELL_SIZE := Vector2i(64, 64)
const FRAME_COUNT := 4
const FOOT_BASELINE_Y := 58
const PALETTE_LIMIT := 48


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var texture := load(SHEET_PATH) as Texture2D
	if texture == null:
		_fail("King idle-down runtime texture did not load.")
		return
	var image := texture.get_image()
	if image == null or image.get_size() != Vector2i(CELL_SIZE.x * FRAME_COUNT, CELL_SIZE.y):
		_fail("King idle-down sheet is not an exact 4x1 grid of 64x64 cells.")
		return

	var frame_hashes: Dictionary = {}
	var palette: Dictionary = {}
	for frame_index in FRAME_COUNT:
		var frame := image.get_region(Rect2i(
			Vector2i(frame_index * CELL_SIZE.x, 0),
			CELL_SIZE
		))
		var used_rect := frame.get_used_rect()
		if (
			used_rect.position.x < 4
			or used_rect.end.x > CELL_SIZE.x - 4
			or used_rect.position.y < 4
			or used_rect.end.y != FOOT_BASELINE_Y + 1
		):
			_fail("King idle-down frame %d violates its safety margin or baseline: %s." % [frame_index, used_rect])
			return

		for y in CELL_SIZE.y:
			for x in CELL_SIZE.x:
				var color := frame.get_pixel(x, y)
				if color.a != 0.0 and color.a != 1.0:
					_fail("King idle-down frame %d contains partial alpha." % frame_index)
					return
				if color.a == 0.0:
					continue
				var color_key := Color8(
					int(round(color.r * 255.0)),
					int(round(color.g * 255.0)),
					int(round(color.b * 255.0)),
					255
				).to_html(false)
				palette[color_key] = true
				if (
					color.r > 0.58
					and color.b > 0.58
					and color.g < 0.40
					and absf(color.r - color.b) < 0.36
				):
					_fail("King idle-down frame %d retains a magenta-family matte pixel." % frame_index)
					return
		frame_hashes[hash(frame.get_data())] = true

	if frame_hashes.size() != FRAME_COUNT:
		_fail("King idle-down loop contains duplicated filler frames.")
		return
	if palette.size() > PALETTE_LIMIT:
		_fail("King idle-down sheet exceeds its %d-color palette limit." % PALETTE_LIMIT)
		return

	var frames := load(FRAMES_PATH) as SpriteFrames
	if (
		frames == null
		or frames.get_animation_names() != PackedStringArray(["idle_down"])
		or frames.get_frame_count(&"idle_down") != FRAME_COUNT
		or not frames.get_animation_loop(&"idle_down")
		or not is_equal_approx(frames.get_animation_speed(&"idle_down"), 3.0)
	):
		_fail("King idle-down SpriteFrames does not expose the single approved loop.")
		return
	for frame_index in FRAME_COUNT:
		var atlas := frames.get_frame_texture(&"idle_down", frame_index) as AtlasTexture
		if atlas == null or atlas.region != Rect2(frame_index * 64, 0, 64, 64):
			_fail("King idle-down frame %d uses the wrong atlas region." % frame_index)
			return

	var preview_scene := load(PREVIEW_PATH) as PackedScene
	var preview := preview_scene.instantiate() if preview_scene != null else null
	if preview == null:
		_fail("King idle-down preview scene did not instantiate.")
		return
	root.add_child(preview)
	var body := preview.get_node_or_null("Body") as AnimatedSprite2D
	if (
		body == null
		or body.sprite_frames != frames
		or body.animation != &"idle_down"
		or body.position != Vector2(0, -26)
		or body.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST
	):
		preview.queue_free()
		_fail("King idle-down preview lost its animation, filter, or foot anchor.")
		return
	preview.queue_free()

	print("KING_IDLE_DOWN_ASSET_SMOKE_OK")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
