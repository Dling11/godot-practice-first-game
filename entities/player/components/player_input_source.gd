class_name PlayerInputSource
extends Node

## Translates local device input into player intent.
## Keeping this boundary separate lets another authority source replace it later.

func get_move_direction() -> Vector2:
	return Input.get_vector(
		"player_move_left",
		"player_move_right",
		"player_move_up",
		"player_move_down"
	)


func resolve_cardinal_facing(move_direction: Vector2, current_facing: Vector2) -> Vector2:
	## Combat facing follows movement intent, never passive pointer position.
	## Exact diagonal ties retain the matching current axis to avoid flicker.
	if move_direction.is_zero_approx():
		return current_facing
	var horizontal := Vector2(signf(move_direction.x), 0.0)
	var vertical := Vector2(0.0, signf(move_direction.y))
	if absf(move_direction.x) > absf(move_direction.y):
		return horizontal
	if absf(move_direction.y) > absf(move_direction.x):
		return vertical
	if absf(current_facing.x) > 0.5 and signf(current_facing.x) == signf(move_direction.x):
		return horizontal
	if absf(current_facing.y) > 0.5 and signf(current_facing.y) == signf(move_direction.y):
		return vertical
	return horizontal if not is_zero_approx(move_direction.x) else vertical


func is_primary_attack_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_attack_primary")


func is_evade_just_pressed() -> bool:
	return Input.is_action_just_pressed("player_dodge")


func is_ability_1_just_pressed() -> bool:
	return (
		Input.is_action_just_pressed("player_skill_1")
		or Input.is_action_just_pressed("player_ability_1")
	)


func is_ability_2_just_pressed() -> bool:
	return (
		Input.is_action_just_pressed("player_skill_2")
		or Input.is_action_just_pressed("player_ability_2")
	)
