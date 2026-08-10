extends SceneTree

const SHEET_PATH := "res://assets/characters/playable/king/king_idle_sheet_64x64.png"
const BODY_SHEET_PATH := "res://assets/characters/playable/king/king_idle_body_sheet_64x64.png"
const SWORD_SHEET_PATH := "res://assets/characters/playable/king/king_idle_sword_sheet_64x64.png"
const FRAMES_PATH := "res://assets/characters/playable/king/king_idle_sprite_frames.tres"
const PREVIEW_PATH := "res://entities/player/king/king_idle_preview.tscn"
const METRICS_PATH := "res://art_source/review/characters/playable/king/king_idle_metrics.json"
const SHEET_SIZE := Vector2i(256, 256)
const CELL_SIZE := Vector2i(64, 64)
const COLUMNS := 4
const DIRECTIONS := [&"down", &"left", &"right", &"up"]
const FOOT_PIXEL_Y := 57
const OPAQUE_COLOR_LIMIT := 20


func _initialize() -> void:
	var texture := load(SHEET_PATH) as Texture2D
	var image := texture.get_image() if texture != null else null
	if image == null or image.get_size() != SHEET_SIZE:
		_fail("King idle runtime sheet is missing or not 256x256.")
		return

	var opaque_colors := {}
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a != 0.0 and color.a != 1.0:
				_fail("King idle sheet contains non-binary alpha at %s,%s." % [x, y])
				return
			if color.a == 0.0:
				continue
			if _looks_like_matte(color):
				_fail("King idle sheet contains magenta/lime matte residue at %s,%s." % [x, y])
				return
			opaque_colors[Color8(color.r8, color.g8, color.b8, 255).to_html(false)] = true
	if opaque_colors.size() > OPAQUE_COLOR_LIMIT:
		_fail("King idle sheet exceeds the %s-color runtime palette (%s)." % [OPAQUE_COLOR_LIMIT, opaque_colors.size()])
		return

	for row in DIRECTIONS.size():
		var frame_signatures := {}
		for column in COLUMNS:
			var cell_rect := Rect2i(column * CELL_SIZE.x, row * CELL_SIZE.y, CELL_SIZE.x, CELL_SIZE.y)
			var cell := image.get_region(cell_rect)
			var used := cell.get_used_rect()
			if used.size == Vector2i.ZERO:
				_fail("King idle %s frame %s is empty." % [DIRECTIONS[row], column])
				return
			if used.end.y - 1 != FOOT_PIXEL_Y:
				_fail("King idle %s frame %s misses the shared foot baseline." % [DIRECTIONS[row], column])
				return
			if used.position.x < 2 or used.end.x > CELL_SIZE.x - 2 or used.position.y < 2:
				_fail("King idle %s frame %s crosses its safe cell margin." % [DIRECTIONS[row], column])
				return
			frame_signatures[hash(cell.save_png_to_buffer())] = true
		if frame_signatures.size() < 3:
			_fail("King idle %s row uses duplicate filler instead of an authored idle cycle." % DIRECTIONS[row])
			return

	if not _right_row_is_exact_mirror(image):
		_fail("King idle right row is not an exact mirror of the left row.")
		return
	if not _validate_layered_sword_contract():
		return

	var frames := load(FRAMES_PATH) as SpriteFrames
	if frames == null:
		_fail("King idle SpriteFrames resource is missing.")
		return
	for row in DIRECTIONS.size():
		var animation_name := StringName("idle_" + String(DIRECTIONS[row]))
		if (
			not frames.has_animation(animation_name)
			or not frames.get_animation_loop(animation_name)
			or frames.get_frame_count(animation_name) != COLUMNS
			or not is_equal_approx(frames.get_animation_speed(animation_name), 3.0)
		):
			_fail("King SpriteFrames animation is incomplete: %s" % animation_name)
			return
		for column in COLUMNS:
			var atlas := frames.get_frame_texture(animation_name, column) as AtlasTexture
			var expected := Rect2i(column * CELL_SIZE.x, row * CELL_SIZE.y, CELL_SIZE.x, CELL_SIZE.y)
			if atlas == null or Rect2i(atlas.region) != expected:
				_fail("King SpriteFrames atlas region is incorrect: %s frame %s." % [animation_name, column])
				return

	var preview := load(PREVIEW_PATH) as PackedScene
	var preview_instance := preview.instantiate() if preview != null else null
	var body := preview_instance.get_node_or_null("Body") as AnimatedSprite2D if preview_instance != null else null
	if body == null or body.sprite_frames != frames or body.position != Vector2(0.0, -26.0):
		_fail("King AnimatedSprite2D preview is missing or not foot-anchored.")
		return
	preview_instance.free()

	print("King idle asset smoke test passed.")
	quit(0)


