extends "res://tools/launch_king_greatsword_confidence_review.gd"
var checks := 0
var failures := 0
var contacts := {}
func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
func _run() -> void:
	await super._run()
	var attack: MeleeAttackComponent = stage.player.attack_component
	attack.weapon.basic_damage_minimum = 100
	attack.weapon.basic_damage_maximum = 100
	attack.weapon.critical_chance_ratio = 0
	attack.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void:
		var key := str(attack.combo_step)+"/"+str(target.get_parent().get_instance_id())
		contacts[key] = contacts.get(key,0)+1
		check(is_equal_approx(info.raw_amount,100*GAME_COMBO.damage_multipliers[attack.combo_step]),"Authored damage multiplier changed")
		check(info.direction.dot(attack.get_attack_direction())>.99,"Visual return changed knockback direction")
	)
	for direction in [1,-1]:
		stage.player.facing_direction = Vector2(direction,0)
		axe_presenter.face_horizontal(direction)
		for step in 5:
			cancel_combo()
			place_target()
			var target_id := contact_target.get_instance_id()
			var rear := make_target(Vector2(-direction*76,0))
			var outside := make_target(Vector2(direction*144,0))
			attack._next_combo_step = step
			strike()
			var deadline := Time.get_ticks_msec()+6000
			while attack.phase!=MeleeAttackComponent.Phase.IDLE and Time.get_ticks_msec()<deadline: await physics_frame
			check(attack.phase==MeleeAttackComponent.Phase.IDLE,"Cut timed out")
			check(contacts.get(str(step)+"/"+str(target_id),0)==1,"Missing/duplicate frontal contact")
			check(contacts.get(str(step)+"/"+str(rear.get_instance_id()),0)==0,"Cosmetic follow-through adds rear damage")
			check(contacts.get(str(step)+"/"+str(outside.get_instance_id()),0)==0,"Cut exceeds authored reach")
			rear.queue_free()
			outside.queue_free()
	cancel_combo()
	stage.queue_free()
	await process_frame
	print("Greatsword contact: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)
