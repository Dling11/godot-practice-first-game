extends "res://tests/sanctuary_test_base.gd"

const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const PLAYER = preload("res://entities/player/player.tscn")
const WEAPON = preload("res://data/weapons/families/twinsteel_prototype/weapon.tres")
const POSES = preload("res://assets/characters/playable/king/dual_twinsteel/descending.tres")
const IDLE = preload("res://assets/characters/playable/king/dual_twinsteel/idle.tres")
const RUN = preload("res://assets/characters/playable/king/dual_twinsteel/run.tres")
const Trail = preload("res://gameplay/presentation/axe_swing_trail.gd")
const StepMotion = preload("res://gameplay/movement/melee_step_motion.gd")
const OUT := "res://art_source/review/combat/king_dual_twinsteel_2026_10_05/"
var actors: Array[Player] = []
var presenters: Array[Node2D] = []
var began: Array[Array] = [[],[],[]]
var pending: Array[bool] = [false,false,false]
var timeline: Array[Dictionary] = []
var images: Array[Image] = []

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(1000,650)
	root.content_scale_size = root.size
	var bg := ColorRect.new()
	bg.color = Color("263339")
	bg.size = Vector2(root.size)
	root.add_child(bg)
	for spec in [[Vector2(25,18),"TWINSTEEL / right · five linked cuts"],[Vector2(525,18),"TWINSTEEL / left · same grips and reach"],[Vector2(25,445),"Actual game size"],[Vector2(525,445),"Run · legs exchange with travel"]]:
		var label := Label.new()
		label.position = spec[0]
		label.text = spec[1]
		root.add_child(label)
	var locations := [Vector2(220,270),Vector2(780,270),Vector2(175,540)]
	for index in 3:
		var actor: Player = PLAYER.instantiate()
		actor.position = locations[index]
		actor.scale = Vector2.ONE*(3.0 if index<2 else 1.0)
		actor.movement_bounds = Rect2(0,0,2000,1000)
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.set_weapon_definition(WEAPON),"Prototype weapon rejected")
		actor.get_node("VisualRoot/Body").hide()
		var legacy := actor.get_node("GreatswordEffects")
		if actor.attack_component.phase_changed.is_connected(legacy._on_attack_phase): actor.attack_component.phase_changed.disconnect(legacy._on_attack_phase)
		legacy.hide()
		actor.facing_direction = Vector2.LEFT if index==1 else Vector2.RIGHT
		var p := Presenter.new()
		p.continuation_requested = func() -> bool: return pending[index]
		p.continuation_pending = func() -> bool: return pending[index]
		check(p.configure(POSES,actor.attack_component),"Dual presenter rejected")
		check(p.configure_idle(IDLE),"Dual carry rejected")
		p.position = Vector2(0,-16)
		p.scale = Vector2.ONE*.5
		p.face_horizontal(actor.facing_direction.x)
		actor.get_node("VisualRoot").add_child(p)
		var trail := Trail.new()
		trail.configure(actor.attack_component,load("res://assets/characters/playable/king/dual_twinsteel/swing.png"))
		trail.rows = 5
		trail.origins = PackedVector2Array([Vector2(64,64),Vector2(64,64),Vector2(64,64),Vector2(64,64),Vector2(64,64)])
		trail.world_origin = Vector2(0,-16)
		trail.edge_feather_pixels = 2
		actor.add_child(trail)
		var step := StepMotion.new()
		step.actor = actor
		step.attack = actor.attack_component
		step.step_distances = PackedFloat32Array([4,4,4,0,6])
		actor.add_child(step)
		actor.attack_component.attack_started.connect(func() -> void:
			began[index].append(actor.attack_component.combo_step)
			pending[index] = actor.attack_component.combo_step<4
		)
		actor.attack_component.attack_finished.connect(func() -> void:
			if pending[index]: actor.attack_component.request_attack.call_deferred(actor.facing_direction)
		)
		actors.append(actor)
		presenters.append(p)
	var runner := Presenter.new()
	var dummy := MeleeAttackComponent.new()
	root.add_child(dummy)
	runner.configure(RUN,dummy,false)
	runner.position = Vector2(745,520)
	runner.scale = Vector2.ONE*1.5
	root.add_child(runner)
	runner.play_locomotion(RUN,0.36,true)
	_validate_clips(presenters[0])
	var combo: Resource = WEAPON.combo
	var seconds := 0.0
	for cut in 5: seconds += combo.windups[cut]+combo.contacts[cut]+combo.recoveries[cut]
	check(is_equal_approx(seconds,2.2),"Twinsteel chain is not 2.20 seconds")
	check(combo.is_radial(3) and not combo.is_radial(4),"Only spin may contact behind the player")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT+"motion_frames/"))
	var capture := DisplayServer.get_name()!="headless" and "--capture" in OS.get_cmdline_user_args()
	for frame in 105:
		if frame==8:
			for actor in actors: check(actor.attack_component.request_attack(actor.facing_direction),"Primary failed")
		runner.advance_locomotion(3.66)
		await process_frame
		await process_frame
		if capture:
			await RenderingServer.frame_post_draw
			images.append(root.get_texture().get_image())
		var states: Array[Dictionary] = []
		for index in 3:
			var p: Node2D = presenters[index]
			check(p.offhand_rig.visible,"Independent offhand vanished")
			check(p.offhand_sprite.texture==p.weapon_sprite.texture,"Twinsteel pair uses mismatched sprites")
			check(p.offhand_rig.position.distance_to(p.weapon_rig.position)>=4,"Two blades share one fictitious grip")
			states.append({"step":actors[index].attack_component.combo_step,"phase":actors[index].attack_component.phase,"pose":p.pose_index,"main_grip":var_to_str(p.weapon_rig.position),"offhand_grip":var_to_str(p.offhand_rig.position)})
		timeline.append({"frame":frame,"file":"motion_frames/frame_%03d.png"%frame,"elapsed_ms":roundi(frame*1000.0/30.0),"actors":states})
	for index in 3:
		check(began[index]==[0,1,2,3,4],"Chain missed a cut: "+str(began[index]))
		check(presenters[index].definition==IDLE,"Chain failed to settle to carry")
		check(actors[index].position.distance_to(locations[index]+actors[index].facing_direction*18)<.1,"Presentation changed physical travel")
	# Switching back to an existing one-blade profile hides the optional rig.
	var old: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	presenters[0].select_clip(old)
	presenters[0].set_pose(0)
	check(not presenters[0].offhand_rig.visible,"Offhand leaks into single-blade art")
	presenters[0].select_clip(IDLE)
	presenters[0].set_pose(0)
	check(presenters[0].offhand_rig.visible,"Offhand cannot return after clip swap")
	for frame in images.size(): check(images[frame].save_png(OUT+"motion_frames/frame_%03d.png"%frame)==OK,"Capture failed")
	FileAccess.open(OUT+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	FileAccess.open(OUT+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"frames":images.size(),"chain_seconds":seconds,"independent_blades":true,"campaign_integrated":false},"\t")+"\n")
	for actor in actors: actor.queue_free()
	runner.queue_free()
	dummy.queue_free()
	await process_frame
	print("TWINSTEEL_MOTION checks=%d failures=%d"%[checks,failures])
	quit(1 if failures else 0)

