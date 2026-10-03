extends SceneTree

const Gallery = preload("res://tools/stage_presentation_gallery.gd")
const OUTPUT := "res://art_source/review/ui/stage_presentation_2026_10_03/"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	root.mode = Window.MODE_WINDOWED
	var gallery := Control.new()
	gallery.set_script(Gallery)
	root.add_child(gallery)
	current_scene = gallery
	gallery.show_portal(2)
	await create_timer(.8).timeout
	await capture_loop("grasp",16)
	gallery.show_portal(3)
	await create_timer(.8).timeout
	await capture_loop("maw",16)
	gallery.show_loading()
	gallery._loading.heading.text = "ENTERING THE NEXT STAGE"
	gallery._loading.progress_label.text = "MOTION PREVIEW • 37%"
	await capture_loop("loading",24)
	gallery.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("STAGE_MOTION: 56 native frames; loading fixed 37% rehearsal, production uses real resources")
	quit()

func capture_loop(key: String, count: int) -> void:
	var path := OUTPUT+key+"_frames/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path))
	for index in count:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(path+"frame_%02d.png" % index) == OK)
		await create_timer(.1).timeout
