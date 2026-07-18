extends SceneTree

const Catalog = preload("res://data/items/opaw_weapon_catalog.tres")
const AshwoodBlade = preload("res://data/weapons/ashwood_blade.tres")
const IronSword = preload("res://data/weapons/iron_sword.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not Catalog.has_valid_layout() or Catalog.weapons.size() != 2:
		_fail("Opaw's catalog must expose the two approved early-game swords.")
		return
	var item: EquipmentDefinition = Catalog.default_weapon
	if item.rarity != EquipmentDefinition.Rarity.WOOD:
		_fail("Opaw's first equipment item must remain in the Wood tier.")
		return
	if item.item_id != &"weapon_ashwood_blade" or item.item_id != AshwoodBlade.weapon_id:
		_fail("The equipment preview and runtime weapon do not share the Ashwood Blade identity.")
		return
	if item.synergy_description.is_empty():
		_fail("Ashwood Blade presentation is missing its authored skill relationship.")
		return
	if item.icon.get_size() != Vector2(64, 64):
		_fail("Ashwood Blade inventory icon is not 64x64.")
		return
	if AshwoodBlade.world_texture == null or AshwoodBlade.world_texture.get_size() != Vector2(16, 24):
		_fail("Ashwood Blade runtime world art is not 16x24.")
		return
	if AshwoodBlade.attack_style == null or not AshwoodBlade.attack_style.is_valid_style():
		_fail("Ashwood Blade is missing its reusable sword attack style.")
		return
	if AshwoodBlade.attack_style.style_id != &"balanced_slash":
		_fail("Ashwood Blade no longer uses the approved Balanced Slash profile.")
		return
	if not _validate_binary_icon(item.icon):
		return
	if item.weapon_definition != AshwoodBlade or item.purchase_price != 0:
		_fail("The Ashwood Blade must remain Opaw's free permanent fallback.")
		return
	if not is_equal_approx(AshwoodBlade.damage, 25.0):
		_fail("The presentation migration unexpectedly changed authoritative sword tuning.")
		return
	var iron_item := Catalog.find_weapon(&"weapon_iron_sword")
	if (
		iron_item == null
		or iron_item.weapon_definition != IronSword
		or iron_item.purchase_price != 18
		or not iron_item.is_compatible_with(&"warrior")
		or iron_item.is_compatible_with(&"mage")
	):
		_fail("Iron Sword catalog ownership, price, or Warrior restriction is invalid.")
		return
	if IronSword.world_texture.get_size() != Vector2(16, 24) or iron_item.icon.get_size() != Vector2(64, 64):
		_fail("Iron Sword runtime assets do not match the approved icon/world sizes.")
		return
	if IronSword.attack_style != AshwoodBlade.attack_style or not is_equal_approx(IronSword.damage, 32.0):
		_fail("Iron Sword must reuse Balanced Slash while providing its authored damage upgrade.")
		return
	print("Equipment catalog smoke test passed.")
	quit(0)


func _validate_binary_icon(texture: Texture2D) -> bool:
	var image := texture.get_image()
	if image.get_pixel(0, 0).a > 0.001 or image.get_pixel(63, 63).a > 0.001:
		_fail("Ashwood Blade icon corners are not transparent.")
		return false
	var colors: Dictionary = {}
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a > 0.001 and color.a < 0.999:
				_fail("Ashwood Blade icon contains soft alpha.")
				return false
			if color.a > 0.999:
				colors[color.to_rgba32()] = true
	if colors.size() > 8:
		_fail("Ashwood Blade icon exceeds its eight-color runtime palette.")
		return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
