extends SceneTree

const OUT := "res://art_source/review/characters/king/unbroken_vow_in_engine_2026_09_27/"

func _initialize() -> void:
	call_deferred("_capture")

func _capture() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	DirAccess.make_dir_recursive_absolute(OUT)
	var lab: Node = load("res://levels/combat_lab/combat_lab.tscn").instantiate()
	root.add_child(lab)
	current_scene = lab
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.player.position = Vector2(360, 320)
	var review: Node = lab.get_node("KingCombatReview")
	review.open_buff_test()
	var test: Node = review.buff_test
	await process_frame
	await RenderingServer.frame_post_draw
	_save("01_controls.png")
	test.play_preview()
	test.set_physics_process(false)
	test.advance(.17)
	await process_frame
	await RenderingServer.frame_post_draw
	_save("02_release.png")
	test.advance(.16)
	await process_frame
	await RenderingServer.frame_post_draw
	_save("03_sustain_native.png")
	lab.camera.zoom = Vector2(2, 2)
	await process_frame
	await RenderingServer.frame_post_draw
	_save("04_sustain_close.png")
	test.close()
	await process_frame
	await RenderingServer.frame_post_draw
	_save("05_restored.png")
	lab.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	print("UNBROKEN_VOW_GPU_CAPTURE: five real Combat Lab renders saved")
	quit()

func _save(name: String) -> void:
	assert(root.get_texture().get_image().save_png(OUT + name) == OK)
