class_name PlayerMovementComponent
extends Node

## Calculates velocity without owning input, physics movement, or presentation.

@export_range(1.0, 1000.0, 1.0, "suffix:px/s") var max_speed: float = 120.0
@export_range(1.0, 5000.0, 1.0, "suffix:px/s^2") var acceleration: float = 900.0
@export_range(1.0, 5000.0, 1.0, "suffix:px/s^2") var deceleration: float = 1100.0


func calculate_velocity(
	current_velocity: Vector2,
	move_direction: Vector2,
	delta: float
) -> Vector2:
	var target_velocity := move_direction.limit_length(1.0) * max_speed
	var change_rate := acceleration if not move_direction.is_zero_approx() else deceleration
	return current_velocity.move_toward(target_velocity, change_rate * delta)
