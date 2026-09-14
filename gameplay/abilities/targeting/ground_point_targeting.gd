class_name GroundPointTargeting
extends Node2D

signal targeting_started(component: AbilityComponent)
signal targeting_cancelled
signal targeting_confirmed(component: AbilityComponent, target_global_position: Vector2)

var _component: AbilityComponent
var _target_local := Vector2.DOWN * 80.0
var _range := 220.0
var _radius := 52.0
var _lane_preview: Dictionary = {}


func _ready() -> void:
	visible = false


func _exit_tree() -> void:
	_set_cursor_targeting(false)


func is_targeting() -> bool:
	return _component != null


func get_target_component() -> AbilityComponent:
	return _component


func begin_targeting(component: AbilityComponent, initial_direction: Vector2) -> bool:
	if component == null or not component.supports_ground_targeting() or not component.is_ready():
		return false
	_component = component
	_range = component.get_target_range_pixels()
	_radius = component.get_target_radius_pixels()
	_target_local = (initial_direction.normalized() if not initial_direction.is_zero_approx() else Vector2.DOWN) * minf(96.0, _range)
	if component.is_fixed_length_line_targeted():
		_target_local = _target_local.normalized() * _range
	_update_lane_preview()
	visible = true
	_set_cursor_targeting(true)
	queue_redraw()
	targeting_started.emit(component)
	return true


func update_aim(pointer_global_position: Vector2, stick_direction: Vector2) -> void:
	if not is_targeting():
		return
	var next_local := pointer_global_position - _aim_origin()
	if stick_direction.length_squared() > 0.16:
		next_local = stick_direction.normalized() * _range
	if next_local.length() > _range:
		next_local = next_local.normalized() * _range
	if _component.is_fixed_length_line_targeted():
		# Keep the last useful direction when the cursor crosses King's center.
		next_local = next_local.normalized() * _range if next_local.length_squared() >= .01 else _target_local
	_target_local = next_local
	_update_lane_preview()
	queue_redraw()


func confirm_targeting() -> bool:
	if not is_targeting():
		return false
	var component := _component
	var target := _aim_origin() + _target_local
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
	_lane_preview.clear()
	visible = false
	_set_cursor_targeting(false)
	queue_redraw()


func _draw() -> void:
	if not is_targeting():
		return
	if _component.is_fixed_length_line_targeted():
		_draw_lane()
		return
	draw_dashed_line(Vector2.ZERO, _target_local, Color(0.42, 0.74, 0.96, 0.72), 1.0, 8.0, false)
	draw_arc(Vector2.ZERO, _range, 0.0, TAU, 64, Color(0.22, 0.45, 0.68, 0.32), 1.0, false)
	draw_circle(_target_local, _radius, Color(0.05, 0.19, 0.31, 0.18))
	draw_arc(_target_local, _radius, 0.0, TAU, 48, Color(0.75, 0.91, 1.0, 0.88), 2.0, false)
	var core := _component.get_target_core_radius_pixels()
	if core>0.0:
		draw_arc(_target_local,core,0.0,TAU,32,Color(1.0,.78,.31,.8),1.0,false)
	draw_line(_target_local + Vector2(-10, 0), _target_local + Vector2(10, 0), Color(1.0, 0.78, 0.31, 0.95), 2.0)
	draw_line(_target_local + Vector2(0, -10), _target_local + Vector2(0, 10), Color(1.0, 0.78, 0.31, 0.95), 2.0)


func _update_lane_preview() -> void:
	_lane_preview = _component.get_target_lane_preview(_aim_origin() + _target_local) if _component != null and _component.is_fixed_length_line_targeted() else {}


func _aim_origin() -> Vector2:
	# The legacy circle marker sits 16px above the feet. A ground lane must
	# measure cursor direction from the same origin as its committed attack.
	if _component != null and _component.is_fixed_length_line_targeted() and _component.owner is Node2D:
		return (_component.owner as Node2D).global_position
	return global_position


func _draw_lane() -> void:
	if _lane_preview.is_empty():
		return
	var waves: Array = _lane_preview.get("waves",[])
	for index in maxi(0,waves.size()-1):
		_draw_lane_shape(waves[index],false)
	_draw_lane_shape(_lane_preview,true)


func _draw_lane_shape(path: Dictionary, primary: bool) -> void:
	var lane_radius: float = path.radius
	var start: Vector2 = to_local(path.contact)
	var end: Vector2 = to_local(path.end)
	var forward: Vector2 = path.direction
	var side := forward.orthogonal()
	var color := Color("8bdcff")
	var points := PackedVector2Array()
	# Capsule caps match the swept front radius used by combat authority.
	for index in 13:
		points.append(end + forward.rotated(-PI*.5 + PI*index/12.0) * lane_radius)
	for index in 13:
		points.append(start + forward.rotated(PI*.5 + PI*index/12.0) * lane_radius)
	draw_colored_polygon(points, Color(color, .12 if primary else .035))
	points.append(points[0])
	draw_polyline(points, Color(color,.85 if primary else .35), 1.0)
	if not primary:
		draw_line(end-side*lane_radius,end+side*lane_radius,Color(color,.45),1.0)
	if primary:
		draw_line(start,end,Color(color,.40),1.0)
	if primary and start.distance_to(end) > 12.0:
		for fraction in [.3,.6,.85]:
			var tip := start.lerp(end,fraction)
			draw_polyline(PackedVector2Array([tip-forward*5.0+side*4.0,tip,tip-forward*5.0-side*4.0]),Color(color,.9),1.0)
	if path.blocked:
		draw_line(end-side*lane_radius,end+side*lane_radius,Color("efb86c"),2.0)


func _set_cursor_targeting(active: bool) -> void:
	var cursor_service := get_node_or_null("/root/CursorService")
	if cursor_service != null:
		cursor_service.set_targeting_active(active)
