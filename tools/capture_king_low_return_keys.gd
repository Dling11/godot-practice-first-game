extends "res://tools/launch_king_greatsword_confidence_review.gd"
const OUT := "res://art_source/review/combat/king_low_return_2026_10_05/"
func _run() -> void:
	await super._run()
	root.content_scale_size = Vector2i(1600,1000)
	root.size = Vector2i(1600,1000)
	toolbar.hide()
	var layer := CanvasLayer.new()
	layer.layer = 7
	stage.add_child(layer)
	var background := ColorRect.new()
	background.size = Vector2(1600,1000)
	background.color = Color("202b30")
	layer.add_child(background)
	for direction in 2:
		for pose in RETURN_POSES.pose_count:
			var origin := Vector2(direction*800+(pose%4)*200,pose/4*250)
			var label := Label.new()
			label.text = str(pose)+" / "+("4th end" if pose<2 else "front contact" if pose<=6 else "low return" if pose<=10 else "carry")
			label.position = origin+Vector2(8,8)
			layer.add_child(label)
			var rig := Presenter.new()
			assert(rig.configure(RETURN_POSES,stage.player.attack_component,false))
			rig.scale = Vector2.ONE*0.8
			rig.position = origin+Vector2(100,148)
			layer.add_child(rig)
			rig.face_horizontal(1 if direction==0 else -1)
			rig.set_pose(pose)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+"return_keys.png")==OK)
	stage.queue_free()
	await process_frame
	quit()
