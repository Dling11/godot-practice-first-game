extends SceneTree

## Builds a new four-pose Consecutive Thrust body sheet only from the approved
## compact-armless Opaw sheet. This deliberately prevents a generated model
## draft from changing Opaw's established silhouette.

const SOURCE_PATH := (
	"res://assets/characters/playable/opaw/compact_armless/"
	+ "opaw_compact_armless_attack_body_sheet_48x32.png"
)
const OUTPUT_PATH := (
	"res://assets/characters/playable/opaw/compact_armless/"
	+ "opaw_consecutive_thrust_body_sheet_48x32.png"
)
const CELL_SIZE := Vector2i(48, 32)
const SOURCE_COLUMNS := 3
const OUTPUT_COLUMNS := 4
const DIRECTION_ROWS := 4
const SOURCE_COLUMNS_BY_POSE := [0, 1, 1, 2]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE_PATH)
	if source == null or source.is_empty():
		push_error("Unable to load approved Opaw action sheet: %s" % SOURCE_PATH)
		quit(1)
		return
	if source.get_size() != Vector2i(SOURCE_COLUMNS * CELL_SIZE.x, DIRECTION_ROWS * CELL_SIZE.y):
		push_error("Approved Opaw action sheet has an unexpected grid contract.")
		quit(1)
		return

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
			var source_rect := Rect2i(
				Vector2i(source_column * CELL_SIZE.x, row * CELL_SIZE.y),
				CELL_SIZE
			)
			var destination := Vector2i(output_column * CELL_SIZE.x, row * CELL_SIZE.y)
			output.blit_rect(source, source_rect, destination)

	var save_error := output.save_png(OUTPUT_PATH)
	if save_error != OK:
		push_error("Unable to save Consecutive Thrust body sheet: %s" % error_string(save_error))
		quit(1)
		return
	print("Built Opaw Consecutive Thrust body sheet: %s" % OUTPUT_PATH)
	quit(0)
