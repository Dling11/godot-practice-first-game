extends SceneTree
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const PROFILE = preload("res://data/weapons/families/twinsteel_prototype/presentation.tres")
const OUT := "res://art_source/review/combat/king_dual_close_hilt_2026_10_05/gait/"
var evidence_path := OUT
var only_up := false
var only_side := false
func _initialize() -> void: call_deferred("render_gait")
func render_gait() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://art_source/review/"): evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
		elif argument=="--facing=up": only_up=true
		elif argument=="--facing=side": only_side=true
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(360 if only_up else (480 if only_side else 960),420)
	root.content_scale_size=root.size
	var bg := ColorRect.new()
	bg.color=Color("263339")
	bg.size=Vector2(root.size)
	root.add_child(bg)
	var attack := MeleeAttackComponent.new()
	root.add_child(attack)
	var rigs: Array[Node2D] = []
	var views: Array[Vector2] = [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
	if only_up:
		views.clear()
		views.append(Vector2.UP)
	elif only_side:
		views.resize(2)
	for index in views.size():
		var facing := views[index]
		for small in [false,true]:
			var p := Presenter.new()
			var clip: Resource = PROFILE.run_for(facing)
			p.configure(clip,attack,false)
			p.position=Vector2(180 if only_up else 120+index*240,300 if small else 150)
			p.scale=Vector2.ONE*(.5 if small else 1.5)
			root.add_child(p)
			p.face_horizontal(-1 if facing==Vector2.LEFT else 1)
			p.play_locomotion(clip,48.0/110.0,true)
			rigs.append(p)
		var label := Label.new()
		label.position=Vector2(22+index*240,18)
		label.text="UP / BACK · CENTERED STRIDE" if only_up else ["RIGHT","LEFT","UP / BACK","DOWN / FRONT"][index]
		root.add_child(label)
	var note := Label.new()
	note.position=Vector2(22,355)
	note.text="3x above / actual game size below\nCentered hips · original alternating steps" if only_up else ("3x above / actual game size below\nLower-hand front sword · dark edges · tucked rear arm" if only_side else "3x above / actual game size below · compact carry · native front head, neck and torso")
	note.add_theme_font_size_override("font_size",14)
	root.add_child(note)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path+"motion_frames/"))
	var records: Array[Dictionary] = []
	var captures: Array[Image] = []
	for frame in 48:
		for rig in rigs: rig.advance_locomotion(3.0)
		await process_frame
		await RenderingServer.frame_post_draw
		captures.append(root.get_texture().get_image())
		records.append({"frame":frame,"file":"motion_frames/frame_%03d.png"%frame,"elapsed_ms":roundi(frame*3000.0/110.0),"travel_per_frame":3.0})
	for frame in captures.size(): assert(captures[frame].save_png(evidence_path+"motion_frames/frame_%03d.png"%frame)==OK)
	FileAccess.open(evidence_path+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("DUAL_GAIT: 48 native frames / ",views.size()," facings / 3x and actual size")
	quit()
