extends "res://tools/capture_king_spellward_locomotion.gd"

const STUN_OUT := "res://art_source/review/combat/stun_indicator_2026_09_14/"


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(STUN_OUT)
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
	actor.global_position = Vector2(325, 320)
	actor._set_facing_direction(Vector2.RIGHT)
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	lab.camera.zoom = Vector2(3, 3)
	lab.camera.global_position = Vector2(400, 292)
	var mobs: Array[Node2D] = []
	for enemy_name in ["forsaken_thrall", "armored_hog"]:
		var mob: Node2D = load("res://entities/enemies/%s/%s.tscn" % [enemy_name, enemy_name]).instantiate()
		mob.target = actor
		mob.position = Vector2(400 + mobs.size() * 75, 320)
		lab.add_child(mob)
		mob.set_physics_process(false)
		mobs.append(mob)
	await _wait(1.0)
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(0, 40)
	caption.size.x = 960
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 22)
	caption.text = "STUN  /  SHARED HEAD EFFECT"
	overlay.add_child(caption)
	for index in 3:
		var label := Label.new()
		label.text = ["KING", "THRALL", "ARMORED HOG"][index]
		label.position = Vector2(175 + index * 225, 388)
		label.size.x = 160
		label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		label.add_theme_font_size_override("font_size", 16)
		overlay.add_child(label)
	review.sample_hit(2.2)
	for mob in mobs:
		mob.get_node("HealthComponent").apply_damage(DamageInfo.new(1.0, actor, Vector2.ZERO, 0.0, 0.0, false, 2.2))
	await process_frame
	await process_frame
	for frame_index in 48:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(STUN_OUT + "frame_%03d.png" % frame_index)
		await _wait(1.0 / 24.0)
	caption.text = "CONTROL RETURNS  /  STARS CLEAR"
	for mob in mobs:
		if mob is ForsakenThrall:
			mob._enter_state(ForsakenThrall.State.CHASE, 0.0)
		elif mob is ArmoredHog:
			mob._enter(ArmoredHog.State.CHASE, 0.0)
	await _wait(.4)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(STUN_OUT + "recovered.png")
	actor.hide()
	for mob in mobs:
		mob.hide()
	for child in overlay.get_children():
		child.hide()
	caption.show()
	caption.text = "EXAMINER  /  GUARD BROKEN"
	var examiner: Examiner = load("res://entities/enemies/examiner/examiner.tscn").instantiate()
	examiner.target = actor
	examiner.position = Vector2(400, 330)
	lab.add_child(examiner)
	examiner.set_physics_process(false)
	await _wait(1.0)
	examiner._enter(Examiner.State.GUARD_BROKEN, 2.0)
	await _wait(.25)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(STUN_OUT + "examiner.png")
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("STUN_CAPTURE_COMPLETE")
	quit()