func _validate_clips(p: Node2D) -> void:
	var clips: Array[Resource] = [POSES]
	clips.append_array(POSES.follow_up_clips)
	clips.append(IDLE)
	clips.append(RUN)
	for clip in clips:
		check(clip.has_valid_layout(),"Invalid dual pose layout")
		var image: Image = clip.body_atlas.get_image()
		for key in clip.pose_count:
			p.select_clip(clip)
			p.set_pose(key)
			check(p.weapon_rig.position.is_equal_approx(clip.primary_hands[key]-Vector2(96,64)),"Main grip detached")
			check(p.offhand_rig.position.is_equal_approx(clip.offhand.hands[key]-Vector2(96,64)),"Offhand grip detached")
			var cell := Vector2i(key%4,key/4)*Vector2i(192,128)
			for grip in [clip.primary_hands[key],clip.offhand.hands[key]]:
				var color := image.get_pixelv(cell+Vector2i(grip))
				check(color.a>.65 and color.r>color.g*1.35 and color.g>color.b*1.25,"Hilt is not on a drawn brown glove")
			if clip==IDLE or clip==RUN:
				var main_tip: Vector2 = p._weapon_basis_for(key)*(clip.weapon_tip-clip.weapon_primary_grip)
				var off_tip: Vector2 = clip.offhand.basis_for(key,clip.cell_size)*(clip.offhand.tip-clip.offhand.grip)
				check(main_tip.y<=30 and off_tip.y<=30,"Carry/run sword tip pierces the registered sole plane")
		for property in ["hands","axes","behind_body","visible_poses"]:
			var damaged: Resource = clip.offhand.duplicate()
			damaged.set(property,damaged.get(property).slice(0,1))
			check(not damaged.has_valid_layout(clip.pose_count,clip.cell_size),"Malformed offhand accepted")
	for cut in 4:
		var a: Resource = clips[cut]
		var b: Resource = clips[cut+1]
		check(a.primary_hands[12]==b.primary_hands[0] and a.offhand.hands[12]==b.offhand.hands[0],"Both blade grips must inherit the queued endpoint")
		check(a.body_atlas.get_image().get_region(Rect2i(0,384,192,128)).get_data()==b.body_atlas.get_image().get_region(Rect2i(0,0,192,128)).get_data(),"Full-body queue endpoint snaps")
	p.select_clip(IDLE)
	p.set_pose(0)
