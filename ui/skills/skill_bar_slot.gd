class_name SkillBarSlot
extends PanelContainer

## Compact reusable HUD observer for one configured skill slot.

signal activation_requested(slot_number: int)

@export var slot_definition: SkillSlotDefinition

@onready var ability_icon: TextureRect = %AbilityIcon
@onready var key_label: Label = %KeyLabel
@onready var state_label: Label = %StateLabel
@onready var ability_name: Label = %AbilityName
@onready var cooldown_bar: ProgressBar = %CooldownBar
@onready var cooldown_tick: Timer = %CooldownTick
@onready var activation_button: Button = %ActivationButton

var ability_component: AbilityComponent
var _cooldown_tween: Tween


func _ready() -> void:
	if slot_definition != null:
		configure(slot_definition)


func configure(definition: SkillSlotDefinition) -> void:
	slot_definition = definition
	name = "Skill%d" % definition.slot_number
	key_label.text = str(definition.slot_number)
	ability_icon.texture = definition.get_icon()
	tooltip_text = "%s — %s" % [definition.get_display_name(), definition.get_status_text()]
	activation_button.tooltip_text = tooltip_text
	if definition.is_equipped():
		ability_name.text = definition.ability.hud_name
		modulate = Color.WHITE
		activation_button.disabled = ability_component == null
		_show_ready()
	else:
		ability_name.text = "SEALED"
		state_label.text = "LOCKED"
		state_label.add_theme_color_override("font_color", Color(0.62, 0.58, 0.66, 1))
		cooldown_bar.value = 0.0
		modulate = Color(0.48, 0.48, 0.52, 0.82)
		activation_button.disabled = true


func bind_ability(component: AbilityComponent) -> void:
	ability_component = component
	if component == null:
		activation_button.disabled = true
		if slot_definition != null and slot_definition.is_equipped():
			state_label.text = "UNAVAILABLE"
			state_label.add_theme_color_override("font_color", Color(0.92, 0.4, 0.4, 1))
			modulate = Color(0.68, 0.52, 0.52, 1)
		return
	component.cooldown_started.connect(_show_cooldown)
	component.cooldown_finished.connect(_show_ready)
	if component.is_ready():
		_show_ready()
	else:
		_show_cooldown(component.cooldown_remaining)


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
	if slot_definition == null or not slot_definition.is_equipped():
		return
	if _cooldown_tween != null and _cooldown_tween.is_valid():
		_cooldown_tween.kill()
	cooldown_bar.value = 0.0
	modulate = Color.WHITE
	activation_button.disabled = false
	state_label.text = "READY"
	state_label.add_theme_color_override("font_color", Color(0.62, 0.9, 0.54, 1))
	cooldown_tick.stop()


func _on_cooldown_tick() -> void:
	if not is_instance_valid(ability_component):
		cooldown_tick.stop()
		return
	state_label.text = "%.1f" % ability_component.cooldown_remaining


func _on_activation_button_pressed() -> void:
	if (
		slot_definition == null
		or not slot_definition.is_equipped()
		or not is_instance_valid(ability_component)
	):
		return
	activation_requested.emit(slot_definition.slot_number)
