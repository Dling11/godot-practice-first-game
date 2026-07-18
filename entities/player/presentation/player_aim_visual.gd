extends Node2D

## Presents aim direction without owning or changing player gameplay state.

@export var ability_component: AbilityComponent
@export var lock_during_ability_cast := false

var _cast_facing_locked := false


func _ready() -> void:
	if not lock_during_ability_cast or ability_component == null:
		return
	ability_component.ability_started.connect(_lock_cast_facing)
	ability_component.ability_finished.connect(_release_cast_facing)


func set_facing_direction(direction: Vector2) -> void:
	if _cast_facing_locked:
		return
	if not direction.is_zero_approx():
		rotation = direction.angle()


func _lock_cast_facing() -> void:
	if ability_component == null:
		return
	var cast_direction := ability_component.get_cast_direction()
	if cast_direction.is_zero_approx():
		return
	_cast_facing_locked = true
	rotation = cast_direction.angle()


func _release_cast_facing() -> void:
	_cast_facing_locked = false
