class_name GroundPointTargeting
extends Node2D

signal targeting_started(component: SovereignPursuitComponent)
signal targeting_cancelled
signal targeting_confirmed(component: SovereignPursuitComponent, target_global_position: Vector2)

var _component: SovereignPursuitComponent
var _target_local := Vector2.DOWN * 80.0
var _range := 220.0


func _ready() -> void:
	visible = false


func _exit_tree() -> void:
	_set_cursor_targeting(false)


func is_targeting() -> bool:
	return _component != null


func get_target_component() -> SovereignPursuitComponent:
	return _component


func begin_targeting(component: SovereignPursuitComponent, initial_direction: Vector2) -> bool:
	var pursuit := component.definition as SovereignPursuitDefinition if component != null else null
	if component == null or pursuit == null or not component.is_ready():
		return false
	_component = component
	_range = pursuit.target_range_pixels
	_target_local = (initial_direction.normalized() if not initial_direction.is_zero_approx() else Vector2.DOWN) * minf(96.0, _range)
	visible = true
	_set_cursor_targeting(true)
	queue_redraw()
	targeting_started.emit(component)
	return true


func update_aim(pointer_global_position: Vector2, stick_direction: Vector2) -> void:
	if not is_targeting():
		return
	var next_local := pointer_global_position - global_position
	if stick_direction.length_squared() > 0.16:
		next_local = stick_direction.normalized() * _range
	if next_local.length() > _range:
		next_local = next_local.normalized() * _range
	_target_local = next_local
	queue_redraw()


func confirm_targeting() -> bool:
	if not is_targeting():
		return false
	var component := _component
	var target := global_position + _target_local
	_clear()
	targeting_confirmed.emit(component, target)
	return true


func cancel_targeting() -> bool:
	if not is_targeting():
		return false
	_clear()
	targeting_cancelled.emit()
	return true


func _clear() -> void:
	_component = null
	visible = false
	_set_cursor_targeting(false)
	queue_redraw()


func _draw() -> void:
	if not is_targeting():
		return
	draw_dashed_line(Vector2.ZERO, _target_local, Color(0.42, 0.74, 0.96, 0.72), 1.0, 8.0, false)
	draw_arc(Vector2.ZERO, _range, 0.0, TAU, 64, Color(0.22, 0.45, 0.68, 0.32), 1.0, false)
	draw_circle(_target_local, 52.0, Color(0.05, 0.19, 0.31, 0.18))
	draw_arc(_target_local, 52.0, 0.0, TAU, 32, Color(0.75, 0.91, 1.0, 0.88), 2.0, false)
	draw_line(_target_local + Vector2(-10, 0), _target_local + Vector2(10, 0), Color(1.0, 0.78, 0.31, 0.95), 2.0)
	draw_line(_target_local + Vector2(0, -10), _target_local + Vector2(0, 10), Color(1.0, 0.78, 0.31, 0.95), 2.0)


func _set_cursor_targeting(active: bool) -> void:
	var cursor_service := get_node_or_null("/root/CursorService")
	if cursor_service != null:
		cursor_service.set_targeting_active(active)

