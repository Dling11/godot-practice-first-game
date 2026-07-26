class_name HealthComponent
extends Node

signal health_changed(current: float, maximum: float)
signal damaged(info: DamageInfo)
signal damage_blocked(info: DamageInfo)
signal died

@export_range(1.0, 999999.0, 1.0) var maximum_health: float = 100.0

var current_health: float
var is_invulnerable := false


func _ready() -> void:
	current_health = maximum_health


func set_maximum_health(next_maximum: float, preserve_missing_health := true) -> void:
	var previous_maximum := maximum_health
	var missing_health := maxf(previous_maximum - current_health, 0.0)
	maximum_health = maxf(next_maximum, 1.0)
	if preserve_missing_health:
		current_health = clampf(maximum_health - missing_health, 0.0, maximum_health)
	else:
		current_health = minf(current_health, maximum_health)
	health_changed.emit(current_health, maximum_health)


func set_current_health(next_current: float) -> void:
	current_health = clampf(next_current, 0.0, maximum_health)
	health_changed.emit(current_health, maximum_health)


func heal(amount: float) -> float:
	if current_health <= 0.0 or amount <= 0.0 or current_health >= maximum_health:
		return 0.0
	var previous_health := current_health
	current_health = minf(current_health + amount, maximum_health)
	health_changed.emit(current_health, maximum_health)
	return current_health - previous_health


func apply_damage(info: DamageInfo) -> bool:
	if current_health <= 0.0 or info.amount <= 0.0:
		return false
	if is_invulnerable:
		damage_blocked.emit(info)
		return false

	current_health = maxf(current_health - info.amount, 0.0)
	damaged.emit(info)
	health_changed.emit(current_health, maximum_health)
	if current_health <= 0.0:
		died.emit()
	return true


func set_invulnerable(value: bool) -> void:
	is_invulnerable = value
