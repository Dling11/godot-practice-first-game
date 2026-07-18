extends SceneTree

## Builds the rapid-flurry body sheet from Opaw's approved compact-armless
## frames only. Small per-frame pixel offsets create rhythm without introducing
## a generated replacement character, arms, or hands.

const SOURCE_PATH := (
	"res://assets/characters/playable/opaw/compact_armless/"
	+ "opaw_compact_armless_attack_body_sheet_48x32.png"
)
const OUTPUT_PATH := (
	"res://assets/characters/playable/opaw/compact_armless/"
	+ "opaw_consecutive_thrust_rapid_body_sheet_48x32.png"
)
const CELL_SIZE := Vector2i(48, 32)
const SOURCE_COLUMNS := 3
const OUTPUT_COLUMNS := 8
const DIRECTION_ROWS := 4
const SOURCE_COLUMNS_BY_POSE := [0, 0, 1, 1, 1, 1, 2, 2]
const FRAME_OFFSETS := [
	Vector2i.ZERO,
	Vector2i(-1, 0),
	Vector2i(1, 0),
	Vector2i(0, -1),
	Vector2i(1, -1),
	Vector2i(-1, 0),
	Vector2i(2, 0),
	Vector2i.ZERO,
]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		return _fail("Unable to load approved Opaw action sheet: %s" % SOURCE_PATH)
	if source.get_size() != Vector2i(SOURCE_COLUMNS * CELL_SIZE.x, DIRECTION_ROWS * CELL_SIZE.y):
		return _fail("Approved Opaw action sheet has an unexpected grid contract.")

	var output := Image.create_empty(
		OUTPUT_COLUMNS * CELL_SIZE.x,
		DIRECTION_ROWS * CELL_SIZE.y,
		false,
		Image.FORMAT_RGBA8
	)
	output.fill(Color.TRANSPARENT)
	for row in DIRECTION_ROWS:
		for output_column in OUTPUT_COLUMNS:
			var source_column: int = SOURCE_COLUMNS_BY_POSE[output_column]
			var source_cell := source.get_region(Rect2i(
				Vector2i(source_column * CELL_SIZE.x, row * CELL_SIZE.y),
				CELL_SIZE
			))
			var frame := Image.create_empty(CELL_SIZE.x, CELL_SIZE.y, false, Image.FORMAT_RGBA8)
			frame.fill(Color.TRANSPARENT)
			frame.blit_rect(
				source_cell,
				Rect2i(Vector2i.ZERO, CELL_SIZE),
				FRAME_OFFSETS[output_column]
			)
			output.blit_rect(
				frame,
				Rect2i(Vector2i.ZERO, CELL_SIZE),
				Vector2i(output_column * CELL_SIZE.x, row * CELL_SIZE.y)
			)

	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var save_error := output.save_png(OUTPUT_PATH)
	if save_error != OK:
		return _fail("Unable to save rapid Consecutive Thrust body sheet: %s" % error_string(save_error))
	print("Built rapid Opaw Consecutive Thrust body sheet: %s" % OUTPUT_PATH)
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
