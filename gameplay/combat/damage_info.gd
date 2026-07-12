class_name DamageInfo
extends RefCounted

var amount: float
var source: Node
var direction: Vector2


func _init(new_amount: float, new_source: Node, new_direction: Vector2) -> void:
	amount = new_amount
	source = new_source
	direction = new_direction.normalized()

