extends SceneTree

const BODY_FRAMES := "res://assets/characters/playable/king/king_core_sprite_frames.tres"
const VFX_FRAMES := "res://assets/characters/playable/king/king_attack_vfx_sprite_frames.tres"
const PREVIEW := "res://entities/player/king/king_core_animation_preview.tscn"
const DIRECTIONS := [&"down", &"left", &"right", &"up"]
const ATTACK_COUNTS := {
	"opening_cut": 8,
	"reversal_cut": 8,
	"horizon_break": 10,
	"falling_divide": 12,
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var body := load(BODY_FRAMES) as SpriteFrames
	var vfx := load(VFX_FRAMES) as SpriteFrames
	if body == null or vfx == null:
		_fail("King core body or VFX SpriteFrames did not load.")
		return

	for direction in DIRECTIONS:
		for state in [&"idle", &"walk"]:
			var animation := StringName("%s_%s" % [state, direction])
			if not body.has_animation(animation) or body.get_frame_count(animation) != 4:
				_fail("King locomotion animation %s is incomplete." % animation)
				return
			if not body.get_animation_loop(animation):
				_fail("King locomotion animation %s must loop." % animation)
				return

	for attack_name: String in ATTACK_COUNTS:
		for direction in [&"left", &"right"]:
			var animation := StringName("%s_%s" % [attack_name, direction])
			var expected: int = ATTACK_COUNTS[attack_name]
			if (
				not body.has_animation(animation)
				or body.get_frame_count(animation) != expected
				or body.get_animation_loop(animation)
			):
				_fail("King body attack %s has the wrong count or loop mode." % animation)
				return
			if (
				not vfx.has_animation(animation)
				or vfx.get_frame_count(animation) != expected
				or vfx.get_animation_loop(animation)
			):
				_fail("King VFX attack %s has the wrong count or loop mode." % animation)
				return

	if not _validate_direction_mirror(
		"res://assets/characters/playable/king/idle/king_idle_sheet_64x64.png", 64, 4
	):
		return
	if not _validate_direction_mirror(
		"res://assets/characters/playable/king/walk/king_walk_sheet_64x64.png", 64, 4
	):
		return
	for attack_name: String in ATTACK_COUNTS:
		var height := 128 if attack_name == "falling_divide" else 96
		var size_label := "128x%d" % height
		if not _validate_pair_mirror(
			"res://assets/characters/playable/king/attacks/%s/king_%s_left_sheet_%s.png" % [attack_name, attack_name, size_label],
			"res://assets/characters/playable/king/attacks/%s/king_%s_right_sheet_%s.png" % [attack_name, attack_name, size_label]
		):
			return

	var preview_scene := load(PREVIEW) as PackedScene
	var preview := preview_scene.instantiate() if preview_scene != null else null
	if preview == null:
		_fail("King core animation preview did not instantiate.")
		return
	root.add_child(preview)
	var preview_body := preview.get_node_or_null("Body") as AnimatedSprite2D
	var preview_vfx := preview.get_node_or_null("AttackVFX") as AnimatedSprite2D
	if (
		preview_body == null
		or preview_body.animation != &"idle_down"
		or preview_body.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST
		or preview_vfx == null
		or preview_vfx.texture_filter != CanvasItem.TEXTURE_FILTER_NEAREST
	):
		preview.queue_free()
		_fail("King preview lost its body, VFX layer, or nearest-neighbor filter.")
		return
	preview.queue_free()
	print("KING_CORE_ANIMATION_ASSET_SMOKE_OK")
	quit(0)


func _validate_direction_mirror(path: String, cell_size: int, frame_count: int) -> bool:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.get_size() != Vector2i(cell_size * frame_count, cell_size * 4):
		_fail("King direction sheet has invalid dimensions: %s." % path)
		return false
	for frame_index in frame_count:
		var left := image.get_region(Rect2i(frame_index * cell_size, cell_size, cell_size, cell_size))
		var right := image.get_region(Rect2i(frame_index * cell_size, cell_size * 2, cell_size, cell_size))
		left.flip_x()
		if left.get_data() != right.get_data():
			_fail("King right-facing frame is not an exact mirror in %s frame %d." % [path, frame_index])
			return false
	return true


func _validate_pair_mirror(left_path: String, right_path: String) -> bool:
	var left := Image.load_from_file(ProjectSettings.globalize_path(left_path))
	var right := Image.load_from_file(ProjectSettings.globalize_path(right_path))
	if left == null or right == null or left.get_size() != right.get_size():
		_fail("King attack mirror pair failed to load: %s / %s." % [left_path, right_path])
		return false
	var frame_width := 128
	var frame_count := left.get_width() / frame_width
	for frame_index in frame_count:
		var left_frame := left.get_region(Rect2i(frame_index * frame_width, 0, frame_width, left.get_height()))
		var right_frame := right.get_region(Rect2i(frame_index * frame_width, 0, frame_width, right.get_height()))
		left_frame.flip_x()
		if left_frame.get_data() != right_frame.get_data():
			_fail("King attack mirror mismatch at %s frame %d." % [left_path, frame_index])
			return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
