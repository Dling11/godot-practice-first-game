extends "res://tools/launch_king_greatsword_review.gd"

const OUT := "res://art_source/review/combat/king_huge_greatsword_2026_10_04/"
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
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var actor: Player = stage.player
	var attack: MeleeAttackComponent = actor.attack_component
	var clips: Array[Resource] = [GREAT_POSES]
	clips.append_array(GREAT_POSES.follow_up_clips)
	check(clips.size()==4,"Four moves missing")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Review can save")
	for clip in clips:
		check(clip.has_valid_layout(),"Invalid clip")
		axe_presenter.select_clip(clip)
		for pose in 8:
			axe_presenter.set_pose(pose)
			var grip: Vector2 = axe_presenter.weapon_rig.transform*Vector2.ZERO
			check(grip.distance_to(clip.primary_hands[pose]-Vector2(96,64))<0.001,"Primary grip detached")
			var axis: Vector2 = axe_presenter.weapon_rig.transform.basis_xform(clip.weapon_handle_axis).normalized()
			check(axis.dot((clip.secondary_hands[pose]-clip.primary_hands[pose]).normalized())>0.999,"Shaft misaligned")
			check(axe_presenter.weapon_sprite.texture==GREAT_POSES.weapon_texture and axe_presenter.weapon_sprite.scale==Vector2.ONE,"Rigid sword changes shape")
			var bounds := axe_presenter.body_sprite.texture.get_image().get_used_rect()
			check(bounds.end.y in [95,96,97] and bounds.position.x>0 and bounds.end.x<192,"Clipped body or foot registration drift")
			var body_image := axe_presenter.body_sprite.texture.get_image()
			check(body_image.get_pixelv(Vector2i(clip.primary_hands[pose])).a>0 and body_image.get_pixelv(Vector2i(clip.secondary_hands[pose])).a>0,"Hand anchor outside authored body: %s/%d" % [clip.resource_path,pose])
	attack.cancel_attack()
	var origin := actor.global_position
	var outside := make_target(Vector2(200,0))
	place_crowd()
	await create_timer(0.12).timeout
	attack.hit_landed.connect(record_hit)
	play_combo()
	var seen: Dictionary = {}
	var air := false
	for tick in 420:
		await physics_frame
		await process_frame
		if attack.combo_step==2 and axe_presenter.position.y<=-33.9: air = true
		if attack.phase==MeleeAttackComponent.Phase.ACTIVE:
			seen["%d/%d" % [attack.combo_step,swing_trail._frame]] = true
			check(axe_presenter.position.y==-16,"Jump deals damage before landing")
		else: check(swing_trail._frame==-1,"Inactive trail remains")
		if attack.phase==MeleeAttackComponent.Phase.IDLE and _auto_cuts_left==0 and _continuation.is_stopped(): break
	for step in 4:
		for target in [contact_target]+extra_targets:
			check(contacts.get("%d/%d" % [step,target.get_instance_id()],0)==1,"Missing/duplicate crowd hit step %d" % step)
		check(not contacts.has("%d/%d" % [step,outside.get_instance_id()]),"Hit exceeds reach")
	check(seen.size()==16,"Missing slash animation frames")
	check(air,"No eighteen-pixel jump")
	check(absf(actor.global_position.x-origin.x-38)<0.1,"Physical steps don't total 38px: %s" % (actor.global_position-origin))
	check(impact_presenter.bursts_created==5,"Crowd creates excessive or missing impact bursts: %d" % impact_presenter.bursts_created)
	check(Geometry2D.is_point_in_polygon(impact_presenter.ground_offset,attack.weapon.combo.hitbox_shapes[2].points),"Ground impact exceeds slam contact")
	try_slam()
	while attack.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
	await physics_frame
	paused = true
	await process_frame
	var burst: ImpactPresenter.Burst = impact_presenter.get_child(0)
	var frozen_frame := burst.frame
	await create_timer(0.15,true).timeout
	check(burst.frame==frozen_frame,"Pause advances impact frames")
	paused = false
	cancel_combo()
	check(impact_presenter.get_child_count()==0 and swing_trail._frame==-1,"Cancel leaves active impact")
	check(not step_motion.is_physics_processing() and not axe_presenter.is_processing(),"Idle processing remains")
	play_combo()
	await create_timer(0.18).timeout
	paused = true
	var held := actor.global_position
	var held_pose := axe_presenter.pose_index
	await create_timer(0.2,true).timeout
	check(actor.global_position==held and axe_presenter.pose_index==held_pose,"Pause advances step/body")
	paused = false
	cancel_combo()
	await create_timer(0.5).timeout
	check(actor.global_position==held and not step_motion.is_physics_processing() and impact_presenter.get_child_count()==0,"Cancel retains motion/effects")
	var wall := StaticBody2D.new()
	wall.collision_layer = actor.collision_mask
	wall.position = actor.global_position+Vector2(10,0)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(2,80)
	collision.shape = rectangle
	wall.add_child(collision)
	stage.get_node("World").add_child(wall)
	await physics_frame
	var before_wall := actor.global_position
	strike()
	await create_timer(0.4).timeout
	check(step_motion.blocked and actor.global_position.x-before_wall.x<8,"Step crosses wall")
	cancel_combo()
	wall.queue_free()
	await physics_frame
	var bounds := actor.movement_bounds
	actor.movement_bounds = Rect2(actor.global_position-Vector2(20,20),Vector2(22,40))
	strike()
	await create_timer(0.4).timeout
	check(step_motion.blocked and actor.global_position.x<=actor.movement_bounds.end.x+0.001,"Step exceeds bounds")
	cancel_combo()
	actor.movement_bounds = bounds
	var shared: WeaponDefinition = load("res://data/weapons/king_signature_sword.tres")
	check(shared.combo.step_count()==3 and shared.combo.hitbox_shapes.is_empty() and shared.melee_hitbox_shape.points[3].x==36,"Normal sword mutated")
	var default_definition := load("res://data/weapons/weapon_family_pose_definition.gd").new() as Resource
	default_definition.body_atlas = GREAT_POSES.body_atlas
	default_definition.hand_atlas = GREAT_POSES.hand_atlas
	default_definition.weapon_texture = GREAT_POSES.weapon_texture
	default_definition.primary_hands = GREAT_POSES.primary_hands
	default_definition.secondary_hands = GREAT_POSES.secondary_hands
	default_definition.lift_pixels[0] = -36
	check(not default_definition.has_valid_layout(),"Default lift limit changed")
	default_definition.maximum_lift_pixels = 48
	check(default_definition.has_valid_layout(),"Authored larger jump fails validation")
	await gallery(clips)
	await reset_review()
	check(step_motion!=null and not step_motion.is_physics_processing() and axe_presenter.definition==GREAT_POSES,"Reset retains old motion")
	stage.queue_free()
	await process_frame
	print("KING_HUGE_GREATSWORD_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func record_hit(hurtbox: HurtboxComponent,_info: DamageInfo) -> void:
	var attack: MeleeAttackComponent = stage.player.attack_component
	var key := "%d/%d" % [attack.combo_step,hurtbox.get_parent().get_instance_id()]
	contacts[key] = contacts.get(key,0)+1
	check(attack.phase==MeleeAttackComponent.Phase.ACTIVE and axe_presenter.position.y==-16,"Contact before grounded ACTIVE")

func gallery(clips: Array[Resource]) -> void:
	toolbar.hide()
	root.content_scale_size = Vector2i(1280,1000)
	root.size = Vector2i(1280,1000)
	var layer := CanvasLayer.new()
	layer.layer = 8
	stage.add_child(layer)
	var background := ColorRect.new()
	background.size = Vector2(1280,1000)
	background.color = Color("202b30")
	layer.add_child(background)
	for action in 4:
		for frame in 4:
			var origin := Vector2(frame*320,action*250)
			var label := Label.new()
			label.text = "%s / pose %d" % [NAMES[action],[0,3,5,7][frame]]
			label.position = origin+Vector2(8,4)
			layer.add_child(label)
			var group := Node2D.new()
			group.position = origin+Vector2(145,180)
			group.scale = Vector2.ONE*2
			layer.add_child(group)
			var presenter := Presenter.new()
			assert(presenter.configure(clips[action],stage.player.attack_component,false))
			presenter.position = Vector2(0,-16)
			presenter.scale = Vector2.ONE*0.5
			group.add_child(presenter)
			presenter.set_pose([0,3,5,7][frame])
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(OUT+"gallery.png")==OK)
	layer.queue_free()
	await process_frame
