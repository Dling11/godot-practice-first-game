extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const PLAYER = preload("res://entities/player/player.tscn")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	var measurements: Array[Dictionary] = []
	for direction in [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]:
		var actor: Player = PLAYER.instantiate()
		actor.position = Vector2(200,200)
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		actor.equip_owned_weapon(ITEM)
		actor._set_facing_direction(direction)
		actor.attack_component._next_combo_step = 2
		actor.request_primary_attack()
		var deadline := Time.get_ticks_msec()+3000
		while actor.attack_component.phase != MeleeAttackComponent.Phase.ACTIVE and Time.get_ticks_msec()<deadline:
			await physics_frame
		if actor.attack_component.phase != MeleeAttackComponent.Phase.ACTIVE:
			push_error("Landing probe timed out")
			quit(1)
			return
		var family := actor.get_node("WeaponFamilyPresentation")
		var presenter: Node2D = family.presenter
		var steel_tip: Vector2 = actor.to_local(presenter.weapon_rig.to_global(presenter.definition.weapon_tip-presenter.definition.weapon_primary_grip))
		for burst in family.impacts.get_children():
			if burst.row != 1: continue
			var impact: Vector2 = actor.to_local(burst.global_position)
			measurements.append({"direction":var_to_str(direction),"clip":presenter.definition.resource_path,"pose":presenter.pose_index,"steel_tip_actor_local":var_to_str(steel_tip),"ground_burst_actor_local":var_to_str(impact),"horizontal_gap_pixels":absf(steel_tip.x-impact.x),"anchor_gap_pixels":steel_tip.distance_to(impact)})
		actor.attack_component.cancel_attack()
		actor.queue_free()
		await process_frame
	FileAccess.open("res://art_source/review/combat/king_greatsword_independent_review_2026_10_05/landing_measurements.json",FileAccess.WRITE).store_string(JSON.stringify(measurements,"\t")+"\n")
	print("Installed slam anchor measurements: ",JSON.stringify(measurements))
	quit(0 if measurements.size()==4 else 1)
