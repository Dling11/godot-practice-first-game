extends Node

## Owns the project's hardware cursor vocabulary. Gameplay systems request a
## semantic cursor state; no world Sprite2D follows the pointer with added lag.

const DEFAULT_CURSOR = preload(
	"res://assets/ui/cursors/generated/cursor_royal_pointer_generated_32.png"
)
const INTERACT_CURSOR = preload(
	"res://assets/ui/cursors/generated/cursor_royal_interact_generated_32.png"
)
const TARGET_CURSOR = preload(
	"res://assets/ui/cursors/generated/cursor_royal_target_generated_32.png"
)

var targeting_active := false
var combat_target_selected := false


func _ready() -> void:
	_install_cursor_vocabulary()
	_apply_arrow_cursor()


func set_targeting_active(active: bool) -> void:
	if targeting_active == active:
		return
	targeting_active = active
	_apply_arrow_cursor()


func set_combat_target_selected(selected: bool) -> void:
	if combat_target_selected == selected:
		return
	combat_target_selected = selected
	_apply_arrow_cursor()


func _install_cursor_vocabulary() -> void:
	if DisplayServer.get_name() == "headless":
		return
	Input.set_custom_mouse_cursor(
		INTERACT_CURSOR,
		Input.CURSOR_POINTING_HAND,
		Vector2(12.0, 10.0)
	)


func _apply_arrow_cursor() -> void:
	if DisplayServer.get_name() == "headless":
		return
	if targeting_active or combat_target_selected:
		Input.set_custom_mouse_cursor(
			TARGET_CURSOR,
			Input.CURSOR_ARROW,
			Vector2(2.0, 2.0)
		)
		return
	Input.set_custom_mouse_cursor(
		DEFAULT_CURSOR,
		Input.CURSOR_ARROW,
		Vector2(2.0, 2.0)
	)
