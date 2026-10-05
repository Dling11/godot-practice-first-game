extends "res://tools/launch_king_axe_run_review.gd"

const GREATSWORD = preload("res://data/items/equipment/king_royal_greatsword.tres")
const OUT := "res://art_source/review/combat/king_weapon_availability_2026_10_05/"
var checks := 0
var failures := 0
var starts: Array[int] = []

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	await key(KEY_TAB)
	var deadline := Time.get_ticks_msec()+6000
	while (current_scene.scene_file_path!="res://levels/combat_lab/combat_lab.tscn" or root.get_node("SceneTransition")._transitioning) and Time.get_ticks_msec()<deadline:
		await process_frame
	check(current_scene.scene_file_path=="res://levels/combat_lab/combat_lab.tscn","Axe review Tab failed to enter playable practice")
	if failures: quit(1); return
	var lab := current_scene
	lab.clear_simulation()
	var actor: Player = lab.player
	var menu: CharacterMenu = lab.get_node("UI/CharacterMenu")
	var inventory := root.get_node("WeaponInventory")
	check(menu.visible and paused,"Axe practice did not open a visible Bag")
	check(inventory.owns_weapon(GAME_ITEM.item_id) and inventory.owns_weapon(GREATSWORD.item_id),"Practice omitted one accepted family")
	check(actor.get_equipped_weapon_item()==GAME_ITEM,"Axe review entered practice with the wrong weapon")
	menu._on_equipment_selected(GAME_ITEM)
	menu.equipment_detail_panel.equip_requested.emit(GAME_ITEM)
	check(is_instance_valid(menu._family_portrait) and menu._family_portrait.definition==GAME_ITEM.weapon_definition.family_presentation.idle_poses,"Bag axe paper doll is missing")
	await capture("bag_axe.png")
	await key(KEY_ESCAPE)
	check(not paused,"Closing axe Bag did not resume controls")
	actor.set_process_unhandled_input(false)
	actor.set_physics_process(false)
	var attack := actor.attack_component
	var family := actor.get_node("WeaponFamilyPresentation")
	attack.attack_started.connect(func() -> void: starts.append(attack.combo_step))
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		actor._set_facing_direction(direction)
		attack.reset_combo()
		starts.clear()
		check(actor.request_primary_attack(),"Production axe cannot start")
		for step in 5:
			await until_active(attack)
			check(attack.combo_step==step and attack.get_attack_direction()==direction,"Axe chain changed step/facing")
			if step<4: check(actor.request_primary_attack(),"Axe cannot buffer its next cut")
			if step<4: await until_step(attack,step+1)
		await until_idle(attack)
		check(starts==[0,1,2,3,4] and actor._buffered_action==Player.BufferedAction.NONE,"Axe lost/repeated a cut or left ghost input")
	# Real hurtboxes: fifth spin hits each close target once and pushes outwards.
	actor._set_facing_direction(Vector2.RIGHT)
	var rear := make_practice_target(actor,Vector2(-50,0))
	var front := make_practice_target(actor,Vector2(50,0))
	var distant := make_practice_target(actor,Vector2(105,0))
	var rear_hits: Array[DamageInfo] = []
	var front_hits: Array[DamageInfo] = []
	rear.get_node("HealthComponent").damaged.connect(func(info: DamageInfo) -> void: rear_hits.append(info))
	front.get_node("HealthComponent").damaged.connect(func(info: DamageInfo) -> void: front_hits.append(info))
	await physics_frame
	attack.reset_combo()
	actor.request_primary_attack()
	await until_idle(attack)
	check(rear_hits.is_empty() and front_hits.size()==1,"Ordinary axe sweep hits behind or duplicates contacts")
	front_hits.clear()
	attack._next_combo_step = 4
	actor.request_primary_attack()
	await until_active(attack)
	await create_timer(.12).timeout
	await capture("axe_whirlwind.png")
	await until_idle(attack)
	check(rear_hits.size()==1 and front_hits.size()==1,"Whirlwind does not hit each side exactly once")
	if rear_hits.size()==1 and front_hits.size()==1:
		check(rear_hits[0].direction.x<-.9 and front_hits[0].direction.x>.9,"Whirlwind knockback is not outward")
	check(distant.get_node("HealthComponent").current_health==10000,"Whirlwind exceeds its authored reach")
	for target in [rear,front,distant]: target.queue_free()
	await process_frame
	family.presenter._rest_timer.stop()
	family.presenter._rest()
	await create_timer(.6).timeout
	check(family.presenter._resting and family.presenter.definition.stowed_poses[family.presenter.pose_index]==1,"Production axe lost accepted back-stowed idle")
	check(family._plant_marker==null,"Axe incorrectly uses a planted greatsword effect")
	await capture("axe_rest.png")
	check(actor.request_primary_attack() and family.presenter._drawing,"Back-stowed axe does not draw before attacking")
	await create_timer(.34).timeout
	check(attack.phase!=MeleeAttackComponent.Phase.IDLE,"Axe draw never returns control to Player")
	attack.cancel_attack()
	actor.velocity = Vector2(80,0)
	await physics_frame
	var old_pose: int = family.presenter.pose_index
	actor.global_position += Vector2(18,0)
	await physics_frame
	check(family.presenter._running and family.presenter.pose_index!=old_pose and family.presenter.definition==RUN_POSES,"Accepted back-mounted axe gait does not advance from movement")
	await capture("axe_run.png")
	actor.velocity = Vector2.ZERO
	await physics_frame
	check(actor.equip_owned_weapon(GREATSWORD),"Cannot switch from axe to greatsword")
	await process_frame
	check(family.profile==GREATSWORD.weapon_definition.family_presentation and is_instance_valid(family.impacts),"Axe-to-greatsword switch leaves the wrong rig")
	check(actor.equip_owned_weapon(GAME_ITEM),"Cannot switch back to axe")
	await process_frame
	check(family.profile==GAME_ITEM.weapon_definition.family_presentation and family.impacts==null,"Greatsword-to-axe switch leaks planted impact rig")
	check(actor.equip_owned_weapon(actor.weapon_catalog.default_weapon),"Cannot return to King's original sword")
	check(family.presenter==null and actor.get_node("VisualRoot/Body").visible,"Unequip leaks a family or hides original body")
	# Existing F9 acquisition also works on the normal Player path.
	inventory.reset_inventory()
	actor.apply_debug_testing_preset()
	check(inventory.owns_weapon(GAME_ITEM.item_id),"F9 does not make the axe available")
	var snapshot: Dictionary = inventory.create_snapshot()
	check(inventory.can_restore_snapshot(snapshot) and inventory.restore_snapshot(snapshot),"Axe catalog breaks inventory snapshots")
	lab.queue_free()
	await process_frame
	await process_frame
	print("Axe gameplay smoke: %d checks, %d failures" % [checks,failures])
	quit(1 if failures else 0)

