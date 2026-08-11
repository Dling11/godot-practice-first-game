class_name EchoingSeverVisual
extends Node2D

## Presentation-only observer for Echoing Sever's authoritative two contacts.
## The exact aim remains owned by AbilityPivot and damage remains in the
## component/hitbox; this node only selects approved VFX animations.

@export var ability_component: AbilityComponent
@export var effect_sprite: AnimatedSprite2D


func _ready() -> void:
	visible = false
	if effect_sprite != null:
		effect_sprite.visible = false
		if not effect_sprite.animation_finished.is_connected(_on_animation_finished):
			effect_sprite.animation_finished.connect(_on_animation_finished)


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not _is_echoing_sever() or effect_sprite == null:
		hide_visual()
		return
	if phase == AbilityComponent.Phase.WIND_UP:
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"wind_up")


func play_strike(strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	if not _is_echoing_sever() or effect_sprite == null:
		return
	visible = true
	effect_sprite.visible = true
	effect_sprite.play(&"echo" if strike_index > 0 else &"primary")


func hide_visual() -> void:
	if effect_sprite != null:
		effect_sprite.stop()
		effect_sprite.visible = false
	visible = false


func _on_animation_finished() -> void:
	if effect_sprite != null and effect_sprite.animation == &"primary":
		effect_sprite.play(&"rift_hold")


func _is_echoing_sever() -> bool:
	return (
		ability_component != null
		and ability_component.definition != null
		and ability_component.definition.ability_id == &"echoing_sever"
	)
