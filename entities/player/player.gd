class_name Player
extends CharacterBody2D

## Coordinates player intent, movement authority, and outward-facing state.

signal facing_changed(direction: Vector2)
signal movement_changed(direction: Vector2, is_moving: bool)
signal interaction_started
signal interaction_finished
signal defeated

const PlayerInputSourceScript = preload("res://entities/player/components/player_input_source.gd")
const PlayerMovementComponentScript = preload("res://entities/player/components/player_movement_component.gd")
const MeleeAttackComponentScript = preload("res://entities/player/components/melee_attack_component.gd")
const EvadeComponentScript = preload("res://entities/player/components/evade_component.gd")
const AbilityComponentScript = preload("res://gameplay/abilities/ability_component.gd")

@export var movement_bounds := Rect2(56.0, 56.0, 528.0, 248.0)
@export var skill_loadout: SkillLoadoutDefinition
@export var equipment_showcase: EquipmentShowcaseDefinition

@onready var input_source: PlayerInputSourceScript = %InputSource
@onready var movement_component: PlayerMovementComponentScript = %MovementComponent
@onready var attack_component: MeleeAttackComponentScript = %MeleeAttackComponent
@onready var evade_component: EvadeComponentScript = %EvadeComponent
@onready var ability_1_component: AbilityComponentScript = %Ability1Component
@onready var health_component: HealthComponent = %HealthComponent
@onready var progression_component: PlayerProgressionComponent = %ProgressionComponent
@onready var weapon_visual: PlayerWeaponVisual = $VisualRoot/WeaponVisual

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
	if input_source.is_ability_1_just_pressed():
		request_ability_1()

	if evade_component.is_dashing():
		velocity = evade_component.get_dash_velocity()
	elif ability_1_component.is_casting():
		velocity = movement_component.calculate_velocity(velocity, Vector2.ZERO, delta)
	else:
		velocity = movement_component.calculate_velocity(velocity, move_direction, delta)
	var is_moving := (
		not move_direction.is_zero_approx()
		and not evade_component.is_dashing()
		and not ability_1_component.is_casting()
	)
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
	if is_defeated or not evade_component.is_ready() or ability_1_component.is_casting():
		return false
	return attack_component.request_attack(facing_direction)


func request_evade(direction: Vector2) -> bool:
	if (
		is_defeated
		or attack_component.phase != attack_component.Phase.IDLE
		or ability_1_component.is_casting()
	):
		return false
	return evade_component.request_evade(direction)


func request_ability_1() -> bool:
	if (
		is_defeated
		or attack_component.phase != attack_component.Phase.IDLE
		or not evade_component.is_ready()
	):
		return false
	return ability_1_component.request_cast(facing_direction)


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	## Equipment/inventory may call this seam later. Swapping is intentionally
	## idle-only, and never changes the shared Opaw body SpriteFrames.
	if (
		next_weapon == null
		or next_weapon.world_texture == null
		or is_defeated
		or attack_component.phase != attack_component.Phase.IDLE
		or ability_1_component.is_casting()
		or evade_component.is_dashing()
	):
		return false
	if not weapon_visual.set_weapon_definition(next_weapon):
		return false
	attack_component.weapon = next_weapon
	return true


func face_toward(world_position: Vector2) -> void:
	## Used by explicit world interactions before their modal pauses gameplay.
	## Input remains the normal owner of facing outside that interaction moment.
	_set_facing_direction(world_position - global_position)


func begin_interaction(world_position: Vector2) -> void:
	if is_defeated:
		return
	face_toward(world_position)
	interaction_started.emit()


func finish_interaction() -> void:
	if is_defeated:
		return
	interaction_finished.emit()


func get_ability_component_for_slot(slot_number: int) -> AbilityComponent:
	if skill_loadout == null:
		return null
	var slot := skill_loadout.get_slot(slot_number)
	if slot == null or slot.ability == null:
		return null
	for child: Node in get_children():
		var component := child as AbilityComponent
		if component != null and component.definition == slot.ability:
			return component
	return null


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
	ability_1_component.cancel_cast()
	set_physics_process(false)
	defeated.emit()
