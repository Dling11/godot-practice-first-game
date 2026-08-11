class_name SovereignPursuitVisual
extends Node2D

@export var ability_component: SovereignPursuitComponent
@export var effect_sprite: AnimatedSprite2D

var _fade_tween: Tween
var _shockwave_tween: Tween
var _preserve_crater := false
var _shockwave_radius := 0.0
var _shockwave_alpha := 0.0


func _ready() -> void:
	set_as_top_level(true)
	_clear_visual()
	if effect_sprite != null and not effect_sprite.animation_finished.is_connected(_on_animation_finished):
		effect_sprite.animation_finished.connect(_on_animation_finished)


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not _is_pursuit() or effect_sprite == null:
		return
	if phase == AbilityComponent.Phase.ACTIVE:
		_reset_fade()
		_follow_landing_origin()
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"launch")


func play_strike(_strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	if not _is_pursuit() or effect_sprite == null:
		return
	_follow_landing_origin()
	_reset_fade()
	visible = true
	effect_sprite.visible = true
	effect_sprite.play(&"impact")
	_play_landing_shockwave()


func hide_visual() -> void:
	# Ability recovery ends before the authored crater should disappear. Preserve
	# only a completed landing residue; cancels and pre-impact exits clear now.
	if _preserve_crater:
		return
	_clear_visual()


func _clear_visual() -> void:
	_reset_fade()
	_reset_shockwave()
	if effect_sprite != null:
		effect_sprite.stop()
		effect_sprite.visible = false
	visible = false


func _on_animation_finished() -> void:
	if effect_sprite != null and effect_sprite.animation == &"impact":
		_preserve_crater = true
		effect_sprite.play(&"crater")
		_fade_tween = create_tween()
		_fade_tween.tween_interval(0.65)
		_fade_tween.tween_property(effect_sprite, "modulate:a", 0.0, 0.85)
		_fade_tween.tween_callback(_finish_crater)


func _is_pursuit() -> bool:
	return ability_component != null and ability_component.definition != null and ability_component.definition.ability_id == &"sovereign_pursuit"


func _follow_landing_origin() -> void:
	if ability_component != null and ability_component.owner is Node2D:
		global_position = (ability_component.owner as Node2D).global_position
		global_rotation = 0.0


func _reset_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
	_preserve_crater = false
	if effect_sprite != null:
		effect_sprite.modulate.a = 1.0


func _play_landing_shockwave() -> void:
	_reset_shockwave()
	_shockwave_radius = 18.0
	_shockwave_alpha = 0.95
	queue_redraw()
	_shockwave_tween = create_tween().set_parallel(true)
	_shockwave_tween.tween_method(_set_shockwave_radius, 18.0, 62.0, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_shockwave_tween.tween_method(_set_shockwave_alpha, 0.95, 0.0, 0.28).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)


func _reset_shockwave() -> void:
	if _shockwave_tween != null and _shockwave_tween.is_valid():
		_shockwave_tween.kill()
	_shockwave_tween = null
	_shockwave_radius = 0.0
	_shockwave_alpha = 0.0
	queue_redraw()


func _set_shockwave_radius(value: float) -> void:
	_shockwave_radius = value
	queue_redraw()


func _set_shockwave_alpha(value: float) -> void:
	_shockwave_alpha = value
	queue_redraw()


func _draw() -> void:
	if _shockwave_alpha <= 0.0:
		return
	var ground_center := Vector2(0.0, 16.0)
	draw_circle(ground_center, maxf(_shockwave_radius - 5.0, 1.0), Color(0.36, 0.68, 1.0, 0.08 * _shockwave_alpha))
	draw_arc(ground_center, _shockwave_radius, 0.0, TAU, 40, Color(0.88, 0.96, 1.0, 0.9 * _shockwave_alpha), 2.0, false)
	draw_arc(ground_center, maxf(_shockwave_radius - 5.0, 1.0), 0.0, TAU, 32, Color(0.34, 0.62, 1.0, 0.62 * _shockwave_alpha), 1.0, false)


func _finish_crater() -> void:
	_preserve_crater = false
	_clear_visual()
