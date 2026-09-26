extends "res://tools/capture_king_spellward_lab.gd"

const MOTION_OUT := "res://art_source/review/characters/king/spellward_locomotion_2026_09_14/"

# Keep the review deterministic even if the desktop keyboard/controller is in use.
# Only device intent is substituted; Player still owns movement and facing.
class CaptureInput extends PlayerInputSource:
	var movement := Vector2.ZERO
	func get_move_direction() -> Vector2:
		return movement
	func get_aim_direction() -> Vector2:
		return Vector2.ZERO
	func is_primary_attack_just_pressed() -> bool:
		return false
	func is_evade_just_pressed() -> bool:
		return false
	func is_ability_1_just_pressed() -> bool:
		return false
	func is_ability_2_just_pressed() -> bool:
		return false
	func is_ability_3_just_pressed() -> bool:
		return false
	func is_ability_4_just_pressed() -> bool:
		return false

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	lab = Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	actor = lab.player
	root.set_disable_input(true)
	var capture_input := CaptureInput.new()
	actor.add_child(capture_input)
	actor.input_source = capture_input
	review = lab.get_node("KingSpellwardReview")
	review.open_review()
	lab.clear_simulation()
	await process_frame
	actor.global_position = Vector2(400, 300)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(MOTION_OUT + "playable_lab.png")
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	lab.camera.zoom = Vector2(2, 2)
	lab.camera.global_position = Vector2(400, 300)
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(20, 16)
	caption.size = Vector2(920, 30)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 18)
	overlay.add_child(caption)
	caption.text = "KING C · PLANTED IDLE / SHOULDER CARRY"
	var start := Engine.get_process_frames()
	for direction in [Vector2.DOWN, Vector2.RIGHT, Vector2.UP, Vector2.LEFT]:
		actor._set_facing_direction(direction)
		await _wait(2.1)
		var body := actor.get_node("VisualRoot/Body") as AnimatedSprite2D
		print("IDLE_CAPTURE ", direction, " clip=", body.animation, " position=", actor.global_position, " input=", actor.input_source.get_move_direction())
		assert(String(body.animation) == "idle_" + String(body.call("_direction_name", direction)), "Capture received unexpected movement/facing")
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(MOTION_OUT + String(body.animation) + ".png")
	_record("idle", start)
	caption.text = "FOUR-DIRECTION WALK · THIN CHARCOAL OUTLINE"
	start = Engine.get_process_frames()
	for direction in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		actor.global_position = Vector2(400, 300)
		capture_input.movement = direction
		await _wait(.85)
		capture_input.movement = Vector2.ZERO
		await _wait(.12)
	_record("walk", start)
	actor.global_position = Vector2(400, 300)
	caption.text = "APPROVED THREE CUTS · ORIGINAL FRAMES / TIMING / CONTACT TRAILS"
	start = Engine.get_process_frames()
	await _combo(Vector2.RIGHT)
	await _combo(Vector2.UP)
	_record("combo", start)
	FileAccess.open(MOTION_OUT + "segments.json", FileAccess.WRITE).store_string(JSON.stringify(segments, "\t"))
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("SPELLWARD_LOCOMOTION_CAPTURE_COMPLETE")
	quit()
