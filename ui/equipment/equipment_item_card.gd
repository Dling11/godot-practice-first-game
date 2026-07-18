class_name EquipmentItemCard
extends Button

## Reusable focusable owned-inventory card.

signal item_selected(definition: EquipmentDefinition)

@onready var item_icon: TextureRect = %ItemIcon
@onready var rarity_label: Label = %RarityLabel
@onready var name_label: Label = %NameLabel
@onready var status_label: Label = %StatusLabel

var definition: EquipmentDefinition
var is_equipped := false
var is_class_compatible := true
var _aura_tween: Tween


func _ready() -> void:
	pressed.connect(_on_pressed)


func configure(item: EquipmentDefinition, equipped: bool, class_compatible: bool = true) -> void:
	definition = item
	is_equipped = equipped
	is_class_compatible = class_compatible
	name = item.item_id
	item_icon.texture = item.icon
	rarity_label.text = item.get_rarity_name()
	rarity_label.add_theme_color_override("font_color", item.get_rarity_color())
	name_label.text = item.display_name.to_upper()
	status_label.text = (
		"EQUIPPED"
		if equipped
		else ("CLICK TO EQUIP" if class_compatible else "CLASS LOCKED")
	)
	status_label.add_theme_color_override(
		"font_color",
		Color("d6c171") if equipped else (Color("9ab85d") if class_compatible else Color("c45b50"))
	)
	tooltip_text = "%s — %s — %s" % [
		item.display_name,
		item.get_rarity_name(),
		item.get_class_requirement_text(),
	]
	_apply_rarity_style(item.get_rarity_color(), equipped)
	_start_restrained_aura()


func _apply_rarity_style(color: Color, equipped: bool) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color("0c1018")
	normal.border_color = color.darkened(0.42)
	normal.set_border_width_all(1)
	normal.set_corner_radius_all(2)
	var hover := normal.duplicate() as StyleBoxFlat
	hover.bg_color = color.darkened(0.78)
	hover.border_color = color
	var pressed_style := normal.duplicate() as StyleBoxFlat
	pressed_style.bg_color = color.darkened(0.68)
	pressed_style.border_color = Color("d6c171") if equipped else color.lightened(0.16)
	pressed_style.set_border_width_all(2)
	add_theme_stylebox_override("normal", normal)
	add_theme_stylebox_override("hover", hover)
	add_theme_stylebox_override("pressed", pressed_style)


func _start_restrained_aura() -> void:
	if _aura_tween != null:
		_aura_tween.kill()
	if definition == null or definition.rarity < EquipmentDefinition.Rarity.LEGENDARY:
		item_icon.modulate = Color.WHITE
		return
	var base_color := definition.get_rarity_color()
	item_icon.modulate = base_color.lightened(0.32)
	_aura_tween = create_tween().set_loops()
	_aura_tween.tween_property(item_icon, "modulate", Color.WHITE, 0.9).set_trans(Tween.TRANS_SINE)
	_aura_tween.tween_property(item_icon, "modulate", base_color.lightened(0.32), 1.1).set_trans(Tween.TRANS_SINE)


func _on_pressed() -> void:
	if definition != null:
		item_selected.emit(definition)
