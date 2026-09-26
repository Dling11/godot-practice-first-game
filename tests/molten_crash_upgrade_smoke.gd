extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const Thrall = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
var checks := 0
var failures := 0

func _initialize() -> void:
	call_deferred("_run")

func _check(ok: bool, label: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(label)

func _foe(lab: Node, actor: Player, offset: Vector2) -> ForsakenThrall:
	var foe: ForsakenThrall = Thrall.instantiate()
	foe.position = actor.position+offset
	foe.target = actor
	lab.add_child(foe)
	foe.set_physics_process(false)
	foe.health_component.set_maximum_health(1000,false)
	foe.health_component.set_current_health(1000)
	foe._enter_state(foe.State.CHASE,0.0)
	return foe

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var lab := Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	var actor: Player = lab.player
	var review: Node = lab.get_node("KingSpellwardReview")
	review.open_review()
	lab.clear_simulation()
	var original_definition := actor.ability_2_component.definition
	review.toggle_molten_review()
	actor.position = Vector2(380,300)
	actor.set_physics_process(false)
	actor._debug_unlimited_skills = false
	var ability: RiftbreakComponent = actor.ability_2_component
	ability.set_critical_profile(0.0,1.5)
	_check((ability.definition as MoltenCrashDefinition).form==MoltenCrashDefinition.Form.FOUNDATION,"Foundation did not start selected")
	_check(review.molten_review.set_form(MoltenCrashDefinition.Form.ADVANCED),"Advanced unavailable")
	_check(ability.definition.effect_radius_pixels==80.0,"Advanced radius")
	_check(is_equal_approx(ability.definition.weapon_damage_multiplier,2.3),"Advanced budget")
	var near := _foe(lab,actor,Vector2(70,0))
	var outside := _foe(lab,actor,Vector2(90,0))
	var blocked := _foe(lab,actor,Vector2(-45,0))
	var wall := StaticBody2D.new()
	wall.position = actor.position+Vector2(-25,0)
	var wall_shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(8,60)
	wall_shape.shape = rectangle
	wall.add_child(wall_shape)
	lab.add_child(wall)
	await physics_frame
	await physics_frame
	_check(ability.request_cast(Vector2.RIGHT,100),"Advanced cast rejected")
	await create_timer(.24,false).timeout
	_check(is_equal_approx(near.health_component.current_health,770),"Advanced damage/radius")
	_check(outside.health_component.current_health==1000,"Advanced exceeded 80px")
	await create_timer(.25,false).timeout
	_check(not ability.is_casting(),"Advanced commitment length changed")
	_check(review.molten_review.set_form(MoltenCrashDefinition.Form.AWAKENED),"Awakened unavailable")
	_check(ability.definition.effect_radius_pixels==84.0,"Awakened main radius")
	_check((ability.definition as MoltenCrashDefinition).aftershock_radius_pixels==86.0,"Awakened pulse radius")
	near.health_component.set_current_health(1000)
	outside.position = actor.position+Vector2(85,0)
	outside.health_component.set_current_health(1000)
	var events: Array[DamageInfo] = []
	ability.hit_landed.connect(func(_target: HurtboxComponent, info: DamageInfo) -> void: events.append(info))
	ability.clear_cooldown()
	_check(ability.request_cast(Vector2.RIGHT,100),"Awakened cast rejected")
	await create_timer(.26,false).timeout
	_check(is_equal_approx(near.health_component.current_health,808),"Awakened crash must be 80 percent of budget")
	_check(outside.health_component.current_health==1000,"Awakened main hit reached beyond 84px")
	var origin := actor.position
	actor.position += Vector2(120,90)
	await create_timer(.17,false).timeout
	_check(not ability.is_casting(),"Awakened delayed recovery")
	_check(not review.molten_review.set_form(MoltenCrashDefinition.Form.MATURE),"Pending aftershock allowed form swap")
	await create_timer(.19,false).timeout
	var active_visuals := get_nodes_in_group("molten_crash_review_effects")
	var pulse_visible := false
	for effect in active_visuals:
		if effect.source==actor and effect._ring.visible and effect._ring.region_rect.position.x>=0.0:
			pulse_visible = true
	_check(pulse_visible,"Damage pulse had no registered animated ring")
	_check(is_equal_approx(near.health_component.current_health,760),"Awakened center did not receive 192+48")
	_check(is_equal_approx(outside.health_component.current_health,952),"Pulse did not reach outer 86px")
	_check(blocked.health_component.current_health==1000,"Delayed pulse crossed a wall")
	_check(events.size()==3,"Awakened generated duplicate/missing hits")
	_check(events[0].stun_seconds>.0 and events[1].stun_seconds==0.0 and events[2].stun_seconds==0.0,"Aftershock repeated stun")
	actor.position = origin
	await create_timer(.4,false).timeout
	_check(review.molten_review.set_form(MoltenCrashDefinition.Form.MATURE),"Mature unavailable")
	_check(ability.definition.effect_radius_pixels==86.0,"Mature exceeded radius cap")
	near.position = actor.position+Vector2(35,0)
	outside.position = actor.position+Vector2(75,0)
	near.health_component.set_current_health(1000)
	outside.health_component.set_current_health(1000)
	ability.clear_cooldown()
	_check(ability.request_cast(Vector2.RIGHT,100),"Mature cast rejected")
	await create_timer(.60,false).timeout
	_check(is_equal_approx(near.health_component.current_health,730),"Mature center budget")
	_check(is_equal_approx(outside.health_component.current_health,790.48),"Mature gentler rim budget")
	_check(outside.stagger_component.is_stunned(),"Mature damage rim lost its initial stun")
	_check(not ability.is_casting(),"Mature commitment length changed")
	await create_timer(.4,false).timeout
	_check(review.molten_review.set_form(MoltenCrashDefinition.Form.AWAKENED),"Could not select Awakened for cancel test")
	near.health_component.set_current_health(1000)
	ability.clear_cooldown()
	ability.request_cast(Vector2.RIGHT,100)
	await create_timer(.27,false).timeout
	actor.is_defeated = true
	await create_timer(.38,false).timeout
	_check(is_equal_approx(near.health_component.current_health,808),"Defeat failed to cancel released heat pulse")
	_check(get_nodes_in_group("molten_crash_review_pulses").is_empty(),"Released pulse leaked after defeat")
	actor.is_defeated = false
	ability.cancel_cast()
	near.health_component.set_current_health(1000)
	ability.clear_cooldown()
	_check(ability.request_cast(Vector2.RIGHT,100),"Review-exit cancel cast rejected")
	await create_timer(.40,false).timeout
	_check(review.molten_review.set_enabled(false),"Review did not restore while pulse pending")
	await create_timer(.22,false).timeout
	_check(is_equal_approx(near.health_component.current_health,808),"Review exit failed to cancel pulse")
	_check(get_nodes_in_group("molten_crash_review_pulses").is_empty(),"Review exit left released pulse")
	_check(ability.definition==original_definition,"Original definition did not restore")
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("MOLTEN_UPGRADE_CHECKS=",checks," FAILURES=",failures)
	quit(0 if failures==0 else 1)
