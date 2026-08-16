extends SceneTree

## Normalizes the generated 3x2 Piercing Rush concept sheet into a deterministic
## six-frame runtime atlas. The deliberately large 192 px cells allow the peak
## frame to extend far beyond Opaw without changing the authoritative hitbox.

const SOURCE_PATH := (
	"res://art_source/generated/skills/opaw/piercing_rush/"
	+ "opaw_piercing_rush_vfx_clean_v1.png"
)
const OUTPUT_PATH := (
	"res://assets/skills/opaw/warrior/piercing_rush/"
	+ "opaw_piercing_rush_vfx_sheet_192x192.png"
)
const FRAME_SIZE := Vector2i(192, 192)
const OUTPUT_COLUMNS := 3
const SOURCE_SCALE := 0.25

# The generated peak frame intentionally crosses the ideal 512 px grid line.
# These non-overlapping capture zones preserve it without pulling pixels from
# the neighboring ring-impact frame.
const SOURCE_ZONES := [
	Rect2i(0, 0, 420, 512),
	Rect2i(420, 0, 500, 512),
	Rect2i(920, 0, 616, 512),
	Rect2i(0, 512, 704, 512),
	Rect2i(704, 512, 396, 512),
	Rect2i(1100, 512, 436, 512),
]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		push_error("Unable to load Piercing Rush clean source: %s" % SOURCE_PATH)
		quit(1)
		return

	var output := Image.create_empty(
		OUTPUT_COLUMNS * FRAME_SIZE.x,
		2 * FRAME_SIZE.y,
		false,
		Image.FORMAT_RGBA8
	)
	output.fill(Color.TRANSPARENT)

	for frame_index in SOURCE_ZONES.size():
		var zone: Rect2i = SOURCE_ZONES[frame_index]
		var capture := source.get_region(zone)
		var used := capture.get_used_rect()
		if used.size.x <= 0 or used.size.y <= 0:
			push_error("Piercing Rush source frame %s is empty." % frame_index)
			quit(1)
			return
		var frame := capture.get_region(used)
		frame.resize(
			maxi(1, roundi(frame.get_width() * SOURCE_SCALE)),
			maxi(1, roundi(frame.get_height() * SOURCE_SCALE)),
			Image.INTERPOLATE_NEAREST
		)
		_harden_alpha(frame)
		if frame.get_width() > FRAME_SIZE.x - 12 or frame.get_height() > FRAME_SIZE.y - 12:
			push_error(
				"Piercing Rush frame %s exceeds its runtime cell: %s"
				% [frame_index, frame.get_size()]
			)
			quit(1)
			return

		var cell_origin := Vector2i(
			(frame_index % OUTPUT_COLUMNS) * FRAME_SIZE.x,
			(frame_index / OUTPUT_COLUMNS) * FRAME_SIZE.y
		)
		# Align every effect's left edge to the weapon origin and vertically
		# center it so rotating AbilityPivot keeps all four directions stable.
		var destination := cell_origin + Vector2i(
			6,
			roundi((FRAME_SIZE.y - frame.get_height()) * 0.5)
		)
		output.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), destination)

	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir())
	)
	var save_error := output.save_png(OUTPUT_PATH)
	if save_error != OK:
		push_error("Unable to save Piercing Rush atlas: %s" % error_string(save_error))
		quit(1)
		return
	print("Processed Piercing Rush VFX atlas: %s" % OUTPUT_PATH)
	quit(0)


func _harden_alpha(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			pixel.a = 1.0 if pixel.a >= 0.35 else 0.0
			image.set_pixel(x, y, pixel)
