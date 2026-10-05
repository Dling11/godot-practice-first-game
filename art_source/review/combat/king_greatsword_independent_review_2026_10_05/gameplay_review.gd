extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const TARGET = preload("res://entities/training/training_target.tscn")
const OUT := "res://art_source/review/combat/king_greatsword_independent_review_2026_10_05/gameplay/"
var started: Array[int] = []

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").configure_storage_path_for_testing("user://greatsword_gameplay_smoke.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("RunSession").reset_run()
	var hub := HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var actor: Player = hub.player
	actor.set_physics_process(false)
	actor.set_process_unhandled_input(false) # Scripted intent cannot race desktop clicks.
	var attack := actor.attack_component
	var inventory := root.get_node("WeaponInventory")
	var old_snapshot: Dictionary = inventory.create_snapshot()
	check(not inventory.owns_weapon(ITEM.item_id),"Prototype was automatically granted to the campaign")
	actor.apply_debug_testing_preset()
	check(inventory.owns_weapon(ITEM.item_id),"Normal F9 preset did not unlock the approved greatsword")
	check(actor.equip_owned_weapon(ITEM),"Bag ownership path cannot equip the greatsword")
	var family := actor.get_node("WeaponFamilyPresentation")
	actor._set_facing_direction(Vector2.RIGHT)
	await process_frame
	check(family.presenter.visible and not actor.get_node("VisualRoot/Body").visible,"Greatsword did not replace the production side body")
	check(attack.weapon == ITEM.weapon_definition and attack.weapon.combo.step_count()==5,"Production weapon/chain did not install")
	check(attack.weapon.family_presentation.attack_poses.follow_up_clips[2].queued_recovery_window==Vector2(10,11),"Fourth is missing the drawn continuation recovery")
	check(family.presenter.weapon_sprite.texture.get_size()==Vector2(30,140),"Huge original steel changed size")
	await capture("sanctuary_equipped.png")
	hub.character_menu.open_menu()
	await process_frame
	hub.character_menu._on_equipment_selected(ITEM)
	hub.character_menu.equipment_detail_panel.equip_requested.emit(ITEM)
	check(actor.get_equipped_weapon_item()==ITEM,"Bag EQUIP button path lost the greatsword")
	check(is_instance_valid(hub.character_menu._family_portrait),"Bag paper doll still displays the old sword")
	await capture("bag_greatsword.png")
	hub.character_menu.close_menu()
	await process_frame
	attack.configure_random_seed_for_testing(52)
	attack.attack_started.connect(func() -> void: started.append(attack.combo_step))
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		attack.reset_combo()
		started.clear()
		check(actor.request_primary_attack(),"Production primary attack rejected")
		for step in 5:
			await _until_active(attack)
			check(attack.combo_step==step and attack.get_attack_direction()==direction,"Combo drift: expected step %d facing %s, actual step %d direction %s / player %s" % [step,direction,attack.combo_step,attack.get_attack_direction(),actor.facing_direction])
			if absf(direction.y)>0:
				var root_clip := ITEM.weapon_definition.family_presentation.attack_for(direction)
				var expected_clip: Resource = root_clip if step==0 else root_clip.follow_up_clips[step-1]
				check(family.presenter.visible and not actor.get_node("VisualRoot/Body").visible,"Vertical attack still shows the original short sword")
				check(family.presenter.definition==expected_clip,"Vertical combo does not use its authored body/hand clip")
			if step<4:
				check(actor.request_primary_attack(),"Normal primary input could not buffer the next cut")
			if direction==Vector2.RIGHT and step==4:
				await create_timer(.12).timeout
				check(family.presenter.definition==ITEM.weapon_definition.family_presentation.attack_poses.follow_up_clips[3],"Game did not use accepted return clip")
				await capture("fifth_contact.png")
				paused = true
				var pose: int = family.presenter.pose_index
				var remaining := attack._phase_time_remaining
				await create_timer(.12,true,false,true).timeout
				check(family.presenter.pose_index==pose and is_equal_approx(remaining,attack._phase_time_remaining),"Pause advanced attack/presentation")
				paused = false
			if step<4: await _until_step(attack,step+1)
		await _until_idle(attack)
		check(started==[0,1,2,3,4],"Production input lost/repeated a cut")
		check(actor._buffered_action==Player.BufferedAction.NONE,"Combo left a ghost buffered action")
	# The shortened final recovery still retains a queued input from early wind-up.
	actor._set_facing_direction(Vector2.RIGHT)
	attack._next_combo_step = 4
	check(actor.request_primary_attack() and actor.request_primary_attack(),"Fifth early-input queue rejected")
	check(actor.action_buffer_timer.time_left>attack.get_remaining_attack_seconds(),"Queued input expires before the fifth can finish")
	await _until_step(attack,0)
	actor._clear_buffered_action()
	attack.cancel_attack()
	await process_frame
	family.presenter._rest_timer.stop()
	family.presenter._rest()
	await create_timer(.6).timeout
	check(family.presenter._resting and family.presenter.pose_index==7,"Proud planted idle disappeared")
	await capture("planted_idle.png")
	check(actor.request_primary_attack() and family.presenter._drawing,"Attack did not retrieve planted steel")
	check(actor.request_primary_attack() and attack.phase==MeleeAttackComponent.Phase.IDLE,"Repeated input skipped the planted retrieval")
	await create_timer(.34).timeout
	check(attack.phase!=MeleeAttackComponent.Phase.IDLE,"Retrieval did not hand control back to Player")
	actor._clear_buffered_action()
	attack.cancel_attack()
	check(actor.request_evade(Vector2.LEFT),"Equipped greatsword blocks evade")
	await process_frame
	check(not family.presenter.visible and actor.get_node("VisualRoot/Body").visible,"Evade leaves duplicated family art")
	actor.evade_component.cancel_evade()
	check(actor.request_ability(2),"Equipped greatsword blocks Molten Crash")
	await process_frame
	check(not family.presenter.visible,"Skill leaves the greatsword idle drawn over its body")
	actor.get_active_ability_component().cancel_cast()
	await process_frame
	actor._set_facing_direction(Vector2.RIGHT)
	actor.velocity = Vector2(80,0)
	await physics_frame
	var stride: int = family.presenter.pose_index
	actor.global_position += Vector2(18,0)
	await physics_frame
	check(family.presenter._running and family.presenter.pose_index!=stride,"Production running glides without distance-driven steps")
	actor.velocity = Vector2.ZERO
	await physics_frame
	check(not family.presenter._running,"Run did not settle to carry")
	for direction in [Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		actor.velocity = direction*80
		await physics_frame
		var previous_pose: int = family.presenter.pose_index
		actor.global_position += direction*18
		await physics_frame
		check(family.presenter.definition==ITEM.weapon_definition.family_presentation.run_for(direction) and family.presenter.pose_index!=previous_pose,"Vertical run has the wrong body or glides")
		actor.velocity = Vector2.ZERO
		await physics_frame
		check(family.presenter.definition==ITEM.weapon_definition.family_presentation.idle_for(direction),"Vertical gait settles to the old weapon/body")
	check(actor.equip_owned_weapon(actor.weapon_catalog.default_weapon),"Could not switch back to the original weapon")
	check(family.presenter==null and actor.get_node("VisualRoot/Body").visible,"Unequip leaked a rig/hidden original body")
	check(inventory.can_restore_snapshot(old_snapshot) and inventory.restore_snapshot(old_snapshot),"Pre-greatsword saves stopped restoring")
	# Player scene has the same adapter in campaign arenas, not just the hub.
	var campaign_player: Player = preload("res://entities/player/player.tscn").instantiate()
	root.add_child(campaign_player)
	campaign_player.set_physics_process(false)
	campaign_player.set_process_unhandled_input(false)
	inventory.acquire_weapon(ITEM)
	check(campaign_player.equip_owned_weapon(ITEM),"Fresh campaign Player cannot install the family")
	var family_2 := campaign_player.get_node("WeaponFamilyPresentation")
	campaign_player._set_facing_direction(Vector2.RIGHT)
	check(is_instance_valid(family_2.presenter),"New arena Player is missing the runtime rig")
	var target := TARGET.instantiate()
	target.position = campaign_player.position + Vector2(80,0)
	root.add_child(target)
	target.get_node("HealthComponent").set_maximum_health(10000,false)
	target.get_node("HealthComponent").set_current_health(10000)
	await physics_frame
	check(campaign_player.request_primary_attack(),"Arena attack failed")
	await _until_idle(campaign_player.attack_component)
	check(target.get_node("HealthComponent").current_health < 10000,"Equipped greatsword cannot hit real targets")
	campaign_player.queue_free()
	target.queue_free()
	await process_frame
	hub.queue_free()
	await process_frame
	inventory.equip_weapon(&"king",&"warrior",ITEM)
	var arena := preload("res://levels/test_arena/test_arena.tscn").instantiate()
	root.add_child(arena)
	current_scene = arena
	await process_frame
	var arena_player: Player = arena.player
	arena_player.set_process_unhandled_input(false)
	arena_player._set_facing_direction(Vector2.RIGHT)
	check(arena_player.attack_component.weapon==ITEM.weapon_definition,"Stage I did not carry the equipped family across scenes")
	check(arena_player.get_node("WeaponFamilyPresentation").presenter.visible,"Stage I shows the old side body")
	await capture("stage_1_equipped.png")
	print("Greatsword gameplay smoke: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func _until_active(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+6000
	while attack.phase != MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.ACTIVE,"Timed out before contact")

func _until_step(attack: MeleeAttackComponent, step: int) -> void:
	var deadline := Time.get_ticks_msec()+6000
	while (attack.combo_step!=step or attack.phase==MeleeAttackComponent.Phase.IDLE) and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.combo_step==step and attack.phase!=MeleeAttackComponent.Phase.IDLE,"Buffered continuation timed out")

func _until_idle(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+6000
	while attack.phase != MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.IDLE,"Attack did not settle")

func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file)==OK,"Native evidence capture failed")
