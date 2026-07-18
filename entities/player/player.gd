class_name Player
extends CharacterBody2D

## Coordinates player intent, movement authority, and outward-facing state.

signal facing_changed(direction: Vector2)
signal movement_changed(direction: Vector2, is_moving: bool)
signal interaction_started
signal interaction_finished
signal defeated
signal testing_preset_applied(level: int, coins: int)

const PlayerInputSourceScript = preload("res://entities/player/components/player_input_source.gd")
const PlayerMovementComponentScript = preload("res://entities/player/components/player_movement_component.gd")
const MeleeAttackComponentScript = preload("res://entities/player/components/melee_attack_component.gd")
const EvadeComponentScript = preload("res://entities/player/components/evade_component.gd")
const AbilityComponentScript = preload("res://gameplay/abilities/ability_component.gd")

@export var movement_bounds := Rect2(56.0, 56.0, 528.0, 248.0)
@export var character_id: StringName = &"opaw"
@export var character_class_id: StringName = &"warrior"
@export var skill_loadout: SkillLoadoutDefinition
@export var weapon_catalog: WeaponCatalogDefinition

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
var _primary_attack_buffered := false
var _buffered_primary_attack_direction := Vector2.DOWN


func _ready() -> void:
	health_component.died.connect(_on_died)
	evade_component.phase_changed.connect(_on_evade_phase_changed)
	_apply_inventory_weapon()
	facing_changed.emit(facing_direction)


func _physics_process(delta: float) -> void:
	var move_direction := input_source.get_move_direction()
	if not move_direction.is_zero_approx():
		_set_movement_facing_direction(move_direction)
	if input_source.is_evade_just_pressed():
		var evade_direction := move_direction if not move_direction.is_zero_approx() else facing_direction
		request_evade(evade_direction)
	if input_source.is_ability_1_just_pressed():
		request_ability_1()

	if evade_component.is_dashing():
		velocity = evade_component.get_dash_velocity()
	elif ability_1_component.is_casting():
		if ability_1_component.has_active_movement():
			velocity = ability_1_component.get_active_velocity()
		else:
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

	if input_source.is_primary_attack_just_pressed():
		request_primary_attack()


func _unhandled_input(event: InputEvent) -> void:
	if not event.is_action_pressed("debug_max_progression"):
		return
	if progression_component.apply_debug_testing_preset():
		get_viewport().set_input_as_handled()
		testing_preset_applied.emit(
			progression_component.level,
			progression_component.coins
		)


func request_primary_attack() -> bool:
	if (
		is_defeated
		or ability_1_component.is_casting()
		or attack_component.phase != attack_component.Phase.IDLE
	):
		return false
	if evade_component.is_dashing():
		_primary_attack_buffered = true
		_buffered_primary_attack_direction = facing_direction
		return true
	if evade_component.is_recovering():
		var attack_direction := facing_direction
		if not evade_component.cancel_recovery():
			return false
		return attack_component.request_attack(attack_direction)
	if not evade_component.is_ready():
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
	return request_ability(1)


func request_ability(slot_number: int) -> bool:
	var component := get_ability_component_for_slot(slot_number)
	if (
		component == null
		or is_defeated
		or attack_component.phase != attack_component.Phase.IDLE
		or not evade_component.is_ready()
	):
		return false
	if component.definition.activation_mode != AbilityDefinition.ActivationMode.IMMEDIATE_DIRECTIONAL:
		return false
	var weapon_damage := (
		attack_component.weapon.damage
		if attack_component.weapon != null
		else 0.0
	)
	return component.request_cast(facing_direction, weapon_damage)


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	## Swapping is intentionally idle-only and never changes the shared Opaw
	## body SpriteFrames. Ownership is validated by equip_owned_weapon().
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


func get_equipped_weapon_item() -> EquipmentDefinition:
	if weapon_catalog == null or not weapon_catalog.has_valid_layout():
		return null
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory == null:
		return weapon_catalog.default_weapon
	var item_id: StringName = inventory.get_equipped_weapon_id(
		character_id,
		weapon_catalog.default_weapon.item_id
	)
	return weapon_catalog.find_weapon(item_id)


func equip_owned_weapon(item: EquipmentDefinition) -> bool:
	if (
		item == null
		or weapon_catalog == null
		or weapon_catalog.find_weapon(item.item_id) != item
		or not item.is_compatible_with(character_class_id)
	):
		return false
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory == null or not inventory.owns_weapon(item.item_id):
		return false
	if not set_weapon_definition(item.weapon_definition):
		return false
	return inventory.equip_weapon(character_id, character_class_id, item)


func _apply_inventory_weapon() -> void:
	var equipped_item := get_equipped_weapon_item()
	if equipped_item == null or not set_weapon_definition(equipped_item.weapon_definition):
		push_error("Player requires a valid equipped weapon from its weapon catalog.")


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


func _set_movement_facing_direction(move_direction: Vector2) -> void:
	_set_facing_direction(
		input_source.resolve_cardinal_facing(move_direction, facing_direction)
	)


func _on_evade_phase_changed(phase: int, _duration_seconds: float) -> void:
	if phase != EvadeComponent.Phase.RECOVERY or not _primary_attack_buffered:
		return
	var attack_direction := _buffered_primary_attack_direction
	_primary_attack_buffered = false
	if not evade_component.cancel_recovery():
		return
	_set_facing_direction(attack_direction)
	if not attack_component.request_attack(attack_direction):
		push_error("Buffered primary attack could not start after dash recovery.")


func _on_died() -> void:
	if is_defeated:
		return
	is_defeated = true
	_primary_attack_buffered = false
	velocity = Vector2.ZERO
	attack_component.cancel_attack()
	evade_component.cancel_evade()
	ability_1_component.cancel_cast()
	set_physics_process(false)
	defeated.emit()
