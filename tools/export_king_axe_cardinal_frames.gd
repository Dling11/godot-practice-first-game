extends SceneTree

## Native rendered pose sheets include the rigid axe and foreground glove.
const PROFILE = preload("res://data/weapons/families/iron_beard/presentation.tres")
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
var output := "res://art_source/review/combat/king_axe_head_thrust_2026_10_06/"
const NAMES := ["CHOP","RISING CUT","HEAD THRUST","HOP SLAM","WHIRLWIND"]

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://art_source/review/"): output=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(2340,900)
	root.content_scale_size=root.size
	var background := ColorRect.new()
	background.size=Vector2(root.size)
	background.color=Color("263339")
	root.add_child(background)
	var attack := MeleeAttackComponent.new()
	root.add_child(attack)
	var presenters: Array[Node2D] = []
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output))
	for direction in [Vector2.UP,Vector2.DOWN,Vector2.RIGHT]:
		var clip: Resource = PROFILE.attack_for(direction)
		var chain: Array[Resource] = [clip]
		chain.append_array(clip.follow_up_clips)
		for cut in chain.size():
			for key in chain[cut].pose_count:
				var label := Label.new()
				label.position=Vector2(key*180+6,cut*180+5)
				label.text=NAMES[cut]+" / "+str(key+1)+(" Q" if key>=10 else "")
				label.add_theme_font_size_override("font_size",10)
				root.add_child(label)
				var p := Presenter.new()
				if not p.configure(chain[cut],attack,false): quit(1); return
				p.position=Vector2(key*180+90,cut*180+102)
				p.scale=Vector2.ONE*1.2
				root.add_child(p)
				p.set_pose(key)
				presenters.append(p)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var facing := "up" if direction==Vector2.UP else ("down" if direction==Vector2.DOWN else "side")
		if root.get_texture().get_image().save_png(output+facing+"_attacks.png")!=OK: quit(1); return
		for p in presenters:
			root.remove_child(p)
			p.queue_free()
		presenters.clear()
		for child in root.get_children():
			if child is Label: root.remove_child(child); child.queue_free()
	await process_frame
	print("AXE_FRAME_SHEETS rendered195 complete body/axe/grip poses")
	quit()
