class_name ExaminerGroundJudgmentVfx
extends Node2D

const LIFETIME := 0.82
const RADIUS := 72.0

var elapsed := 0.0
var cracks: Array[PackedVector2Array] = []


func _ready() -> void:
	z_index = 10
	for index in 12:
		var angle := float(index) * TAU / 12.0 + 0.11
		var direction := Vector2.from_angle(angle)
		cracks.append(PackedVector2Array([
			Vector2.ZERO,
			direction * (16.0 + float(index % 3) * 3.0),
			direction * (35.0 + float(index % 4) * 4.0) + direction.rotated(PI * 0.5) * (4.0 if index % 2 == 0 else -4.0),
			direction * (55.0 + float(index % 3) * 5.0),
		]))
	queue_redraw()


func _process(delta: float) -> void:
	elapsed += delta
	if elapsed >= LIFETIME:
		queue_free()
		return
	queue_redraw()


func _draw() -> void:
	var progress := clampf(elapsed / LIFETIME, 0.0, 1.0)
	var flash := 1.0 - clampf(progress / 0.18, 0.0, 1.0)
	draw_circle(Vector2.ZERO, lerpf(14.0, 38.0, 1.0 - flash), Color(1.0, 0.92, 0.54, flash * 0.48), false, 4.0, false)
	var reveal := clampf(progress / 0.14, 0.0, 1.0)
	var fade := 1.0 - clampf((progress - 0.56) / 0.44, 0.0, 1.0)
	for crack in cracks:
		var visible := maxi(2, ceili(float(crack.size()) * reveal))
		var partial := PackedVector2Array()
		for point_index in mini(visible, crack.size()):
			partial.append(crack[point_index])
		draw_polyline(partial, Color(0.12, 0.10, 0.08, fade * 0.86), 2.0, false)
	var wave := clampf(progress / 0.52, 0.0, 1.0)
	var wave_radius := lerpf(18.0, RADIUS + 12.0, ease(wave, 0.64))
	for arc_index in 6:
		var start := float(arc_index) * TAU / 6.0 + 0.08
		draw_arc(Vector2.ZERO, wave_radius, start, start + 0.72, 9, Color(1.0, 0.79, 0.25, (1.0 - wave) * 0.82), 3.0, false)
	for mote_index in 14:
		var angle := float(mote_index) * TAU / 14.0 + 0.17
		var distance := lerpf(12.0, 78.0 + float(mote_index % 4) * 3.0, progress)
		var mote := Vector2.from_angle(angle) * distance
		mote.y *= 0.58
		draw_rect(Rect2(mote - Vector2.ONE, Vector2(2, 2)), Color(1.0, 0.9, 0.56, fade * 0.76), true)

