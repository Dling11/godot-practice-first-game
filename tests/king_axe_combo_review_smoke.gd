extends "res://tools/launch_king_axe_grip_review.gd"

const OUT := "res://art_source/review/combat/king_axe_combo_v2_2026_10_04/"
var checks := 0
var failures := 0
var accepted_steps: Array[int] = []

func check(condition: bool,message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	check(POSES.has_valid_layout() and POSES.follow_up_clips.size()==2,"Three complete clips missing")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Combo review saves")
	check(not stage.player.is_physics_processing(),"Review allows invented walking")
	var clips: Array[Resource] = [POSES,POSES.follow_up_clips[0],POSES.follow_up_clips[1]]
	for action in 3:
		var clip = clips[action]
		axe_presenter.select_clip(clip)
		for pose in 8:
			axe_presenter.set_pose(pose)
			var grip: Vector2 = axe_presenter.weapon_rig.transform * clip.weapon_primary_grip + axe_presenter.weapon_rig.transform.basis_xform(axe_presenter.weapon_sprite.position)
			check(grip.distance_to(clip.primary_hands[pose]-Vector2(96,64))<0.001,"Grip loses contact when blade side changes")
			var shaft: Vector2 = axe_presenter.weapon_rig.transform.basis_xform(clip.weapon_handle_axis).normalized()
			check(shaft.dot((clip.secondary_hands[pose]-clip.primary_hands[pose]).normalized())>0.999,"Support hand detached")
			check(axe_presenter.weapon_sprite.texture==POSES.weapon_texture and axe_presenter.weapon_sprite.scale==Vector2.ONE,"Weapon resized/redrawn between cuts")
			var bounds := axe_presenter.body_sprite.texture.get_image().get_used_rect()
			check(bounds.end.y in [95,96,97] and bounds.position.x>0 and bounds.end.x<192,"Pose floor drifts or body clips")
			if action==2 and pose in [2,3]: check(axe_presenter.weapon_rig.get_index()==0 and axe_presenter.weapon_rig.z_index==0,"Raised axe hides face or disappears under terrain")
			if pose in [4,5]:
				var cutting_normal: Vector2 = axe_presenter.weapon_rig.transform.basis_xform(Vector2(-10,4)).normalized()
				check(cutting_normal.dot(Vector2.UP if action==1 else Vector2.DOWN)>0.35,"Blunt side leads contact instead of cutting edge")
		var image: Image = clip.body_atlas.get_image()
		check(image.get_size()==Vector2i(768,256),"Body atlas dimensions drift")
		var binary := true
		for y in image.get_height():
			for x in image.get_width():
				var a := image.get_pixel(x,y).a
				if a!=0 and a!=1: binary = false
		check(binary,"Body alpha not binary")
	axe_presenter.select_clip(POSES)
	axe_presenter.set_pose(0)
	check(clips[2].lift_pixels[2]<0 and clips[2].lift_pixels[3]<clips[2].lift_pixels[2] and clips[2].lift_pixels[4]==0,"Finisher lacks airborne-to-grounded transition")
	place_target()
	await create_timer(0.12).timeout
	stage.player.attack_component.hit_landed.connect(func(_hurt: HurtboxComponent,_info: DamageInfo) -> void:
		accepted_steps.append(stage.player.attack_component.combo_step)
		check(stage.player.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE,"Trail causes damage outside contact")
		check(axe_presenter.position==Vector2(0,-16),"Finisher deals contact damage while airborne"))
	play_combo()
	check(swing_trail._frame==-1,"Trail shows during anticipation")
	await create_timer(0.10).timeout
	toggle_pause()
	var held := axe_presenter.pose_index
	await create_timer(0.15,true).timeout
	check(axe_presenter.pose_index==held and accepted_steps.is_empty(),"Pause advances combo")
	toggle_pause()
	var saw_lift := false
	var seen_frames: Dictionary = {}
	for tick in 240:
		await physics_frame
		await process_frame
		var attack: MeleeAttackComponent = stage.player.attack_component
		if attack.combo_step==2 and axe_presenter.position.y<-16: saw_lift = true
		if attack.phase==MeleeAttackComponent.Phase.ACTIVE:
			seen_frames["%d/%d" % [attack.combo_step,swing_trail._frame]] = true
			check(swing_trail._row==attack.combo_step,"Wrong swing family for accepted cut")
		elif swing_trail._frame>=0:
			check(false,"White contact art survives inactive hitbox")
		if accepted_steps.size()==3 and attack.phase==MeleeAttackComponent.Phase.IDLE and _auto_cuts_left==0: break
	check(accepted_steps==[0,1,2],"Combo hits duplicate or skip a cut")
	check(saw_lift,"Hop poses never leave the planted floor")
	check(seen_frames.size()==12,"Not all twelve real-clock swing frames display")
	check(swing_trail._frame==-1 and axe_presenter.pose_index==0,"Finished combo leaves trail/lift")
	await capture("controls.png")
	play_combo()
	await create_timer(0.09).timeout
	cancel_combo()
	var contacts := accepted_steps.size()
	await create_timer(0.9).timeout
	check(accepted_steps.size()==contacts and swing_trail._frame==-1 and _auto_cuts_left==0 and _continuation.is_stopped(),"Cancel leaves queued attacks/effect")
	strike()
	strike()
	strike()
	for tick in 180:
		await physics_frame
		await process_frame
		if accepted_steps.size()>=contacts+2 and stage.player.attack_component.phase==MeleeAttackComponent.Phase.IDLE and _continuation.is_stopped(): break
	check(accepted_steps.size()==contacts+2,"Input buffer stores more than one follow-up")
	cancel_combo()
	await gallery(clips)
	check(load("res://data/weapons/king_signature_sword.tres").combo.windups[0]<0.20,"Shared production sword mutated")
	play_combo()
	await reset_review()
	check(axe_presenter.pose_index==0 and _auto_cuts_left==0 and _queued_cut==false and swing_trail._frame==-1,"Reset retains old combo")
	stage.queue_free()
	await process_frame
	print("KING_AXE_COMBO_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+name)==OK)

func gallery(clips: Array[Resource]) -> void:
	toolbar.hide()
	var layer := CanvasLayer.new()
	layer.layer = 8
	stage.add_child(layer)
	var background := ColorRect.new()
	background.size = Vector2(960,540)
	background.color = Color("202b30")
	layer.add_child(background)
	var title := Label.new()
	title.text = "AXE V2 · EDGE LEADS CUT · FOUR WHITE DRAWINGS PER ACTION · NATIVE / 3x"
	title.add_theme_font_size_override("font_size",13)
	title.position = Vector2(10,5)
	layer.add_child(title)
	for action in 3:
		for frame in 4:
			var origin := Vector2(frame*240,action*170+28)
			var label := Label.new()
			label.text = "%s · frame %d" % [["Down cut","Rising cut","Hop slam"][action],frame+1]
			label.add_theme_font_size_override("font_size",12)
			label.position = origin+Vector2(8,0)
			layer.add_child(label)
			for magnification in [1.0,3.0]:
				var group := Node2D.new()
				group.position = origin+Vector2(34 if magnification==1 else 122,100)
				group.scale = Vector2.ONE*magnification
				layer.add_child(group)
				var body := Presenter.new()
				body.configure(clips[action],stage.player.attack_component,false)
				body.position = Vector2(0,-16)
				body.scale = Vector2(0.5,0.5)
				group.add_child(body)
				var window: Vector2 = clips[action].phase_windows[1]
				body.set_pose(int(lerpf(window.x,window.y,frame/3.0)))
				var trail := SwingTrail.new()
				trail.configure(stage.player.attack_component,SWING_ART)
				group.add_child(trail)
				trail._points = (stage.player.attack_component.collision_shape.shape as ConvexPolygonShape2D).points
				trail._row = action
				trail._set_frame(frame)
	await capture("contact_gallery.png")
	layer.queue_free()
	await process_frame
