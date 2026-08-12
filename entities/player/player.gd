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

enum BufferedAction { NONE, PRIMARY_ATTACK, EVADE, ABILITY }

const ACTION_BUFFER_WINDOW_SECONDS := 0.8

const PlayerInputSourceScript = preload("res://entities/player/components/player_input_source.gd")
const PlayerMovementComponentScript = preload("res://entities/player/components/player_movement_component.gd")
const MeleeAttackComponentScript = preload("res://entities/player/components/melee_attack_component.gd")
const EvadeComponentScript = preload("res://entities/player/components/evade_component.gd")
const AbilityComponentScript = preload("res://gameplay/abilities/ability_component.gd")
const DirectionalWedgeTargetingScript = preload("res://gameplay/abilities/targeting/directional_wedge_targeting.gd")
const GroundPointTargetingScript = preload("res://gameplay/abilities/targeting/ground_point_targeting.gd")

@export var movement_bounds := Rect2(56.0, 56.0, 528.0, 248.0)
@export var character_id: StringName = &"opaw"
@export var character_class_id: StringName = &"warrior"
@export var skill_loadout: SkillLoadoutDefinition
@export var awakened_skill_loadout: SkillLoadoutDefinition
@export var debug_test_skill_loadout: SkillLoadoutDefinition
@export var weapon_catalog: WeaponCatalogDefinition

@onready var input_source: PlayerInputSourceScript = %InputSource
@onready var movement_component: PlayerMovementComponentScript = %MovementComponent
@onready var attack_component: MeleeAttackComponentScript = %MeleeAttackComponent
@onready var evade_component: EvadeComponentScript = %EvadeComponent
@onready var ability_1_component: AbilityComponentScript = %Ability1Component
@onready var ability_2_component: AbilityComponentScript = %Ability2Component
@onready var ability_3_component: AbilityComponentScript = %Ability3Component
@onready var ability_4_component: AbilityComponentScript = %Ability4Component
@onready var directional_wedge_targeting: DirectionalWedgeTargetingScript = %DirectionalWedgeTargeting
@onready var ground_point_targeting: GroundPointTargetingScript = %GroundPointTargeting
@onready var health_component: HealthComponent = %HealthComponent
@onready var progression_component: PlayerProgressionComponent = %ProgressionComponent
@onready var vitality_component: PlayerVitalityComponent = %VitalityComponent
@onready var health_regeneration_component: PlayerHealthRegenerationComponent = %HealthRegenerationComponent
@onready var weapon_visual: PlayerWeaponVisual = $VisualRoot/WeaponVisual
@onready var action_buffer_timer: Timer = %ActionBufferTimer

var facing_direction := Vector2.DOWN
var is_defeated := false
var _was_moving := false
var _buffered_action := BufferedAction.NONE
var _buffered_action_direction := Vector2.DOWN
var _buffered_ability_slot := 0
var _pending_weapon_definition: WeaponDefinition
var _debug_unlimited_skills := false


func _ready() -> void:
	_restore_run_health()
	health_component.health_changed.connect(_sync_run_health)
	health_component.died.connect(_on_died)
	evade_component.phase_changed.connect(_on_evade_phase_changed)
	attack_component.phase_changed.connect(_on_attack_phase_changed)
	attack_component.attack_finished.connect(_on_attack_finished)
	ability_1_component.ability_finished.connect(_on_ability_finished)
	ability_2_component.ability_finished.connect(_on_ability_finished)
	ability_3_component.ability_finished.connect(_on_ability_finished)
	ability_4_component.ability_finished.connect(_on_ability_finished)
	action_buffer_timer.timeout.connect(_clear_buffered_action)
	directional_wedge_targeting.targeting_confirmed.connect(_on_directional_targeting_confirmed)
	ground_point_targeting.targeting_confirmed.connect(_on_ground_targeting_confirmed)
	_apply_story_skill_loadout()
	_apply_inventory_weapon()
	facing_changed.emit(facing_direction)


func _restore_run_health() -> void:
	var run_session := get_node_or_null("/root/RunSession")
	if run_session == null:
		return
	if run_session.has_player_health_state():
		health_component.set_current_health(
			clampf(
				run_session.player_current_health,
				1.0,
				health_component.maximum_health
			)
		)
	else:
		run_session.update_player_health(health_component.current_health)


func _sync_run_health(current: float, _maximum: float) -> void:
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		run_session.update_player_health(current)


