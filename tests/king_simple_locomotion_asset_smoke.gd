extends SceneTree

const SHEET_PATH := "res://assets/characters/playable/king/simple_reboot/king_simple_locomotion_sheet_48x32.png"
const ATTACK_SHEET_PATH := "res://assets/characters/playable/king/simple_reboot/king_simple_basic_slash_sheet_64x32.png"
const RIFTBREAK_SHEET_PATH := "res://assets/characters/playable/king/simple_reboot/king_riftbreak_body_sheet_64x32.png"
const PURSUIT_SHEET_PATH := "res://assets/characters/playable/king/simple_reboot/king_sovereign_pursuit_body_sheet_64x32.png"
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
	var attack_texture := load(ATTACK_SHEET_PATH) as Texture2D
	var attack_image := attack_texture.get_image() if attack_texture != null else null
	if attack_image == null or attack_image.get_size() != Vector2i(384, 128):
		_fail("King's basic slash sheet is not an exact 6x4 atlas of 64x32 cells.")
		return
	for y in range(attack_image.get_height()):
		for x in range(attack_image.get_width()):
			var alpha := attack_image.get_pixel(x, y).a
			if alpha != 0.0 and alpha != 1.0:
				_fail("King's basic slash sheet contains non-binary alpha at %s,%s." % [x, y])
				return
	for row in range(4):
		for column in range(6):
			var cell := attack_image.get_region(Rect2i(column * 64, row * 32, 64, 32))
			var used_rect := cell.get_used_rect()
			if used_rect.end.y != 30 or used_rect.size.y < 23 or used_rect.size.y > 25:
				_fail("King attack frame %d:%d drifted from the calibrated body scale/baseline: %s." % [row, column, used_rect])
				return
	var exact_attack_image := Image.load_from_file(ProjectSettings.globalize_path(ATTACK_SHEET_PATH))
	for column in range(6):
		var left_frame := exact_attack_image.get_region(Rect2i(column * 64, 32, 64, 32))
		var right_frame := exact_attack_image.get_region(Rect2i(column * 64, 64, 64, 32))
		if not _images_are_horizontal_mirrors(left_frame, right_frame):
			_fail("King's side attack frame %d is not an exact mirror." % column)
			return
	var riftbreak_texture := load(RIFTBREAK_SHEET_PATH) as Texture2D
	var riftbreak_image := riftbreak_texture.get_image() if riftbreak_texture != null else null
	if riftbreak_image == null or riftbreak_image.get_size() != Vector2i(384, 128):
		_fail("King's Riftbreak body sheet is not an exact 6x4 atlas of 64x32 cells.")
		return
	for row in range(4):
		for column in range(6):
			var cell := riftbreak_image.get_region(Rect2i(column * 64, row * 32, 64, 32))
			var used_rect := cell.get_used_rect()
			if used_rect.end.y != 30 or used_rect.size.y < 22 or used_rect.size.y > 30:
				_fail("King Riftbreak frame %d:%d drifted from its fixed baseline/scale: %s." % [row, column, used_rect])
				return
			for y in range(cell.get_height()):
				for x in range(cell.get_width()):
					var alpha := cell.get_pixel(x, y).a
					if alpha != 0.0 and alpha != 1.0:
						_fail("King Riftbreak frame %d:%d contains non-binary alpha." % [row, column])
						return
		for endpoint_column in [0, 5]:
			var endpoint := riftbreak_image.get_region(Rect2i(endpoint_column * 64 + 8, row * 32, 48, 32))
			var idle := image.get_region(Rect2i(0, row * 32, 48, 32))
			if not _images_are_equal(endpoint, idle):
				_fail("Riftbreak %s endpoint does not exactly match King's idle pixels." % DIRECTIONS[row])
				return

	var frames := load(FRAMES_PATH) as SpriteFrames
	if frames == null:
		_fail("King's simple SpriteFrames resource did not load.")
		return
	for direction in DIRECTIONS:
		var idle_name := StringName("idle_%s" % direction)
		var walk_name := StringName("walk_%s" % direction)
		var attack_name := StringName("attack_%s" % direction)
		var riftbreak_name := StringName("riftbreak_%s" % direction)
		var pursuit_name := StringName("sovereign_pursuit_%s" % direction)
		if not frames.has_animation(idle_name) or frames.get_frame_count(idle_name) != 1:
			_fail("King is missing exact one-frame %s." % idle_name)
			return
		if not frames.has_animation(walk_name) or frames.get_frame_count(walk_name) != 4:
			_fail("King is missing exact four-frame %s." % walk_name)
			return
		if not is_equal_approx(frames.get_animation_speed(walk_name), 8.0):
			_fail("King's %s playback speed drifted from 8 FPS." % walk_name)
			return
		if not frames.has_animation(attack_name) or frames.get_frame_count(attack_name) != 6:
			_fail("King is missing exact six-frame %s." % attack_name)
			return
		if not frames.has_animation(riftbreak_name) or frames.get_frame_count(riftbreak_name) != 6:
			_fail("King is missing exact six-frame %s." % riftbreak_name)
			return
		if not frames.has_animation(pursuit_name) or frames.get_frame_count(pursuit_name) != 6:
			_fail("King is missing exact six-frame %s." % pursuit_name)
			return
		for fallback_prefix in [&"dash", &"interact", &"hurt", &"defeat"]:
			if not frames.has_animation(StringName("%s_%s" % [fallback_prefix, direction])):
				_fail("King is missing safe %s presentation for %s." % [fallback_prefix, direction])
				return

	var preview_scene := load(PREVIEW_PATH) as PackedScene
	var preview := preview_scene.instantiate() if preview_scene != null else null
	if preview == null:
		_fail("King's isolated locomotion preview did not instantiate.")
		return
	root.add_child(preview)
	await process_frame
	var preview_sprites := preview.find_children("*", "AnimatedSprite2D", true, false)
	if preview_sprites.size() != 1:
		_fail("King preview must contain exactly one AnimatedSprite2D body, found %d." % preview_sprites.size())
		return
	var sprite := preview_sprites[0] as AnimatedSprite2D
	if not sprite.is_playing():
		_fail("King's single preview body is not animating.")
		return
	preview.queue_free()
	print("King simple locomotion asset smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)


func _images_are_horizontal_mirrors(first: Image, second: Image) -> bool:
	if first.get_size() != second.get_size():
		return false
	for y in range(first.get_height()):
		for x in range(first.get_width()):
			if first.get_pixel(x, y) != second.get_pixel(second.get_width() - 1 - x, y):
				return false
	return true


func _images_are_equal(first: Image, second: Image) -> bool:
	if first.get_size() != second.get_size():
		return false
	for y in range(first.get_height()):
		for x in range(first.get_width()):
			if first.get_pixel(x, y) != second.get_pixel(x, y):
				return false
	return true
