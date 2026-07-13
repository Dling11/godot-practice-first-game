class_name DamageInfo
extends RefCounted

var amount: float
var source: Node
var direction: Vector2
var knockback_strength: float


func _init(
	new_amount: float,
	new_source: Node,
	new_direction: Vector2,
	new_knockback_strength := 0.0
) -> void:
	amount = new_amount
	source = new_source
	direction = new_direction.normalized()
	knockback_strength = maxf(new_knockback_strength, 0.0)
