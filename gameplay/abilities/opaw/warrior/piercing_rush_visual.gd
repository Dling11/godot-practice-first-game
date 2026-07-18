class_name PiercingRushVisual
extends Node2D

## Generated six-frame spirit-lance presentation for Piercing Rush. The large
## outer ribbons are cosmetic; AbilityComponent and its narrow hitbox remain
## movement, contact, damage, and cooldown authority.

const FRAME_SIZE := Vector2(192.0, 192.0)
const FRAME_COLUMNS := 3
const SPIRIT_WHITE := Color(1.0, 0.98, 0.82, 1.0)
const RELIC_GOLD := Color(0.96, 0.74, 0.28, 1.0)

@export var ability_component: AbilityComponent
@export var effect_sprite: Sprite2D

var _effect_tween: Tween
var _core_alpha := 0.0


func _ready() -> void:
	if effect_sprite == null:
		push_error("PiercingRushVisual requires its generated effect Sprite2D.")
	hide()


func play_phase(phase: int, duration_seconds: float) -> void:
	if (
		ability_component == null
		or ability_component.definition == null
		or ability_component.definition.presentation_style
			!= AbilityDefinition.PresentationStyle.THRUST
	):
		hide_visual()
		return
	_kill_tween()
	show()
	if effect_sprite != null:
		effect_sprite.show()
		effect_sprite.modulate = Color.WHITE
	match phase:
		AbilityComponent.Phase.WIND_UP:
			_core_alpha = 0.18
			_show_frame(0)
			_effect_tween = create_tween()
			_effect_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			_effect_tween.tween_interval(maxf(duration_seconds * 0.46, 0.001))
			_effect_tween.tween_callback(_show_frame.bind(1))
			_effect_tween.tween_method(
				_set_core_alpha,
				0.18,
				0.52,
				maxf(duration_seconds * 0.54, 0.001)
			)
		AbilityComponent.Phase.ACTIVE:
			_core_alpha = 1.0
			_show_frame(2)
			_effect_tween = create_tween()
			_effect_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			_effect_tween.tween_interval(maxf(duration_seconds * 0.38, 0.001))
			_effect_tween.tween_callback(_show_frame.bind(3))
			_effect_tween.tween_method(
				_set_core_alpha,
				1.0,
				0.78,
				maxf(duration_seconds * 0.62, 0.001)
			)
		AbilityComponent.Phase.RECOVERY:
			_show_frame(4)
			_effect_tween = create_tween()
			_effect_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
			_effect_tween.tween_interval(maxf(duration_seconds * 0.38, 0.001))
			_effect_tween.tween_callback(_show_frame.bind(5))
			_effect_tween.tween_method(
				_set_core_alpha,
				_core_alpha,
				0.0,
				maxf(duration_seconds * 0.62, 0.001)
			)
			if effect_sprite != null:
				_effect_tween.parallel().tween_property(
					effect_sprite,
					"modulate:a",
					0.0,
					maxf(duration_seconds * 0.62, 0.001)
				)
			_effect_tween.tween_callback(hide)
	queue_redraw()


func hide_visual() -> void:
	_kill_tween()
	_core_alpha = 0.0
	if effect_sprite != null:
		effect_sprite.hide()
		effect_sprite.modulate = Color.WHITE
	hide()
	queue_redraw()


func _draw() -> void:
	if _core_alpha <= 0.001:
		return
	# This tight underlay follows the actual 44 px contact lane. The generated
	# plume can be enormous without teaching the player that its outer ribbons hit.
	var alpha := clampf(_core_alpha, 0.0, 1.0)
	draw_line(Vector2(6.0, 0.0), Vector2(50.0, 0.0), Color(RELIC_GOLD, 0.52 * alpha), 5.0)
	draw_line(Vector2(6.0, 0.0), Vector2(50.0, 0.0), Color(SPIRIT_WHITE, 0.96 * alpha), 2.0)


func _show_frame(frame_index: int) -> void:
	if effect_sprite == null:
		return
	var column := frame_index % FRAME_COLUMNS
	var row := frame_index / FRAME_COLUMNS
	effect_sprite.region_rect = Rect2(
		Vector2(column, row) * FRAME_SIZE,
		FRAME_SIZE
	)
	effect_sprite.show()


func _set_core_alpha(value: float) -> void:
	_core_alpha = value
	queue_redraw()


func _kill_tween() -> void:
	if _effect_tween != null and _effect_tween.is_valid():
		_effect_tween.kill()
