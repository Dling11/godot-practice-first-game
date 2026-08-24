class_name CourtOfFirstMeasure
extends Node2D

var _measure_energy := 0.0
var _pulse_tween: Tween


func _ready() -> void:
	queue_redraw()


func pulse_measure(duration_seconds := 2.2) -> void:
	if _pulse_tween != null and _pulse_tween.is_valid():
		_pulse_tween.kill()
	_measure_energy = 0.0
	_pulse_tween = create_tween()
	_pulse_tween.tween_property(self, "_measure_energy", 1.0, 0.28)
	_pulse_tween.tween_interval(maxf(duration_seconds - 0.7, 0.1))
	_pulse_tween.tween_property(self, "_measure_energy", 0.0, 0.42)


func _process(_delta: float) -> void:
	if _measure_energy > 0.001:
		queue_redraw()


func _draw() -> void:
	var center := Vector2(365.0, 287.0)
	draw_circle(center, 224.0, Color("14202b"))
	draw_circle(center, 216.0, Color("263a42"))
	draw_circle(center, 205.0, Color("314950"))
	draw_circle(center, 194.0, Color("263a42"))
	draw_circle(center, 184.0, Color("2d4249"))
	var dormant := Color(0.55, 0.62, 0.55, 0.34)
	var active := Color(1.0, 0.82, 0.34, 0.34 + _measure_energy * 0.45)
	for radius in [68.0, 112.0, 151.0, 184.0]:
		draw_arc(center, radius, 0.0, TAU, 96, dormant.lerp(active, _measure_energy), 2.0)
	for index in range(12):
		var angle := TAU * float(index) / 12.0
		var start := center + Vector2.RIGHT.rotated(angle) * 78.0
		var finish := center + Vector2.RIGHT.rotated(angle) * 181.0
		draw_line(start, finish, dormant.lerp(active, _measure_energy), 1.0)
	for point in [Vector2(126, 118), Vector2(604, 118), Vector2(126, 456), Vector2(604, 456)]:
		_draw_pylon(point)


func _draw_pylon(point: Vector2) -> void:
	draw_polygon(PackedVector2Array([point + Vector2(-18, 12), point + Vector2(18, 12), point + Vector2(11, -20), point + Vector2(-11, -20)]), PackedColorArray([Color("26323b")]))
	draw_polyline(PackedVector2Array([point + Vector2(-18, 12), point + Vector2(18, 12), point + Vector2(11, -20), point + Vector2(-11, -20), point + Vector2(-18, 12)]), Color("9b8451"), 2.0)
	var flame := Color(0.48, 0.94, 1.0, 0.92)
	draw_polygon(PackedVector2Array([point + Vector2(-6, -22), point + Vector2(0, -42), point + Vector2(7, -22), point + Vector2(1, -16)]), PackedColorArray([flame]))
