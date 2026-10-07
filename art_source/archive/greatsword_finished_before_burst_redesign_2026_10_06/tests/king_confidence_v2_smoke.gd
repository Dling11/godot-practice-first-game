extends "res://tools/launch_king_greatsword_confidence_review.gd"

const OUT := "res://art_source/review/combat/king_greatsword_readability_2026_10_05/preserved/"
const AXE_RUN = preload("res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres")
var checks := 0
var failures := 0
var contacts := 0

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	await super._run()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var actor: Player = stage.player
	var attack: MeleeAttackComponent = actor.attack_component
	for clip in [PRIDE_POSES,RUN_POSES,AXE_RUN]:
		check(clip.has_valid_layout(),"Invalid registered clip")
		axe_presenter.select_clip(clip)
		var hashes: Dictionary = {}
		for pose in 8:
			axe_presenter.set_pose(pose)
			var image := axe_presenter.body_sprite.texture.get_image()
			var bounds := image.get_used_rect()
			check(bounds.end.y>=90 and bounds.end.y<=101 and bounds.position.x>0 and bounds.end.x<192,"Foot drift/clipped pose")
			hashes[hash(image.get_data())] = true
			if not clip.stowed_poses[pose] and not clip.released_poses[pose]:
				check(image.get_pixelv(Vector2i(clip.primary_hands[pose])).a>0,"Detached primary hand")
			if clip.released_poses[pose]: check(axe_presenter.hand_sprite.texture.get_image().get_used_rect().size==Vector2i.ZERO,"Crossed arms still grips blade")
		check(hashes.size()>=7,"Run/action has duplicated stationary anatomy")
	cancel_combo()
	# Desktop focus loss intentionally cancels review locomotion. Regain focus
	# after the manual cel audit before testing real timed movement.
	root.grab_focus()
	await process_frame
	var origin := actor.global_position
	horizontal_motion.set_direction(1)
	# Locomotion is physics-driven. A render-clock timer can expire before
	# 0.65s of physics travel on a busy native renderer (31 rather than39 ticks).
	for tick in 40: await physics_frame
	check(actor.global_position.x-origin.x>50 and axe_presenter.definition==RUN_POSES and axe_presenter._running,"No genuine right running")
	check(axe_presenter.weapon_sprite.texture==GREAT_POSES.weapon_texture and axe_presenter.weapon_sprite.scale==Vector2.ONE,"Running changes sword proportions")
	var stride := axe_presenter._locomotion_distance
	horizontal_motion.set_direction(-1)
	check(is_equal_approx(stride,axe_presenter._locomotion_distance),"Facing change resets stride")
	horizontal_motion.set_direction(1)
	for index in 8:
		check(RUN_POSES.primary_hands[index].x>=93 and RUN_POSES.primary_hands[index].x<=94 and RUN_POSES.secondary_hands[index]-RUN_POSES.primary_hands[index]==Vector2(8,4),"Sword shoulder/shaft still jumps across run frames")
		check(RUN_POSES.weapon_behind_body[index]==0,"Held run handle hidden by body")
	paused = true
	var held := actor.global_position
	var held_pose := axe_presenter.pose_index
	await create_timer(0.2,true).timeout
	check(actor.global_position==held and axe_presenter.pose_index==held_pose,"Pause advances run")
	paused = false
	horizontal_motion.stop_and_clear()
	check(not horizontal_motion.is_physics_processing() and axe_presenter.definition==PRIDE_POSES,"Run never returns to one-hand carry")
	horizontal_motion.set_direction(-1)
	await create_timer(0.2).timeout
	horizontal_motion.stop_and_clear()
	check(actor.global_position.x<held.x and actor.facing_direction==Vector2.LEFT and axe_presenter.scale.x<0,"Mirrored left run wrong")
	place_target()
	attack.hit_landed.connect(func(_hurtbox: HurtboxComponent,_info: DamageInfo) -> void: contacts += 1)
	strike()
	await create_timer(0.92).timeout
	check(contacts==1 and attack.get_attack_direction()==Vector2.LEFT,"Left attack contact/facing wrong")
	cancel_combo()
	actor.facing_direction = Vector2.RIGHT
	axe_presenter.face_horizontal(1)
	proud_idle()
	await create_timer(0.6).timeout
	check(axe_presenter._resting and axe_presenter.pose_index==7 and axe_presenter.definition==PRIDE_POSES,"Pride idle missing")
	check(PRIDE_POSES.primary_hands[5]==PRIDE_POSES.primary_hands[7] and PRIDE_POSES.secondary_hands[5]==PRIDE_POSES.secondary_hands[7],"Planted sword drifts as arms fold")
	check(PRIDE_POSES.ground_clipped_poses[7]>0 and axe_presenter.weapon_rig.transform.y.y<0 and absf(axe_presenter.weapon_rig.transform.y.x)<0.01,"Pride blade isn't upright")
	check(is_instance_valid(_plant_marker) and absf(_plant_marker.position.y)<0.01 and _plant_marker.position.x<0,"Plant marker isn't beside left foot on ground")
	check(impact_presenter.bursts_created==2,"Plant burst missing or damage effect duplicated")
	await capture("pride.png")
	strike()
	check(axe_presenter._drawing and attack.phase==MeleeAttackComponent.Phase.IDLE,"Pride attacks before retrieving sword")
	paused = true
	await create_timer(0.16,true).timeout
	check(attack.phase==MeleeAttackComponent.Phase.IDLE and axe_presenter._drawing,"Paused retrieval starts attack")
	paused = false
	cancel_combo()
	await create_timer(0.4).timeout
	check(attack.phase==MeleeAttackComponent.Phase.IDLE and not axe_presenter._drawing,"Cancelled retrieval starts a ghost attack")
	proud_idle()
	await create_timer(0.6).timeout
	strike()
	await create_timer(0.31).timeout
	check(attack.phase==MeleeAttackComponent.Phase.WIND_UP and not axe_presenter._drawing,"Retrieval fails to start requested attack")
	cancel_combo()
	place_target()
	try_slam()
	while attack.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
	check(swing_trail.frame_sample_transforms.size()==4,"Slam still uses detached broad-area UVs")
	check(axe_presenter.position.y==-16,"Slam damages before feet land")
	await create_timer(0.06).timeout
	await capture("slam.png")
	cancel_combo()
	check(swing_trail._frame==-1,"Cancelled blade trail remains")
	actor.facing_direction = Vector2.LEFT
	axe_presenter.face_horizontal(-1)
	try_slam()
	while attack.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
	var ground: ImpactPresenter.Burst = impact_presenter.get_child(0)
	var tip: Vector2 = axe_presenter.get_parent().to_global(axe_presenter.get_contact_tip_in_parent())
	check(ground.row==1 and ground.global_position.distance_to(tip)<0.01 and actor.to_local(tip).x<0 and actor.to_local(tip).y>0,"Left slam ground does not meet the frontal blade tip")
	cancel_combo()
	axe_presenter.face_horizontal(1)
	await gallery()
	await reset_review()
	check(horizontal_motion.direction==0 and not horizontal_motion.is_physics_processing() and axe_presenter.definition==PRIDE_POSES,"Reset retains movement/draw state")
	stage.queue_free()
	await process_frame
	print("KING_CONFIDENCE_V2 checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+name)==OK)

func gallery() -> void:
	toolbar.hide()
	root.content_scale_size = Vector2i(1280,750)
	root.size = Vector2i(1280,750)
	var layer := CanvasLayer.new()
	layer.layer = 8
	stage.add_child(layer)
	var background := ColorRect.new()
	background.size = Vector2(1280,750)
	background.color = Color("202b30")
	layer.add_child(background)
	var clips := [PRIDE_POSES,RUN_POSES,AXE_RUN]
	var titles := ["Proud carry / plant","Greatsword run","Axe back run"]
	for row in clips.size():
		for frame in 4:
			var origin := Vector2(frame*320,row*250)
			var label := Label.new()
			label.text = titles[row]+" / "+str([0,4,5,7][frame] if row==0 else frame*2)
			label.position = origin+Vector2(8,4)
			layer.add_child(label)
			var body := Presenter.new()
			assert(body.configure(clips[row],stage.player.attack_component,false))
			body.position = origin+Vector2(145,180)-Vector2(0,32)
			body.scale = Vector2.ONE
			layer.add_child(body)
			body.set_pose([0,4,5,7][frame] if row==0 else frame*2)
	await capture("gallery.png")
	layer.queue_free()
	await process_frame
