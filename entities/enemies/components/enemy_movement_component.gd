class_name EnemyMovementComponent
extends Node


func calculate_velocity(
	current_velocity: Vector2,
	direction: Vector2,
	max_speed: float,
	acceleration: float,
	delta: float
) -> Vector2:
	var target_velocity := direction.normalized() * max_speed if not direction.is_zero_approx() else Vector2.ZERO
	return current_velocity.move_toward(target_velocity, acceleration * delta)

