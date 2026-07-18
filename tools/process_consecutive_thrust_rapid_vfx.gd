extends SceneTree

## Packs the reviewed 6x2 rapid-flurry source into twelve consistent 192 px
## gameplay cells. The generated source contains effects only; Opaw's body and
## weapon stay in their normal presentation ownership.

const SOURCE_PATH := (
	"res://art_source/generated/skills/opaw/consecutive_thrust/rapid_v3/"
	+ "opaw_consecutive_thrust_rapid_vfx_clean_v3.png"
)
const OUTPUT_PATH := (
	"res://assets/skills/opaw/warrior/consecutive_thrust/"
	+ "opaw_consecutive_thrust_rapid_vfx_sheet_192x192.png"
)
const SOURCE_INSET := 8
const FRAME_SIZE := Vector2i(192, 192)
const FRAME_COLUMNS := 6
const FRAME_ROWS := 2
const SOURCE_SCALE := 0.40


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		return _fail("Unable to load rapid Consecutive Thrust VFX source: %s" % SOURCE_PATH)
	var output := Image.create_empty(
		FRAME_COLUMNS * FRAME_SIZE.x,
		FRAME_ROWS * FRAME_SIZE.y,
		false,
		Image.FORMAT_RGBA8
	)
	output.fill(Color.TRANSPARENT)
	for frame_index in range(FRAME_COLUMNS * FRAME_ROWS):
		var column := frame_index % FRAME_COLUMNS
		var row := frame_index / FRAME_COLUMNS
		var left := roundi(float(column) * source.get_width() / float(FRAME_COLUMNS))
		var right := roundi(float(column + 1) * source.get_width() / float(FRAME_COLUMNS))
		var top := roundi(float(row) * source.get_height() / float(FRAME_ROWS))
		var bottom := roundi(float(row + 1) * source.get_height() / float(FRAME_ROWS))
		var capture := source.get_region(Rect2i(
			Vector2i(left + SOURCE_INSET, top + SOURCE_INSET),
			Vector2i(right - left, bottom - top) - Vector2i.ONE * SOURCE_INSET * 2
		))
		_harden_alpha(capture)
		var used := capture.get_used_rect()
		if used.size.x <= 0 or used.size.y <= 0:
			return _fail("Rapid Consecutive Thrust VFX frame %d is empty." % frame_index)
		var frame := capture.get_region(used)
		frame.resize(
			maxi(1, roundi(frame.get_width() * SOURCE_SCALE)),
			maxi(1, roundi(frame.get_height() * SOURCE_SCALE)),
			Image.INTERPOLATE_NEAREST
		)
		if frame.get_width() > FRAME_SIZE.x - 12 or frame.get_height() > FRAME_SIZE.y - 12:
			return _fail("Rapid Consecutive Thrust VFX frame %d exceeds its runtime cell." % frame_index)
		var destination := Vector2i(
			column * FRAME_SIZE.x + 6,
			row * FRAME_SIZE.y + roundi((FRAME_SIZE.y - frame.get_height()) * 0.5)
		)
		output.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), destination)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var save_error := output.save_png(OUTPUT_PATH)
	if save_error != OK:
		return _fail("Unable to save rapid Consecutive Thrust atlas: %s" % error_string(save_error))
	print("Processed rapid Consecutive Thrust VFX atlas: %s" % OUTPUT_PATH)
	quit(0)


func _harden_alpha(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			## Zero RGB together with low alpha so transparent source residue cannot
			## turn into a dark rectangle after Godot imports the PNG.
			if pixel.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
			else:
				pixel.a = 1.0
				image.set_pixel(x, y, pixel)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
