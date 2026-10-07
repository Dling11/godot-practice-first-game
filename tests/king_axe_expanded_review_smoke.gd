extends "res://tools/launch_king_axe_expanded_review.gd"

const OUT := "res://art_source/review/combat/king_axe_head_thrust_2026_10_06/side_review/"
var checks := 0
var failures := 0
var contacts: Dictionary = {}

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	await super._run()
	root.size = Vector2i(1280,720)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var attack: MeleeAttackComponent = stage.player.attack_component
	check(EXPANDED_POSES.has_valid_layout() and EXPANDED_POSES.follow_up_clips.size()==4,"Five valid attack clips missing")
	check(axe_presenter.definition==CARRY_POSES and not axe_presenter._resting,"Default pose still raised")
	check(not axe_presenter.is_processing() and not axe_presenter.is_physics_processing(),"Idle polls")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Review can save")
	check(not stage.player.is_physics_processing(),"Preview pretends to have locomotion")
	var clips: Array[Resource] = [EXPANDED_POSES]
	clips.append_array(EXPANDED_POSES.follow_up_clips)
	clips.append(CARRY_POSES)
	for clip in clips:
		axe_presenter.select_clip(clip)
		for pose in clip.pose_count:
			axe_presenter.set_pose(pose)
			var grip: Vector2 = axe_presenter.weapon_rig.transform * Vector2.ZERO
			check(grip.distance_to(clip.primary_hands[pose]-Vector2(96,64))<0.001,"Primary grip detached")
			check(axe_presenter.weapon_sprite.texture==POSES.weapon_texture and axe_presenter.weapon_sprite.scale==Vector2.ONE,"Canonical axe changed scale")
			var bounds := axe_presenter.body_sprite.texture.get_image().get_used_rect()
			check(bounds.end.y in [95,96,97] and bounds.position.x>0 and bounds.end.x<192,"Foot drift or clipped body")
			if not clip.single_hand_poses[pose]:
				var shaft: Vector2 = axe_presenter.weapon_rig.transform.basis_xform(clip.weapon_handle_axis).normalized()
				check(shaft.dot((clip.secondary_hands[pose]-clip.primary_hands[pose]).normalized())>0.999,"Supporting grip detached")
			if clip==CARRY_POSES and pose>=4: check(axe_presenter.weapon_rig.get_index()==0,"Resting axe not behind body")
		var img: Image = clip.body_atlas.get_image()
		var binary := true
		for y in img.get_height():
			for x in img.get_width():
				if img.get_pixel(x,y).a not in [0.0,1.0]: binary = false
		check(binary,"Nonbinary body alpha")
	stage.player.attack_component.cancel_attack()
	axe_presenter._rest_timer.start(0.15)
	toggle_pause()
	await create_timer(0.25,true).timeout
	check(not axe_presenter._resting,"Pause advances AFK timer")
	toggle_pause()
	await create_timer(0.75).timeout
	check(axe_presenter._resting and axe_presenter.pose_index==7 and axe_presenter.definition==CARRY_POSES,"AFK fails to stow axe")
	check(CARRY_POSES.stowed_poses[7]!=0 and axe_presenter.hand_sprite.texture.get_image().get_used_rect().size==Vector2i.ZERO,"Rest still grips a raised axe")
	await capture("rest.png")
	var visual: Node = axe_presenter.get_parent()
	visual.remove_child(axe_presenter)
	check(axe_presenter._rest_timer.is_stopped() and not attack.phase_changed.is_connected(axe_presenter._on_phase),"Detached idle timer/observer remains live")
	visual.add_child(axe_presenter)
	await process_frame
	check(not axe_presenter._rest_timer.is_stopped() and attack.phase_changed.is_connected(axe_presenter._on_phase),"Reattached carry fails to resume idle")
	var rear := make_target(Vector2(-55,0))
	var outside := make_target(Vector2(104,0))
	await create_timer(0.12).timeout
	attack.hit_landed.connect(record_hit)
	play_combo()
	check(not axe_presenter._resting and axe_presenter.definition==EXPANDED_POSES,"Strike cannot draw from rest")
	var seen: Dictionary = {}
	var air := false
	for tick in 420:
		await physics_frame
		await process_frame
		if attack.combo_step==3 and axe_presenter.position.y<-16: air = true
		if attack.phase==MeleeAttackComponent.Phase.ACTIVE:
			seen["%d/%d" % [attack.combo_step,swing_trail._frame]] = true
			check(swing_trail._row==attack.combo_step,"Trail row mismatches move")
			if attack.combo_step==4: check(attack.hitbox._uses_radial_direction,"Spin knockback is not radial")
		else: check(swing_trail._frame==-1,"Trail outlives hitbox")
		if attack.phase==MeleeAttackComponent.Phase.IDLE and _auto_cuts_left==0 and _continuation.is_stopped(): break
	for step in 5: check(contacts.get("%d/%d" % [step,contact_target.get_instance_id()],0)==1,"Distant target missed or double hit on cut %d" % step)
	for step in 4: check(not contacts.has("%d/%d" % [step,rear.get_instance_id()]),"Front cleave hits behind")
	check(contacts.get("4/%d" % rear.get_instance_id(),0)==1,"Spin misses rear target or duplicates")
	for step in 5: check(not contacts.has("%d/%d" % [step,outside.get_instance_id()]),"Attack exceeds authored range")
	check(seen.size()==20,"Not all twenty white FX frames display")
	check(air,"Hop never becomes airborne")
	check(axe_presenter.definition==CARRY_POSES and axe_presenter.pose_index==0,"Finished combo returns to raised guard")
	await capture("controls.png")
	play_combo()
	await create_timer(0.08).timeout
	cancel_combo()
	var before := contacts.size()
	await create_timer(0.8).timeout
	check(contacts.size()==before and swing_trail._frame==-1 and _continuation.is_stopped(),"Cancel retains queued attacks")
	check(axe_presenter.definition==CARRY_POSES,"Cancel fails to relax grip")
	var shared: WeaponDefinition = load("res://data/weapons/king_signature_sword.tres")
	check(shared.combo.step_count()==3 and shared.combo.hitbox_shapes.is_empty(),"Shared sword chain mutated")
	check((shared.melee_hitbox_shape as ConvexPolygonShape2D).points[3].x==36,"Shared sword reach mutated")
	check(shared.combo.hitbox_shape(4,shared.melee_hitbox_shape)==shared.melee_hitbox_shape and not shared.combo.is_radial(4),"Empty profile fallback broken")
	await gallery(clips)
	play_combo()
	await reset_review()
	check(axe_presenter.definition==CARRY_POSES and swing_trail._frame==-1 and _auto_cuts_left==0,"Reset keeps old action/pose")
	stage.queue_free()
	await process_frame
	print("KING_AXE_EXPANDED_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func record_hit(hurtbox: HurtboxComponent,info: DamageInfo) -> void:
	var attack: MeleeAttackComponent = stage.player.attack_component
	var target := hurtbox.get_parent()
	var key := "%d/%d" % [attack.combo_step,target.get_instance_id()]
	contacts[key] = contacts.get(key,0)+1
	check(attack.phase==MeleeAttackComponent.Phase.ACTIVE,"Inactive contact")
	check(axe_presenter.position==Vector2(0,-16),"Airborne hop deals ground contact")
	if attack.combo_step==4 and target.global_position.x<stage.player.global_position.x: check(info.direction.x<0,"Rear foe knocked toward wielder")

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+name)==OK)

