extends "res://tools/capture_king_spellward_locomotion.gd"

const RIFT_OUT := "res://art_source/review/characters/king/riftbreak_targeted_2026_09_14/"


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(RIFT_OUT)
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
	review.toggle_riftbreak_review()
	lab.clear_simulation()
	await process_frame
	actor.position = Vector2(325, 330)
	actor._set_facing_direction(Vector2.RIGHT)
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	lab.camera.zoom = Vector2(2, 2)
	lab.camera.global_position = Vector2(415, 315)
	var foes: Array[ForsakenThrall] = []
	for offset in [Vector2.ZERO, Vector2(52, 0)]:
		var foe: ForsakenThrall = load("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn").instantiate()
		foe.target = actor
		foe.position = Vector2(440, 330) + offset
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000, false)
		foe.health_component.set_current_health(1000)
		foes.append(foe)
	await _wait(.8)
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(0, 30)
	caption.size.x = 960
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 20)
	overlay.add_child(caption)
	caption.text = "RIFTBREAK REVIEW  /  AIM THE STUN CENTER"
	var begin := Engine.get_process_frames()
	for cycle in 2:
		actor.position = Vector2(325, 330)
		actor.ability_2_component.clear_cooldown()
		actor.request_ability(2)
		actor.ground_point_targeting.update_aim(Vector2(440, 330), Vector2.ZERO)
		actor.set_physics_process(false)
		await _wait(.7)
		actor.ground_point_targeting.update_aim(Vector2(440, 330), Vector2.ZERO)
		actor.ground_point_targeting.confirm_targeting()
		actor.set_physics_process(true)
		await _wait(.23)
		caption.text = "DIRECT HIT: STUN  /  OUTER BLAST: FLINCH + PUSH"
		if cycle == 0:
			await RenderingServer.frame_post_draw
			root.get_texture().get_image().save_png(RIFT_OUT + "impact.png")
		await _wait(.2)
		capture_input.movement = Vector2.DOWN
		caption.text = "CONTROL RETURNS AT 0.38s  /  THE DEBRIS CONTINUES"
		await _wait(.5)
		capture_input.movement = Vector2.ZERO
		await _wait(.65)
		caption.text = "RIFTBREAK REVIEW  /  AIM THE STUN CENTER"
		for foe in foes:
			foe._enter_state(ForsakenThrall.State.CHASE, 0.0)
	_record("targeted_riftbreak", begin)
	FileAccess.open(RIFT_OUT + "segments.json", FileAccess.WRITE).store_string(JSON.stringify(segments, "\t"))
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("RIFTBREAK_CAPTURE_COMPLETE")
	quit()
