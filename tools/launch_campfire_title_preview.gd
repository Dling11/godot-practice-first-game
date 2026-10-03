extends SceneTree

const Title := preload("res://ui/screens/title/title_screen.tscn")
const Preview := preload("res://tools/campfire_title_preview.gd")
const OUTPUT := "res://art_source/review/ui/campfire_title_2026_10_03/"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	var save := root.get_node("SaveService")
	assert(save.configure_storage_path_for_testing("user://campfire_title_review.json"))
	var capturing := "--capture" in OS.get_cmdline_user_args()
	if capturing:
		save.suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	var title := Title.instantiate() as TitleScreen
	root.add_child(title)
	current_scene = title
	title.get_node("Background").hide()
	var preview := Control.new()
	preview.set_script(Preview)
	title.add_child(preview)
	title.move_child(preview,0)
	var title_group: Control = title.get_node("Content/TitleGroup")
	title_group.position = Vector2(50,58)
	title_group.size.x = 310
	var name_label: Label = title.get_node("Content/TitleGroup/Title")
	name_label.text = "BATTLE\nOF GODS"
	name_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	name_label.add_theme_font_size_override("font_size",36)
	var subtitle: Label = title.get_node("Content/TitleGroup/Subtitle")
	subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	title.main_menu_panel.position = Vector2(50,195)
	title.main_menu_panel.size = Vector2(258,220)
	title.main_menu_panel.add_theme_stylebox_override("panel",StyleBoxEmpty.new())
	var footer := title.get_node("Content/Footer") as Label
	footer.text = "CAMPFIRE ART & MOTION PREVIEW · ISOLATED PROFILE"
	if not capturing:
		return
	DirAccess.make_dir_recursive_absolute(OUTPUT + "campfire_frames/")
	var fire_frames: Dictionary = {}
	var king_frames: Dictionary = {}
	var watcher_frames: Dictionary = {}
	var origins: Array[Vector2] = []
	var original_background: Vector2 = preview.backdrop.position
	await create_timer(.7).timeout
	for index in 80:
		await RenderingServer.frame_post_draw
		assert(preview.backdrop.position == original_background, "Preview scenery shifted")
		fire_frames[preview.fire.frame] = true
		king_frames[str(preview.king.animation)+str(preview.king.frame)] = true
		watcher_frames[str(preview.watchers[0].animation)+str(preview.watchers[0].frame)] = true
		origins.append(preview.watchers[0].position)
		assert(root.get_texture().get_image().save_png(OUTPUT+"campfire_frames/frame_%02d.png" % index) == OK)
		await create_timer(.1).timeout
	assert(fire_frames.size() == 8 and king_frames.size() >= 1 and watcher_frames.size() >= 4)
	assert(origins[0] != origins[30], "Rootling poses animate but actor doesn't walk")
	assert(save.get_profile_path() == "user://campfire_title_review.json")
	FileAccess.open(OUTPUT+"motion.json",FileAccess.WRITE).store_string(JSON.stringify({"fire_frames":fire_frames.size(),"king_poses":king_frames.size(),"watcher_poses":watcher_frames.size(),"native_frames":80,"scene_shift":false,"profile":save.get_profile_path()},"\t"))
	print("CAMPFIRE_PREVIEW: 80 native captures, actual8 flame frames, King/Rootling poses and displacement; stable background; isolated storage")
	title.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	quit()
