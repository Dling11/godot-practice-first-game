class_name EquipmentSlotCard
extends PanelContainer

## Small reusable loadout slot. Empty slots are honest presentation, not items.

@onready var slot_icon: TextureRect = %SlotIcon
@onready var slot_label: Label = %SlotLabel
@onready var item_label: Label = %ItemLabel


func configure(slot_name: String, item: EquipmentDefinition = null, empty_icon: Texture2D = null) -> void:
	slot_label.text = slot_name.to_upper()
	if item != null:
		slot_icon.texture = item.icon
		item_label.text = item.display_name.to_upper()
		item_label.add_theme_color_override("font_color", item.get_rarity_color())
		tooltip_text = "%s — %s" % [item.display_name, item.get_rarity_name()]
	else:
		slot_icon.texture = empty_icon
		item_label.text = "EMPTY"
		item_label.add_theme_color_override("font_color", Color("74806b"))
		tooltip_text = "%s slot — no item equipped" % slot_name.capitalize()
