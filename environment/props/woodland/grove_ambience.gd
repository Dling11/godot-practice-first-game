extends Node2D

## Reuse the accepted two-bird flight, with its Timer/Tween cadence, in the glade.
func _ready() -> void:
	var birds := preload("res://levels/sanctuary/town/garden_birds.gd").new()
	birds.name = "GroveBirds"
	birds.position = Vector2(384, 160)
	add_child(birds)
	birds.set_enabled(true)
