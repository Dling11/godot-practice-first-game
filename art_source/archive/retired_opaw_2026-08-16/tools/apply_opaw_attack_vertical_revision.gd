extends SceneTree

## Replaces only Opaw's down/up attack source rows. The approved left/right
## source rows remain byte-for-byte unchanged inside the composed board.

const ATTACK_SOURCE_PATH := "res://art_source/generated/characters/playable/opaw/compact_armless/opaw_compact_armless_attack_body_source.png"
const VERTICAL_REVISION_PATH := "res://art_source/generated/characters/playable/opaw/compact_armless/opaw_compact_armless_attack_vertical_revision.png"
const DIRECTION_ROWS := 4
const REVISED_ROWS := [0, 3]


func _initialize() -> void:
	var attack_source := Image.load_from_file(ATTACK_SOURCE_PATH)
	var revision := Image.load_from_file(VERTICAL_REVISION_PATH)
	if attack_source == null or attack_source.is_empty():
		push_error("Unable to load Opaw's composed attack source.")
		quit(1)
		return
	if revision == null or revision.is_empty() or revision.get_size() != attack_source.get_size():
		push_error("Opaw's vertical attack revision must match the composed source dimensions.")
		quit(1)
		return
	for row: int in REVISED_ROWS:
		var top := roundi(float(row) * attack_source.get_height() / DIRECTION_ROWS)
		var bottom := roundi(float(row + 1) * attack_source.get_height() / DIRECTION_ROWS)
		var row_rect := Rect2i(0, top, attack_source.get_width(), bottom - top)
		attack_source.blit_rect(revision, row_rect, row_rect.position)
	var save_error := attack_source.save_png(ATTACK_SOURCE_PATH)
	if save_error != OK:
		push_error("Unable to save Opaw's composed attack source: %s" % error_string(save_error))
		quit(1)
		return
	print("Applied Opaw's down/up attack revision while preserving left/right rows.")
	quit(0)
