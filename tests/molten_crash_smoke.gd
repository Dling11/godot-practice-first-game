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
	var ability: RiftbreakComponent = actor.ability_2_component
	var original := ability.definition
	var original_script: Script = ability.get_script()
	var saved: Array = root.get_node("RunSession").king_skill_slots.duplicate()
	review.toggle_earthsplitter_review()
	review.toggle_earthsplitter_form()
	var earth := actor.ability_1_component.definition
	review.toggle_molten_review()
	_check(review.molten_review.enabled,"Molten review failed")
	_check(not ability.supports_ground_targeting(),"Molten must be local, not targeted")
	_check(actor.get_ability_component_for_slot(2)==ability,"Slot 2 lost binding")
	_check(actor.ability_1_component.definition==earth,"Molten modified accepted Skill 1")
	actor.position = Vector2(380,300)
	actor.set_physics_process(false)
	actor._debug_unlimited_skills = false
	ability.set_critical_profile(0.0,1.5)
	_check(actor.request_ability(2) and not actor.ground_point_targeting.is_targeting(),"Hotkey 2 did not cast immediately")
	ability.cancel_cast()
	await process_frame
	_check(get_nodes_in_group("molten_crash_review_effects").is_empty(),"Windup cancel left sword")
	ability.clear_cooldown()
	var foes: Array[ForsakenThrall] = []
	for offset in [Vector2(45,0),Vector2(0,45),Vector2(0,-45),Vector2(-50,0),Vector2(98,0),Vector2(40,40)]:
		var foe: ForsakenThrall = Thrall.instantiate()
		foe.position = actor.position+offset
		foe.target = actor
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000,false)
		foe.health_component.set_current_health(1000)
		foe._enter_state(foe.State.CHASE,0.0)
		foes.append(foe)
	# Real shared Boss response: damage accepted but no ordinary stun.
	foes[5].stagger_component.configure(load("res://data/enemies/rootbound_husk.tres"))
	var wall := StaticBody2D.new()
	wall.position = actor.position+Vector2(-25,0)
	var shape := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(8,60)
	shape.shape = rect
	wall.add_child(shape)
	lab.add_child(wall)
	await physics_frame
	await physics_frame
	var counts: Dictionary = {}
	ability.hit_landed.connect(func(target: HurtboxComponent,_info: DamageInfo) -> void: counts[target]=counts.get(target,0)+1)
	_check(ability.request_cast(Vector2.LEFT,100),"Local cast rejected")
	_check(not review.molten_review.set_enabled(false),"Changed review during cast")
	await create_timer(.12,false).timeout
	_check(foes[0].health_component.current_health==1000,"Damage before sword contact")
	await create_timer(.12,false).timeout
	for index in foes.size():
		var should_hit := index in [0,1,2,5]
		_check(is_equal_approx(foes[index].health_component.current_health,800 if should_hit else 1000),"Radius/LOS damage mismatch "+str(index))
		_check(counts.get(foes[index].get_node("Hurtbox"),0)==(1 if should_hit else 0),"Duplicate/missing contact "+str(index))
	_check(foes[0].stagger_component.is_stunned(),"Initial contact did not stun")
	_check(foes[0].get_node("StunIndicator").visible,"Stun stars missing")
	_check(not foes[5].stagger_component.is_stunned(),"Boss resistance bypassed")
	_check(foes[0].knockback_component.velocity.x>0 and foes[1].knockback_component.velocity.y>0,"Push was not radial")
	var origin := actor.position
	await create_timer(.16,false).timeout
	_check(not ability.is_casting(),"Molten exceeded .36s commitment")
	var visuals := get_nodes_in_group("molten_crash_review_effects")
	_check(visuals.size()==1 and visuals[0]._burst.visible,"Aftermath ended before control return")
	actor.position += Vector2(100,80)
	_check(visuals[0].global_position==origin,"Residual followed moving King")
	_check(not ability.request_cast(Vector2.RIGHT,100),"Cooldown bypassed")
	await create_timer(.9,false).timeout
	_check(get_nodes_in_group("molten_crash_review_effects").is_empty(),"Visual leaked")
	_check(foes[0].health_component.current_health==800,"Cooling ground repeated damage")
	_check(not foes[0].stagger_component.is_stunned(),"Aftermath repeated stun")
	actor.position = origin
	ability.clear_cooldown()
	ability.request_cast(Vector2.UP,100)
	await create_timer(.10,false).timeout
	ability.cancel_cast()
	await create_timer(.2,false).timeout
	_check(foes[0].health_component.current_health==800,"Cancelled windup still hit")
	ability.clear_cooldown()
	ability.request_cast(Vector2.DOWN,100)
	await create_timer(.24,false).timeout
	actor.is_defeated = true
	await create_timer(.2,false).timeout
	_check(get_nodes_in_group("molten_crash_review_effects").is_empty(),"Defeat left effects")
	actor.is_defeated = false
	ability.cancel_cast()
	_check(review.molten_review.set_enabled(false),"Restore failed")
	_check(ability.definition==original and ability.get_script()==original_script,"Original Skill 2 did not restore")
	_check(actor.ability_1_component.definition==earth,"Restore lost Skill 1")
	_check(root.get_node("RunSession").king_skill_slots==saved,"Saved slots changed")
	# Earlier targeted review and local molten review must never stack definitions.
	review.toggle_riftbreak_review()
	review.toggle_molten_review()
	_check(review.molten_review.enabled and not review.riftbreak_review.enabled and not ability.supports_ground_targeting(),"Targeted comparison leaked into Molten")
	review.toggle_molten_review()
	_check(ability.definition==original,"Targeted-to-Molten restoration failed")
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("MOLTEN_CRASH_CHECKS=",checks," FAILURES=",failures)
	quit(0 if failures==0 else 1)

