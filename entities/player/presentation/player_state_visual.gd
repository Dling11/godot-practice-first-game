extends Node

@export var body_visual: AnimatedSprite2D


func flash_damaged(_info: DamageInfo) -> void:
	_flash(Color(2.0, 0.55, 0.55, 1.0), 0.14)


func flash_blocked(_info: DamageInfo) -> void:
	_flash(Color(0.65, 1.25, 2.0, 1.0), 0.12)


func play_defeat() -> void:
	if body_visual == null:
		return
	var tween := create_tween()
	tween.set_parallel(true)
	tween.tween_property(body_visual, "modulate", Color(0.28, 0.25, 0.35, 0.7), 0.35)


func _flash(color: Color, duration_seconds: float) -> void:
	if body_visual == null:
		return
	var tween := create_tween()
	body_visual.modulate = color
	tween.tween_property(body_visual, "modulate", Color.WHITE, duration_seconds)
