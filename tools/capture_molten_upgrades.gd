extends "res://tools/capture_king_spellward_locomotion.gd"

const UPGRADE_OUT := "res://art_source/review/characters/king/molten_crash_upgrades_2026_09_26/"

func _run() -> void:
	DirAccess.make_dir_recursive_absolute(UPGRADE_OUT)
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
	review.toggle_earthsplitter_review()
	review.toggle_earthsplitter_form()
	review.toggle_molten_review()
	lab.clear_simulation()
	await _wait(.2)
	await _shot("playable_lab")
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	lab.camera.set_physics_process(false)
	lab.camera.top_level = true
	lab.camera.set_process(false)
	lab.camera.position_smoothing_enabled = false
	lab.camera.zoom = Vector2(1.7,1.7)
	lab.camera.global_position = Vector2(425,300)
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(0,24)
	caption.size.x = 960
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",18)
	overlay.add_child(caption)
	await _wait(.2)
	var names := ["FOUNDATION / STONE + LIGHT","ADVANCED / MOLTEN","AWAKENED / FURNACE BREAK","MATURE / CALDERA"]
	for form in 4:
		actor.position = Vector2(425,300)
		actor._set_facing_direction(Vector2.RIGHT)
		if form > 0:
			assert(review.molten_review.set_form(form))
		actor.ability_2_component.clear_cooldown()
		caption.text = names[form]
		await _wait(.24)
		actor.request_ability(2)
		await _wait(.22)
		await _shot("form_%d_contact" % form)
		await _wait(.18)
		input.movement = Vector2.DOWN
		await _wait(.18)
		await _shot("form_%d_after" % form)
		input.movement = Vector2.ZERO
		await _wait(.72)
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("MOLTEN_UPGRADE_CAPTURE_COMPLETE")
	quit()

func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(UPGRADE_OUT+label+".png")
