class_name ExaminerActionVfx
extends Node2D

var kind: StringName = &"precision_thrust"
var direction := Vector2.RIGHT
var elapsed := 0.0
var lifetime := 0.28


func configure(action_kind: StringName, action_direction: Vector2) -> void:
	kind = action_kind
	direction = action_direction.normalized() if not action_direction.is_zero_approx() else Vector2.RIGHT
	rotation = direction.angle()
	lifetime = 0.18 if kind == &"precision_thrust" else 0.32


func _ready() -> void:
	z_index = 12
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= lifetime:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(elapsed / lifetime, 0.0, 1.0)
	var alpha := 1.0 - progress
	if kind == &"precision_thrust":
		var length := lerpf(30.0, 86.0, progress)
		draw_colored_polygon(PackedVector2Array([
			Vector2(2, -3), Vector2(length, -1), Vector2(length + 13, 0), Vector2(length, 1), Vector2(2, 3)
		]), Color(1.0, 0.88, 0.38, alpha * 0.72))
		draw_line(Vector2(6, 0), Vector2(length + 16, 0), Color(1.0, 1.0, 0.9, alpha), 2.0, false)
	elif kind == &"divine_sweep":
		var sweep := lerpf(0.35, 2.35, progress)
		draw_arc(Vector2.ZERO, 58.0, -1.18, -1.18 + sweep, 18, Color(1.0, 0.78, 0.24, alpha * 0.86), 5.0, false)
		draw_arc(Vector2.ZERO, 64.0, -1.08, -1.08 + sweep, 18, Color(1.0, 1.0, 0.78, alpha * 0.58), 2.0, false)
	elif kind == &"judgment_charge":
		for index in 7:
			var offset := float(index - 3) * 5.0
			var length := 32.0 + float(index % 3) * 11.0
			draw_line(Vector2(-length, offset), Vector2(9, offset * 0.35), Color(1.0, 0.72, 0.18, alpha * 0.54), 2.0, false)

