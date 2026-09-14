extends SceneTree

const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const Thrall = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
var checks := 0
var failures := 0
func _initialize() -> void:
	call_deferred("_run")
func _check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var lab := Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	var player: Player = lab.player
	var review: Node = lab.get_node("KingSpellwardReview")
	review.open_review()
	lab.clear_simulation()
	var ability: AbilityComponent = player.ability_1_component
	var original := ability.definition
	var old_script: Script = ability.get_script()
	var slots: Array = player.get_node("KingSkillLibrary").current_ids()
	var saved: Array = root.get_node("RunSession").king_skill_slots.duplicate()
	review.toggle_earthsplitter_review()
	_check(review.earthsplitter_review.enabled, "Earthsplitter toggle failed")
	_check(player.get_ability_component_for_slot(1) == ability, "Slot 1 must point at the live review")
	_check(original.activation_mode == AbilityDefinition.ActivationMode.DIRECTIONAL_WEDGE_TARGETED, "Original definition was changed")
	player.position = Vector2(300,300)
	player.set_physics_process(false)
	# Cursor distance selects heading only; all facings retain the exact reach.
	var facings := [Vector2.RIGHT,Vector2(1,1).normalized(),Vector2.DOWN,Vector2(-1,1).normalized(),Vector2.LEFT,Vector2(-1,-1).normalized(),Vector2.UP,Vector2(1,-1).normalized(),Vector2.RIGHT.rotated(.297)]
	for direction in facings:
		var near := ability.get_target_lane_preview(player.position + direction*12)
		var far := ability.get_target_lane_preview(player.position + direction*500)
		_check(near.end.is_equal_approx(far.end), "Cursor distance changed lane length")
		_check(is_equal_approx(player.position.distance_to(near.end),164.0), "Clear-space lane lost full reach")
		_check(near.direction.is_equal_approx(direction), "Exact aim angle was quantized")
		ability.clear_cooldown()
		_check(ability.request_cast_at(player.position + direction*12,100), "Near-pointer cast failed")
		_check(ability.get_target_global_position().is_equal_approx(near.end), "Preview and committed endpoint diverged")
		ability.cancel_cast()
	ability.clear_cooldown()
	player.request_ability(1)
	player.ground_point_targeting.update_aim(player.position + Vector2(12,0),Vector2.ZERO)
	var near_aim: Vector2 = player.ground_point_targeting._target_local
	player.ground_point_targeting.update_aim(player.position,Vector2.ZERO)
	_check(near_aim.is_equal_approx(Vector2(164,0)), "Near-pointer marker is not full length")
	_check(player.ground_point_targeting._target_local.is_equal_approx(near_aim), "Centered cursor lost heading")
	player.ground_point_targeting.cancel_targeting()
	var foes: Array[ForsakenThrall] = []
	for offset in [Vector2(60,0), Vector2(110,0), Vector2(150,0), Vector2(90,65)]:
		var foe: ForsakenThrall = Thrall.instantiate()
		foe.position = player.position + offset
		foe.target = player
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000,false)
		foe.health_component.set_current_health(1000)
		foes.append(foe)
	await create_timer(.3).timeout
	_check(player.request_ability(1) and player.ground_point_targeting.is_targeting(), "Skill 1 must target before casting")
	player.ground_point_targeting.cancel_targeting()
	_check(ability.is_ready(), "Cancelling aim must not spend cooldown")
	var hits: Dictionary = {}
	ability.hit_landed.connect(func(target: HurtboxComponent, _info: DamageInfo) -> void: hits[target] = hits.get(target,0)+1)
	_check(ability.request_cast_at(Vector2(464,300),100), "Ground cast failed")
	_check(not review.earthsplitter_review.set_enabled(false), "Cannot swap during windup")
	await create_timer(.14).timeout
	_check(foes[0].health_component.current_health == 1000, "Damage happened before sword contact")
	await create_timer(.24, false).timeout
	_check(not ability.is_casting(), "Player commitment exceeded .38 seconds")
	_check(not get_nodes_in_group("earthsplitter_review_effects").is_empty(), "Effects must outlast body commitment")
	player.position += Vector2(0,55)
	await create_timer(.22).timeout
	for i in 3:
		_check(foes[i].health_component.current_health < 1000, "Wave missed in-lane target " + str(i))
		_check(is_equal_approx(foes[i].health_component.current_health, 835.0), "Each target must receive one 165% weapon hit")
		_check(not foes[i].stagger_component.is_stunned(), "Earthsplitter must never stun")
	_check(foes[3].health_component.current_health == 1000, "Out-of-lane target was hit")
	for count in hits.values():
		_check(count == 1, "A target received duplicate rupture hits")
	_check(hits.size() == 3, "The whole lane must hit three targets once")
	for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]:
		ability.clear_cooldown()
		_check(ability.request_cast_at(player.position + direction*500,100), "Cardinal cast failed")
		_check(ability.get_target_global_position().distance_to(player.position) <= 164.01, "Range did not clamp")
		ability.cancel_cast()
	await create_timer(.1).timeout
	_check(get_nodes_in_group("earthsplitter_review_effects").size() <= 1, "Cancelled windup left a sword")
	player.position = Vector2(300,300)
	for index in range(1,foes.size()):
		foes[index].position = Vector2(700,600+index*25)
	for direction in facings:
		foes[0].position = player.position + direction*100.0
		foes[0].health_component.set_current_health(1000)
		await physics_frame
		await physics_frame
		ability.clear_cooldown()
		player.ground_point_targeting.begin_targeting(ability,direction)
		player.ground_point_targeting.update_aim(player.position+direction*12.0,Vector2.ZERO)
		player.ground_point_targeting.confirm_targeting()
		_check(ability.get_target_global_position().is_equal_approx(player.position+direction*164.0), "Confirmed marker changed heading or reach: %s actual=%s expected=%s" % [direction,ability.get_target_global_position(),player.position+direction*164.0])
		await create_timer(.65).timeout
		_check(foes[0].health_component.current_health < 1000, "Confirmed near-pointer lane missed its directional target: %s" % direction)
	ability.clear_cooldown()
	var wall := StaticBody2D.new()
	wall.position = player.position + Vector2(85,0)
	var collision := CollisionShape2D.new()
	var rect := RectangleShape2D.new()
	rect.size = Vector2(10,110)
	collision.shape = rect
	wall.add_child(collision)
	lab.add_child(wall)
	await physics_frame
	await physics_frame
	foes[3].position = player.position + Vector2(102,0)
	foes[3].health_component.set_current_health(1000)
	var wall_preview := ability.get_target_lane_preview(player.position+Vector2(164,0))
	_check(wall_preview.blocked and wall_preview.end.x > player.position.x + 45.0 and wall_preview.end.x + 17.0 < wall.position.x - 4.0, "Preview does not account for wave width")
	_check(ability.request_cast_at(player.position+Vector2(164,0),100), "Wall cast failed")
	_check(ability.get_target_global_position().is_equal_approx(wall_preview.end), "Wall preview differs from committed endpoint")
	_check(ability.get_target_global_position().x < wall.position.x, "Target point crossed wall")
	await create_timer(.6).timeout
	_check(foes[3].health_component.current_health == 1000, "Damage reached behind wall")
	_check(review.earthsplitter_review.set_enabled(false), "Restoration failed")
	_check(ability.get_script()==old_script and ability.definition==original, "Script or definition did not restore")
	_check(player.get_node("KingSkillLibrary").current_ids()==slots, "Slots did not restore")
	_check(root.get_node("RunSession").king_skill_slots==saved, "Review changed saved loadout")
	wall.queue_free()
	await process_frame
	await physics_frame
	_check(review.earthsplitter_review.set_enabled(true), "Second review activation failed")
	player.position = Vector2(300,300)
	player.attack_component.set_equipment_attack_speed_bonus(.5)
	player.movement_component.set_equipment_speed_bonus(.35)
	ability.clear_cooldown()
	ability.request_cast_at(player.position+Vector2(0,160),100)
	await create_timer(.37, false).timeout
	_check(not ability.is_casting(), "Gear speed must not create a longer casting lock")
	_check(not get_nodes_in_group("earthsplitter_review_attacks").is_empty(), "Rupture should still travel after control returns")
	_check(review.earthsplitter_review.set_enabled(false), "Post-release review restoration failed")
	await process_frame
	_check(get_nodes_in_group("earthsplitter_review_attacks").is_empty(), "Restoring review left invisible damage authority")
	_check(get_nodes_in_group("earthsplitter_review_effects").is_empty(), "Restoring review left orphaned presentation")
	_check(review.earthsplitter_review.set_enabled(true), "Death review activation failed")
	ability.clear_cooldown()
	ability.request_cast_at(player.position+Vector2(0,160),100)
	await create_timer(.23, false).timeout
	player.is_defeated = true
	await create_timer(.1).timeout
	_check(get_nodes_in_group("earthsplitter_review_attacks").is_empty(), "Defeat must cancel released damage")
	_check(get_nodes_in_group("earthsplitter_review_effects").is_empty(), "Defeat must clear sword and ground effects")
	player.is_defeated = false
	ability.cancel_cast()
	review.earthsplitter_review.set_enabled(false)
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("EARTHSPLITTER_CHECKS=", checks, " FAILURES=", failures)
	quit(0 if failures==0 else 1)
