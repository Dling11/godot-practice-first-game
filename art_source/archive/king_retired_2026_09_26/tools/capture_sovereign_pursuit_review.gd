extends "res://tools/capture_king_spellward_locomotion.gd"

const PURSUIT_OUT := "res://art_source/review/characters/king/sovereign_pursuit_2026_09_26/"


func _run() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PURSUIT_OUT))
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	lab = Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	actor = lab.player
	root.set_disable_input(true)
	var input := CaptureInput.new()
	actor.add_child(input)
	actor.input_source = input
	review = lab.get_node("KingSpellwardReview")
	review.open_review()
	lab.clear_simulation()
	await _wait(.15)
	await _shot("playable_lab")
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	lab.camera.set_physics_process(false)
	lab.camera.top_level = true
	lab.camera.set_process(false)
	lab.camera.position_smoothing_enabled = false
	lab.camera.zoom = Vector2(1.7, 1.7)
	lab.camera.global_position = Vector2(400, 300)
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(0, 24)
	caption.size.x = 960
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 18)
	overlay.add_child(caption)
	for version in 2:
		actor.global_position = Vector2(330, 310)
		actor._set_facing_direction(Vector2.RIGHT)
		actor.ability_3_component.clear_cooldown()
		if version == 1:
			review.toggle_pursuit_review()
			assert(bool(review.get("_pursuit_review_enabled")), "Pursuit comparison did not install review art")
		caption.text = "SOVEREIGN PURSUIT · ORIGINAL" if version == 0 else "SOVEREIGN PURSUIT · BLADE-CUT TEST"
		await _wait(.25)
		assert(actor.request_ability(3))
		actor.ground_point_targeting.update_aim(Vector2(470, 310), Vector2.ZERO)
		assert(actor.ground_point_targeting.confirm_targeting())
		await _wait(.24)
		await _shot("%s_travel" % ("original" if version == 0 else "review"))
		await _wait(.22)
		await _shot("%s_impact" % ("original" if version == 0 else "review"))
		await _wait(.18)
		await _shot("%s_ring" % ("original" if version == 0 else "review"))
		await _wait(.32)
		await _shot("original_crater" if version == 0 else "review_afterglow")
		await _wait(1.35 if version == 0 else .85)
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("PURSUIT_REVIEW_CAPTURE_COMPLETE")
	quit()


func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(PURSUIT_OUT + label + ".png")
