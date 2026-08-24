class_name ExaminerAxiomLane
extends Node2D

var _length := 500.0
var _width := 28.0
var _active := false
var _alpha := 0.0


func configure(
	center: Vector2,
	direction: Vector2,
	length: float,
	width: float,
	warning_seconds: float,
	resolve_delay: float
) -> void:
	global_position = center
	rotation = direction.angle()
	_length = length
	_width = width
	queue_redraw()
	var tween := create_tween()
	tween.tween_property(self, "_alpha", 0.5, maxf(warning_seconds * 0.45, 0.05))
	tween.tween_property(self, "_alpha", 0.18, maxf(resolve_delay - warning_seconds * 0.45, 0.05))
	tween.tween_callback(_resolve)
	tween.tween_interval(0.08)
	tween.tween_property(self, "_alpha", 0.0, 0.20)
	tween.tween_callback(queue_free)


func _process(_delta: float) -> void:
	queue_redraw()


func _resolve() -> void:
	_active = true
	_alpha = 0.95
	queue_redraw()


func _draw() -> void:
	var half := Vector2(_length * 0.5, _width * 0.5)
	var color := Color(1.0, 0.93, 0.58, _alpha) if _active else Color(0.96, 0.78, 0.32, _alpha)
	draw_rect(Rect2(-half, half * 2.0), color, true)
	draw_line(Vector2(-half.x, 0.0), Vector2(half.x, 0.0), Color(1.0, 1.0, 0.86, minf(_alpha + 0.18, 1.0)), 2.0)
