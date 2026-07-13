class_name PlayerInputSource
extends Node

## Translates local device input into player intent.
## Keeping this boundary separate lets another authority source replace it later.

@export_range(0.0, 1.0, 0.01) var aim_deadzone: float = 0.25


func get_move_direction() -> Vector2:
	return Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_up",
		"player_move_down"
	)


func get_aim_direction(origin: Vector2, pointer_world_position: Vector2) -> Vector2:
	var stick_direction := Input.get_vector(
		"player_aim_left",
		"player_aim_right",
		"player_aim_up",
		"player_aim_down"
	)
	if stick_direction.length() >= aim_deadzone:
		return stick_direction.normalized()

	var pointer_direction := pointer_world_position - origin
	if pointer_direction.length_squared() > 16.0:
		return pointer_direction.normalized()

	return Vector2.ZERO


func is_primary_attack_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_attack_primary")


func is_evade_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_dodge")


func is_ability_1_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_ability_1")