func _physics_process(delta: float) -> void:
	_try_apply_pending_weapon()
	var move_direction := input_source.get_move_direction()
	if directional_wedge_targeting.is_targeting():
		directional_wedge_targeting.update_aim(
			get_global_mouse_position() - directional_wedge_targeting.global_position,
			input_source.get_aim_direction()
		)
	if ground_point_targeting.is_targeting():
		ground_point_targeting.update_aim(get_global_mouse_position(), input_source.get_aim_direction())
	if not move_direction.is_zero_approx():
		_set_movement_facing_direction(move_direction)
	if input_source.is_evade_just_pressed():
		var evade_direction := move_direction if not move_direction.is_zero_approx() else facing_direction
		request_evade(evade_direction)
	if input_source.is_ability_1_just_pressed():
		request_ability_1()
	if input_source.is_ability_2_just_pressed():
		request_ability(2)
	if input_source.is_ability_3_just_pressed():
		request_ability(3)
	if input_source.is_ability_4_just_pressed():
		request_ability(4)

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

func _unhandled_input(event: InputEvent) -> void:
	if _is_targeting_any_ability():
		if event.is_action_pressed("player_attack_primary"):
			if directional_wedge_targeting.is_targeting():
				directional_wedge_targeting.confirm_targeting()
			else:
				ground_point_targeting.confirm_targeting()
			get_viewport().set_input_as_handled()
			return
		if (
			event.is_action_pressed("ui_cancel")
			or (event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_RIGHT and event.pressed)
		):
			_cancel_all_targeting()
			get_viewport().set_input_as_handled()
			return
	if event.is_action_pressed("player_attack_primary"):
		if request_primary_attack():
			get_viewport().set_input_as_handled()
		return
	if not event.is_action_pressed("debug_max_progression"):
		return
	progression_component.apply_debug_testing_preset()
	var save_service := get_node_or_null("/root/SaveService")
	if save_service != null:
		save_service.suppress_autosave_for_debug_session()
	_unlock_debug_test_equipment()
	_unlock_debug_test_materials()
	_enable_debug_test_loadout()
	_enable_debug_unlimited_skills()
	_unlock_debug_test_expeditions()
	get_viewport().set_input_as_handled()
	testing_preset_applied.emit(
		progression_component.level,
		progression_component.coins
	)


func request_primary_attack() -> bool:
	if is_defeated or _is_targeting_any_ability():
		return false
	if is_any_ability_casting():
		return _buffer_action(BufferedAction.PRIMARY_ATTACK, facing_direction)
	if attack_component.phase != attack_component.Phase.IDLE:
		_buffer_action(BufferedAction.PRIMARY_ATTACK, facing_direction)
		return true
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
	if is_defeated:
		return false
	if direction.is_zero_approx():
		return false
	_cancel_all_targeting()
	var active_ability := get_active_ability_component()
	if active_ability != null:
		if not evade_component.is_evade_available():
			return false
		if active_ability.definition != null and active_ability.definition.dash_cancelable:
			active_ability.cancel_cast()
		else:
			return _buffer_action(BufferedAction.EVADE, direction)
	if attack_component.phase != attack_component.Phase.IDLE:
		if not evade_component.is_evade_available():
			return false
		_buffer_action(BufferedAction.EVADE, direction)
		if attack_component.phase == attack_component.Phase.RECOVERY:
			return _try_execute_buffered_action()
		return true
	if not evade_component.is_evade_available():
		return false
	return evade_component.request_evade(direction)


func request_ability_1() -> bool:
	return request_ability(1)


