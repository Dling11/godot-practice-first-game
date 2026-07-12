class_name HurtboxComponent
extends Area2D

@export var health_component: HealthComponent


func receive_hit(info: DamageInfo) -> bool:
	if health_component == null:
		push_error("HurtboxComponent requires a HealthComponent.")
		return false
	return health_component.apply_damage(info)

