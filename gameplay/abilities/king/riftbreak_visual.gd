class_name RiftbreakVisual
extends Node2D

## Presentation-only observer for Riftbreak's generated ground-rupture frames.
## Damage radius and radial knockback remain owned by the component/hitbox.

@export var ability_component: RiftbreakComponent
@export var effect_sprite: AnimatedSprite2D


func _ready() -> void:
	visible = false
	if effect_sprite != null:
		effect_sprite.visible = false
		if not effect_sprite.animation_finished.is_connected(_on_animation_finished):
			effect_sprite.animation_finished.connect(_on_animation_finished)


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not _is_riftbreak() or effect_sprite == null:
		hide_visual()
		return
	if phase == AbilityComponent.Phase.WIND_UP:
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"wind_up")


func play_strike(_strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	if not _is_riftbreak() or effect_sprite == null:
		return
	visible = true
	effect_sprite.visible = true
	effect_sprite.play(&"impact")


func hide_visual() -> void:
	if effect_sprite != null:
		effect_sprite.stop()
		effect_sprite.visible = false
	visible = false


func _on_animation_finished() -> void:
	if effect_sprite != null and effect_sprite.animation == &"impact":
		effect_sprite.play(&"residual")


func _is_riftbreak() -> bool:
	return (
		ability_component != null
		and ability_component.definition != null
		and ability_component.definition.ability_id == &"riftbreak"
	)
