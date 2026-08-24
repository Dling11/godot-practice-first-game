class_name ExaminerDivineDescentLaunchVfx
extends Node2D

const LIFETIME := 0.58

var elapsed := 0.0


func _ready() -> void:
	z_index = 9
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(elapsed / LIFETIME, 0.0, 1.0)
	var fade := 1.0 - progress
	var ring_radius := lerpf(8.0, 54.0, ease(progress, 0.58))
	draw_arc(Vector2.ZERO, ring_radius, 0.0, TAU, 40, Color(1.0, 0.84, 0.34, fade * 0.76), 3.0, false)
	for index in 18:
		var angle := float(index) * TAU / 18.0 + 0.13
		var distance := lerpf(8.0, 46.0 + float(index % 4) * 5.0, progress)
		var point := Vector2.from_angle(angle) * distance
		point.y *= 0.44
		point.y -= progress * (8.0 + float(index % 5) * 3.0)
		var size := 2.0 + float(index % 2)
		draw_rect(Rect2(point - Vector2.ONE * size * 0.5, Vector2.ONE * size), Color(0.84, 0.78, 0.61, fade * 0.72), true)
	for ray_index in 6:
		var angle := float(ray_index) * TAU / 6.0
		var start := Vector2.from_angle(angle) * 5.0
		var finish := Vector2.from_angle(angle) * lerpf(15.0, 66.0, progress)
		finish.y *= 0.48
		draw_line(start, finish, Color(1.0, 0.94, 0.65, fade * 0.58), 2.0)
