class_name ConsecutiveThrustVisual
extends Node2D

## Presentation-only twelve-frame rapid spirit-lance sequence for Opaw's second skill.
## Its bright drawn core reads the definition-owned forward contact lane.

const FRAME_SIZE := Vector2(192.0, 192.0)
const FRAME_COLUMNS := 6
const SPIRIT_WHITE := Color(1.0, 0.98, 0.82, 1.0)
const RELIC_GOLD := Color(1.0, 0.72, 0.22, 1.0)
## Keep the guide compact: a long center thread makes the rapid VFX look like
## a strange spear rather than a tight flurry. Gameplay still owns 128 px reach.
const VISIBLE_CORE_LENGTH_PIXELS := 72.0
const GOLD_ORIGIN_FLARE_LENGTH_PIXELS := 24.0
const ACTIVE_FLURRY_FRAMES := [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
const ACTIVE_FLURRY_ANGLES := [-0.14, 0.12, -0.10, 0.14, -0.11, 0.08, -0.08, 0.10, -0.05, 0.0]
const STRIKE_FRAMES := [1, 2, 3, 4, 5, 8, 10]
const STRIKE_ANGLE_OFFSETS := [-0.14, 0.12, -0.10, 0.14, -0.11, 0.08, 0.0]
## The final flash begins on the exact `strike_started` signal that plays its sword cue.
## It then collapses through the existing smaller effect cells instead of holding a
## delayed recovery-frame explosion that reads as slow motion.
const FINAL_DECAY_FRAMES := [11, 10, 9, 8]
const FINAL_DECAY_OPACITIES := [1.0, 0.76, 0.46, 0.22]
const FINAL_DECAY_CORE_ALPHAS := [1.0, 0.68, 0.38, 0.14]
const FINAL_DECAY_CORE_SCALES := [1.0, 0.76, 0.52, 0.30]
const FINAL_DECAY_INTERVAL_SECONDS := 0.045

@export var ability_component: AbilityComponent
@export var effect_sprite: Sprite2D

var _core_alpha := 0.0
var _final_strike := false
var _strike_angle := 0.0
var _core_length_scale := 1.0
var _flurry_frame_index := 0
var _flurry_timer: Timer
var _final_decay_step := 0
var _final_decay_timer: Timer


func _ready() -> void:
	_flurry_timer = Timer.new()
	_flurry_timer.one_shot = false
	add_child(_flurry_timer)
	_flurry_timer.timeout.connect(_advance_flurry_frame)
	_final_decay_timer = Timer.new()
	_final_decay_timer.one_shot = true
	add_child(_final_decay_timer)
	_final_decay_timer.timeout.connect(_advance_final_decay)
	hide_visual()


func play_phase(phase: AbilityComponent.Phase, _duration_seconds: float) -> void:
	match phase:
		AbilityComponent.Phase.WIND_UP:
			_stop_final_decay()
			_final_strike = false
			_strike_angle = 0.0
			_core_length_scale = 1.0
			_core_alpha = 0.38
			_show_frame(0)
		AbilityComponent.Phase.ACTIVE:
			_core_alpha = 0.94
			_start_flurry_animation(_duration_seconds)
		AbilityComponent.Phase.RECOVERY:
			_stop_flurry_animation()
			# The final impact is already decaying from its own strike event. Do not
			# replace it with a new giant frame during recovery.
			if not _final_strike:
				_strike_angle = 0.0
				_core_length_scale = 0.44
				_core_alpha = 0.20
				_show_frame(8)
	queue_redraw()


func play_strike(strike_index: int, strike_count: int, _duration_seconds: float) -> void:
	_final_strike = strike_index >= strike_count - 1
	_core_alpha = 1.0
	var frame_index := clampi(strike_index, 0, STRIKE_FRAMES.size() - 1)
	_strike_angle = STRIKE_ANGLE_OFFSETS[frame_index]
	if _final_strike:
		_stop_flurry_animation()
		_play_final_impact()
	else:
		_core_length_scale = 1.0
		_show_frame(STRIKE_FRAMES[frame_index])
	queue_redraw()


func hide_visual() -> void:
	_stop_flurry_animation()
	_stop_final_decay()
	_core_alpha = 0.0
	_final_strike = false
	_strike_angle = 0.0
	_core_length_scale = 1.0
	if effect_sprite != null:
		effect_sprite.modulate = Color.WHITE
		effect_sprite.hide()
	hide()
	queue_redraw()


func _start_flurry_animation(active_seconds: float) -> void:
	_stop_final_decay()
	_flurry_frame_index = 0
	_flurry_timer.wait_time = maxf(0.03, active_seconds / float(ACTIVE_FLURRY_FRAMES.size()))
	_advance_flurry_frame()
	_flurry_timer.start()


func _stop_flurry_animation() -> void:
	if _flurry_timer != null:
		_flurry_timer.stop()


func _play_final_impact() -> void:
	_stop_final_decay()
	_final_decay_step = 0
	_show_final_decay_frame()
	_final_decay_timer.start(FINAL_DECAY_INTERVAL_SECONDS)


func _stop_final_decay() -> void:
	_final_decay_step = 0
	if _final_decay_timer != null:
		_final_decay_timer.stop()


func _advance_final_decay() -> void:
	_final_decay_step += 1
	if _final_decay_step >= FINAL_DECAY_FRAMES.size():
		_core_alpha = 0.0
		if effect_sprite != null:
			effect_sprite.hide()
		hide()
		queue_redraw()
		return
	_show_final_decay_frame()
	_final_decay_timer.start(FINAL_DECAY_INTERVAL_SECONDS)
	queue_redraw()


func _show_final_decay_frame() -> void:
	_show_frame(FINAL_DECAY_FRAMES[_final_decay_step])
	_core_alpha = FINAL_DECAY_CORE_ALPHAS[_final_decay_step]
	_core_length_scale = FINAL_DECAY_CORE_SCALES[_final_decay_step]
	if effect_sprite != null:
		effect_sprite.modulate = Color(1.0, 1.0, 1.0, FINAL_DECAY_OPACITIES[_final_decay_step])


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
	effect_sprite.modulate = Color.WHITE
	effect_sprite.show()
	show()


func _draw() -> void:
	if _core_alpha <= 0.001:
		return
	var contact_reach := _get_contact_reach_pixels()
	if contact_reach <= 4.0:
		return
	var core_length := minf(contact_reach, VISIBLE_CORE_LENGTH_PIXELS) * _core_length_scale
	var origin := Vector2(4.0, 0.0)
	var tip := Vector2(core_length, 0.0).rotated(_strike_angle)
	var gold_flare_length := minf(
		core_length,
		GOLD_ORIGIN_FLARE_LENGTH_PIXELS * _core_length_scale
	)
	var gold_tip := Vector2(gold_flare_length, 0.0).rotated(_strike_angle)
	draw_line(origin, gold_tip, Color(RELIC_GOLD, 0.48 * _core_alpha), 3.0)
	draw_line(origin, tip, Color(SPIRIT_WHITE, 0.78 * _core_alpha), 2.0)


func _get_contact_reach_pixels() -> float:
	if ability_component == null or ability_component.definition == null:
		return 0.0
	return ability_component.definition.get_forward_lance_reach_pixels()


func _get_contact_half_width_pixels() -> float:
	if ability_component == null or ability_component.definition == null:
		return 0.0
	return ability_component.definition.get_forward_lance_half_width_pixels()
