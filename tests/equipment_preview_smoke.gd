extends SceneTree

const KingCatalog = preload("res://data/items/king_weapon_catalog.tres")
const KingSword = preload("res://data/weapons/king_signature_sword.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var expected_slots := PackedStringArray([
		"WEAPON", "HEAD", "PLATE", "GLOVES", "LEGGINGS", "BOOTS",
		"BRACER", "AMULET", "RING", "TALISMAN",
	])
	if PackedStringArray(EquipmentDefinition.Slot.keys()) != expected_slots:
		_fail("EquipmentDefinition lost the finalized one-weapon, five-armor, four-accessory slot contract.")
		return
	if (
		not KingCatalog.has_valid_layout()
		or KingCatalog.weapons.size() != 2
		or KingCatalog.default_weapon.weapon_definition != KingSword
		or KingSword.weapon_id != &"weapon_king_signature_sword"
		or not KingSword.uses_integrated_visual
		or KingSword.world_texture != null
		or KingSword.attack_style.style_id != &"king_sword_form"
		or not is_equal_approx(KingSword.basic_damage_minimum, 10.0)
		or not is_equal_approx(KingSword.basic_damage_maximum, 12.0)
	):
		_fail("King's signature sword identity, integrated presentation, or 10-12 normal damage is invalid.")
		return
	var varkuun_edge := KingCatalog.find_weapon(&"weapon_varkuun_edge_essence")
	if (
		varkuun_edge == null
		or not varkuun_edge.is_equippable_weapon()
		or not varkuun_edge.weapon_definition.uses_integrated_visual
		or not is_equal_approx(varkuun_edge.weapon_definition.damage, 28.0)
		or not is_equal_approx(varkuun_edge.weapon_definition.basic_damage_minimum, 11.0)
		or not is_equal_approx(varkuun_edge.weapon_definition.basic_damage_maximum, 13.0)
	):
		_fail("Varkuun Edge lost its testable integrated 11-13 / 28-power contract.")
		return
	print("King equipment catalog smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
