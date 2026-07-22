class_name Player
extends CharacterBody2D

## Coordinates player intent, movement authority, and outward-facing state.

signal facing_changed(direction: Vector2)
signal movement_changed(direction: Vector2, is_moving: bool)
signal interaction_started
signal interaction_finished
signal defeated
signal testing_preset_applied(level: int, coins: int)
signal skill_loadout_changed

enum BufferedAction { NONE, PRIMARY_ATTACK, ABILITY_1, ABILITY_2 }

const PlayerInputSourceScript = preload("res://entities/player/components/player_input_source.gd")
const PlayerMovementComponentScript = preload("res://entities/player/components/player_movement_component.gd")
const MeleeAttackComponentScript = preload("res://entities/player/components/melee_attack_component.gd")
const EvadeComponentScript = preload("res://entities/player/components/evade_component.gd")
const AbilityComponentScript = preload("res://gameplay/abilities/ability_component.gd")

@export var movement_bounds := Rect2(56.0, 56.0, 528.0, 248.0)
@export var character_id: StringName = &"opaw"
@export var character_class_id: StringName = &"warrior"
@export var skill_loadout: SkillLoadoutDefinition
@export var debug_test_skill_loadout: SkillLoadoutDefinition
@export var weapon_catalog: WeaponCatalogDefinition

@onready var input_source: PlayerInputSourceScript = %InputSource
@onready var movement_component: PlayerMovementComponentScript = %MovementComponent
@onready var attack_component: MeleeAttackComponentScript = %MeleeAttackComponent
@onready var evade_component: EvadeComponentScript = %EvadeComponent
@onready var ability_1_component: AbilityComponentScript = %Ability1Component
@onready var ability_2_component: AbilityComponentScript = %Ability2Component
@onready var health_component: HealthComponent = %HealthComponent
@onready var progression_component: PlayerProgressionComponent = %ProgressionComponent
@onready var weapon_visual: PlayerWeaponVisual = $VisualRoot/WeaponVisual

var facing_direction := Vector2.DOWN
var is_defeated := false
var _was_moving := false
var _buffered_action := BufferedAction.NONE
var _buffered_action_direction := Vector2.DOWN


