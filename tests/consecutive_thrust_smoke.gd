extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TargetScene = preload("res://entities/training/training_target.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const ConsecutiveThrust = preload("res://data/abilities/opaw/warrior/consecutive_thrust.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if (
		ConsecutiveThrust.ability_id != &"consecutive_thrust"
		or ConsecutiveThrust.strike_count() != 7
		or not is_equal_approx(ConsecutiveThrust.weapon_damage_multiplier, 1.0)
		or ConsecutiveThrust.hitbox_shape == null
	):
		_fail("Consecutive Thrust definition is missing its seven-strike directional contract.")
		return

	var player := PlayerScene.instantiate() as Player
	var target := TargetScene.instantiate()
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(player)
	root.add_child(target)
	root.add_child(hud)
	player.global_position = Vector2(120.0, 180.0)
	target.global_position = Vector2(174.0, 180.0)
	player._set_facing_direction(Vector2.RIGHT)
	hud.bind_player(player)
	await process_frame
	if player.skill_loadout.get_slot(2).is_equipped():
		_fail("Normal loadout exposed Consecutive Thrust before the F9 test preset.")
		return

	var f9_event := InputEventAction.new()
	f9_event.action = "debug_max_progression"
	f9_event.pressed = true
	player._unhandled_input(f9_event)
	await process_frame
	if (
		player.progression_component.level != 10
		or player.progression_component.coins != 999
		or player.skill_loadout.get_slot(2).ability != ConsecutiveThrust
	):
		_fail("F9 did not enable the complete authored debug skill loadout.")
		return
	var slot := hud.get_skill_slot(2)
	if slot == null or slot.ability_name.text != "RAPID THRUST" or slot.activation_button.disabled:
		_fail("F9 did not refresh the clickable Consecutive Thrust HUD slot.")
		return

	var ability := player.ability_2_component
	var observed_strikes: Array[int] = []
	ability.strike_started.connect(func(index: int, _count: int, _duration: float) -> void:
		observed_strikes.append(index)
	)
	var hit_amounts: Array[float] = []
	var hit_knockbacks: Array[float] = []
	var hit_staggers: Array[float] = []
	var health := target.get_node("HealthComponent") as HealthComponent
	health.damaged.connect(func(info: DamageInfo) -> void:
		hit_amounts.append(info.amount)
		hit_knockbacks.append(info.knockback_strength)
		hit_staggers.append(info.stagger_seconds)
	)
	slot.activation_button.pressed.emit()
	if not ability.is_casting() or player.request_primary_attack() or player.request_evade(Vector2.RIGHT):
		_fail("Consecutive Thrust did not commit correctly against normal attack and evade input.")
		return
	var body_visual := player.get_node("VisualRoot/ConsecutiveThrustBodyVisual") as ConsecutiveThrustBodyVisual
	var vfx_visual := player.get_node("AbilityPivot/ConsecutiveThrustVisual") as ConsecutiveThrustVisual
	for frame in range(105):
		await physics_frame
		if ability.phase == AbilityComponent.Phase.ACTIVE and (not body_visual.visible or not vfx_visual.visible):
			_fail("Consecutive Thrust did not show its dedicated body and VFX frames during active strikes.")
			return
	if ability.is_casting():
		_fail("Consecutive Thrust did not complete within its authored action window.")
		return
	if observed_strikes != [0, 1, 2, 3, 4, 5, 6]:
		_fail("Consecutive Thrust did not emit seven ordered strike windows.")
		return
	if hit_amounts.size() != 7 or hit_knockbacks.size() != 7 or hit_staggers.size() != 7:
		_fail("Consecutive Thrust did not hit one close target once per authored strike.")
		return
	var expected_damage := PackedFloat32Array([4.5, 4.75, 5.0, 5.25, 5.5, 6.25, 25.0])
	for index in expected_damage.size():
		if not is_equal_approx(hit_amounts[index], expected_damage[index]):
			_fail("Consecutive Thrust damage did not match authored rapid-flurry balance.")
			return
		if not is_equal_approx(hit_knockbacks[index], 0.0 if index < 6 else 150.0):
			_fail("Consecutive Thrust did not reserve knockback for the final lance.")
			return
		if not is_equal_approx(hit_staggers[index], 0.21 if index < 6 else 0.42):
			_fail("Consecutive Thrust did not carry its authored rapid-stagger contract.")
			return
	if not is_equal_approx(health.current_health, 43.75):
		_fail("Consecutive Thrust total seven-hit damage is not 225% of Ashwood base damage.")
		return
	if body_visual.visible or vfx_visual.visible:
		_fail("Consecutive Thrust visuals did not clean up after recovery.")
		return
	print("Rapid Consecutive Thrust F9, multi-hit, presentation, and balance smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
