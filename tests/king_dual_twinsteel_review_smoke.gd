extends "res://tools/launch_king_dual_twinsteel_review.gd"
var checks := 0
var failures := 0
var hits: Array[Dictionary] = []
var began: Array[int] = []
const REVIEW_OUT := "res://art_source/review/combat/king_dual_close_hilt_2026_10_05/"
var evidence_path := REVIEW_OUT
var handoff_gaps: Array[int] = []
var last_finished_tick := -1

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://art_source/review/"): evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path))
	super._initialize()

func _run() -> void:
	await super._run()
	if DisplayServer.get_name()!="headless":
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(evidence_path+"playable_review.png")
	stage.player.attack_component.hit_landed.connect(func(target: HurtboxComponent,_info: DamageInfo) -> void:
		hits.append({"target":target.get_parent().get_instance_id(),"step":stage.player.attack_component.combo_step})
	)
	stage.player.attack_component.attack_started.connect(func() -> void: began.append(stage.player.attack_component.combo_step))
	stage.player.attack_component.attack_finished.connect(func() -> void: last_finished_tick=Engine.get_physics_frames())
	stage.player.attack_component.attack_started.connect(func() -> void:
		if stage.player.attack_component.combo_step>0 and last_finished_tick>=0:
			var gap := Engine.get_physics_frames()-last_finished_tick
			handoff_gaps.append(gap)
			check(gap<=1,"Combo continuation adds a physics-timer pause")
	)
	var rear_id: int = targets[1].get_instance_id()
	var front_id: int = targets[0].get_instance_id()
	var rear_health: HealthComponent = targets[1].get_node("HealthComponent")
	var front_health: HealthComponent = targets[0].get_node("HealthComponent")
	await physics_frame
	await physics_frame
	play_combo()
	for tick in 180: await physics_frame
	check(began==[0,1,2,3,4],"Real review chain drops/repeats an input")
	check(handoff_gaps.size()==4,"Combo timing did not observe all handoffs")
	check(stage.player.attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Chain remains locked")
	check(front_health.current_health<10000,"Front target received no damage")
	check(rear_health.current_health<10000,"Spin did not hit rear target")
	var per_contact := {}
	var rear_steps: Array[int] = []
	for record in hits:
		var contact: String = "%d/%d"%[record.target,record.step]
		check(not per_contact.has(contact),"Both blades doubled one contact")
		per_contact[contact] = true
		if record.target==rear_id: rear_steps.append(record.step)
	check(rear_steps==[3],"Rear damage occurs outside the one radial spin: "+str(rear_steps))
	check(per_contact.has("%d/0"%front_id),"First cut misses the intended front lane")
	# The review owns its visible controls; hidden game menus cannot trap Tab.
	var tab := InputEventKey.new()
	tab.keycode = KEY_TAB
	tab.pressed = true
	input_controller._unhandled_input(tab)
	check(not control_column.visible and not paused,"Tab caused invisible menu/pause")
	input_controller._unhandled_input(tab)
	check(control_column.visible,"Tab cannot restore review controls")
	var esc := InputEventKey.new()
	esc.keycode = KEY_ESCAPE
	esc.pressed = true
	input_controller._unhandled_input(esc)
	check(paused and control_column.visible,"Esc pause has no visible controls")
	input_controller._unhandled_input(esc)
	check(not paused,"Esc cannot resume")
	var before: Vector2 = stage.player.position
	cardinal_motion.set_direction(Vector2.LEFT)
	for tick in 12: await physics_frame
	check(stage.player.position.x<before.x,"Review A/D cannot move")
	check(presenter._running,"Running stays on a frozen body")
	check(presenter.pose_index>0,"Gait does not respond to travel")
	cardinal_motion.stop_and_clear()
	var space := InputEventKey.new()
	space.keycode = KEY_SPACE
	space.pressed = true
	input_controller._unhandled_input(space)
	input_controller._unhandled_input(space)
	check(queued,"SPACE cannot buffer a second real input")
	await reset_review()
	for tick in 3: await physics_frame
	stage.player.attack_component.hit_landed.connect(func(target: HurtboxComponent,_info: DamageInfo) -> void:
		hits.append({"target":target.get_parent().get_instance_id(),"step":stage.player.attack_component.combo_step})
	)
	stage.player.attack_component.attack_started.connect(func() -> void: began.append(stage.player.attack_component.combo_step))
	check(not has_pending_cut(),"Reset leaves an old queued attack")
	check(not paused,"Reset leaves input paused")
	check(presenter.definition==IDLE,"Reset fails to restore paired carry")
	var cardinal_contacts: Array[Dictionary] = []
	for facing in [Vector2.UP,Vector2.DOWN,Vector2.LEFT]:
		cancel_combo()
		began.clear()
		hits.clear()
		face_and_targets(facing)
		check(presenter.definition==PROFILE.idle_for(facing),"Cardinal carry falls back to the side body")
		check(presenter.scale.x>0 or facing==Vector2.LEFT,"Vertical body was mirrored")
		for tick in 3: await physics_frame
		var rear: int = targets[1].get_instance_id()
		var front: int = targets[0].get_instance_id()
		play_combo()
		cardinal_motion.set_direction(Vector2.RIGHT)
		check(stage.player.facing_direction==facing,"Walking input turns the committed attack")
		check(presenter._default_definition==PROFILE.attack_for(facing),"Walking input swaps body midway through cut")
		cardinal_motion.stop_and_clear()
		for tick in 180: await physics_frame
		check(began==[0,1,2,3,4],"Cardinal combo missed a cut")
		check(presenter.definition==PROFILE.idle_for(facing),"Cardinal recovery did not return to matching carry")
		var pairs := {}
		var behind: Array[int] = []
		for hit in hits:
			var pair := "%d/%d"%[hit.target,hit.step]
			check(not pairs.has(pair),"Cardinal paired blades doubled a hit")
			pairs[pair]=true
			if hit.target==rear: behind.append(hit.step)
		check(behind==[3],"Cardinal rear contacts occur outside spin")
		for cut in 5: check(pairs.has("%d/%d"%[front,cut]),"Cardinal forward cut missed: "+str(facing)+"/"+str(cut))
		cardinal_contacts.append({"direction":var_to_str(facing),"contacts":hits.duplicate(true),"began":began.duplicate(),"rear_steps":behind})
		var blocked_origin: Vector2 = stage.player.position
		cardinal_motion.set_direction(facing)
		for tick in 12: await physics_frame
		check(stage.player.position.distance_to(blocked_origin)<6 and presenter.pose_index==0,"Blocked travel advances a gliding gait")
		cardinal_motion.stop_and_clear()
		for target in targets: target.queue_free()
		targets.clear()
		for tick in 3: await physics_frame
		var origin: Vector2 = stage.player.position
		var movement_key := InputEventKey.new()
		movement_key.physical_keycode=KEY_W if facing==Vector2.UP else (KEY_S if facing==Vector2.DOWN else KEY_A)
		movement_key.pressed=true
		cardinal_motion._unhandled_key_input(movement_key)
		for tick in 12: await physics_frame
		check((stage.player.position-origin).dot(facing)>1,"Cardinal running cannot move in its facing")
		check(presenter.definition==PROFILE.run_for(facing) and presenter.pose_index>0,"Cardinal run uses the wrong/frozen body")
		movement_key.pressed=false
		cardinal_motion._unhandled_key_input(movement_key)
		check(presenter.definition==PROFILE.idle_for(facing),"Stopping run does not restore directional carry")
	var reach_proof := await validate_reach()
	# Pausing between finishing and the deferred cut must preserve the
	# scheduled input; cancellation must invalidate that same generation.
	cancel_combo()
	auto_left=1
	_finished()
	toggle_pause()
	await process_frame
	check(continuation_scheduled,"Pause discards a buffered continuation")
	toggle_pause()
	await process_frame
	check(stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE,"Resume loses buffered continuation")
	cancel_combo()
	auto_left=1
	_finished()
	cancel_combo()
	await process_frame
	check(stage.player.attack_component.phase==MeleeAttackComponent.Phase.IDLE and not has_pending_cut(),"Deferred stale input survives cancel")
	FileAccess.open(evidence_path+"review_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"cardinal_contacts":cardinal_contacts,"rear_steps":rear_steps,"handoff_physics_ticks":handoff_gaps,"reach_proof":reach_proof,"tab_controls":true,"rewardless":true},"\t")+"\n")
	print("TWINSTEEL_REVIEW checks=%d failures=%d"%[checks,failures])
	stage.queue_free()
	await process_frame
	quit(1 if failures else 0)

func validate_reach() -> Array[Dictionary]:
	var records: Array[Dictionary] = []
	for facing in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		cancel_combo()
		cardinal_motion.face(facing)
		for target in targets: target.queue_free()
		targets.clear()
		await physics_frame
		# Shape reach is measured from the registered body/contact origin,
		# sixteen pixels above the actor's feet, in every facing.
		var origin: Vector2 = stage.player.attack_component.hitbox.global_position
		for offset in [facing*68.0,facing*110.0,facing*45.0+facing.orthogonal()*26.0]:
			var target: Node2D = TARGET.instantiate()
			target.position=origin+offset
			stage.get_node("World/Actors").add_child(target)
			target.get_node("BodyCollision").disabled=true
			var tiny := CircleShape2D.new()
			tiny.radius=1.0
			target.get_node("Hurtbox/CollisionShape2D").shape=tiny
			target.get_node("HealthComponent").set_maximum_health(10000,false)
			target.get_node("HealthComponent").set_current_health(10000)
			targets.append(target)
		await physics_frame
		await physics_frame
		hits.clear()
		strike()
		for tick in 30: await physics_frame
		var reached: HealthComponent = targets[0].get_node("HealthComponent")
		var outside: HealthComponent = targets[1].get_node("HealthComponent")
		var flank: HealthComponent = targets[2].get_node("HealthComponent")
		check(reached.current_health<10000,"Longer first cut misses a tiny 68px target: "+str(facing))
		check(outside.current_health==10000,"Longer cut damages beyond its boundary")
		check(flank.current_health==10000,"Thrust still hits the old broad swing lane")
		check(hits.size()==1,"Longer paired slash repeats damage or hits outside the lane")
		records.append({"direction":var_to_str(facing),"inside_distance":68,"outside_distance":110,"flank_offset":var_to_str(facing*45.0+facing.orthogonal()*26.0),"flank_hit":flank.current_health<10000,"contacts":hits.size()})
		for target in targets: target.queue_free()
		targets.clear()
		await physics_frame
	return records

func check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
