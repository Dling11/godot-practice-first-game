class_name DashBarSlot
extends PanelContainer

## Compact HUD control for the core dash action and its cooldown.

signal activation_requested

@onready var state_label: Label = %StateLabel
@onready var cooldown_bar: ProgressBar = %CooldownBar
@onready var cooldown_tick: Timer = %CooldownTick
@onready var activation_button: Button = %ActivationButton

var evade_component: EvadeComponent
var _cooldown_tween: Tween


func bind_evade(component: EvadeComponent) -> void:
	evade_component = component
	if component == null:
		activation_button.disabled = true
		state_label.text = "UNAVAILABLE"
		return
	component.cooldown_started.connect(_show_cooldown)
	component.cooldown_finished.connect(_show_ready)
	if component.get_cooldown_remaining() > 0.0:
		_show_cooldown(component.get_cooldown_remaining())
	else:
		_show_ready()


func _show_cooldown(duration_seconds: float) -> void:
	if _cooldown_tween != null and _cooldown_tween.is_valid():
		_cooldown_tween.kill()
	modulate = Color(0.58, 0.58, 0.58, 1.0)
	activation_button.disabled = true
	state_label.text = "%.1f" % duration_seconds
	state_label.add_theme_color_override("font_color", Color(0.94, 0.72, 0.38, 1))
	cooldown_bar.max_value = duration_seconds
	cooldown_bar.value = duration_seconds
	cooldown_tick.start()
	_cooldown_tween = create_tween()
	_cooldown_tween.tween_property(cooldown_bar, "value", 0.0, duration_seconds)


func _show_ready() -> void:
	if _cooldown_tween != null and _cooldown_tween.is_valid():
		_cooldown_tween.kill()
	cooldown_bar.value = 0.0
	modulate = Color.WHITE
	activation_button.disabled = false
	state_label.text = "READY"
	state_label.add_theme_color_override("font_color", Color(0.62, 0.9, 0.54, 1))
	cooldown_tick.stop()


func _on_cooldown_tick() -> void:
	if not is_instance_valid(evade_component):
		cooldown_tick.stop()
		return
	state_label.text = "%.1f" % evade_component.get_cooldown_remaining()


func _on_activation_button_pressed() -> void:
	if is_instance_valid(evade_component):
		activation_requested.emit()