func request_ability(slot_number: int) -> bool:
	var component := get_ability_component_for_slot(slot_number)
	if _is_targeting_any_ability():
		## Repeating the skill key is intentionally consumed but never confirms.
		## Confirmation belongs only to primary attack/right trigger.
		return directional_wedge_targeting.get_target_component() == component or ground_point_targeting.get_target_component() == component
	if (
		component == null
		or is_defeated
		or not component.is_ready()
	):
		return false
	if is_any_ability_casting():
		return _buffer_action(BufferedAction.ABILITY, facing_direction, slot_number)
	if attack_component.phase != attack_component.Phase.IDLE:
		_buffer_action(BufferedAction.ABILITY, facing_direction, slot_number)
		if attack_component.phase == attack_component.Phase.RECOVERY:
			return _try_execute_buffered_action()
		return true
	if evade_component.is_dashing():
		return _buffer_action(BufferedAction.ABILITY, facing_direction, slot_number)
	if evade_component.is_recovering():
		_buffer_action(BufferedAction.ABILITY, facing_direction, slot_number)
		return _try_execute_buffered_action()
	if not evade_component.is_ready():
		return false
	return _begin_ability_input(component, facing_direction)


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	## Swapping is intentionally idle-only and never changes the shared Opaw
	## body SpriteFrames. Ownership is validated by equip_owned_weapon().
	if (
		next_weapon == null
		or next_weapon.world_texture == null
		or next_weapon.melee_hitbox_shape == null
		or is_defeated
		or attack_component.phase != attack_component.Phase.IDLE
		or is_any_ability_casting()
		or _is_targeting_any_ability()
		or evade_component.is_dashing()
	):
		return false
	if not weapon_visual.set_weapon_definition(next_weapon):
		return false
	return attack_component.set_weapon_definition(next_weapon)


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
	if not inventory.equip_weapon(character_id, character_class_id, item):
		return false
	if set_weapon_definition(item.weapon_definition):
		_pending_weapon_definition = null
	else:
		_pending_weapon_definition = item.weapon_definition
	return true


func can_awaken_skill_2() -> bool:
	if character_id != &"opaw":
		return false
	var story_state := get_node_or_null("/root/StoryState")
	return (
		progression_component.level >= 3
		and awakened_skill_loadout != null
		and (story_state == null or not story_state.has_story_flag(&"opaw_consecutive_thrust_awakened"))
	)


func awaken_skill_2() -> bool:
	if not can_awaken_skill_2():
		return false
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.remember_story(&"opaw_consecutive_thrust_awakened")
	skill_loadout = awakened_skill_loadout
	skill_loadout_changed.emit()
	return true


func _apply_inventory_weapon() -> void:
	var equipped_item := get_equipped_weapon_item()
	if equipped_item == null or not set_weapon_definition(equipped_item.weapon_definition):
		push_error("Player requires a valid equipped weapon from its weapon catalog.")


func _try_apply_pending_weapon() -> void:
	if _pending_weapon_definition == null:
		return
	if set_weapon_definition(_pending_weapon_definition):
		_pending_weapon_definition = null


func _apply_story_skill_loadout() -> void:
	var story_state := get_node_or_null("/root/StoryState")
	if (
		story_state != null
		and story_state.has_story_flag(&"opaw_consecutive_thrust_awakened")
		and awakened_skill_loadout != null
	):
		skill_loadout = awakened_skill_loadout


func face_toward(world_position: Vector2) -> void:
	## Used by explicit world interactions before their modal pauses gameplay.
	## Input remains the normal owner of facing outside that interaction moment.
	_set_facing_direction(world_position - global_position)


func begin_interaction(world_position: Vector2) -> void:
	if is_defeated:
		return
	_cancel_all_targeting()
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
	for component in [ability_1_component, ability_2_component, ability_3_component, ability_4_component]:
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
	## A repeated primary attack waits for the full recovery so button mashing
	## cannot erase the weapon's authored cadence.
	if (
		phase == MeleeAttackComponent.Phase.RECOVERY
		and _buffered_action != BufferedAction.PRIMARY_ATTACK
	):
		_try_execute_buffered_action()


func _on_attack_finished() -> void:
	if _buffered_action == BufferedAction.PRIMARY_ATTACK:
		_try_execute_buffered_action()


func _buffer_action(action: BufferedAction, direction: Vector2, ability_slot := 0) -> bool:
	## One latest intent survives only a short responsiveness window. It never
	## waits through a long cooldown or stacks a sequence of future actions.
	_buffered_action = action
	_buffered_ability_slot = ability_slot
	_buffered_action_direction = (
		direction.normalized()
		if not direction.is_zero_approx()
		else facing_direction
	)
	action_buffer_timer.start(ACTION_BUFFER_WINDOW_SECONDS)
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
	var ability_slot := _buffered_ability_slot
	_clear_buffered_action()
	if action == BufferedAction.PRIMARY_ATTACK:
		_set_facing_direction(action_direction)
		return attack_component.request_attack(action_direction)
	if action == BufferedAction.EVADE:
		return evade_component.request_evade(action_direction)
	var component := get_ability_component_for_slot(ability_slot)
	if component == null:
		return false
	_set_facing_direction(action_direction)
	return _begin_ability_input(component, action_direction)


