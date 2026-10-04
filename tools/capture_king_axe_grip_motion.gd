extends "res://tools/launch_king_axe_grip_review.gd"

const OUT := "res://art_source/review/combat/king_axe_grip_2026_10_04/"
const COMBO_OUT := "res://art_source/review/combat/king_axe_combo_v2_2026_10_04/"

func _run() -> void:
	await super._run()
	var combo := "--combo" in OS.get_cmdline_user_args()
	var folder: String = COMBO_OUT if combo else OUT
	root.size = Vector2i(960,540)
	toolbar.hide()
	place_target()
	await create_timer(0.2).timeout
	var layer := CanvasLayer.new()
	layer.layer = 7
	stage.add_child(layer)
	var background := ColorRect.new()
	background.position = Vector2(632,148)
	background.size = Vector2(248,344)
	background.color = Color("202b30")
	layer.add_child(background)
	var caption := Label.new()
	caption.text = "SAME MELEE CLOCK · 4x VIEW"
	caption.add_theme_font_size_override("font_size",12)
	caption.position = Vector2(642,156)
	layer.add_child(caption)
	var enlarged := Presenter.new()
	assert(enlarged.configure(POSES,stage.player.attack_component))
	enlarged.scale = Vector2(2,2)
	enlarged.position = Vector2(720,370)
	layer.add_child(enlarged)
	var trail := SwingTrail.new()
	trail.configure(stage.player.attack_component,SWING_ART)
	trail.position = Vector2(720,434)
	trail.scale = Vector2(4,4)
	layer.add_child(trail)
	var records: Array[Dictionary] = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder+"motion_frames/"))
	var started := Time.get_ticks_msec()
	for index in (82 if combo else 30):
		if index == 3:
			if combo: play_combo()
			else: strike()
		await create_timer(1.0/30.0).timeout
		await RenderingServer.frame_post_draw
		var name := "motion_frames/frame_%03d.png" % index
		var capture := root.get_texture().get_image().get_region(Rect2i(360,140,528,360))
		assert(capture.save_png(folder+name)==OK)
		records.append({"file":name,"elapsed_ms":Time.get_ticks_msec()-started,"phase":stage.player.attack_component.phase,"step":stage.player.attack_component.combo_step,"pose":axe_presenter.pose_index,"trail_frame":swing_trail._frame,"lift":axe_presenter.position.y+16})
	FileAccess.open(folder+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("AXE_MOTION_CAPTURE frames=",records.size()," real melee clock; capture is not a performance benchmark")
	stage.queue_free()
	await process_frame
	quit()
