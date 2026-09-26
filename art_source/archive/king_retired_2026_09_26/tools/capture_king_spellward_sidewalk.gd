extends "res://tools/capture_king_spellward_locomotion.gd"

const SIDE_OUT := "res://art_source/review/characters/king/spellward_sidewalk_2026_09_14/"

func _run() -> void:
	var whole_body := "--bodywalk" in OS.get_cmdline_user_args()
	var output := "res://art_source/review/characters/king/spellward_bodywalk_2026_09_14/" if whole_body else SIDE_OUT
	var leg_review := "--legcycle" in OS.get_cmdline_user_args()
	if leg_review:
		output = "res://art_source/review/characters/king/spellward_legcycle_2026_09_14/"
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
	caption.text = "KING C · BOTH BOOTS LIFT / SHOULDER CARRY"
	if whole_body:
		caption.text = "KING C · WHOLE-BODY STRIDE / WAIST AND ARM SWING"
	overlay.add_child(caption)
	actor.global_position = Vector2(320, 300)
	for direction in [Vector2.RIGHT, Vector2.LEFT]:
		capture_input.movement = direction
		await _wait(1.25)
		if whole_body:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(output + ("moving_right.png" if direction.x > 0 else "moving_left.png"))
		capture_input.movement = Vector2.ZERO
		await _wait(.3)
	# Render the actual normalized frames for contact/passing visual inspection.
	var body := actor.get_node("VisualRoot/Body") as AnimatedSprite2D
	if leg_review:
		var slow_start := Engine.get_process_frames() / 60.0
		var slow_layer := CanvasLayer.new()
		root.add_child(slow_layer)
		var backdrop := ColorRect.new()
		backdrop.size = Vector2(960, 540)
		backdrop.color = Color("19232e")
		slow_layer.add_child(backdrop)
		for index in 2:
			var study := AnimatedSprite2D.new()
			study.sprite_frames = body.sprite_frames
			study.material = body.material
			study.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			study.position = Vector2(290 + index * 380, 250)
			study.scale = Vector2(3, 3)
			study.speed_scale = .25
			slow_layer.add_child(study)
			study.play("walk_right" if index == 0 else "walk_left")
		await _wait(2.3)
		FileAccess.open(output + "slow_segment.json", FileAccess.WRITE).store_string(JSON.stringify({"start": slow_start + .05, "end": Engine.get_process_frames() / 60.0}))
		slow_layer.queue_free()
		await process_frame
	var background := ColorRect.new()
	background.color = Color("19232e")
	background.size = Vector2(960, 540)
	overlay.add_child(background)
	for row in (4 if whole_body else 2):
		for col in 4:
			var sprite := Sprite2D.new()
			var right_facing := row < 2 if whole_body else row == 0
			var index := col + (row % 2) * 4 if whole_body else col
			sprite.texture = body.sprite_frames.get_frame_texture("walk_right" if right_facing else "walk_left", index)
			sprite.material = body.material
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.scale = Vector2(1.3, 1.3) if whole_body else Vector2(2, 2)
			sprite.position = Vector2(155 + col * 210, 60 + row * 125) if whole_body else Vector2(155 + col * 210, 140 + row * 220)
			overlay.add_child(sprite)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(output + "frames.png")
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("SPELLWARD_SIDEWALK_CAPTURE_COMPLETE")
	quit()