func _clear_buffered_action() -> void:
	_buffered_action = BufferedAction.NONE
	_buffered_ability_slot = 0
	if not action_buffer_timer.is_stopped():
		action_buffer_timer.stop()


func _begin_ability_input(component: AbilityComponent, direction: Vector2) -> bool:
	if component == null or component.definition == null or not component.is_ready():
		return false
	match component.definition.activation_mode:
		AbilityDefinition.ActivationMode.DIRECTIONAL_WEDGE_TARGETED:
			return directional_wedge_targeting.begin_targeting(component, direction)
		AbilityDefinition.ActivationMode.GROUND_TARGETED:
			return ground_point_targeting.begin_targeting(component, direction)
		AbilityDefinition.ActivationMode.IMMEDIATE_DIRECTIONAL, AbilityDefinition.ActivationMode.SELF_AREA:
			return _start_ability(component, direction)
	return false


func _start_ability(component: AbilityComponent, direction: Vector2) -> bool:
	var weapon_damage := (
		attack_component.weapon.damage
		if attack_component.weapon != null
		else 0.0
	)
	return component.request_cast(direction, weapon_damage)


func _on_directional_targeting_confirmed(component: AbilityComponent, direction: Vector2) -> void:
	if component == null or is_defeated or is_any_ability_casting():
		return
	## The hitbox/VFX preserve the exact 360-degree aim. King's current body art
	## deliberately chooses the nearest cardinal animation until diagonal sheets
	## are ever approved, and ordinary post-cast combat facing stays cardinal.
	_set_facing_direction(
		input_source.resolve_cardinal_facing(direction, facing_direction)
	)
	_start_ability(component, direction)


func _on_ground_targeting_confirmed(component: AbilityComponent, target_global_position: Vector2) -> void:
	if component == null or is_defeated or is_any_ability_casting():
		return
	var direction := target_global_position - global_position
	_set_facing_direction(input_source.resolve_cardinal_facing(direction, facing_direction))
	var weapon_damage := attack_component.weapon.damage if attack_component.weapon != null else 0.0
	component.request_cast_at(target_global_position, weapon_damage)


func _is_targeting_any_ability() -> bool:
	return directional_wedge_targeting.is_targeting() or ground_point_targeting.is_targeting()


func _cancel_all_targeting() -> void:
	directional_wedge_targeting.cancel_targeting()
	ground_point_targeting.cancel_targeting()


func _restore_ability_presentation_facing() -> void:
	## Ability pivots deliberately ignore movement-facing changes while casting.
	## Refresh them once the lock is released so idle presentation is current.
	facing_changed.emit(facing_direction)


func _on_ability_finished() -> void:
	if _debug_unlimited_skills:
		_clear_all_ability_cooldowns()
	_restore_ability_presentation_facing()
	_try_execute_buffered_action()


func _enable_debug_test_loadout() -> void:
	## F9 previews every fully authored test skill without writing Eira's normal
	## session awakening flag.
	if debug_test_skill_loadout == null or skill_loadout == debug_test_skill_loadout:
		return
	skill_loadout = debug_test_skill_loadout
	skill_loadout_changed.emit()


func _enable_debug_unlimited_skills() -> void:
	_debug_unlimited_skills = true
	_clear_all_ability_cooldowns()


func _clear_all_ability_cooldowns() -> void:
	for component in [ability_1_component, ability_2_component, ability_3_component, ability_4_component]:
		if component != null:
			component.clear_cooldown()


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


func _unlock_debug_test_materials() -> void:
	## Normal enemies and chests still grant no materials. This only exposes
	## the existing catalog/inventory UI for fast local inspection.
	var material_inventory := get_node_or_null("/root/MaterialInventory")
	if material_inventory != null:
		material_inventory.apply_debug_testing_preset()


func _unlock_debug_test_expeditions() -> void:
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.apply_debug_expedition_unlocks()


func _on_died() -> void:
	if is_defeated:
		return
	is_defeated = true
	_clear_buffered_action()
	_cancel_all_targeting()
	velocity = Vector2.ZERO
	attack_component.cancel_attack()
	evade_component.cancel_evade()
	ability_1_component.cancel_cast()
	ability_2_component.cancel_cast()
	ability_3_component.cancel_cast()
	ability_4_component.cancel_cast()
	set_physics_process(false)
	defeated.emit()
