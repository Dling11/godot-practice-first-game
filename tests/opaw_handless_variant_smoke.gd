extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HandlessFrames = preload("res://assets/characters/playable/opaw/variants/handless/opaw_handless_sprite_frames.tres")

const SHEETS := [
	["opaw_compact_armless_idle_sheet_32x32.png", "opaw_handless_idle_sheet_32x32.png"],
	["opaw_compact_armless_walk_sheet_32x32.png", "opaw_handless_walk_sheet_32x32.png"],
	["opaw_compact_armless_attack_body_sheet_48x32.png", "opaw_handless_attack_body_sheet_48x32.png"],
	["opaw_compact_armless_dash_sheet_48x32.png", "opaw_handless_dash_sheet_48x32.png"],
	["opaw_compact_armless_interact_sheet_48x32.png", "opaw_handless_interact_sheet_48x32.png"],
	["opaw_compact_armless_hurt_sheet_32x32.png", "opaw_handless_hurt_sheet_32x32.png"],
	["opaw_compact_armless_defeat_sheet_64x32.png", "opaw_handless_defeat_sheet_64x32.png"],
]


func _initialize() -> void:
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	await process_frame
	var active_body := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	if active_body.sprite_frames == HandlessFrames:
		_fail("The review-only handless variant replaced the approved active Opaw frames.")
		return
	for animation_name: StringName in active_body.sprite_frames.get_animation_names():
		if not HandlessFrames.has_animation(animation_name):
			_fail("Handless Opaw is missing animation %s." % animation_name)
			return
		if HandlessFrames.get_frame_count(animation_name) != active_body.sprite_frames.get_frame_count(animation_name):
			_fail("Handless Opaw changed the frame count for %s." % animation_name)
			return

	var changed_pixels := 0
	for names: Array in SHEETS:
		var active := Image.load_from_file("res://assets/characters/playable/opaw/compact_armless/%s" % names[0])
		var variant := Image.load_from_file("res://assets/characters/playable/opaw/variants/handless/%s" % names[1])
		if active == null or variant == null or active.get_size() != variant.get_size():
			_fail("Handless Opaw sheet %s does not preserve the active grid dimensions." % names[1])
			return
		for y in active.get_height():
			for x in active.get_width():
				if active.get_pixel(x, y) != variant.get_pixel(x, y):
					changed_pixels += 1
	if changed_pixels <= 0:
		_fail("The legacy handless review sheets are identical to active compact armless Opaw.")
		return
	print("Opaw handless variant smoke test passed with %s changed pixels." % changed_pixels)
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
