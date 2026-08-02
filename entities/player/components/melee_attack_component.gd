class_name MeleeAttackComponent
extends Node

enum Phase { IDLE, WIND_UP, ACTIVE, RECOVERY }

signal attack_started
signal phase_changed(phase: Phase, duration_seconds: float)
signal attack_finished
signal hit_landed(target: HurtboxComponent, info: DamageInfo)

@export var weapon: WeaponDefinition
@export var hitbox: MeleeHitbox
@export var collision_shape: CollisionShape2D

var phase := Phase.IDLE
var _phase_time_remaining: float
var _attack_direction := Vector2.RIGHT


func _ready() -> void:
	set_physics_process(false)
	if hitbox != null:
		hitbox.hit_landed.connect(_on_hit_landed)
	if weapon != null and weapon.melee_hitbox_shape != null and collision_shape != null:
		collision_shape.shape = weapon.melee_hitbox_shape


func set_weapon_definition(next_weapon: WeaponDefinition) -> bool:
	if (
		next_weapon == null
		or next_weapon.melee_hitbox_shape == null
		or collision_shape == null
	):
		return false
	weapon = next_weapon
	collision_shape.shape = next_weapon.melee_hitbox_shape
	return true


func request_attack(direction: Vector2) -> bool:
	if (
		phase != Phase.IDLE
		or weapon == null
		or weapon.melee_hitbox_shape == null
		or hitbox == null
		or collision_shape == null
	):
		return false
	_attack_direction = direction.normalized() if not direction.is_zero_approx() else Vector2.RIGHT
	attack_started.emit()
	_enter_phase(Phase.WIND_UP, weapon.wind_up_seconds)
	set_physics_process(true)
	return true


func get_attack_direction() -> Vector2:
	## The accepted direction remains immutable until this attack finishes.
	return _attack_direction


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
			hitbox.activate(
				weapon.damage,
				owner,
				_attack_direction,
				weapon.knockback_strength
			)
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
