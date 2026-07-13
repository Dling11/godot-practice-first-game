class_name SweepingCutVisual
extends Line2D

var _fade_tween: Tween


func play_phase(phase: AbilityComponent.Phase, duration_seconds: float) -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	show()
	match phase:
		AbilityComponent.Phase.WIND_UP:
			modulate = Color(0.72, 0.68, 0.54, 0.28)
			width = 1.0
		AbilityComponent.Phase.ACTIVE:
			modulate = Color(0.94, 0.88, 0.66, 0.9)
			width = 3.0
		AbilityComponent.Phase.RECOVERY:
			_fade_tween = create_tween()
			_fade_tween.tween_property(self, "modulate:a", 0.0, duration_seconds)
			_fade_tween.tween_callback(hide)


func hide_visual() -> void:
	if _fade_tween != null and _fade_tween.is_valid():
		_fade_tween.kill()
	hide()
