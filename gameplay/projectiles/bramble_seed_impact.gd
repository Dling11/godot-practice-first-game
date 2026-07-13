extends Node2D


func _ready() -> void:
	scale = Vector2(0.45, 0.45)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.65, 1.65), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	tween.chain().tween_callback(queue_free)
