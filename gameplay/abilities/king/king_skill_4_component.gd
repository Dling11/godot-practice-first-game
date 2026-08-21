class_name KingSkill4Component
extends AbilityComponent

## Resolves a concentrated first impact followed by one delayed larger radial hit
## at a player-confirmed world point. Presentation observes the two strike events.

var _target_global_position := Vector2.ZERO


func request_cast_at(target_global_position: Vector2, equipped_weapon_damage := 0.0) -> bool:
	var skill := definition as KingSkill4Definition
	var actor := owner as Node2D
	if skill == null or actor == null:
		return false
	var offset := target_global_position - actor.global_position
	if offset.length() > skill.target_range_pixels:
		offset = offset.normalized() * skill.target_range_pixels
	_target_global_position = actor.global_position + offset
	return request_cast(offset, equipped_weapon_damage)


func supports_ground_targeting() -> bool:
	return true


func get_target_range_pixels() -> float:
	var skill := definition as KingSkill4Definition
	return skill.target_range_pixels if skill != null else 0.0


func get_target_radius_pixels() -> float:
	var skill := definition as KingSkill4Definition
	return skill.explosion_radius_pixels if skill != null else 0.0


func get_target_global_position() -> Vector2:
	var skill := definition as KingSkill4Definition
	return _target_global_position + Vector2(0.0, skill.ground_center_offset_y if skill != null else 0.0)


func cancel_cast() -> void:
	_reset_hitbox_position()
	super.cancel_cast()


func _start_current_strike() -> void:
	var skill := definition as KingSkill4Definition
	if skill == null or hitbox == null or collision_shape == null:
		return
	var strike_count := definition.strike_count()
	_strike_time_remaining = definition.active_seconds / float(strike_count)
	collision_shape.shape = (
		skill.explosion_hitbox_shape
		if _current_strike_index >= strike_count - 1
		else definition.hitbox_shape
	)
	hitbox.global_position = get_target_global_position()
	hitbox.activate_radial(
		definition.resolve_strike_damage(_equipped_weapon_damage, _current_strike_index),
		owner,
		hitbox.global_position,
		definition.resolve_strike_knockback(_current_strike_index),
		definition.resolve_strike_stagger(_current_strike_index),
		_critical_chance_ratio,
		_critical_damage_multiplier
	)
	strike_started.emit(_current_strike_index, strike_count, _strike_time_remaining)


func _advance_phase() -> void:
	var previous_phase := phase
	super._advance_phase()
	if previous_phase == Phase.RECOVERY:
		_reset_hitbox_position()


func _reset_hitbox_position() -> void:
	if hitbox != null:
		hitbox.position = Vector2.ZERO