func _ready() -> void:
	health_component.died.connect(_on_died)
	evade_component.phase_changed.connect(_on_evade_phase_changed)
	attack_component.phase_changed.connect(_on_attack_phase_changed)
	ability_1_component.ability_finished.connect(_restore_ability_presentation_facing)
	ability_2_component.ability_finished.connect(_restore_ability_presentation_facing)
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
	if input_source.is_ability_2_just_pressed():
		request_ability(2)

	if evade_component.is_dashing():
		velocity = evade_component.get_dash_velocity()
	elif is_any_ability_casting():
		var active_ability := get_active_ability_component()
		if active_ability != null and active_ability.has_active_movement():
			velocity = active_ability.get_active_velocity()
		else:
			velocity = movement_component.calculate_velocity(velocity, Vector2.ZERO, delta)
	else:
		velocity = movement_component.calculate_velocity(velocity, move_direction, delta)
	var is_moving := (
		not move_direction.is_zero_approx()
		and not evade_component.is_dashing()
		and not is_any_ability_casting()
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
		_unlock_debug_test_equipment()
		_enable_debug_test_loadout()
		_unlock_debug_test_expeditions()
		get_viewport().set_input_as_handled()
		testing_preset_applied.emit(
			progression_component.level,
			progression_component.coins
		)


func request_primary_attack() -> bool:
	if (
		is_defeated
		or is_any_ability_casting()
		or attack_component.phase != attack_component.Phase.IDLE
	):
		return false
	if evade_component.is_dashing():
		return _buffer_action(BufferedAction.PRIMARY_ATTACK, facing_direction)
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
		or is_any_ability_casting()
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
		or is_any_ability_casting()
		or not component.is_ready()
	):
		return false
	if component.definition.activation_mode != AbilityDefinition.ActivationMode.IMMEDIATE_DIRECTIONAL:
		return false
	var action := (
		BufferedAction.ABILITY_1
		if slot_number == 1
		else BufferedAction.ABILITY_2
	)
	if attack_component.phase != attack_component.Phase.IDLE:
		_buffer_action(action, facing_direction)
		if attack_component.phase == attack_component.Phase.RECOVERY:
			return _try_execute_buffered_action()
		return true
	if evade_component.is_dashing():
		return _buffer_action(action, facing_direction)
	if evade_component.is_recovering():
		_buffer_action(action, facing_direction)
		return _try_execute_buffered_action()
	if not evade_component.is_ready():
		return false
	return _start_ability(component, facing_direction)


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	## Swapping is intentionally idle-only and never changes the shared Opaw
	## body SpriteFrames. Ownership is validated by equip_owned_weapon().
	if (
		next_weapon == null
		or next_weapon.world_texture == null
		or is_defeated
		or attack_component.phase != attack_component.Phase.IDLE
		or is_any_ability_casting()
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


func get_active_ability_component() -> AbilityComponent:
	for component in [ability_1_component, ability_2_component]:
		if component != null and component.is_casting():
			return component
	return null


func is_any_ability_casting() -> bool:
	return get_active_ability_component() != null


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
	if phase != EvadeComponent.Phase.RECOVERY:
		return
	_try_execute_buffered_action()


func _on_attack_phase_changed(phase: int, _duration_seconds: float) -> void:
	## A buffered technique never interrupts a live sword hit. It may replace only
	## the normal attack's recovery, matching the existing dash-recovery rule.
	if phase == MeleeAttackComponent.Phase.RECOVERY:
		_try_execute_buffered_action()


func _buffer_action(action: BufferedAction, direction: Vector2) -> bool:
	## One intent is retained until the current committed action reaches its
	## explicit safe boundary. A later valid input intentionally replaces it.
	_buffered_action = action
	_buffered_action_direction = (
		direction.normalized()
		if not direction.is_zero_approx()
		else facing_direction
	)
	return true


func _try_execute_buffered_action() -> bool:
	if _buffered_action == BufferedAction.NONE or is_defeated or is_any_ability_casting():
		return false
	if attack_component.phase != attack_component.Phase.IDLE:
		if attack_component.phase != attack_component.Phase.RECOVERY:
			return false
		attack_component.cancel_attack()
	if evade_component.is_dashing():
		return false
	if evade_component.is_recovering() and not evade_component.cancel_recovery():
		return false
	if not evade_component.is_ready():
		return false
	var action := _buffered_action
	var action_direction := _buffered_action_direction
	_buffered_action = BufferedAction.NONE
	if action == BufferedAction.PRIMARY_ATTACK:
		_set_facing_direction(action_direction)
		return attack_component.request_attack(action_direction)
	var component := get_ability_component_for_slot(
		1 if action == BufferedAction.ABILITY_1 else 2
	)
	if component == null:
		return false
	_set_facing_direction(action_direction)
	return _start_ability(component, action_direction)


func _start_ability(component: AbilityComponent, direction: Vector2) -> bool:
	var weapon_damage := (
		attack_component.weapon.damage
		if attack_component.weapon != null
		else 0.0
	)
	return component.request_cast(direction, weapon_damage)


func _restore_ability_presentation_facing() -> void:
	## Ability pivots deliberately ignore movement-facing changes while casting.
	## Refresh them once the lock is released so idle presentation is current.
	facing_changed.emit(facing_direction)


func _enable_debug_test_loadout() -> void:
	## F9 previews every fully authored test skill. The immutable normal loadout
	## remains sealed until Eira's future awakening flow owns normal unlocks.
	if debug_test_skill_loadout == null or skill_loadout == debug_test_skill_loadout:
		return
	skill_loadout = debug_test_skill_loadout
	skill_loadout_changed.emit()


func _unlock_debug_test_equipment() -> void:
	## Debug F9 makes every already-authored compatible weapon testable without
	## pretending that normal Orren purchases or future loot were completed.
	if weapon_catalog == null or not weapon_catalog.has_valid_layout():
		return
	var inventory := get_node_or_null("/root/WeaponInventory")
	if inventory == null:
		return
	for item: EquipmentDefinition in weapon_catalog.weapons:
		if item != null and item.is_compatible_with(character_class_id):
			inventory.acquire_weapon(item)


func _unlock_debug_test_expeditions() -> void:
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.apply_debug_expedition_unlocks()


func _on_died() -> void:
	if is_defeated:
		return
	is_defeated = true
	_buffered_action = BufferedAction.NONE
	velocity = Vector2.ZERO
	attack_component.cancel_attack()
	evade_component.cancel_evade()
	ability_1_component.cancel_cast()
	ability_2_component.cancel_cast()
	set_physics_process(false)
	defeated.emit()
