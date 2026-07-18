extends SceneTree

## Converts the generated effect-only 4x2 board into a clean 192 px runtime
## atlas. The crop excludes generator divider lines and removes residual green
## fringe before binary-alpha pixel-art import.

const SOURCE_PATH := (
	"res://art_source/generated/skills/opaw/consecutive_thrust/"
	+ "opaw_consecutive_thrust_vfx_clean_v2.png"
)
const OUTPUT_PATH := (
	"res://assets/skills/opaw/warrior/consecutive_thrust/"
	+ "opaw_consecutive_thrust_vfx_sheet_192x192.png"
)
const SOURCE_INSET := 8
const FRAME_SIZE := Vector2i(192, 192)
const FRAME_COLUMNS := 4
const SOURCE_SCALE := 0.38


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		return _fail("Unable to load Consecutive Thrust VFX source: %s" % SOURCE_PATH)
	var output := Image.create_empty(
		FRAME_COLUMNS * FRAME_SIZE.x,
		2 * FRAME_SIZE.y,
		false,
		Image.FORMAT_RGBA8
	)
	output.fill(Color.TRANSPARENT)
	for frame_index in range(8):
		var column := frame_index % FRAME_COLUMNS
		var row := frame_index / FRAME_COLUMNS
		var left := roundi(float(column) * source.get_width() / float(FRAME_COLUMNS))
		var right := roundi(float(column + 1) * source.get_width() / float(FRAME_COLUMNS))
		var top := roundi(float(row) * source.get_height() / 2.0)
		var bottom := roundi(float(row + 1) * source.get_height() / 2.0)
		var source_origin := Vector2i(left + SOURCE_INSET, top + SOURCE_INSET)
		var capture := source.get_region(Rect2i(
			source_origin,
			Vector2i(right - left, bottom - top) - Vector2i.ONE * SOURCE_INSET * 2
		))
		_remove_green_fringe(capture)
		var used := capture.get_used_rect()
		if used.size.x <= 0 or used.size.y <= 0:
			return _fail("Consecutive Thrust VFX frame %d is empty." % frame_index)
		var frame := capture.get_region(used)
		frame.resize(
			maxi(1, roundi(frame.get_width() * SOURCE_SCALE)),
			maxi(1, roundi(frame.get_height() * SOURCE_SCALE)),
			Image.INTERPOLATE_NEAREST
		)
		_harden_alpha(frame)
		if frame.get_width() > FRAME_SIZE.x - 12 or frame.get_height() > FRAME_SIZE.y - 12:
			return _fail("Consecutive Thrust VFX frame %d exceeds its runtime cell." % frame_index)
		var destination := Vector2i(
			(frame_index % FRAME_COLUMNS) * FRAME_SIZE.x + 6,
			(frame_index / FRAME_COLUMNS) * FRAME_SIZE.y
				+ roundi((FRAME_SIZE.y - frame.get_height()) * 0.5)
		)
		output.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), destination)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var save_error := output.save_png(OUTPUT_PATH)
	if save_error != OK:
		return _fail("Unable to save Consecutive Thrust atlas: %s" % error_string(save_error))
	print("Processed Consecutive Thrust VFX atlas: %s" % OUTPUT_PATH)
	quit(0)


func _remove_green_fringe(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			var brightest := maxf(pixel.r, maxf(pixel.g, pixel.b))
			var green_screen := (
				pixel.g > 0.25
				and pixel.g > pixel.r * 1.005
				and pixel.b < pixel.g * 0.75
			)
			# The generator's dark charcoal field is not fully black after scaling.
			# Preserve only bright magic pixels; dim residue reads as dirty rectangles
			# at the 960x540 gameplay scale.
			var near_black_background := brightest < 0.58
			if green_screen or near_black_background:
				pixel.a = 0.0
				image.set_pixel(x, y, pixel)


func _harden_alpha(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			pixel.a = 1.0 if pixel.a >= 0.35 else 0.0
			image.set_pixel(x, y, pixel)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
