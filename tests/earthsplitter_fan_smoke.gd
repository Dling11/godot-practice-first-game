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
	var saved: Array = root.get_node("RunSession").king_skill_slots.duplicate()
	review.toggle_earthsplitter_review()
	review.toggle_earthsplitter_form()
	_check(review.earthsplitter_review.form==1,"First upgrade must be the fan")
	actor.position = Vector2(300,280)
	actor.set_physics_process(false)
	ability.set_critical_profile(0.0,1.5)
	var origin := actor.position
	var headings := [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP,Vector2(1,1).normalized(),Vector2.RIGHT.rotated(.297)]
	for heading in headings:
		var near := ability.get_target_lane_preview(origin+heading*3)
		var far := ability.get_target_lane_preview(origin+heading*800)
		_check(near.waves.size()==4,"Fan needs three lanes plus center follow-up")
		for index in 4:
			var lane: Dictionary = near.waves[index]
			_check(lane.end.is_equal_approx(far.waves[index].end),"Pointer distance changed reach")
			_check(lane.contact.is_equal_approx(origin+heading*34),"Branches did not share sword contact")
			_check(lane.direction.is_equal_approx(heading.rotated(deg_to_rad([-20.0,20.0,0.0,0.0][index]))),"Fan does not rotate with aim")
	var foes: Array[ForsakenThrall] = []
	for offset in [Vector2(60,0),Vector2(180,0),Vector2(180,-53),Vector2(180,53),Vector2(180,100),Vector2(238,0)]:
		var foe: ForsakenThrall = Thrall.instantiate()
		foe.position = origin+offset
		foe.target = actor
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000,false)
		foe.health_component.set_current_health(1000)
		foes.append(foe)
	await physics_frame
	await physics_frame
	var counts: Dictionary = {}
	ability.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void:
		counts[target] = counts.get(target,0)+1
		_check(info.stun_seconds==0.0,"Fan applied stun"))
	_check(actor.request_ability(1),"Fan lost equipped slot binding")
	_check(not review.earthsplitter_review.set_form(2),"Form changed during aim")
	actor.ground_point_targeting.cancel_targeting()
	_check(ability.request_cast_at(origin+Vector2(196,0),100),"Fan cast rejected")
	_check(ability.get_cast_direction()==Vector2.RIGHT,"Sword follows a side lane")
	await create_timer(.14,false).timeout
	_check(foes[0].health_component.current_health==1000,"Fan damaged before sword contact")
	await create_timer(.10,false).timeout
	var sequences := get_nodes_in_group("earthsplitter_review_sequences")
	_check(sequences.size()==1 and sequences[0]._next==3,"Fan lanes were not released together")
	actor.position += Vector2(0,-70)
	ability.amplify_committed_cast(10)
	await create_timer(.15,false).timeout
	_check(not ability.is_casting(),"Fan extended body commitment")
	_check(sequences[0]._next==3,"Finisher should wait until after body recovery")
	_check(not review.earthsplitter_review.set_form(2),"Form change discarded a queued finisher")
	await create_timer(.3,false).timeout
	_check(get_nodes_in_group("earthsplitter_review_sequences").is_empty(),"Fan finisher sequence leaked")
	for index in foes.size():
		_check(is_equal_approx(foes[index].health_component.current_health,[760.0,760.0,900.0,900.0,1000.0,860.0][index]),"Fan damage/coverage wrong for target "+str(index))
		_check(counts.get(foes[index].get_node("Hurtbox"),0)==[2,2,1,1,0,1][index],"Overlap duplicated damage")
	actor.position = origin
	# Only the upper branch is blocked; center/lower must still work.
	var wall := StaticBody2D.new()
	wall.position = origin+Vector2(115,-37)
	var collision := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(12,12)
	collision.shape = rectangle
	wall.add_child(collision)
	lab.add_child(wall)
	for foe in foes:
		foe.health_component.set_current_health(1000)
	await physics_frame
	await physics_frame
	var preview := ability.get_target_lane_preview(origin+Vector2(196,0))
	_check(preview.waves[0].blocked,"Upper lane ignored obstacle")
	_check(not preview.waves[1].blocked and not preview.waves[2].blocked,"One branch wall incorrectly blocked whole fan")
	ability.clear_cooldown()
	ability.request_cast_at(origin+Vector2(196,0),100)
	await create_timer(.7,false).timeout
	_check(foes[2].health_component.current_health==1000,"Upper branch hit through wall")
	_check(is_equal_approx(foes[1].health_component.current_health,760) and is_equal_approx(foes[3].health_component.current_health,900),"Clear branches lost damage")
	wall.queue_free()
	await process_frame
	# A new wall between release beats must still stop the committed finisher.
	for foe in foes:
		foe.health_component.set_current_health(1000)
	ability.clear_cooldown()
	ability.request_cast_at(origin+Vector2(228,0),100)
	await create_timer(.39,false).timeout
	var late_wall := StaticBody2D.new()
	late_wall.position = origin+Vector2(95,0)
	var late_shape := CollisionShape2D.new()
	var late_rectangle := RectangleShape2D.new()
	late_rectangle.size = Vector2(8,120)
	late_shape.shape = late_rectangle
	late_wall.add_child(late_shape)
	lab.add_child(late_wall)
	await create_timer(.4,false).timeout
	_check(is_equal_approx(foes[1].health_component.current_health,900),"Late wall did not stop center follow-up")
	_check(foes[5].health_component.current_health==1000,"Finisher-only distant target was hit through a late wall")
	late_wall.queue_free()
	await process_frame
	_check(review.earthsplitter_review.set_form(2),"Cascade candidate was lost")
	_check(ability.definition.build_waves()[2].delay==.32,"Cascade timing changed")
	_check(review.earthsplitter_review.set_form(1),"Fan restore failed")
	ability.clear_cooldown()
	ability.request_cast_at(origin+Vector2(196,0),100)
	await create_timer(.23,false).timeout
	actor.is_defeated = true
	await create_timer(.3,false).timeout
	_check(get_nodes_in_group("earthsplitter_review_sequences").is_empty(),"Defeat left fan sequence")
	_check(get_nodes_in_group("earthsplitter_review_attacks").is_empty(),"Defeat left fan damage")
	_check(get_nodes_in_group("earthsplitter_review_effects").is_empty(),"Defeat left fan visuals")
	actor.is_defeated = false
	ability.cancel_cast()
	ability.clear_cooldown()
	ability.request_cast_at(origin+Vector2(228,0),100)
	await create_timer(.39,false).timeout
	_check(review.earthsplitter_review.set_enabled(false),"Review restoration failed")
	await create_timer(.3,false).timeout
	_check(get_nodes_in_group("earthsplitter_review_sequences").is_empty() and get_nodes_in_group("earthsplitter_review_attacks").is_empty(),"Review exit retained a queued finisher")
	_check(ability.definition==original,"Original ability not restored")
	_check(root.get_node("RunSession").king_skill_slots==saved,"Fan modified saved slots")
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("EARTHSPLITTER_FAN_CHECKS=",checks," FAILURES=",failures)
	quit(0 if failures==0 else 1)
