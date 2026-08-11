class_name RiftbreakVisual
extends Node2D

## Presentation-only observer for Riftbreak's generated ground-rupture frames.
## Damage radius and radial knockback remain owned by the component/hitbox.

@export var ability_component: RiftbreakComponent
@export var effect_sprite: AnimatedSprite2D

var _fade_tween: Tween
var _preserve_residual := false


func _ready() -> void:
	set_as_top_level(true)
	_clear_visual()
	if effect_sprite != null:
		if not effect_sprite.animation_finished.is_connected(_on_animation_finished):
			effect_sprite.animation_finished.connect(_on_animation_finished)


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not _is_riftbreak() or effect_sprite == null:
		hide_visual()
		return
	if phase == AbilityComponent.Phase.WIND_UP:
		_reset_fade()
		_capture_cast_origin()
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"wind_up")


func play_strike(_strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	if not _is_riftbreak() or effect_sprite == null:
		return
	visible = true
	_reset_fade()
	effect_sprite.visible = true
	effect_sprite.play(&"impact")


func hide_visual() -> void:
	if _preserve_residual:
		return
	_clear_visual()


func _clear_visual() -> void:
	_reset_fade()
	if effect_sprite != null:
		effect_sprite.stop()
		effect_sprite.visible = false
	visible = false


func _on_animation_finished() -> void:
	if effect_sprite != null and effect_sprite.animation == &"impact":
		_preserve_residual = true
		effect_sprite.play(&"residual")
		_fade_tween = create_tween()
		_fade_tween.tween_interval(0.55)
		_fade_tween.tween_property(effect_sprite, "modulate:a", 0.0, 0.75)
		_fade_tween.tween_callback(_finish_residual)


func _reset_fade() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	_fade_tween = null
	_preserve_residual = false
	if effect_sprite != null:
		effect_sprite.modulate.a = 1.0


func _finish_residual() -> void:
	_preserve_residual = false
	_clear_visual()


func _capture_cast_origin() -> void:
	if ability_component != null and ability_component.owner is Node2D:
		global_position = (ability_component.owner as Node2D).global_position
		global_rotation = 0.0


func _is_riftbreak() -> bool:
	return (
		ability_component != null
		and ability_component.definition != null
		and ability_component.definition.ability_id == &"riftbreak"
	)
