extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	var ability := player.ability_1_component as EchoingSeverComponent
	var targeting := player.directional_wedge_targeting
	var visual := player.get_node("AbilityPivot/EchoingSeverVisual") as EchoingSeverVisual
	var weapon_visual := player.get_node("VisualRoot/WeaponVisual") as PlayerWeaponVisual
	var body_visual := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	if ability == null or ability.definition.ability_id != &"echoing_sever":
		_fail("King Skill 1 is not owned by EchoingSeverComponent.")
		return
	if visual == null or visual.effect_sprite == null:
		_fail("Echoing Sever's final presentation sprite is not wired into the player scene.")
		return
	for animation_name in [&"wind_up", &"primary", &"rift_hold", &"echo"]:
		if not visual.effect_sprite.sprite_frames.has_animation(animation_name):
			_fail("Echoing Sever VFX is missing animation: %s" % animation_name)
			return
	if not player.request_ability_1() or not targeting.is_targeting():
		_fail("Skill 1 did not enter directional wedge targeting.")
		return
	if ability.cooldown_remaining > 0.0 or ability.is_casting():
		_fail("Target preview spent cooldown or began damage authority before confirm.")
		return
	if not player.request_ability_1() or not targeting.is_targeting():
		_fail("Repeating Skill 1 should be consumed without confirming or cancelling targeting.")
		return
	if ability.is_casting() or ability.cooldown_remaining > 0.0:
		_fail("Repeating Skill 1 incorrectly committed Echoing Sever.")
		return
	player._set_movement_facing_direction(Vector2.LEFT)
	if not targeting.is_targeting():
		_fail("Movement incorrectly removed the active target preview.")
		return
	targeting.update_aim(Vector2(80.0, 14.0), Vector2.ZERO)
	var expected_pointer_aim := Vector2(80.0, 14.0).normalized()
	if targeting.get_target_direction().distance_to(expected_pointer_aim) > 0.0001:
		_fail("Pointer aim did not preserve its exact 360-degree direction.")
		return
	if not is_zero_approx(targeting.rotation):
		_fail("Directional target presentation rotated its node instead of drawing exact aim locally.")
		return
	if not root.get_node("CursorService").targeting_active:
		_fail("Entering target mode did not request the targeting hardware cursor.")
		return
	var right_click_cancel := InputEventMouseButton.new()
	right_click_cancel.button_index = MOUSE_BUTTON_RIGHT
	right_click_cancel.pressed = true
	player._unhandled_input(right_click_cancel)
	if targeting.is_targeting() or ability.cooldown_remaining > 0.0:
		_fail("Right-click cancellation failed or spent Echoing Sever's cooldown.")
		return
	if root.get_node("CursorService").targeting_active:
		_fail("Cancelling target mode did not restore the gameplay cursor.")
		return
	if not player.request_ability_1() or not player.request_evade(Vector2.RIGHT):
		_fail("Dash was not available from the movable target-preview state.")
		return
	if targeting.is_targeting():
		_fail("Dash did not cancel the target preview before movement commitment.")
		return
	player.evade_component.cancel_evade()
	if not player.request_ability_1():
		_fail("Echoing Sever could not target again after a free cancellation.")
		return
	targeting.update_aim(Vector2.LEFT, Vector2.DOWN)
	if targeting.get_target_direction() != Vector2.DOWN:
		_fail("Right-stick aim did not take priority over pointer aim.")
		return
	var ten_oclock_aim := Vector2(-0.8660254, -0.5)
	targeting.update_aim(ten_oclock_aim, Vector2.ZERO)
	if targeting.get_target_direction().distance_to(ten_oclock_aim) > 0.0001:
		_fail("A ten-o'clock aim was collapsed back to a cardinal direction.")
		return

	var strikes: Array[int] = []
	ability.strike_started.connect(func(index: int, _count: int, _duration: float) -> void:
		strikes.append(index)
	)
	var confirm_event := InputEventAction.new()
	confirm_event.action = &"player_attack_primary"
	confirm_event.pressed = true
	player._unhandled_input(confirm_event)
	if targeting.is_targeting():
		_fail("Primary attack/right trigger did not confirm the active preview.")
		return
	if not ability.is_casting() or ability.cooldown_remaining <= 0.0:
		_fail("Confirmation did not begin the cast and cooldown together.")
		return
	if player.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
		_fail("Target confirmation leaked into a simultaneous basic attack.")
		return
	if ability.get_cast_direction().distance_to(ten_oclock_aim) > 0.0001:
		_fail("The confirmed exact aim direction was not frozen for the cast.")
		return
	if player.facing_direction != Vector2.LEFT:
		_fail("Ten-o'clock gameplay aim did not select King's nearest left-facing body animation.")
		return

	ability._physics_process(0.17)
	if strikes != [0]:
		_fail("The primary sever did not open exactly one first hit window.")
		return
	if visual.effect_sprite.animation != &"primary" or not visual.effect_sprite.visible:
		_fail("The primary contact did not select the authored cleave VFX.")
		return
	if weapon_visual.swing_trail.visible or weapon_visual.swing_smoke.visible:
		_fail("Echoing Sever leaked the shared normal-attack trail behind its dedicated VFX.")
		return
	if body_visual.get("_recoil_tween") == null:
		_fail("The primary Echoing Sever contact did not start King's restrained recoil/settle.")
		return
	ability._physics_process(0.09)
	if strikes.size() != 1:
		_fail("The inactive rift delay created an unintended damage window.")
		return
	ability._physics_process(0.30)
	if strikes != [0, 1]:
		_fail("The delayed rift did not create exactly one second hit window.")
		return
	if visual.effect_sprite.animation != &"echo":
		_fail("The delayed contact did not select the authored echo VFX.")
		return
	ability._physics_process(0.30)
	if ability.is_casting():
		_fail("Echoing Sever did not leave recovery cleanly.")
		return

	print("Echoing Sever targeting and timing smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
