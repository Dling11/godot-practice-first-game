class_name ConsecutiveThrustVisual
extends Node2D

## Presentation-only twelve-frame rapid spirit-lance sequence for Opaw's second skill.
## Its narrow drawn core communicates the definition-owned 76 px contact lane.

const FRAME_SIZE := Vector2(192.0, 192.0)
const FRAME_COLUMNS := 6
const SPIRIT_WHITE := Color(1.0, 0.98, 0.82, 1.0)
const RELIC_GOLD := Color(1.0, 0.72, 0.22, 1.0)
const ACTIVE_FLURRY_FRAMES := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
const ACTIVE_FLURRY_ANGLES := [-0.14, 0.12, -0.10, 0.14, -0.11, 0.08, -0.08, 0.10, -0.05, 0.0]
const STRIKE_FRAMES := [1, 2, 3, 4, 5, 8, 10]
const STRIKE_ANGLE_OFFSETS := [-0.14, 0.12, -0.10, 0.14, -0.11, 0.08, 0.0]

@export var ability_component: AbilityComponent
@export var effect_sprite: Sprite2D

var _core_alpha := 0.0
var _final_strike := false
var _strike_angle := 0.0
var _flurry_frame_index := 0
var _flurry_timer: Timer


func _ready() -> void:
	_flurry_timer = Timer.new()
	_flurry_timer.one_shot = false
	add_child(_flurry_timer)
	_flurry_timer.timeout.connect(_advance_flurry_frame)
	hide_visual()


func play_phase(phase: AbilityComponent.Phase, _duration_seconds: float) -> void:
	match phase:
		AbilityComponent.Phase.WIND_UP:
			_final_strike = false
			_strike_angle = 0.0
			_core_alpha = 0.38
			_show_frame(0)
		AbilityComponent.Phase.ACTIVE:
			_core_alpha = 0.94
			_start_flurry_animation(_duration_seconds)
		AbilityComponent.Phase.RECOVERY:
			_stop_flurry_animation()
			_strike_angle = 0.0
			_core_alpha = 0.32
			_show_frame(11)
	queue_redraw()


func play_strike(strike_index: int, strike_count: int, _duration_seconds: float) -> void:
	_final_strike = strike_index >= strike_count - 1
	_core_alpha = 1.0
	var frame_index := clampi(strike_index, 0, STRIKE_FRAMES.size() - 1)
	_strike_angle = STRIKE_ANGLE_OFFSETS[frame_index]
	if _final_strike:
		_stop_flurry_animation()
	_show_frame(STRIKE_FRAMES[frame_index])
	queue_redraw()


func hide_visual() -> void:
	_stop_flurry_animation()
	_core_alpha = 0.0
	_final_strike = false
	_strike_angle = 0.0
	if effect_sprite != null:
		effect_sprite.hide()
	hide()
	queue_redraw()


func _start_flurry_animation(active_seconds: float) -> void:
	_flurry_frame_index = 0
	_flurry_timer.wait_time = maxf(0.03, active_seconds / float(ACTIVE_FLURRY_FRAMES.size()))
	_advance_flurry_frame()
	_flurry_timer.start()


func _stop_flurry_animation() -> void:
	if _flurry_timer != null:
		_flurry_timer.stop()


func _advance_flurry_frame() -> void:
	var frame_index := _flurry_frame_index % ACTIVE_FLURRY_FRAMES.size()
	_strike_angle = float(ACTIVE_FLURRY_ANGLES[frame_index])
	_show_frame(ACTIVE_FLURRY_FRAMES[frame_index])
	_flurry_frame_index += 1
	queue_redraw()


func _show_frame(frame_index: int) -> void:
	if effect_sprite == null:
		return
	effect_sprite.region_rect = Rect2(
		Vector2(frame_index % FRAME_COLUMNS, frame_index / FRAME_COLUMNS) * FRAME_SIZE,
		FRAME_SIZE
	)
	effect_sprite.show()
	show()


func _draw() -> void:
	if _core_alpha <= 0.001:
		return
	var core_length := 76.0 if not _final_strike else 90.0
	var outer_width := 6.0 if _final_strike else 4.0
	var tip := Vector2(core_length, 0.0).rotated(_strike_angle)
	draw_line(Vector2(4.0, 0.0), tip, Color(RELIC_GOLD, 0.6 * _core_alpha), outer_width)
	draw_line(Vector2(4.0, 0.0), tip, Color(SPIRIT_WHITE, _core_alpha), 2.0)
