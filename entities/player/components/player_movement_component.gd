class_name PlayerMovementComponent
extends Node

signal speed_changed(speed: float)

## Calculates velocity without owning input, physics movement, or presentation.

@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var max_speed: float = 120.0
@export_range(1.0, 5000.0, 1.0, "suffix:px/s^2") var acceleration: float = 900.0
@export_range(1.0, 5000.0, 1.0, "suffix:px/s^2") var deceleration: float = 1100.0

var _base_max_speed: float
var _equipment_bonus := 0.0
var _temporary_bonus := 0.0


func _ready() -> void:
	_base_max_speed = max_speed


func set_equipment_speed_bonus(bonus_ratio: float) -> void:
	_equipment_bonus = clampf(bonus_ratio, 0.0, 0.35)
	_refresh_speed()


func set_temporary_speed_bonus(bonus_ratio: float) -> void:
	_temporary_bonus = maxf(bonus_ratio, 0.0)
	_refresh_speed()


func _refresh_speed() -> void:
	max_speed = _base_max_speed * (1.0 + clampf(_equipment_bonus + _temporary_bonus, 0.0, .35))
	speed_changed.emit(max_speed)


func calculate_velocity(
	current_velocity: Vector2,
	move_direction: Vector2,
	delta: float
) -> Vector2:
	var target_velocity := move_direction.limit_length(1.0) * max_speed
	var change_rate := acceleration if not move_direction.is_zero_approx() else deceleration
	return current_velocity.move_toward(target_velocity, change_rate * delta)
