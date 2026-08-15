class_name ClickMoveMarker
extends Node2D

## Presentation-only Dota-style destination mark. Navigation and movement stay
## in PlayerCombatTargetingComponent and Player respectively.

@export var targeting_component: PlayerCombatTargetingComponent

var _pulse_time := 0.0


func _ready() -> void:
	top_level = true
	z_index = 28
	visible = false
	if targeting_component == null:
		push_error("ClickMoveMarker requires a targeting component.")
		return
	targeting_component.click_move_changed.connect(_on_click_move_changed)
	set_process(false)


func _process(delta: float) -> void:
	_pulse_time += delta
	queue_redraw()


func _draw() -> void:
	var radius := 10.0 + sin(_pulse_time * 7.0) * 1.2
	var color := Color(0.5, 0.86, 1.0, 0.9)
	draw_arc(Vector2.ZERO, radius + 1.0, 0.0, TAU, 20, Color(0.03, 0.08, 0.12, 0.75), 3.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 20, color, 1.5)
	draw_colored_polygon(PackedVector2Array([Vector2(0, -7), Vector2(-4, 1), Vector2(4, 1)]), color)


func _on_click_move_changed(world_position: Vector2, active: bool) -> void:
	visible = active
	set_process(active)
	if active:
		global_position = world_position
		_pulse_time = 0.0
		queue_redraw()
