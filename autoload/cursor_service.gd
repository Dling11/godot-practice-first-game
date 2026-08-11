extends Node

## Owns the project's hardware cursor vocabulary. Gameplay systems request a
## semantic cursor state; no world Sprite2D follows the pointer with added lag.

const DEFAULT_CURSOR = preload("res://assets/ui/cursors/cursor_wayfarer_24.svg")
const INTERACT_CURSOR = preload("res://assets/ui/cursors/cursor_interact_24.svg")
const TARGET_CURSOR = preload("res://assets/ui/cursors/cursor_target_confirm_24.svg")

var targeting_active := false


func _ready() -> void:
	_install_cursor_vocabulary()
	_apply_arrow_cursor()


func set_targeting_active(active: bool) -> void:
	if targeting_active == active:
		return
	targeting_active = active
	_apply_arrow_cursor()


func _install_cursor_vocabulary() -> void:
	if DisplayServer.get_name() == "headless":
		return
	Input.set_custom_mouse_cursor(
		INTERACT_CURSOR,
		Input.CURSOR_POINTING_HAND,
		Vector2(7.0, 4.0)
	)


func _apply_arrow_cursor() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if targeting_active:
		Input.set_custom_mouse_cursor(
			TARGET_CURSOR,
			Input.CURSOR_ARROW,
			Vector2(3.0, 3.0)
		)
		return
	Input.set_custom_mouse_cursor(
		DEFAULT_CURSOR,
		Input.CURSOR_ARROW,
		Vector2(3.0, 3.0)
	)
