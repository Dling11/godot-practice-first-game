extends SceneTree
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
var folder := "res://assets/characters/playable/king/dual_twinsteel/"
var direction := "side"
func _initialize() -> void: call_deferred("render_gallery")
func render_gallery() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--direction="): direction=argument.trim_prefix("--direction=")
	assert(direction in ["side","up","down"])
	if direction!="side": folder+=direction+"/"
	if DisplayServer.get_name()=="headless":
		push_error("Use native rendering for Twinsteel gallery")
		quit(1)
		return
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(1920,1000)
	root.content_scale_size = root.size
	var bg := ColorRect.new()
	bg.color = Color("263339")
	bg.size = Vector2(root.size)
	root.add_child(bg)
	var attack := MeleeAttackComponent.new()
	root.add_child(attack)
	for row in 5:
		var clip: Resource = load(folder+["descending","rising","scissors","spin","cross_finish"][row]+".tres")
		for key in 10:
			var presenter := Presenter.new()
			presenter.configure(clip,attack,false)
			presenter.position = Vector2(96+key*192,95+row*200)
			presenter.scale = Vector2.ONE*1.5
			root.add_child(presenter)
			presenter.set_pose(key)
			var label := Label.new()
			label.text = "%s / %d"%[["DOWN","RISE","CROSS","SPIN","X FINISH"][row],key]
			label.position = Vector2(8+key*192,row*200+170)
			root.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	var out := "res://art_source/review/combat/king_dual_twinsteel_2026_10_05/"
	if direction!="side": out="res://art_source/review/combat/king_dual_twinsteel_cardinal_2026_10_05/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(out))
	assert(root.get_texture().get_image().save_png(out+("gallery.png" if direction=="side" else direction+"_gallery.png"))==OK)
	print("TWINSTEEL_GALLERY rendered 50 assembled body / blade poses")
	quit()
