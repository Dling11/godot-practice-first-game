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
	var ability: RiftbreakComponent = player.ability_2_component
	var original := ability.definition
	var original_slots: Array = player.get_node("KingSkillLibrary").current_ids()
	var effect: AnimatedSprite2D = player.get_node("AbilityPivot/RiftbreakVisual/EffectSprite")
	var original_frames := effect.sprite_frames
	_check(not ability.supports_ground_targeting(), "Campaign Riftbreak must retain original mode during review")
	review.toggle_riftbreak_review()
	_check(review.riftbreak_review.enabled and ability.supports_ground_targeting(), "Lab preview must opt into targeted cast")
	_check(player.get_ability_component_for_slot(2) == ability, "Slot 2 must bind the per-player preview definition")
	_check(original.activation_mode == AbilityDefinition.ActivationMode.SELF_AREA, "Shared campaign definition was mutated")
	player.position = Vector2(300, 300)
	player.set_physics_process(false)
	var point := Vector2(430, 300)
	var foes: Array[ForsakenThrall] = []
	for offset in [Vector2.ZERO, Vector2(52, 0), Vector2(120, 0)]:
		var foe: ForsakenThrall = Thrall.instantiate()
		foe.position = point + offset
		foe.target = player
		lab.add_child(foe)
		foe.set_physics_process(false)
		foe.health_component.set_maximum_health(1000, false)
		foe.health_component.set_current_health(1000)
		foes.append(foe)
	await create_timer(.8).timeout
	_check(player.request_ability(2) and player.ground_point_targeting.is_targeting(), "2 must aim before spending cooldown")
	_check(ability.cooldown_remaining <= 0.0, "Aiming must not spend cooldown")
	player.ground_point_targeting.cancel_targeting()
	_check(ability.is_ready(), "Target cancel must remain free")
	_check(ability.request_cast_at(point, 100), "Targeted cast failed")
	_check(not review.riftbreak_review.set_enabled(false), "Cannot change preview during committed cast")
	await create_timer(.22).timeout
	_check(foes[0].stagger_component.is_stunned(), "Direct core hit must carry explicit stun")
	_check(foes[0].get_node("StunIndicator").visible, "Core target must show stars")
	_check(not foes[1].stagger_component.is_stunned(), "Outer blast must not stun")
	_check(not foes[1].get_node("StunIndicator").visible, "Outer target must not show stars")
	_check(foes[1].knockback_component.velocity.length() > 0.0, "Outer blast must still push")
	_check(foes[0].health_component.current_health < foes[1].health_component.current_health, "Core and rim must have distinct damage")
	_check(foes[2].health_component.current_health == 1000, "Outside target must receive no damage")
	var core_health := foes[0].health_component.current_health
	await create_timer(.23).timeout
	_check(not ability.is_casting() and effect.visible, "Control must return before the debris finishes")
	player.position += Vector2(-70, 40)
	_check(effect.global_position.distance_to(point) < .1, "Released effect must stay at the aimed contact")
	_check(foes[0].health_component.current_health == core_health, "Aftermath must not apply repeated hidden damage")
	ability.clear_cooldown()
	var wall := StaticBody2D.new()
	wall.position = player.position + Vector2(50, 0)
	var shape := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(10, 120)
	shape.shape = rectangle
	wall.add_child(shape)
	lab.add_child(wall)
	await physics_frame
	await physics_frame
	_check(ability.request_cast_at(player.position + Vector2(400, 0), 100), "Wall test cast failed")
	_check(ability.get_target_global_position().x < wall.position.x, "Ground strike must not pass through terrain")
	ability.cancel_cast()
	wall.queue_free()
	await process_frame
	await physics_frame
	ability.clear_cooldown()
	_check(ability.request_cast_at(player.position + Vector2(400, 0), 100), "Range test cast failed")
	_check(ability.get_target_global_position().distance_to(player.position) <= 180.01, "Target must clamp to range")
	ability.cancel_cast()
	_check(review.riftbreak_review.set_enabled(false), "Preview restoration failed")
	_check(ability.definition == original and effect.sprite_frames == original_frames, "Original resources must restore exactly")
	_check(player.get_node("KingSkillLibrary").current_ids() == original_slots, "Original loadout must restore")
	var control := foes[2].stagger_component
	foes[2].health_component.apply_damage(DamageInfo.new(400, player, Vector2.RIGHT, 40, .11, true))
	_check(not control.is_stunned(), "A huge critical hit alone must never infer stun")
	_check(not foes[2].get_node("StunIndicator").visible, "High damage flinch must not show stars")
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("RIFTBREAK_TARGETED_REVIEW_CHECKS=", checks, " FAILURES=", failures)
	quit(0 if failures == 0 else 1)
