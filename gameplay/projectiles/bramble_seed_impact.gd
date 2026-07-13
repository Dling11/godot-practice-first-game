extends Node2D

@onready var impact_sfx: AudioStreamPlayer2D = %ImpactSfx


func _ready() -> void:
	if DisplayServer.get_name() != "headless":
		impact_sfx.play()
	scale = Vector2(0.45, 0.45)
	var tween := create_tween().set_parallel(true)
	tween.tween_property(self, "scale", Vector2(1.65, 1.65), 0.2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.tween_property(self, "modulate:a", 0.0, 0.2)
	get_tree().create_timer(0.45).timeout.connect(queue_free)
