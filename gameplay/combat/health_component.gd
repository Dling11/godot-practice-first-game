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
