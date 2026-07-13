class_name SanctuaryTreeIdle
extends StaticBody2D

@export var sway_visual: Node2D


func _ready() -> void:
	if sway_visual == null:
		return
	var tween := create_tween().set_loops()
	tween.tween_property(sway_visual, "rotation", deg_to_rad(0.45), 2.4).from(deg_to_rad(-0.35)).set_trans(Tween.TRANS_SINE)
	tween.tween_property(sway_visual, "rotation", deg_to_rad(-0.35), 2.8).set_trans(Tween.TRANS_SINE)
