extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const TargetScene = preload("res://entities/training/training_target.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const PiercingRushDefinition = preload("res://data/abilities/opaw/warrior/piercing_rush.tres")
const SweepingCutDefinition = preload("res://data/abilities/sweeping_cut.tres")
const IronSword = preload("res://data/weapons/iron_sword.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if (
		PiercingRushDefinition.ability_id != &"piercing_rush"
		or PiercingRushDefinition.activation_mode
			!= AbilityDefinition.ActivationMode.IMMEDIATE_DIRECTIONAL
		or PiercingRushDefinition.presentation_style
			!= AbilityDefinition.PresentationStyle.THRUST
		or not is_equal_approx(PiercingRushDefinition.weapon_damage_multiplier, 1.8)
		or not is_equal_approx(PiercingRushDefinition.get_forward_lance_reach_pixels(), 128.0)
		or not is_equal_approx(PiercingRushDefinition.get_forward_lance_half_width_pixels(), 15.0)
		or PiercingRushDefinition.hitbox_shape == null
	):
		_fail("Piercing Rush definition is missing its directional, thrust, scaling, or 128x30 hitbox data.")
		return

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.global_position = Vector2(100.0, 100.0)
	player._set_facing_direction(Vector2.RIGHT)
	await process_frame
	var effect_sprite := player.get_node(
		"AbilityPivot/PiercingRushVisual/EffectSprite"
	) as Sprite2D
	if (
		effect_sprite == null
		or effect_sprite.texture == null
		or effect_sprite.texture.get_size() != Vector2(576.0, 384.0)
		or not effect_sprite.region_enabled
		or effect_sprite.region_rect.size != Vector2(192.0, 192.0)
	):
		_fail("Piercing Rush is missing its six-frame 192x192 generated VFX atlas contract.")
		return
	if player.skill_loadout.get_slot(1).ability != PiercingRushDefinition:
		_fail("Piercing Rush is not equipped in Opaw's slot 1.")
		return
	if player.skill_loadout.get_slot(1).ability == SweepingCutDefinition:
		_fail("Sweeping Cut was not removed from the active slot.")
		return

	var ability := player.ability_1_component
	var observed := {
		"active_start": Vector2.ZERO,
		"active_end": Vector2.ZERO,
		"active_seen": false,
		"visual_seen": false,
	}
	ability.phase_changed.connect(func(phase: int, _duration_seconds: float) -> void:
		if phase == AbilityComponent.Phase.ACTIVE:
			observed.active_start = player.global_position
			observed.active_seen = true
			observed.visual_seen = player.get_node("AbilityPivot/PiercingRushVisual").visible
		elif phase == AbilityComponent.Phase.RECOVERY:
			observed.active_end = player.global_position
	)
	if not player.request_ability_1():
		_fail("Ready Piercing Rush request was rejected.")
		return
	if player.get_node("AbilityPivot/SweepingCutVisual").visible:
		_fail("Piercing Rush incorrectly activated the preserved sweep presentation.")
		return
	if not is_equal_approx(ability.get_resolved_damage(), 45.0):
		_fail("Ashwood Piercing Rush did not snapshot 180% weapon damage.")
		return
	if player.request_primary_attack() or player.request_evade(Vector2.RIGHT):
		_fail("Normal attack or evade was accepted during Piercing Rush commitment.")
		return
	while ability.is_casting():
		if player.health_component.is_invulnerable:
			_fail("Piercing Rush incorrectly granted dash invulnerability.")
			return
		await physics_frame
	if not observed.active_seen or not observed.visual_seen:
		_fail("Piercing Rush did not enter an active spectral-thrust presentation.")
		return
	var rush_distance: float = observed.active_end.distance_to(observed.active_start)
	if rush_distance < 42.0 or rush_distance > 58.0:
		_fail("Piercing Rush movement was outside its roughly 50-pixel budget: %.2f." % rush_distance)
		return
	if player.velocity != Vector2.ZERO:
		_fail("Piercing Rush carried unintended sliding velocity into recovery.")
		return

	ability._physics_process(ability.cooldown_remaining + 0.1)
	if not player.set_weapon_definition(IronSword) or not player.request_ability_1():
		_fail("Iron Sword could not begin the shared Piercing Rush technique.")
		return
	if not is_equal_approx(ability.get_resolved_damage(), 57.6):
		_fail("Iron Piercing Rush did not derive damage from the equipped weapon.")
		return
	ability.cancel_cast()
	player.queue_free()
	await process_frame

	if not await _test_click_and_hit():
		return
	if not await _test_cast_facing_lock():
		return
	print("Piercing Rush movement, scaling, click, hit, and facing-lock smoke test passed.")
	quit(0)


func _test_click_and_hit() -> bool:
	var player := PlayerScene.instantiate() as Player
	var target := TargetScene.instantiate()
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(player)
	root.add_child(target)
	root.add_child(hud)
	player.global_position = Vector2(100.0, 180.0)
	# This target sits beyond the former 98 px contact tip, proving the enlarged
	# 128 px central lance reaches the visibly extended bright core at activation.
	target.global_position = Vector2(235.0, 180.0)
	player._set_facing_direction(Vector2.RIGHT)
	hud.bind_player(player)
	await process_frame
	var slot := hud.get_skill_slot(1)
	if slot == null or slot.ability_name.text != "PIERCE RUSH" or slot.activation_button.disabled:
		_fail("Clickable HUD slot 1 did not present ready Piercing Rush.")
		return false
	var hit := {"count": 0, "knockback": 0.0}
	target.get_node("HealthComponent").damaged.connect(func(info: DamageInfo) -> void:
		hit.count += 1
		hit.knockback = info.knockback_strength
	)
	slot.activation_button.pressed.emit()
	if not player.ability_1_component.is_casting() or not slot.activation_button.disabled:
		_fail("Clicking slot 1 did not request Piercing Rush and lock its cooldown button.")
		return false
	for frame in range(45):
		await physics_frame
	var health := target.get_node("HealthComponent") as HealthComponent
	if not is_equal_approx(health.current_health, 55.0) or hit.count != 1:
		_fail("Piercing Rush did not deliver one 45-damage extended-lance hit.")
		return false
	if not is_equal_approx(hit.knockback, 112.0):
		_fail("Piercing Rush did not deliver its authored knockback.")
		return false
	if slot.state_label.text == "READY":
		_fail("Piercing Rush HUD ignored its cooldown after a clicked cast.")
		return false
	return true


func _test_cast_facing_lock() -> bool:
	var player := PlayerScene.instantiate() as Player
	var up_target := TargetScene.instantiate()
	var left_target := TargetScene.instantiate()
	var right_target := TargetScene.instantiate()
	var down_target := TargetScene.instantiate()
	root.add_child(player)
	root.add_child(up_target)
	root.add_child(left_target)
	root.add_child(right_target)
	root.add_child(down_target)
	player.global_position = Vector2(300.0, 260.0)
	up_target.global_position = Vector2(300.0, 180.0)
	left_target.global_position = Vector2(220.0, 260.0)
	right_target.global_position = Vector2(380.0, 260.0)
	down_target.global_position = Vector2(300.0, 340.0)
	player._set_facing_direction(Vector2.UP)
	await process_frame
	if not player.request_ability_1():
		_fail("Upward Piercing Rush request was rejected.")
		return false
	var pivot := player.get_node("AbilityPivot") as Node2D
	for direction in [Vector2.LEFT, Vector2.DOWN, Vector2.RIGHT]:
		await physics_frame
		player._set_facing_direction(direction)
		if not is_equal_approx(pivot.rotation, Vector2.UP.angle()):
			_fail("Piercing Rush pivot followed movement-facing input during a locked cast.")
			return false
	while player.ability_1_component.is_casting():
		await physics_frame
	var up_health := up_target.get_node("HealthComponent") as HealthComponent
	for wrong_target in [left_target, right_target, down_target]:
		var wrong_health := wrong_target.get_node("HealthComponent") as HealthComponent
		if not is_equal_approx(wrong_health.current_health, wrong_health.maximum_health):
			_fail("Piercing Rush hit a target outside its cast-facing lane.")
			return false
	if not is_equal_approx(up_health.current_health, 55.0):
		_fail("Piercing Rush did not retain its upward damage lane through movement-facing input.")
		return false
	if not is_equal_approx(pivot.rotation, Vector2.RIGHT.angle()):
		_fail("Ability pivot did not restore the latest facing after the cast ended.")
		return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