func gallery(clips: Array[Resource]) -> void:
	toolbar.hide()
	root.content_scale_size = Vector2i(1280,1080)
	root.size = Vector2i(1280,1080)
	var layer := CanvasLayer.new()
	layer.layer = 8
	stage.add_child(layer)
	var background := ColorRect.new()
	background.size = Vector2(1280,1080)
	background.color = Color("202b30")
	layer.add_child(background)
	for action in clips.size():
		for frame in 4:
			var origin := Vector2(frame*320,action*180)
			var label := Label.new()
			label.text = "%s · %d" % [NAMES[action] if action<5 else "Low carry → back rest",frame+1]
			label.position = origin+Vector2(8,2)
			label.add_theme_font_size_override("font_size",12)
			layer.add_child(label)
			var group := Node2D.new()
			group.position = origin+Vector2(132,142)
			group.scale = Vector2.ONE*1.5
			layer.add_child(group)
			var presenter := Presenter.new()
			presenter.configure(clips[action],stage.player.attack_component,false)
			presenter.position = Vector2(0,-16)
			presenter.scale = Vector2.ONE*0.5
			group.add_child(presenter)
			var window: Vector2 = clips[action].phase_windows[1]
			presenter.set_pose(int(lerpf(window.x,window.y,frame/3.0)) if action<5 else [0,3,5,7][frame])
			if action<5:
				var trail := SwingTrail.new()
				configure_trail(trail)
				group.add_child(trail)
				var shape: Shape2D = stage.player.attack_component.weapon.combo.hitbox_shapes[action]
				if shape is CircleShape2D:
					for index in 64: trail._points.append(Vector2.from_angle(index*TAU/64.0)*shape.radius+Vector2(0,-16))
				else:
					for point in shape.points: trail._points.append(point+Vector2(0,-16))
				trail._row = action
				trail.prepare_edge_feather()
				trail._set_frame(frame)
	await capture("gallery.png")
	layer.queue_free()
	await process_frame
