class_name MeleeAttackComponent
extends Node

enum Phase { IDLE, WIND_UP, ACTIVE, RECOVERY }

signal attack_started
signal phase_changed(phase: Phase, duration_seconds: float)
signal attack_finished
signal hit_landed(target: HurtboxComponent, info: DamageInfo)

@export var weapon: WeaponDefinition
@export var hitbox: MeleeHitbox

var phase := Phase.IDLE
var _phase_time_remaining: float
var _attack_direction := Vector2.RIGHT


func _ready() -> void:
	set_physics_process(false)
	if hitbox != null:
		hitbox.hit_landed.connect(_on_hit_landed)


func request_attack(direction: Vector2) -> bool:
	if phase != Phase.IDLE or weapon == null or hitbox == null:
		return false
	_attack_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	attack_started.emit()
	_enter_phase(Phase.WIND_UP, weapon.wind_up_seconds)
	set_physics_process(true)
	return true


func cancel_attack() -> void:
	if hitbox != null:
		hitbox.deactivate()
	phase = Phase.IDLE
	_phase_time_remaining = 0.0
	set_physics_process(false)
	attack_finished.emit()


func _physics_process(delta: float) -> void:
	_phase_time_remaining -= delta
	while _phase_time_remaining <= 0.0 and phase != Phase.IDLE:
		var overflow := -_phase_time_remaining
		_advance_phase()
		_phase_time_remaining -= overflow


func _advance_phase() -> void:
	match phase:
		Phase.WIND_UP:
			_enter_phase(Phase.ACTIVE, weapon.active_seconds)
			hitbox.activate(weapon.damage, owner, _attack_direction)
		Phase.ACTIVE:
			hitbox.deactivate()
			_enter_phase(Phase.RECOVERY, weapon.recovery_seconds)
		Phase.RECOVERY:
			phase = Phase.IDLE
			set_physics_process(false)
			attack_finished.emit()


func _enter_phase(next_phase: Phase, duration_seconds: float) -> void:
	phase = next_phase
	_phase_time_remaining = maxf(duration_seconds, 0.0001)
	phase_changed.emit(phase, duration_seconds)


func _on_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	hit_landed.emit(target, info)
