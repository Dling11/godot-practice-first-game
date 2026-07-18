class_name AbilityComponent
extends Node

enum Phase { IDLE, WIND_UP, ACTIVE, RECOVERY }

signal ability_started
signal phase_changed(phase: Phase, duration_seconds: float)
signal ability_finished
signal cooldown_started(duration_seconds: float)
signal cooldown_finished
signal strike_started(strike_index: int, strike_count: int, duration_seconds: float)
signal hit_landed(target: HurtboxComponent, info: DamageInfo)

@export var definition: AbilityDefinition
@export var hitbox: MeleeHitbox
@export var collision_shape: CollisionShape2D

var phase := Phase.IDLE
var cooldown_remaining := 0.0
var _phase_time_remaining := 0.0
var _cast_direction := Vector2.RIGHT
var _equipped_weapon_damage := 0.0
var _resolved_damage := 0.0
var _current_strike_index := 0
var _strike_time_remaining := 0.0


func _ready() -> void:
	set_physics_process(false)
	if hitbox != null:
		hitbox.hit_landed.connect(_on_hit_landed)


func is_ready() -> bool:
	return phase == Phase.IDLE and cooldown_remaining <= 0.0


func is_casting() -> bool:
	return phase != Phase.IDLE


func get_cast_direction() -> Vector2:
	## The cast direction is immutable from wind-up through recovery. Presentation
	## pivots use this instead of live movement-facing input during a technique.
	return _cast_direction


func get_current_strike_index() -> int:
	return _current_strike_index


func is_current_strike_final() -> bool:
	return definition != null and _current_strike_index >= definition.strike_count() - 1


func request_cast(direction: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if (
		not is_ready()
		or definition == null
		or hitbox == null
		or collision_shape == null
		or definition.hitbox_shape == null
	):
		return false
	_cast_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	_equipped_weapon_damage = equipped_weapon_damage
	_resolved_damage = definition.resolve_damage(equipped_weapon_damage)
	collision_shape.shape = definition.hitbox_shape
	cooldown_remaining = definition.cooldown_seconds
	ability_started.emit()
	cooldown_started.emit(definition.cooldown_seconds)
	_enter_phase(Phase.WIND_UP, definition.wind_up_seconds)
	set_physics_process(true)
	return true


func get_active_velocity() -> Vector2:
	if phase != Phase.ACTIVE or definition == null:
		return Vector2.ZERO
	return _cast_direction * definition.active_movement_speed


func has_active_movement() -> bool:
	return definition != null and definition.active_movement_speed > 0.0


func get_resolved_damage() -> float:
	return _resolved_damage


func cancel_cast() -> void:
	if hitbox != null:
		hitbox.deactivate()
	if phase != Phase.IDLE:
		phase = Phase.IDLE
		_phase_time_remaining = 0.0
		ability_finished.emit()
	_update_processing()


func _physics_process(delta: float) -> void:
	if cooldown_remaining > 0.0:
		cooldown_remaining = maxf(cooldown_remaining - delta, 0.0)
		if cooldown_remaining <= 0.0:
			cooldown_finished.emit()
	if phase != Phase.IDLE:
		if phase == Phase.ACTIVE:
			_advance_active_strikes(delta)
		_phase_time_remaining -= delta
		while _phase_time_remaining <= 0.0 and phase != Phase.IDLE:
			var overflow := -_phase_time_remaining
			_advance_phase()
			_phase_time_remaining -= overflow
	_update_processing()


func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			_enter_phase(Phase.ACTIVE, definition.active_seconds)
			_current_strike_index = 0
			_start_current_strike()
		Phase.ACTIVE:
			hitbox.deactivate()
			_enter_phase(Phase.RECOVERY, definition.recovery_seconds)
		Phase.RECOVERY:
			phase = Phase.IDLE
			ability_finished.emit()


func _enter_phase(next_phase: Phase, duration_seconds: float) -> void:
	phase = next_phase
	_phase_time_remaining = maxf(duration_seconds, 0.0001)
	phase_changed.emit(phase, duration_seconds)


func _advance_active_strikes(delta: float) -> void:
	if definition == null or definition.strike_count() <= 1:
		return
	_strike_time_remaining -= delta
	while _strike_time_remaining <= 0.0 and _current_strike_index < definition.strike_count() - 1:
		_current_strike_index += 1
		_start_current_strike()


func _start_current_strike() -> void:
	if definition == null or hitbox == null:
		return
	var strike_count := definition.strike_count()
	_strike_time_remaining = definition.active_seconds / float(strike_count)
	hitbox.activate(
		definition.resolve_strike_damage(_equipped_weapon_damage, _current_strike_index),
		owner,
		_cast_direction,
		definition.resolve_strike_knockback(_current_strike_index),
		definition.resolve_strike_stagger(_current_strike_index)
	)
	strike_started.emit(_current_strike_index, strike_count, _strike_time_remaining)


func _update_processing() -> void:
	set_physics_process(phase != Phase.IDLE or cooldown_remaining > 0.0)


func _on_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	hit_landed.emit(target, info)
