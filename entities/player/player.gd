class_name Player
extends CharacterBody2D

## Coordinates player intent, movement authority, and outward-facing state.

signal facing_changed(direction: Vector2)
signal movement_changed(direction: Vector2, is_moving: bool)
signal defeated

const PlayerInputSourceScript = preload("res://entities/player/components/player_input_source.gd")
const PlayerMovementComponentScript = preload("res://entities/player/components/player_movement_component.gd")
const MeleeAttackComponentScript = preload("res://entities/player/components/melee_attack_component.gd")
const EvadeComponentScript = preload("res://entities/player/components/evade_component.gd")

@export var movement_bounds := Rect2(56.0, 56.0, 528.0, 248.0)

@onready var input_source: PlayerInputSourceScript = %InputSource
@onready var movement_component: PlayerMovementComponentScript = %MovementComponent
@onready var attack_component: MeleeAttackComponentScript = %MeleeAttackComponent
@onready var evade_component: EvadeComponentScript = %EvadeComponent
@onready var health_component: HealthComponent = %HealthComponent

var facing_direction := Vector2.DOWN
var is_defeated := false
var _was_moving := false


func _ready() -> void:
	health_component.died.connect(_on_died)
	facing_changed.emit(facing_direction)


func _physics_process(delta: float) -> void:
	var move_direction := input_source.get_move_direction()
	if input_source.is_evade_just_pressed():
		var evade_direction := move_direction if not move_direction.is_zero_approx() else facing_direction
		request_evade(evade_direction)

	if evade_component.is_dashing():
		velocity = evade_component.get_dash_velocity()
	else:
		velocity = movement_component.calculate_velocity(velocity, move_direction, delta)
	var is_moving := not move_direction.is_zero_approx() and not evade_component.is_dashing()
	if is_moving != _was_moving:
		_was_moving = is_moving
		movement_changed.emit(move_direction, is_moving)
	move_and_slide()
	global_position = global_position.clamp(
		movement_bounds.position,
		movement_bounds.end
	)

	var aim_direction := input_source.get_aim_direction(
		global_position,
		get_global_mouse_position()
	)
	if aim_direction.is_zero_approx() and not move_direction.is_zero_approx():
		aim_direction = move_direction.normalized()
	_set_facing_direction(aim_direction)
	if input_source.is_primary_attack_just_pressed():
		request_primary_attack()


func request_primary_attack() -> bool:
	if is_defeated or not evade_component.is_ready():
		return false
	return attack_component.request_attack(facing_direction)


func request_evade(direction: Vector2) -> bool:
	if is_defeated or attack_component.phase != attack_component.Phase.IDLE:
		return false
	return evade_component.request_evade(direction)


func _set_facing_direction(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return

	var normalized_direction := direction.normalized()
	if facing_direction.dot(normalized_direction) > 0.9999:
		return

	facing_direction = normalized_direction
	facing_changed.emit(facing_direction)


func _on_died() -> void:
	if is_defeated:
		return
	is_defeated = true
	velocity = Vector2.ZERO
	attack_component.cancel_attack()
	evade_component.cancel_evade()
	set_physics_process(false)
	defeated.emit()
