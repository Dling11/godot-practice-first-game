extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const AXE = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const PLAYER = preload("res://entities/player/player.tscn")
const OUT := "res://art_source/review/combat/king_greatsword_responsive_2026_10_05/"
var actors: Array[Player] = []
var began: Array[Array] = [[],[],[],[],[]]
var images: Array[Image] = []
var timeline: Array[Dictionary] = []
var chain := true

func _run() -> void:
	root.size = Vector2i(1000,560)
	root.content_scale_size = Vector2i(1000,560)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	root.get_node("WeaponInventory").acquire_weapon(AXE)
	var background := ColorRect.new()
	background.color = Color("202b30")
	background.size = Vector2(1000,560)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(background)
	for index in 2:
		var label := Label.new()
		label.position = Vector2(index*500+18,18)
		label.text = "GREATSWORD · 3.00s / full drawn poses" if index==0 else "AXE · unchanged 3.60s benchmark"
		root.add_child(label)
	var note := Label.new()
	note.position = Vector2(18,510)
	note.text = "Same engine clock / same buffered input / actual equipped Player"
	root.add_child(note)
	var positions := [Vector2(240,350),Vector2(2000,350),Vector2(2500,350),Vector2(3000,350),Vector2(735,350)]
	var directions := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2.RIGHT]
	for index in 5:
		var actor: Player = PLAYER.instantiate()
		actor.position = positions[index]
		actor.movement_bounds = Rect2(0,0,4000,1000)
		actor.scale = Vector2.ONE*2.5
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.equip_owned_weapon(AXE if index==4 else ITEM),"Cannot equip comparison actor")
		actor._set_facing_direction(directions[index])
		actor.attack_component.attack_started.connect(func() -> void: began[index].append(actor.attack_component.combo_step))
		actor.attack_component.phase_changed.connect(func(phase: int,_seconds: float) -> void:
			if chain and phase==MeleeAttackComponent.Phase.ACTIVE and actor.attack_component.combo_step<4: actor.request_primary_attack()
			if phase==MeleeAttackComponent.Phase.RECOVERY and index<4:
				var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
				check(presenter._queued_recovery_active==(chain and actor.attack_component.combo_step<4),"Recovery ignores the actual buffer state")
		)
		actors.append(actor)
	_validate_authored_clips()
	var seconds := 0.0
	for cut in 5: seconds += ITEM.weapon_definition.combo.windups[cut]+ITEM.weapon_definition.combo.contacts[cut]+ITEM.weapon_definition.combo.recoveries[cut]
	check(is_equal_approx(seconds,3.0),"Responsive chain is not3.00s")
	DirAccess.make_dir_recursive_absolute(OUT+"motion_frames/")
	var render := DisplayServer.get_name()!="headless" and OS.get_cmdline_user_args().has("--capture")
	for frame in 130:
		if frame==8:
			for actor in actors: check(actor.request_primary_attack(),"Comparison primary refused")
		await process_frame
		await process_frame
		if render:
			await RenderingServer.frame_post_draw
			images.append(root.get_texture().get_image())
		var states: Array[Dictionary] = []
		for actor in actors:
			var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
			states.append({"step":actor.attack_component.combo_step,"phase":actor.attack_component.phase,"pose":presenter.pose_index,"grip":var_to_str(presenter.weapon_rig.position),"blade_degrees":rad_to_deg(presenter.weapon_rig.rotation)})
		timeline.append({"frame":frame,"file":"motion_frames/frame_%03d.png"%frame,"elapsed_ms":roundi(frame*1000.0/30.0),"actors":states})
	for index in 5:
		check(began[index]==[0,1,2,3,4],"Buffered input dropped a cut: "+str(began[index]))
		check(actors[index].attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Comparison did not complete")
		if index<4:
			check(actors[index].position.distance_to(positions[index]+directions[index]*46)<.1,"Presentation changed physical travel")
			check(actors[index].get_node("WeaponFamilyPresentation").presenter.definition==ITEM.weapon_definition.family_presentation.idle_for(directions[index]),"Released combo lost carry")
	# Released recovery chooses its separate authored path and ends on carry.
	chain = false
	for cut in 5:
		var actor: Player = actors[0]
		var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		var before: Transform2D = presenter.weapon_rig.transform
		var body: PackedByteArray = presenter.body_sprite.texture.get_image().get_data()
		actor.attack_component._next_combo_step = cut
		actor.request_primary_attack()
		check(before.is_equal_approx(presenter.weapon_rig.transform) and body==presenter.body_sprite.texture.get_image().get_data(),"Standalone input teleports into a prior chamber")
		while actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE:
			await physics_frame
		check(actor.get_node("WeaponFamilyPresentation").presenter.definition==ITEM.weapon_definition.family_presentation.idle_poses,"Standalone cut leaves a chamber/frozen rig")
	for frame in images.size(): check(images[frame].save_png(OUT+"motion_frames/frame_%03d.png"%frame)==OK,"Capture failed")
	FileAccess.open(OUT+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	FileAccess.open(OUT+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"rendered_frames":images.size(),"greatsword_seconds":seconds,"axe_seconds":3.6,"modular_arms":false,"steel_size":[30,140]},"\t")+"\n")
	for actor in actors: actor.queue_free()
	await process_frame
	print("Responsive greatsword: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)

func _validate_authored_clips() -> void:
	for actor in actors.slice(0,4):
		var profile: Resource = ITEM.weapon_definition.family_presentation
		var first: Resource = profile.attack_for(actor.facing_direction)
		var clips: Array[Resource] = [first]
		clips.append_array(first.follow_up_clips)
		var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		for cut in 5:
			var clip: Resource = clips[cut]
			check(clip.has_valid_layout() and clip.pose_count==12,"Invalid authored motion branch")
			check(clip.weapon_angles.is_empty() and clip.arm_upper_texture==null,"Rejected detached-arm rig remains installed")
			check(clip.weapon_texture.get_size()==Vector2(30,140),"Steel size changed")
			presenter.select_clip(clip)
			for pose in 12:
				presenter.set_pose(pose)
				var pixels: Image = presenter.body_sprite.texture.get_image()
				check(pixels.get_pixelv(Vector2i(clip.primary_hands[pose])).a>.5,"Hilt loses the drawn hand")
				check(presenter.weapon_rig.position.is_equal_approx(clip.primary_hands[pose]-Vector2(96,64)),"Weapon floats off the complete pose")
				check(is_equal_approx(absf(presenter.weapon_rig.transform.determinant()),1),"Steel is stretched")
				check(presenter.arm_rig==null and presenter.hand_sprite.visible,"Detached arms overlap complete art")
			if cut<4:
				presenter.set_pose(11)
				var pixels: PackedByteArray = presenter.body_sprite.texture.get_image().get_data()
				var basis: Transform2D = presenter.weapon_rig.transform
				presenter.select_clip(clips[cut+1])
				presenter.set_pose(0)
				check(pixels==presenter.body_sprite.texture.get_image().get_data() and basis.is_equal_approx(presenter.weapon_rig.transform),"Drawn queued handoff resets the pose")
		presenter._carry()
