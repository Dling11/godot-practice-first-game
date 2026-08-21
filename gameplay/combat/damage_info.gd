class_name DamageInfo
extends RefCounted

var amount: float
var raw_amount: float
var source: Node
var direction: Vector2
var knockback_strength: float
var stagger_seconds: float
var is_critical: bool


func _init(
	new_amount: float,
	new_source: Node,
	new_direction: Vector2,
	new_knockback_strength := 0.0,
	new_stagger_seconds := 0.0,
	new_is_critical := false
) -> void:
	amount = new_amount
	raw_amount = new_amount
	source = new_source
	direction = new_direction.normalized()
	knockback_strength = maxf(new_knockback_strength, 0.0)
	stagger_seconds = maxf(new_stagger_seconds, 0.0)
	is_critical = new_is_critical
