extends "res://tools/launch_king_greatsword_confidence_review.gd"

## Both facing directions use the real 4→5 attack clock, not a pose slideshow.
const OUT := "res://art_source/review/combat/king_linked_return_pair_v10_2026_10_04/"

func _run() -> void:
	await super._run()
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	toolbar.hide()
	var layer := CanvasLayer.new()
	layer.layer = 7
	stage.add_child(layer)
	var background := ColorRect.new()
	background.position = Vector2(552,70)
	background.size = Vector2(398,450)
	background.color = Color("202b30")
	layer.add_child(background)
	var label := Label.new()
	label.position = Vector2(566,82)
	label.add_theme_font_size_override("font_size",12)
	layer.add_child(label)
	var group := Node2D.new()
	group.position = Vector2(750,360)
	group.scale = Vector2.ONE*1.5
	layer.add_child(group)
	var body := Presenter.new()
	body.continuation_requested = has_queued_cut
	body.continuation_pending = has_pending_cut
	assert(body.configure(reviewed_poses,stage.player.attack_component))
	assert(body.configure_idle(PRIDE_POSES))
	body.position = Vector2(0,-16)
	body.scale = Vector2.ONE*0.5
	group.add_child(body)
	var trail := BladeTrail.new()
	configure_trail(trail)
	group.add_child(trail)
	var records: Array[Dictionary] = []
	var captured: Array[Image] = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT+"motion_frames/"))
	var started := Time.get_ticks_msec()
	var origin: Vector2 = stage.player.global_position
	for index in 120:
		if index==10: try_linked_return()
		if index==65:
			stage.player.facing_direction = Vector2.LEFT
			axe_presenter.face_horizontal(-1)
			body.face_horizontal(-1)
			try_linked_return()
		await create_timer(1.0/20.0).timeout
		var attack: MeleeAttackComponent = stage.player.attack_component
		group.position = Vector2(750,360)+(stage.player.global_position-origin)*1.5
		label.text = "FOURTH → FIFTH / "+("RIGHT" if attack.get_attack_direction().x>0 else "LEFT")+"\n"+(["Ready","Wind-up","Contact","Follow-through"][attack.phase])+" / strike "+str(attack.combo_step+1)+"\nNo guard reset between 4 and 5"
		await RenderingServer.frame_post_draw
		var name := "motion_frames/frame_%03d.png" % index
		# Encode after playback; PNG compression must not stall the motion clock.
		captured.append(root.get_texture().get_image().get_region(Rect2i(362,66,588,458)))
		records.append({"file":name,"elapsed_ms":Time.get_ticks_msec()-started,"phase":attack.phase,"step":attack.combo_step,"pose":axe_presenter.pose_index,"clip":axe_presenter.definition.body_atlas.resource_path,"trail_frame":swing_trail._frame,"facing":attack.get_attack_direction().x,"root_position":[stage.player.global_position.x,stage.player.global_position.y]})
	for index in captured.size():
		assert(captured[index].save_png(OUT+records[index].file)==OK)
	FileAccess.open(OUT+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("KING_LINKED_RETURN_MOTION frames=",records.size()," actual 4→5 clock / both facing directions")
	stage.queue_free()
	await process_frame
	quit()
