extends "res://tools/launch_king_greatsword_confidence_review.gd"

const OUT := "res://art_source/review/combat/king_grip_plant_v4_2026_10_04/"

func _run() -> void:
	await super._run()
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	toolbar.hide()
	contact_target.position += Vector2(1000,0)
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
	group.position = Vector2(630,390)
	group.scale = Vector2.ONE*1.25
	layer.add_child(group)
	var body := Presenter.new()
	assert(body.configure(CONFIDENT_POSES,stage.player.attack_component))
	assert(body.configure_idle(PRIDE_POSES))
	body.position = Vector2(0,-16)
	body.scale = Vector2.ONE*0.5
	group.add_child(body)
	var trail := BladeTrail.new()
	configure_trail(trail)
	group.add_child(trail)
	var impacts := ImpactPresenter.new()
	impacts.attack = stage.player.attack_component
	impacts.atlas = IMPACT_ART
	impacts.presentation_anchor = group
	impacts.mirror_horizontal_landing = true
	group.add_child(impacts)
	var planted := {"marker":null}
	body.pose_changed.connect(func(pose: int) -> void:
		if body.definition!=PRIDE_POSES or body._drawing or pose<5:
			if is_instance_valid(planted.marker):
				planted.marker.get_parent().remove_child(planted.marker)
				planted.marker.queue_free()
		if body.definition==PRIDE_POSES and body._resting and not body._drawing and pose==5:
			var point := body.get_plant_ground_position()*0.5+Vector2(0,-16)
			point.x *= -1 if body.scale.x<0 else 1
			impacts._spawn(1,point,0.28,0.24)
			var decal := ImpactPresenter.Burst.new()
			decal.atlas = IMPACT_ART
			decal.row = 1
			decal.frame = 3
			decal.animate = false
			decal.position = point
			decal.scale = Vector2.ONE*0.18
			group.add_child(decal)
			planted.marker = decal
	)
	# Mirror actual idle/run transitions; the inset never owns movement or damage.
	var records: Array[Dictionary] = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT+"motion_frames/"))
	var started := Time.get_ticks_msec()
	var origin: Vector2 = stage.player.global_position
	var previous_position := origin
	for index in 200:
		if index==10:
			horizontal_motion.set_direction(1)
			body.play_locomotion(RUN_POSES,48.0/horizontal_motion.speed,true)
		if index==28:
			horizontal_motion.stop_and_clear()
			body.stop_locomotion()
			place_target()
		if index==32: play_combo()
		if index==115:
			proud_idle()
			body._rest_timer.stop()
			body._rest()
		if index==147:
			strike()
			body.retrieve_from_rest(func() -> void: pass)
		if index==172:
			horizontal_motion.set_direction(-1)
			body.face_horizontal(-1)
			body.play_locomotion(RUN_POSES,48.0/horizontal_motion.speed,true)
		if index==192:
			horizontal_motion.stop_and_clear()
			body.stop_locomotion()
		await create_timer(1.0/20.0).timeout
		body.advance_locomotion(stage.player.global_position.distance_to(previous_position))
		previous_position = stage.player.global_position
		var attack: MeleeAttackComponent = stage.player.attack_component
		group.position = Vector2(630,390)+(stage.player.global_position-origin)*1.25
		label.text = "GREATSWORD V4 / GRIP + SHALLOW PRIDE\n"+("One-hand shoulder run" if axe_presenter._running else "Retrieving planted sword" if axe_presenter._drawing else "Plant / proud crossed arms" if axe_presenter._resting else NAMES[attack.combo_step] if attack.phase!=MeleeAttackComponent.Phase.IDLE else "Confident one-hand carry")
		await RenderingServer.frame_post_draw
		var name := "motion_frames/frame_%03d.png" % index
		assert(root.get_texture().get_image().get_region(Rect2i(362,66,588,458)).save_png(OUT+name)==OK)
		records.append({"file":name,"elapsed_ms":Time.get_ticks_msec()-started,"phase":attack.phase,"step":attack.combo_step,"pose":axe_presenter.pose_index,"trail_frame":swing_trail._frame,"running":axe_presenter._running,"drawing":axe_presenter._drawing,"resting":axe_presenter._resting,"root_position":[stage.player.global_position.x,stage.player.global_position.y]})
	FileAccess.open(OUT+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("KING_CONFIDENCE_MOTION frames=",records.size()," actual action/movement clock; not a performance benchmark")
	stage.queue_free()
	await process_frame
	quit()
