class_name SovereignPursuitTravelVisual
extends Node2D

## Character-following power sheath for Sovereign Pursuit's traversal only.
## The separate top-level SovereignPursuitVisual owns takeoff and landing ground VFX.

@export var ability_component: SovereignPursuitComponent
@export var effect_sprite: AnimatedSprite2D


func _ready() -> void:
	hide_visual()


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not _is_pursuit() or effect_sprite == null:
		hide_visual()
		return
	if phase == AbilityComponent.Phase.ACTIVE:
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"travel")
	elif phase == AbilityComponent.Phase.RECOVERY:
		hide_visual()


func hide_visual() -> void:
	if effect_sprite != null:
		effect_sprite.stop()
		effect_sprite.visible = false
	visible = false


func _is_pursuit() -> bool:
	return (
		ability_component != null
		and ability_component.definition != null
		and ability_component.definition.ability_id == &"sovereign_pursuit"
	)
