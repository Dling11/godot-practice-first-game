extends SceneTree

const OUT := "res://art_source/review/environment/sanctuary_redesign/"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = load("res://levels/sanctuary/sanctuary.tscn").instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	await process_frame
	hub.get_node("UI").visible = false
	var player: Player = hub.get_node("World/Actors/Player")
	player.set_physics_process(false)
	player.position = Vector2(576,580)
	var camera := player.get_node("Camera2D") as Camera2D
	camera.position_smoothing_enabled = false
	camera.reset_smoothing()
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	root.get_texture().get_image().save_png(OUT+"before_native.png")
	camera.reparent(hub)
	camera.position = Vector2(576,384)
	camera.zoom = Vector2(.68,.68)
	camera.limit_left = -10000
	camera.limit_top = -10000
	camera.limit_right = 10000
	camera.limit_bottom = 10000
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"before_overview.png")
	hub.queue_free()
	await process_frame
	print("SANCTUARY_BASELINE_CAPTURED")
	quit()
