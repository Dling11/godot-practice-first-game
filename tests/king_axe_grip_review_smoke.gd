extends "res://tools/launch_king_axe_grip_review.gd"

const OUT := "res://art_source/review/combat/king_axe_grip_2026_10_04/"
var checks := 0
var failures := 0

func check(condition: bool,message: String) -> void:
	checks += 1
	if not condition:
		failures += 1
		push_error(message)

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Proof can save")
	check(POSES.has_valid_layout(),"Pose definition invalid")
	var invalid := POSES.duplicate()
	invalid.columns = 1
	check(not invalid.has_valid_layout(),"Invalid atlas stride accepted")
	invalid = POSES.duplicate()
	invalid.phase_windows = PackedVector2Array([Vector2(0,3),Vector2(3,5),Vector2(6,7)])
	check(not invalid.has_valid_layout(),"Overlapping phase windows accepted")
	invalid = POSES.duplicate()
	invalid.weapon_handle_axis = Vector2.ZERO
	check(not invalid.has_valid_layout(),"Undefined handle orientation accepted")
	check(not stage.player.is_physics_processing(),"One-direction proof allows fake locomotion")
	check(not stage.player.get_node("VisualRoot/Body").visible,"Baked sword body remains visible")
	check(not axe_presenter.is_processing() and not axe_presenter.is_physics_processing(),"Idle presentation polls per frame")
	for texture: Texture2D in [POSES.body_atlas,POSES.hand_atlas,POSES.weapon_texture]:
		var picture := texture.get_image()
		var binary := true
		for y in picture.get_height():
			for x in picture.get_width():
				var alpha := picture.get_pixel(x,y).a
				if alpha != 0 and alpha != 1: binary = false
		check(binary,"Fractional alpha in registered proof")
	for index in 8:
		axe_presenter.set_pose(index)
		var grip: Vector2 = axe_presenter.weapon_rig.transform * POSES.weapon_primary_grip + axe_presenter.weapon_rig.transform.basis_xform(axe_presenter.weapon_sprite.position)
		var wanted: Vector2 = POSES.primary_hands[index]-Vector2(POSES.cell_size)*0.5
		check(grip.distance_to(wanted)<0.001,"Primary grip detached")
		var axis: Vector2 = axe_presenter.weapon_rig.transform.basis_xform(POSES.weapon_handle_axis).normalized()
		var hands: Vector2 = (POSES.secondary_hands[index]-POSES.primary_hands[index]).normalized()
		check(axis.dot(hands)>0.999,"Support hand not along rigid handle")
		check(axe_presenter.weapon_sprite.texture==POSES.weapon_texture and axe_presenter.weapon_sprite.scale==Vector2.ONE,"Weapon redrawn/resized per pose")
		var bounds := axe_presenter.body_sprite.texture.get_image().get_used_rect()
		check(bounds.end.y in [96,97] and bounds.position.x>0 and bounds.end.x<192,"Foot registration or body clipping")
	axe_presenter.set_pose(0)
	place_target()
	await create_timer(0.15).timeout
	var health: HealthComponent = contact_target.get_node("HealthComponent")
	var before := health.current_health
	strike()
	check(axe_presenter.pose_index==0,"Wind-up starts at wrong pose")
	check(not stage.player.attack_component.request_attack(Vector2.LEFT),"Busy cut accepts retarget")
	await create_timer(0.10).timeout
	check(health.current_health==before,"Damage before contact phase")
	check(axe_presenter.pose_index in [1,2],"Wind-up fails to advance")
	toggle_pause()
	var held := axe_presenter.pose_index
	await create_timer(0.12,true).timeout
	check(axe_presenter.pose_index==held and health.current_health==before,"Pause advances pose/contact")
	toggle_pause()
	for tick in 60:
		await physics_frame
		await process_frame
		if stage.player.attack_component.phase==MeleeAttackComponent.Phase.ACTIVE: break
	check(axe_presenter.pose_index in [4,5],"Contact uses non-contact pose")
	await create_timer(0.04).timeout
	check(health.current_health<before and _contacts==1,"Real contact missing or duplicates")
	await capture("contact.png")
	await wait_for_idle()
	check(axe_presenter.pose_index==0 and stage.player.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Completed cut fails to restore guard")
	strike()
	await create_timer(0.07).timeout
	stage.player.attack_component.cancel_attack()
	check(axe_presenter.pose_index==0 and not stage.player.attack_component.hitbox.monitoring,"Cancellation leaves axe/contact active")
	await create_timer(0.35).timeout
	check(axe_presenter.pose_index==0,"Canceled Tween still changes poses")
	var visual_root: Node = axe_presenter.get_parent()
	visual_root.remove_child(axe_presenter)
	check(not stage.player.attack_component.phase_changed.is_connected(axe_presenter._on_phase),"Detached presenter keeps observing attacks")
	strike()
	await wait_for_idle()
	check(axe_presenter.pose_index==0,"Detached presenter advances")
	visual_root.add_child(axe_presenter)
	strike()
	for tick in 30:
		await physics_frame
		await process_frame
		if axe_presenter.pose_index in [1,2]: break
	check(axe_presenter.pose_index in [1,2],"Reattached presenter fails to bind")
	stage.player.attack_component.cancel_attack()
	check(load("res://data/weapons/king_signature_sword.tres").combo!=null,"Proof mutates shared sword")
	contact_target.get_parent().remove_child(contact_target)
	contact_target.queue_free()
	spawn_rootling()
	await create_timer(1.15).timeout
	var foe: Rootling
	for child in stage.get_node("World/Actors").get_children():
		if child is Rootling: foe = child
	check(foe!=null and foe.get_node_or_null("EnemyRewardComponent")==null,"Rootling missing or grants rewards")
	if foe!=null:
		var start: Vector2 = foe.global_position
		await create_timer(0.15).timeout
		check(foe.global_position.distance_to(start)>1,"Review Rootling does not move")
		reposition_near_foe()
		var hp := foe.health_component.current_health
		for attempt in 8:
			strike()
			await create_timer(0.70).timeout
			if not is_instance_valid(foe) or foe.health_component.current_health<hp: break
		check(not is_instance_valid(foe) or foe.health_component.current_health<hp,"Axe cannot hit real moving foe")
	await capture("review.png")
	await gallery()
	strike()
	await reset_review()
	check(axe_presenter.pose_index==0 and _contacts==0 and not paused,"Reset keeps stale pose/contact state")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Reset restores saving")
	strike()
	stage.queue_free()
	await process_frame
	await process_frame
	print("KING_AXE_GRIP_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func capture(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+name)==OK)

func wait_for_idle() -> void:
	for tick in 120:
		await physics_frame
		await process_frame
		if stage.player.attack_component.phase==MeleeAttackComponent.Phase.IDLE: return

func gallery() -> void:
	toolbar.hide()
	var gallery_layer := CanvasLayer.new()
	gallery_layer.layer = 8
	stage.add_child(gallery_layer)
	var background := ColorRect.new()
	background.color = Color("202b30")
	background.size = Vector2(960,540)
	gallery_layer.add_child(background)
	var caption := Label.new()
	caption.text = "IRON BEARD · SAME RIGID AXE · NATIVE + 3x · RIGHT-FACING PROOF"
	caption.position = Vector2(14,8)
	caption.add_theme_font_size_override("font_size",14)
	gallery_layer.add_child(caption)
	for index in 8:
		var origin := Vector2(index%4*240,index/4*250+32)
		var label := Label.new()
		label.text = "%d · %s" % [index,["Guard","Load","Wind-up","Drive","Contact","Follow-through","Settle","Guard"][index]]
		label.position = origin+Vector2(12,218)
		label.add_theme_font_size_override("font_size",13)
		gallery_layer.add_child(label)
		for size in [0.5,1.5]:
			var sprite := Presenter.new()
			assert(sprite.configure(POSES,stage.player.attack_component,false))
			sprite.scale = Vector2.ONE*size
			sprite.position = origin+Vector2(42 if size==0.5 else 124,170 if size==0.5 else 130)
			gallery_layer.add_child(sprite)
			sprite.set_pose(index)
	await capture("poses.png")
	gallery_layer.queue_free()
	await process_frame
