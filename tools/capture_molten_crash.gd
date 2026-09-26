extends "res://tools/capture_king_spellward_locomotion.gd"
const MOLTEN_OUT := "res://art_source/review/characters/king/molten_crash_2026_09_26/"
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(MOLTEN_OUT)
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
	var index := 0
	for facing in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]:
		actor.position = Vector2(425,300)
		actor._set_facing_direction(facing)
		actor.ability_2_component.clear_cooldown()
		caption.text = "MOLTEN CRASH / LOCAL IMPACT / INITIAL STUN"
		await _wait(.3)
		actor.request_ability(2)
		await _wait(.12)
		await _shot("lift_"+str(index))
		await _wait(.09)
		await _shot("contact_"+str(index))
		await _wait(.16)
		caption.text = "CONTROL RETURNS / MOLTEN DEBRIS SETTLES"
		input.movement = facing.orthogonal()
		await _wait(.10)
		await _shot("eruption_"+str(index))
		await _wait(.23)
		input.movement = Vector2.ZERO
		await _shot("cooling_"+str(index))
		await _wait(.7)
		index += 1
	actor.position = Vector2(425,300)
	var foes: Array = []
	for offset in [Vector2(-50,0),Vector2(50,0),Vector2(0,50)]:
		var foe = load("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn").instantiate()
		foe.position = actor.position+offset
		foe.target = actor
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000,false)
		foe.health_component.set_current_health(1000)
		foe._enter_state(foe.State.CHASE,0.0)
		foes.append(foe)
	await _wait(.3)
	caption.text = "ONE RADIAL HIT / STUN STARS / NO REPEATING DAMAGE"
	actor.ability_2_component.clear_cooldown()
	actor.request_ability(2)
	await _wait(.3)
	await _shot("crowd_stun")
	await _wait(1.2)
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("MOLTEN_CAPTURE_COMPLETE")
	quit()
func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(MOLTEN_OUT+label+".png")