func _right_row_is_exact_mirror(image: Image) -> bool:
	var left_y := CELL_SIZE.y
	var right_y := CELL_SIZE.y * 2
	for frame in COLUMNS:
		var frame_x := frame * CELL_SIZE.x
		for y in CELL_SIZE.y:
			for x in CELL_SIZE.x:
				var left := image.get_pixel(frame_x + x, left_y + y)
				var right := image.get_pixel(frame_x + CELL_SIZE.x - 1 - x, right_y + y)
				# Godot's alpha-border import may write RGB values into fully
				# transparent pixels. Those remain visually identical.
				if left.a == 0.0 and right.a == 0.0:
					continue
				if left != right:
					return false
	return true


func _validate_layered_sword_contract() -> bool:
	var body_texture := load(BODY_SHEET_PATH) as Texture2D
	var sword_texture := load(SWORD_SHEET_PATH) as Texture2D
	var body_image := body_texture.get_image() if body_texture != null else null
	var sword_image := sword_texture.get_image() if sword_texture != null else null
	if (
		body_image == null
		or sword_image == null
		or body_image.get_size() != SHEET_SIZE
		or sword_image.get_size() != SHEET_SIZE
	):
		_fail("King idle body/sword layer sheets are missing or incorrectly sized.")
		return false

	var metrics_file := FileAccess.open(METRICS_PATH, FileAccess.READ)
	var metrics: Variant = JSON.parse_string(metrics_file.get_as_text()) if metrics_file != null else null
	if not metrics is Dictionary or metrics.get("sword_construction", "") != "single deterministic 45-degree tip-to-pommel axis":
		_fail("King idle sword construction metadata is missing.")
		return false
	var sword_frames: Array = metrics.get("sword_frames", [])
	if sword_frames.size() != DIRECTIONS.size() * COLUMNS:
		_fail("King idle sword metrics do not cover all sixteen frames.")
		return false

	for entry: Dictionary in sword_frames:
		var direction_index := DIRECTIONS.find(StringName(entry.direction))
		var column: int = entry.column
		if direction_index < 0 or column < 0 or column >= COLUMNS:
			_fail("King idle sword metrics contain an invalid frame address.")
			return false
		var guard := Vector2i(entry.guard[0], entry.guard[1])
		var tip := Vector2i(entry.blade_tip[0], entry.blade_tip[1])
		var hand := Vector2i(entry.hand[0], entry.hand[1])
		var pommel := Vector2i(entry.pommel[0], entry.pommel[1])
		var axis := Vector2i(entry.axis[0], entry.axis[1])
		if (
			_cross(tip - guard, axis) != 0
			or _cross(hand - guard, axis) != 0
			or _cross(pommel - guard, axis) != 0
			or _dot(tip - guard, axis) <= 0
			or _dot(hand - guard, axis) >= 0
			or _dot(pommel - guard, axis) >= _dot(hand - guard, axis)
		):
			_fail("King idle sword is not one ordered tip/guard/hand/pommel axis: %s." % entry)
			return false
		var cell_origin := Vector2i(column * CELL_SIZE.x, direction_index * CELL_SIZE.y)
		for step in range(-7, 17):
			var point := cell_origin + guard + axis * step
			if sword_image.get_pixelv(point).a != 1.0:
				_fail("King idle sword axis has a gap at %s (%s frame %s)." % [point, entry.direction, column])
				return false
	return true


func _cross(left: Vector2i, right: Vector2i) -> int:
	return left.x * right.y - left.y * right.x


func _dot(left: Vector2i, right: Vector2i) -> int:
	return left.x * right.x + left.y * right.y


func _looks_like_matte(color: Color) -> bool:
	var magenta := color.r8 > 170 and color.b8 > 150 and color.g8 < 115
	var lime := color.g8 > 170 and color.r8 < 155 and color.b8 < 155
	return magenta or lime


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
