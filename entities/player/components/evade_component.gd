class_name EvadeComponent
extends Node

enum Phase { READY, DASHING, RECOVERY }

signal evade_started(direction: Vector2)
signal phase_changed(phase: Phase, duration_seconds: float)
signal invulnerability_changed(is_invulnerable: bool)
signal evade_finished

@export var definition: EvadeDefinition

var phase := Phase.READY
var dash_direction := Vector2.DOWN
var _phase_time_remaining: float


func _ready() -> void:
	set_physics_process(false)


func request_evade(direction: Vector2) -> bool:
	if phase != Phase.READY or definition == null or direction.is_zero_approx():
		return false
	dash_direction = direction.normalized()
	phase = Phase.DASHING
	_phase_time_remaining = definition.dash_seconds
	evade_started.emit(dash_direction)
	phase_changed.emit(phase, definition.dash_seconds)
	invulnerability_changed.emit(true)
	set_physics_process(true)
	return true


func get_dash_velocity() -> Vector2:
	if phase != Phase.DASHING or definition == null:
		return Vector2.ZERO
	return dash_direction * definition.speed


func is_ready() -> bool:
	return phase == Phase.READY


func is_dashing() -> bool:
	return phase == Phase.DASHING


func is_recovering() -> bool:
	return phase == Phase.RECOVERY


func cancel_recovery() -> bool:
	## Basic attacks may cancel only the vulnerable recovery window. Keeping
	## active-dash cancellation unavailable preserves distance and i-frame rules.
	if phase != Phase.RECOVERY:
		return false
	phase = Phase.READY
	_phase_time_remaining = 0.0
	set_physics_process(false)
	evade_finished.emit()
	return true


func cancel_evade() -> void:
	if phase == Phase.DASHING:
		invulnerability_changed.emit(false)
	phase = Phase.READY
	_phase_time_remaining = 0.0
	set_physics_process(false)
	evade_finished.emit()


func _physics_process(delta: float) -> void:
	_phase_time_remaining -= delta
	if _phase_time_remaining > 0.0:
		return

	if phase == Phase.DASHING:
		invulnerability_changed.emit(false)
		phase = Phase.RECOVERY
		_phase_time_remaining = definition.recovery_seconds
		phase_changed.emit(phase, definition.recovery_seconds)
	elif phase == Phase.RECOVERY:
		phase = Phase.READY
		set_physics_process(false)
		evade_finished.emit()
