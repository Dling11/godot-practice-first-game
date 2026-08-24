class_name ExaminerDivineDescentVfx
extends Node2D

const LIFETIME := 1.25

var elapsed := 0.0


func _ready() -> void:
	z_index = 12
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(elapsed / LIFETIME, 0.0, 1.0)
	var flash := 1.0 - clampf(progress / 0.11, 0.0, 1.0)
	draw_circle(Vector2.ZERO, lerpf(24.0, 88.0, 1.0 - flash), Color(1.0, 0.96, 0.72, flash * 0.60), false, 7.0, false)
	var wave := clampf(progress / 0.62, 0.0, 1.0)
	for ring_index in 3:
		var radius := lerpf(18.0 + ring_index * 9.0, 196.0 + ring_index * 18.0, ease(wave, 0.62))
		var alpha := (1.0 - wave) * (0.85 - ring_index * 0.18)
		draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, Color(1.0, 0.78, 0.22, alpha), 5.0 - ring_index, false)
	var debris_fade := 1.0 - clampf((progress - 0.56) / 0.44, 0.0, 1.0)
	for index in 32:
		var angle := float(index) * TAU / 32.0 + float(index % 5) * 0.09
		var distance := lerpf(10.0, 88.0 + float(index % 7) * 12.0, ease(progress, 0.7))
		var point := Vector2.from_angle(angle) * distance
		point.y *= 0.58
		var size := 2.0 + float(index % 3)
		draw_colored_polygon(PackedVector2Array([
			point + Vector2(0.0, -size),
			point + Vector2(size, 0.0),
			point + Vector2(0.0, size),
			point + Vector2(-size, 0.0),
		]), Color(1.0, 0.86, 0.42, debris_fade * 0.82))
	for ray_index in 12:
		var angle := float(ray_index) * TAU / 12.0
		var start := Vector2.from_angle(angle) * 18.0
		var finish := Vector2.from_angle(angle) * lerpf(45.0, 145.0, wave)
		finish.y *= 0.62
		draw_line(start, finish, Color(1.0, 0.92, 0.58, (1.0 - wave) * 0.62), 3.0, false)
