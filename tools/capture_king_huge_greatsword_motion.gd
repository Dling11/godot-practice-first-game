extends "res://tools/launch_king_greatsword_review.gd"

const OUT := "res://art_source/review/combat/king_huge_greatsword_2026_10_04/"

func _run() -> void:
	await super._run()
	root.content_scale_size = Vector2i(960,540)
	root.size = Vector2i(960,540)
	toolbar.hide()
	place_crowd()
	await create_timer(0.15).timeout
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
	group.position = Vector2(675,390)
	group.scale = Vector2.ONE*1.5
	layer.add_child(group)
	var body := Presenter.new()
	assert(body.configure(GREAT_POSES,stage.player.attack_component))
	body.position = Vector2(0,-16)
	body.scale = Vector2.ONE*0.5
	group.add_child(body)
	var trail := SwingTrail.new()
	configure_trail(trail)
	group.add_child(trail)
	var impacts := ImpactPresenter.new()
	impacts.attack = stage.player.attack_component
	impacts.atlas = IMPACT_ART
	impacts.presentation_anchor = group
	group.add_child(impacts)
	var records: Array[Dictionary] = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT+"motion_frames/"))
	var started := Time.get_ticks_msec()
	var origin: Vector2 = stage.player.global_position
	for index in 110:
		if index==10: play_combo()
		await create_timer(1.0/20.0).timeout
		var attack: MeleeAttackComponent = stage.player.attack_component
		group.position = Vector2(675,390)+(stage.player.global_position-origin)*1.5
		label.text = "HUGE GREATSWORD / BODY + IMPACT\n"+(NAMES[attack.combo_step] if attack.phase!=MeleeAttackComponent.Phase.IDLE else "Low two-hand guard")
		await RenderingServer.frame_post_draw
		var name := "motion_frames/frame_%03d.png" % index
		assert(root.get_texture().get_image().get_region(Rect2i(362,66,588,458)).save_png(OUT+name)==OK)
		records.append({"file":name,"elapsed_ms":Time.get_ticks_msec()-started,"phase":attack.phase,"step":attack.combo_step,"pose":axe_presenter.pose_index,"trail_frame":swing_trail._frame,"lift":axe_presenter.position.y+16,"root_position":[stage.player.global_position.x,stage.player.global_position.y],"step_distance":step_motion.actual_distance,"active_bursts":impact_presenter.get_child_count()})
	FileAccess.open(OUT+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("HUGE_GREATSWORD_MOTION_CAPTURE frames=",records.size()," actual melee/body clock; not a performance benchmark")
	stage.queue_free()
	await process_frame
	quit()
