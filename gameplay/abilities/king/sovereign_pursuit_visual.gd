class_name SovereignPursuitVisual
extends Node2D

@export var ability_component: SovereignPursuitComponent
@export var effect_sprite: AnimatedSprite2D


func _ready() -> void:
	hide_visual()
	if effect_sprite != null and not effect_sprite.animation_finished.is_connected(_on_animation_finished):
		effect_sprite.animation_finished.connect(_on_animation_finished)


func play_phase(phase: int, _duration_seconds: float) -> void:
	if not _is_pursuit() or effect_sprite == null:
		return
	if phase == AbilityComponent.Phase.ACTIVE:
		_follow_landing_origin()
		visible = true
		effect_sprite.visible = true
		effect_sprite.play(&"descent")


func play_strike(_strike_index: int, _strike_count: int, _duration_seconds: float) -> void:
	if not _is_pursuit() or effect_sprite == null:
		return
	_follow_landing_origin()
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


func _is_pursuit() -> bool:
	return ability_component != null and ability_component.definition != null and ability_component.definition.ability_id == &"sovereign_pursuit"


func _follow_landing_origin() -> void:
	if ability_component != null and ability_component.owner is Node2D:
		global_position = (ability_component.owner as Node2D).global_position
		global_rotation = 0.0
