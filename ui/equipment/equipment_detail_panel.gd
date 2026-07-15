class_name EquipmentDetailPanel
extends PanelContainer

## Read-only detailed item preview with rarity-driven, tweened presentation.

@onready var aura_back: Panel = %AuraBack
@onready var item_icon: TextureRect = %ItemIcon
@onready var rarity_label: Label = %RarityLabel
@onready var name_label: Label = %NameLabel
@onready var power_label: Label = %PowerLabel
@onready var lore_label: Label = %LoreLabel
@onready var synergy_title: Label = %SynergyTitle
@onready var synergy_body: Label = %SynergyBody
@onready var state_label: Label = %StateLabel

var current_definition: EquipmentDefinition
var _aura_tween: Tween


func configure(item: EquipmentDefinition, equipped: bool) -> void:
	current_definition = item
	var rarity_color := item.get_rarity_color()
	item_icon.texture = item.icon
	rarity_label.text = "%s  •  %s" % [item.get_rarity_name(), item.get_slot_name().to_upper()]
	rarity_label.add_theme_color_override("font_color", rarity_color)
	name_label.text = item.display_name.to_upper()
	power_label.text = "PREVIEW POWER  %d" % item.preview_power
	lore_label.text = item.lore
	synergy_title.text = item.synergy_name.to_upper()
	synergy_title.add_theme_color_override("font_color", rarity_color)
	synergy_body.text = item.synergy_description
	state_label.text = (
		"EQUIPPED • ACTIVE ASHWOOD TUNING"
		if equipped
		else "DESIGN PREVIEW • EFFECT NOT ACTIVE"
	)
	state_label.add_theme_color_override(
		"font_color",
		Color("d6c171") if equipped else Color("74806b")
	)
	_apply_aura_style(rarity_color)
	_start_aura(item.rarity)


func _apply_aura_style(color: Color) -> void:
	var aura_style := StyleBoxFlat.new()
	aura_style.bg_color = color.darkened(0.82)
	aura_style.border_color = color
	aura_style.set_border_width_all(2)
	aura_style.set_corner_radius_all(5)
	aura_back.add_theme_stylebox_override("panel", aura_style)


func _start_aura(rarity: EquipmentDefinition.Rarity) -> void:
	if _aura_tween != null:
		_aura_tween.kill()
	aura_back.scale = Vector2.ONE
	var is_high_rarity := rarity in [
		EquipmentDefinition.Rarity.LEGENDARY,
		EquipmentDefinition.Rarity.MYTHIC,
	]
	aura_back.modulate.a = 0.9 if is_high_rarity else 0.58
	var scale_amount := 1.075 if is_high_rarity else 1.035
	_aura_tween = create_tween().set_loops()
	_aura_tween.tween_property(aura_back, "scale", Vector2.ONE * scale_amount, 0.8).set_trans(Tween.TRANS_SINE)
	_aura_tween.parallel().tween_property(aura_back, "modulate:a", 0.25, 0.8).set_trans(Tween.TRANS_SINE)
	_aura_tween.tween_property(aura_back, "scale", Vector2.ONE, 1.0).set_trans(Tween.TRANS_SINE)
	_aura_tween.parallel().tween_property(aura_back, "modulate:a", 0.9, 1.0).set_trans(Tween.TRANS_SINE)
