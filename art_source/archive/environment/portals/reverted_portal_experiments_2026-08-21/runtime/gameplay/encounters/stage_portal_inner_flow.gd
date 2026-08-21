class_name StagePortalInnerFlow
extends Node2D

const SPIRAL_ARM_COUNT := 3
const SPIRAL_SAMPLE_COUNT := 24
const VORTEX_RADIUS_X := 27.0
const VORTEX_RADIUS_Y := 20.0
const ORBIT_SAMPLE_COUNT := 12

var _tier_color := Color(0.28, 0.65, 1.0)
var _phase := 0.0
var _flow_speed := 1.0
var _intensity := 1.0


func configure(color: Color, flow_speed: float, intensity: float) -> void:
	_tier_color = color
	_flow_speed = flow_speed
	_intensity = intensity
	queue_redraw()


func _process(delta: float) -> void:
	_phase = fmod(_phase + delta * _flow_speed * 2.15, TAU)
	queue_redraw()


func _draw() -> void:
	# A subdued core gives the spiral contrast without replacing the portal's
	# translucent view of the stage with an opaque black hole.
	var core_color := _tier_color.darkened(0.72)
	core_color.a = minf(0.42, 0.25 * _intensity)
	draw_colored_polygon(_ellipse_points(VORTEX_RADIUS_X, VORTEX_RADIUS_Y, 24), core_color)

	# Three expanding arms create an unmistakable central vortex. Drawing each
	# arm twice gives it a broad tier-colored body and a crisp luminous center.
	for arm_index in range(SPIRAL_ARM_COUNT):
		var arm := PackedVector2Array()
		for sample_index in range(SPIRAL_SAMPLE_COUNT):
			var progress := float(sample_index) / float(SPIRAL_SAMPLE_COUNT - 1)
			var radius_x := lerpf(2.5, VORTEX_RADIUS_X, progress)
			var radius_y := lerpf(2.0, VORTEX_RADIUS_Y, progress)
			var angle := (
				_phase
				+ float(arm_index) * TAU / float(SPIRAL_ARM_COUNT)
				+ progress * TAU * 1.18
			)
			arm.append(Vector2(
				roundf(cos(angle) * radius_x),
				roundf(sin(angle) * radius_y)
			))
		var body_color := _tier_color.lightened(0.08)
		body_color.a = minf(0.88, 0.60 * _intensity)
		draw_polyline(arm, body_color, 4.0, false)
		var core_line := _tier_color.lightened(0.55)
		core_line.a = minf(1.0, 0.82 * _intensity)
		draw_polyline(arm, core_line, 1.0, false)

	# Broken counter-rotating orbit fragments stop the center from reading as
	# one static pinwheel and make higher-speed destination tiers feel fiercer.
	for orbit_index in range(4):
		var orbit := PackedVector2Array()
		var orbit_start := -_phase * 0.72 + float(orbit_index) * TAU / 4.0
		for sample_index in range(ORBIT_SAMPLE_COUNT):
			var progress := float(sample_index) / float(ORBIT_SAMPLE_COUNT - 1)
			var angle := orbit_start + progress * 0.72
			orbit.append(Vector2(
				roundf(cos(angle) * (VORTEX_RADIUS_X + 3.0)),
				roundf(sin(angle) * (VORTEX_RADIUS_Y + 2.0))
			))
		var orbit_color := _tier_color.lightened(0.4)
		orbit_color.a = minf(0.88, 0.58 * _intensity)
		draw_polyline(orbit, orbit_color, 2.0, false)

	var eye_color := _tier_color.lightened(0.68)
	eye_color.a = minf(1.0, 0.9 * _intensity)
	draw_circle(Vector2.ZERO, 3.0, eye_color)


func _ellipse_points(radius_x: float, radius_y: float, sample_count: int) -> PackedVector2Array:
	var points := PackedVector2Array()
	for sample_index in range(sample_count):
		var angle := float(sample_index) / float(sample_count) * TAU
		points.append(Vector2(
			roundf(cos(angle) * radius_x),
			roundf(sin(angle) * radius_y)
		))
	return points
