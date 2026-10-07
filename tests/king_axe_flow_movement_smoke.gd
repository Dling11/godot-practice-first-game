extends "res://tests/sanctuary_test_base.gd"

## Actual Player input/physics, not just a check of configured ratios.
const PLAYER = preload("res://entities/player/player.tscn")
const ITEM = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const OUTPUT := "res://art_source/review/combat/king_axe_head_thrust_2026_10_06/"
const ACTIONS := ["player_move_right","player_move_left","player_move_up","player_move_down"]
const DIRECTIONS := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://axe_flow_movement_proof.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory(); inventory.acquire_weapon(ITEM)
	var actor: Player = PLAYER.instantiate()
	actor.position=Vector2(400,400)
	actor.movement_bounds=Rect2(0,0,1400,1200)
	root.add_child(actor)
	actor.set_physics_process(false); actor.set_process_unhandled_input(false)
	check(actor.equip_owned_weapon(ITEM),"Cannot equip production Iron Beard")
	var attack := actor.attack_component
	var records: Array[Dictionary] = []
	for index in DIRECTIONS.size():
		Input.action_press(ACTIONS[index])
		await process_frame
		for cut in ITEM.weapon_definition.combo.step_count():
			actor._set_facing_direction(DIRECTIONS[index])
			actor.get_node("WeaponFamilyPresentation").presenter.cancel_presentation_transition()
			attack._next_combo_step=cut
			actor.velocity=DIRECTIONS[index]*actor.movement_component.max_speed
			check(actor.request_primary_attack(),"Actual axe cut refused")
			actor._physics_process(1.0/60.0)
			var wind_speed := actor.velocity.length()
			check(wind_speed>0 and wind_speed<=actor.movement_component.max_speed*.25+.01,"Axe wind-up slides at full speed")
			await _phase(attack,MeleeAttackComponent.Phase.ACTIVE)
			var origin := actor.global_position
			for tick in 3:
				actor._physics_process(1.0/60.0)
				check(actor.velocity==Vector2.ZERO and actor.global_position.is_equal_approx(origin),"Axe moves its collision body during contact")
			check(attack.get_attack_direction()==DIRECTIONS[index],"Walking changes committed axe direction")
			actor.knockback_component.apply_pressure(-DIRECTIONS[index],40)
			actor._physics_process(1.0/60.0)
			check(actor.velocity.dot(-DIRECTIONS[index])>0,"Axe planting blocks incoming knockback")
			actor.knockback_component.clear()
			await _phase(attack,MeleeAttackComponent.Phase.RECOVERY)
			actor._physics_process(.1)
			check(actor.velocity.length()>0 and actor.velocity.length()<=actor.movement_component.max_speed*.6+.01,"Axe recovery stays planted or returns to full speed too soon")
			await _phase(attack,MeleeAttackComponent.Phase.IDLE)
			for tick in 10: actor._physics_process(1.0/60.0)
			check(is_equal_approx(actor.velocity.length(),actor.movement_component.max_speed),"Axe leaves walking permanently slowed")
			records.append({"direction":var_to_str(DIRECTIONS[index]),"cut":cut,"wind_speed":wind_speed,"contact_travel":0.0,"idle_speed":actor.velocity.length()})
		Input.action_release(ACTIONS[index])
	check(actor.request_evade(Vector2.LEFT),"Axe movement treatment prevents dodge")
	actor._physics_process(1.0/60.0)
	check(actor.velocity.x<0 and actor.velocity.length()>actor.movement_component.max_speed,"Axe walking ratio scales dodge")
	actor.evade_component.cancel_evade(); actor._clear_buffered_action()
	actor.queue_free()
	await process_frame
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	FileAccess.open(OUTPUT+"movement_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"records":records},"\t")+"\n")
	print("AXE_FLOW_MOVEMENT checks=%d failures=%d"%[checks,failures])
	quit(1 if failures else 0)

func _phase(attack: MeleeAttackComponent,target: int) -> void:
	var deadline := Time.get_ticks_msec()+3500
	while attack.phase!=target and Time.get_ticks_msec()<deadline: await physics_frame
	check(attack.phase==target,"Axe phase timed out: "+str(target))