func make_practice_target(actor: Player, offset: Vector2) -> Node2D:
	var target: Node2D = TARGET.instantiate()
	current_scene.get_node("World/Actors").add_child(target)
	target.global_position = actor.global_position+offset
	target.get_node("HealthComponent").set_maximum_health(10000,false)
	target.get_node("HealthComponent").set_current_health(10000)
	return target

func until_active(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while attack.phase!=MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.ACTIVE,"Timed out before axe contact")

func until_step(attack: MeleeAttackComponent, step: int) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while (attack.combo_step!=step or attack.phase==MeleeAttackComponent.Phase.IDLE) and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.combo_step==step and attack.phase!=MeleeAttackComponent.Phase.IDLE,"Timed out before buffered axe continuation")

func until_idle(attack: MeleeAttackComponent) -> void:
	var deadline := Time.get_ticks_msec()+4000
	while attack.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==MeleeAttackComponent.Phase.IDLE,"Axe never settled")

func key(code: Key) -> void:
	var event := InputEventKey.new()
	event.keycode = code
	event.physical_keycode = code
	event.pressed = true
	root.push_input(event)
	await process_frame
	event = event.duplicate()
	event.pressed = false
	root.push_input(event)
	await process_frame

func capture(file: String) -> void:
	if DisplayServer.get_name()=="headless": return
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file)==OK,"Axe native capture failed")
