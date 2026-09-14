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
	var ability: AbilityComponent = actor.ability_1_component
	var original := ability.definition
	var original_script: Script = ability.get_script()
	var saved: Array = root.get_node("RunSession").king_skill_slots.duplicate()
	review.toggle_earthsplitter_review()
	_check(review.earthsplitter_review.set_advanced(true),"Advanced form did not activate")
	actor.position = Vector2(300,280)
	actor.set_physics_process(false)
	ability.set_critical_profile(0.0,1.5)
	var preview := ability.get_target_lane_preview(actor.position+Vector2(12,0))
	_check(preview.waves.size()==3,"Preview must show three wave paths")
	for index in 3:
		_check(is_equal_approx(actor.position.distance_to(preview.waves[index].end),[164.0,196.0,228.0][index]),"Preview reach mismatch")
		_check(is_equal_approx(preview.waves[index].radius,[17.0,19.0,21.0][index]),"Preview width mismatch")
	_check(actor.request_ability(1) and actor.ground_point_targeting.is_targeting(),"Advanced slot lost the live component binding")
	_check(not review.earthsplitter_review.set_advanced(false),"Form changed while aiming")
	actor.ground_point_targeting.cancel_targeting()
	var foes: Array[ForsakenThrall] = []
	for offset in [Vector2(100,0),Vector2(205,0),Vector2(240,0),Vector2(100,80)]:
		var foe: ForsakenThrall = Thrall.instantiate()
		foe.position = actor.position+offset
		foe.target = actor
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000,false)
		foe.health_component.set_current_health(1000)
		foes.append(foe)
	await physics_frame
	await physics_frame
	var amounts: Dictionary = {}
	ability.hit_landed.connect(func(target: HurtboxComponent,info: DamageInfo) -> void:
		if not amounts.has(target):
			amounts[target] = []
		amounts[target].append(info.amount))
	_check(ability.request_cast_at(actor.position+Vector2(12,0),100),"Advanced cast rejected")
	_check(not review.earthsplitter_review.set_advanced(false),"Form changed during windup")
	await create_timer(.14).timeout
	_check(foes[0].health_component.current_health==1000,"Damage occurred before sword contact")
	await create_timer(.10,false).timeout
	var sequences := get_nodes_in_group("earthsplitter_review_sequences")
	_check(sequences.size()==1 and sequences[0]._next==1,"First wave timing is wrong")
	await create_timer(.15,false).timeout
	_check(not ability.is_casting(),"Advanced extended the player commitment")
	_check(not review.earthsplitter_review.set_advanced(false),"Form changed while waves were still pending")
	_check(sequences[0]._next==2,"Second wave should release after 0.16s")
	var origin := actor.position
	actor.position += Vector2(0,-70)
	# Changes to the live component after release must not alter this sequence.
	ability.amplify_committed_cast(10.0)
	ability.set_critical_profile(.5,9.0)
	await create_timer(.50,false).timeout
	var expected := [775.0,820.0,876.25,1000.0]
	var counts := [3,2,1,0]
	for index in 4:
		_check(is_equal_approx(foes[index].health_component.current_health,expected[index]),"Incorrect budget/reach on target "+str(index)+": "+str(foes[index].health_component.current_health))
		_check(not foes[index].stagger_component.is_stunned(),"Cascading Rupture applied stun")
		var received: Array = amounts.get(foes[index].get_node("Hurtbox"),[])
		_check(received.size()==counts[index],"Incorrect per-wave hit count on target "+str(index))
	var near: Array = amounts.get(foes[0].get_node("Hurtbox"),[])
	_check(near.size()==3 and is_equal_approx(near[0],45.0) and is_equal_approx(near[1],56.25) and is_equal_approx(near[2],123.75),"Third wave must own the largest damage share")
	_check(get_nodes_in_group("earthsplitter_review_sequences").is_empty(),"Completed sequence leaked")
	_check(review.earthsplitter_review.set_advanced(false),"Foundation restoration failed")
	_check(is_equal_approx(ability.definition.range_pixels,164.0) and is_equal_approx(ability.definition.weapon_damage_multiplier,1.65),"Foundation values were not restored")
	_check(review.earthsplitter_review.set_advanced(true),"Advanced reactivation failed")
	actor.position = origin
	ability.set_critical_profile(0.0,1.5)
	for index in range(1,foes.size()):
		foes[index].position = Vector2(700,600+index*25)
	var heading := Vector2.RIGHT.rotated(.297)
	foes[0].position = origin+heading*100.0
	foes[0].health_component.set_current_health(1000)
	await physics_frame
	await physics_frame
	ability.clear_cooldown()
	_check(ability.request_cast_at(origin+heading*12.0,100),"Intermediate-angle cast failed")
	_check(ability.get_cast_direction().is_equal_approx(heading),"Advanced quantized the exact aim angle")
	await create_timer(.9,false).timeout
	_check(is_equal_approx(foes[0].health_component.current_health,775.0),"Three waves did not hit along an intermediate angle")
	# Recheck terrain for every wave, including a wall added after commitment.
	for late_wall in [false,true]:
		foes[0].position = origin+Vector2(125,0)
		foes[0].health_component.set_current_health(1000)
		var wall := StaticBody2D.new()
		wall.position = origin+Vector2(85,0)
		var collision := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(10,110)
		collision.shape = rectangle
		wall.add_child(collision)
		ability.clear_cooldown()
		if late_wall:
			ability.request_cast_at(origin+Vector2(228,0),100)
			await create_timer(.25,false).timeout
		lab.add_child(wall)
		await physics_frame
		await physics_frame
		if not late_wall:
			var blocked := ability.get_target_lane_preview(origin+Vector2(228,0))
			for path in blocked.waves:
				_check(path.blocked and path.end.x+path.radius < wall.position.x-4.0,"Wave preview crossed a wall")
			ability.request_cast_at(origin+Vector2(228,0),100)
		await create_timer(.9,false).timeout
		_check(foes[0].health_component.current_health==1000,"A queued wave hit through terrain; late wall="+str(late_wall))
		wall.queue_free()
		await process_frame
		await physics_frame
	ability.clear_cooldown()
	ability.request_cast_at(origin+Vector2(228,0),100)
	await create_timer(.24,false).timeout
	actor.is_defeated = true
	await create_timer(.35,false).timeout
	_check(get_nodes_in_group("earthsplitter_review_sequences").is_empty(),"Defeat left future waves queued")
	_check(get_nodes_in_group("earthsplitter_review_attacks").is_empty(),"Defeat left live hitboxes")
	_check(get_nodes_in_group("earthsplitter_review_effects").is_empty(),"Defeat left presentation")
	actor.is_defeated = false
	ability.cancel_cast()
	ability.clear_cooldown()
	ability.request_cast_at(origin+Vector2(228,0),100)
	await create_timer(.39,false).timeout
	_check(review.earthsplitter_review.set_enabled(false),"Review exit failed while late wave was pending")
	await create_timer(.40,false).timeout
	_check(get_nodes_in_group("earthsplitter_review_sequences").is_empty() and get_nodes_in_group("earthsplitter_review_attacks").is_empty(),"Review exit left a delayed wave")
	_check(ability.definition==original and ability.get_script()==original_script,"Original component did not restore")
	_check(root.get_node("RunSession").king_skill_slots==saved,"Advanced review changed saved slots")
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("EARTHSPLITTER_ADVANCED_CHECKS=",checks," FAILURES=",failures)
	quit(0 if failures==0 else 1)
