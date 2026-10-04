extends "res://tools/launch_king_greatsword_confidence_review.gd"
const OUT := "res://art_source/review/combat/king_grip_loop_v4_2026_10_04/"
const AXE_RUN = preload("res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres")
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
	background.size = Vector2(960,540)
	background.color = Color("202b30")
	layer.add_child(background)
	var rigs: Array[Presenter] = []
	for family in 2:
		var label := Label.new()
		label.text = "Greatsword · steady shoulder" if family==0 else "Axe · back carry / free hands"
		label.position = Vector2(28,18+family*260)
		layer.add_child(label)
		var rig := Presenter.new()
		assert(rig.configure(RUN_POSES if family==0 else AXE_RUN,stage.player.attack_component,false))
		rig.scale = Vector2.ONE*2.0
		rig.position = Vector2(500,148+family*260)
		layer.add_child(rig)
		rigs.append(rig)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT+"motion_frames/"))
	var records: Array[Dictionary] = []
	var started := Time.get_ticks_msec()
	horizontal_motion.set_direction(1)
	for index in 64:
		if index==32: horizontal_motion.set_direction(-1)
		await create_timer(0.05).timeout
		for rig in rigs:
			rig.face_horizontal(horizontal_motion.direction)
			rig.set_pose(axe_presenter.pose_index)
		await RenderingServer.frame_post_draw
		var file := "motion_frames/frame_%03d.png" % index
		assert(root.get_texture().get_image().save_png(OUT+file)==OK)
		records.append({"file":file,"elapsed_ms":Time.get_ticks_msec()-started,"pose":axe_presenter.pose_index,"direction":horizontal_motion.direction,"distance":axe_presenter._locomotion_distance})
	horizontal_motion.stop_and_clear()
	FileAccess.open(OUT+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	# Eight consecutive frames, both families; enlarging uses only nearest filtering.
	for child in layer.get_children(): child.queue_free()
	await process_frame
	root.content_scale_size = Vector2i(1600,560)
	root.size = Vector2i(1600,560)
	background = ColorRect.new()
	background.size = Vector2(1600,560)
	background.color = Color("202b30")
	layer.add_child(background)
	for family in 2:
		for pose in 8:
			var label := Label.new()
			label.text = str(pose)+" · "+["contact","down","passing","flight","contact","down","passing","flight"][pose]
			label.position = Vector2(pose*200+8,family*280+8)
			layer.add_child(label)
			var rig := Presenter.new()
			assert(rig.configure(RUN_POSES if family==0 else AXE_RUN,stage.player.attack_component,false))
			rig.scale = Vector2.ONE*1.4
			rig.position = Vector2(pose*200+156,family*280+180)
			layer.add_child(rig)
			rig.set_pose(pose)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+"all_frames.png")==OK)
	print("KING_GAIT_CAPTURE actual distance-driven loop 64 frames / all 8 keys per family")
	stage.queue_free()
	await process_frame
	quit()
