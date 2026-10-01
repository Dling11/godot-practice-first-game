class_name SanctuaryBuildingIdle
extends StaticBody2D

@export var window_glow: Node2D


func _ready() -> void:
	if window_glow == null:
		return
	var tween := create_tween().set_loops()
	tween.tween_property(window_glow, "modulate:a", 0.58, 1.5).from(0.95).set_trans(Tween.TRANS_SINE)
	tween.tween_property(window_glow, "modulate:a", 0.95, 1.9).set_trans(Tween.TRANS_SINE)
