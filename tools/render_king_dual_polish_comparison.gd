extends SceneTree
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const PROFILE = preload("res://data/weapons/families/twinsteel_prototype/presentation.tres")
const OUT := "res://art_source/review/combat/king_dual_close_hilt_2026_10_05/"
var evidence_path := OUT
func _initialize() -> void: call_deferred("render_comparison")
func render_comparison() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://art_source/review/"): evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(1280,870)
	root.content_scale_size=root.size
	var bg := ColorRect.new()
	bg.color=Color("263339")
	bg.size=Vector2(root.size)
	root.add_child(bg)
	var dummy := MeleeAttackComponent.new()
	root.add_child(dummy)
	for row in 4:
		var facing: Vector2 = [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN][row]
		var clip: Resource = PROFILE.run_for(facing)
		label_at(Vector2(12,row*160+8),["RIGHT / eight actual strides","LEFT / mirrored complete body","UP / back stride","DOWN / front stride"][row])
		for key in 8:
			var p := Presenter.new()
			p.configure(clip,dummy,false)
			p.position=Vector2(80+key*160,105+row*160)
			p.scale=Vector2.ONE*1.5
			root.add_child(p)
			p.face_horizontal(-1 if row==1 else 1)
			p.set_pose(key)
	label_at(Vector2(12,672),"3x gameplay scale / compact hip carry / tiny cardinal tilt / original running legs")
	var specs := [
		["AXE side / 57px",load("res://assets/characters/playable/king/axe_proof_v3/carry.tres")],
		["GS side / 54px",load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")],
		["GS up / 44px",load("res://assets/characters/playable/king/greatsword_readability/up/idle.tres")],
		["GS down / 45px",load("res://assets/characters/playable/king/greatsword_readability/down/idle.tres")],
		["DUAL side / 54px",PROFILE.idle_poses],["DUAL back / 54px",PROFILE.upward_idle_poses],["DUAL front / native 53px",PROFILE.downward_idle_poses]]
	for index in specs.size():
		var p := Presenter.new()
		p.configure(specs[index][1],dummy,false)
		p.position=Vector2(85+index*180,795)
		p.scale=Vector2.ONE*1.5
		root.add_child(p)
		p.set_pose(0)
		label_at(Vector2(12+index*180,835),specs[index][0])
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(evidence_path+"gait_and_scale.png")==OK)
	print("DUAL_COMPARISON: four gait rows and heavy-family scale audit rendered")
	quit()
func label_at(point: Vector2,value: String) -> void:
	var label := Label.new()
	label.position=point
	label.text=value
	label.add_theme_font_size_override("font_size",12)
	root.add_child(label)
