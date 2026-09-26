extends "res://tools/capture_king_spellward_locomotion.gd"

const EARTH_OUT := "res://art_source/review/characters/king/earthsplitter_2026_09_14/"
func _run() -> void:
	DirAccess.make_dir_recursive_absolute(EARTH_OUT)
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
	lab.clear_simulation()
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	lab.camera.zoom = Vector2(2,2)
	lab.camera.global_position = Vector2(425,310)
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(0,24)
	caption.size.x = 960
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",18)
	overlay.add_child(caption)
	caption.text = "EARTHSPLITTER / SUMMONED SWORD / REAL SPEED"
	await _wait(.4)
	for direction in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		actor.position = Vector2(425,310) - direction*65
		actor._set_facing_direction(direction)
		actor.ability_1_component.clear_cooldown()
		var begin := Engine.get_process_frames()
		actor.request_ability(1)
		actor.ground_point_targeting.update_aim(actor.position + direction*160,Vector2.ZERO)
		actor.set_physics_process(false)
		await _wait(.32)
		actor.ground_point_targeting.update_aim(actor.position + direction*160,Vector2.ZERO)
		actor.ground_point_targeting.confirm_targeting()
		actor.set_physics_process(true)
		await _wait(.11)
		await _shot("summon_" + str(direction))
		await _wait(.12)
		await _shot("impact_" + str(direction))
		await _wait(.16)
		input.movement = direction.orthogonal()
		caption.text = "CONTROL RETURNS / THE EARTH KEEPS TEARING FORWARD"
		await _wait(.13)
		await _shot("rupture_" + str(direction))
		await _wait(.23)
		input.movement = Vector2.ZERO
		await _wait(.55)
		_record("direction_" + str(direction),begin)
		caption.text = "EARTHSPLITTER / SUMMONED SWORD / REAL SPEED"
	actor.position = Vector2(350,320)
	actor._set_facing_direction(Vector2.RIGHT)
	var foes: Array[ForsakenThrall] = []
	for x in [415,460,500]:
		var foe: ForsakenThrall = load("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn").instantiate()
		foe.position = Vector2(x,320)
		foe.target = actor
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000,false)
		foe.health_component.set_current_health(1000)
		foes.append(foe)
	await _wait(.4)
	caption.text = "LIVE DAMAGE / ONE HIT PER TARGET / FLINCH, NO STUN"
	actor.ability_1_component.clear_cooldown()
	actor.ability_1_component.request_cast_at(Vector2(514,320),40)
	await _wait(.32)
	await _shot("combat")
	await _wait(1.2)
	for foe in foes:
		foe.queue_free()
	FileAccess.open(EARTH_OUT+"segments.json",FileAccess.WRITE).store_string(JSON.stringify(segments,"\t"))
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("EARTHSPLITTER_CAPTURE_COMPLETE")
	quit()

func _shot(label: String) -> void:
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(EARTH_OUT + label.replace(" ","").replace(",","_").replace("(","").replace(")","") + ".png")

