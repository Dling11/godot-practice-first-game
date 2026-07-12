extends Node2D

## Presents aim direction without owning or changing player gameplay state.


func set_facing_direction(direction: Vector2) -> void:
	if not direction.is_zero_approx():
		rotation = direction.angle()

