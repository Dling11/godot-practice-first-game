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
var _targeting_tween: Tween
var _targeting_active := false
var _accent_color := Color(0.45, 0.78, 0.94, 1.0)


const SLOT_ACCENTS := {
	1: Color(0.42, 0.79, 0.96, 1.0),
	2: Color(0.95, 0.69, 0.30, 1.0),
	3: Color(0.36, 0.66, 0.94, 1.0),
	4: Color(0.65, 0.58, 1.0, 1.0),
}


func _ready() -> void:
	if slot_definition != null:
		configure(slot_definition)
	queue_redraw()


func _draw() -> void:
	var accent := Color(1.0, 0.86, 0.52, 1.0) if _targeting_active else _accent_color
	var right := size.x - 2.0
	var bottom := size.y - 2.0
	draw_polyline(PackedVector2Array([
		Vector2(2.0, 8.0), Vector2(2.0, 2.0), Vector2(8.0, 2.0)
	]), accent, 1.0, false)
	draw_polyline(PackedVector2Array([
		Vector2(right - 6.0, bottom), Vector2(right, bottom), Vector2(right, bottom - 6.0)
	]), accent, 1.0, false)


func configure(definition: SkillSlotDefinition) -> void:
	slot_definition = definition
	name = "Skill%d" % definition.slot_number
	_accent_color = SLOT_ACCENTS.get(definition.slot_number, SLOT_ACCENTS[1])
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
	queue_redraw()


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
	# Cooldown remains an actionable rejected state so keyboard, controller,
	# mouse, and future touch input all reach the shared denied-action feedback.
	activation_button.disabled = false
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


func show_targeting() -> void:
	if slot_definition == null or not slot_definition.is_equipped():
		return
	_targeting_active = true
	state_label.text = "AIM  RMB"
	state_label.add_theme_color_override("font_color", Color(1.0, 0.86, 0.5, 1.0))
	if _targeting_tween != null and _targeting_tween.is_valid():
		_targeting_tween.kill()
	ability_icon.modulate = Color.WHITE
	_targeting_tween = create_tween().set_loops()
	_targeting_tween.tween_property(
		ability_icon, "modulate", Color(0.65, 0.9, 1.0, 0.72), 0.22
	)
	_targeting_tween.tween_property(ability_icon, "modulate", Color.WHITE, 0.22)
	queue_redraw()


func clear_targeting_presentation() -> void:
	if not _targeting_active:
		return
	_targeting_active = false
	if _targeting_tween != null and _targeting_tween.is_valid():
		_targeting_tween.kill()
	_targeting_tween = null
	ability_icon.modulate = Color.WHITE
	if is_instance_valid(ability_component) and ability_component.is_ready():
		_show_ready()
	elif is_instance_valid(ability_component):
		_show_cooldown(ability_component.cooldown_remaining)
	queue_redraw()


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
