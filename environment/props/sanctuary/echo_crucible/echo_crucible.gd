extends StaticBody2D

@onready var inner_glow: CanvasItem = %InnerGlow
@onready var orbit: Node2D = %Orbit


func _ready() -> void:
	var pulse := create_tween().set_loops()
	pulse.tween_property(inner_glow, "modulate:a", 0.45, 0.8).from(0.9).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(inner_glow, "modulate:a", 0.9, 1.0).set_trans(Tween.TRANS_SINE)
	var spin := create_tween().set_loops()
	spin.tween_property(orbit, "rotation", TAU, 4.6).from(0.0)
