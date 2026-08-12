class_name SovereignPursuitComponent
extends AbilityComponent

## Moves the player toward one validated ground point, then resolves one radial
## contact at the actual collision-safe landing position.

var _target_global_position := Vector2.ZERO


func request_cast_at(target_global_position: Vector2, equipped_weapon_damage := 0.0) -> bool:
	var pursuit := definition as SovereignPursuitDefinition
	if pursuit == null or owner == null:
		return false
	var actor := owner as Node2D
	if actor == null:
		return false
	var origin: Vector2 = actor.global_position
	var offset := target_global_position - origin
	if offset.length() > pursuit.target_range_pixels:
		offset = offset.normalized() * pursuit.target_range_pixels
	_target_global_position = origin + offset
	return request_cast(offset, equipped_weapon_damage)


func supports_ground_targeting() -> bool:
	return true


func get_target_range_pixels() -> float:
	var pursuit := definition as SovereignPursuitDefinition
	return pursuit.target_range_pixels if pursuit != null else 0.0


func get_target_radius_pixels() -> float:
	var pursuit := definition as SovereignPursuitDefinition
	return pursuit.landing_radius_pixels if pursuit != null else 0.0


func get_active_velocity() -> Vector2:
	if phase != Phase.ACTIVE or owner == null:
		return Vector2.ZERO
	var actor := owner as Node2D
	if actor == null:
		return Vector2.ZERO
	var remaining: Vector2 = _target_global_position - actor.global_position
	if remaining.length_squared() <= 4.0:
		return Vector2.ZERO
	return remaining.normalized() * minf(remaining.length() / maxf(_phase_time_remaining, 0.016), 1000.0)


func has_active_movement() -> bool:
	return phase == Phase.ACTIVE


func cancel_cast() -> void:
	if phase == Phase.ACTIVE:
		invulnerability_changed.emit(false)
	_reset_hitbox_position()
	super.cancel_cast()


func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			_enter_phase(Phase.ACTIVE, definition.active_seconds)
			invulnerability_changed.emit(true)
		Phase.ACTIVE:
			invulnerability_changed.emit(false)
			_land()
			_enter_phase(Phase.RECOVERY, definition.recovery_seconds)
		Phase.RECOVERY:
			if hitbox != null:
				hitbox.deactivate()
			_reset_hitbox_position()
			phase = Phase.IDLE
			ability_finished.emit()


func _land() -> void:
	var pursuit := definition as SovereignPursuitDefinition
	if pursuit == null or hitbox == null:
		return
	_current_strike_index = 0
	# AbilityPivot rotates for directional skills. Pursuit is a world-space landing
	# circle, so place it explicitly at King's feet instead of inheriting that turn.
	hitbox.global_position = (owner as Node2D).global_position + Vector2(0.0, pursuit.ground_center_offset_y)
	hitbox.activate_radial(
		definition.resolve_strike_damage(_equipped_weapon_damage, 0),
		owner,
		hitbox.global_position,
		definition.resolve_strike_knockback(0),
		definition.resolve_strike_stagger(0)
	)
	strike_started.emit(0, 1, definition.recovery_seconds)


func _reset_hitbox_position() -> void:
	if hitbox != null:
		hitbox.position = Vector2.ZERO
