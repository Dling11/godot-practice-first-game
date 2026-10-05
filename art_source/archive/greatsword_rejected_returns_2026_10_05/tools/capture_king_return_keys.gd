extends "res://tools/launch_king_greatsword_confidence_review.gd"
const OUT := "res://art_source/review/combat/king_linked_return_v10_2026_10_04/"
func _run() -> void:
	await super._run()
	root.content_scale_size = Vector2i(1600,500)
	root.size = Vector2i(1600,500)
	toolbar.hide()
	var layer := CanvasLayer.new()
	layer.layer = 7
	stage.add_child(layer)
	var background := ColorRect.new()
	background.size = Vector2(1600,500)
	background.color = Color("202b30")
	layer.add_child(background)
	for direction in 2:
		for pose in 8:
			var label := Label.new()
			label.text = str(pose)+" / "+["4th endpoint","4th endpoint","RETURN CUT","RETURN CUT","RETURN CUT","settle","settle","carry"][pose]
			label.position = Vector2(pose*200+8,direction*250+8)
			layer.add_child(label)
			var rig := Presenter.new()
			assert(rig.configure(reviewed_poses.follow_up_clips[3],stage.player.attack_component,false))
			rig.scale = Vector2.ONE*0.8
			rig.position = Vector2(pose*200+100,direction*250+170)
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
