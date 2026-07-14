class_name SkillSlotCard
extends Button

## Reusable, focusable character-menu presentation for one skill slot.

signal slot_selected(definition: SkillSlotDefinition)

var slot_definition: SkillSlotDefinition


func _ready() -> void:
	pressed.connect(_on_pressed)


func configure(definition: SkillSlotDefinition) -> void:
	slot_definition = definition
	name = "Skill%d" % definition.slot_number
	icon = definition.get_icon()
	text = "[%d]  %s\n\n%s\n\n%s" % [
		definition.slot_number,
		definition.get_display_name().to_upper(),
		definition.get_description(),
		definition.get_status_text(),
	]
	tooltip_text = "%s — %s" % [definition.get_display_name(), definition.get_status_text()]
	modulate = Color.WHITE if definition.is_equipped() else Color(0.66, 0.66, 0.72, 0.9)


func _on_pressed() -> void:
	if slot_definition != null:
		slot_selected.emit(slot_definition)
