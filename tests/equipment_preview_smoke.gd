extends SceneTree

const Showcase = preload("res://data/items/alden_equipment_showcase.tres")
const AshwoodBlade = preload("res://data/weapons/ashwood_blade.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not Showcase.has_valid_layout() or Showcase.featured_items.size() != 1:
		_fail("Alden's starter showcase must expose only one valid authored item.")
		return
	var item: EquipmentDefinition = Showcase.featured_items[0]
	if item.rarity != EquipmentDefinition.Rarity.WOOD:
		_fail("Alden's first equipment item must remain in the Wood tier.")
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
	if not _validate_binary_icon(item.icon):
		return
	if Showcase.equipped_weapon != item:
		_fail("The Ashwood Blade must remain Alden's only equipped starter presentation.")
		return
	if not is_equal_approx(AshwoodBlade.damage, 25.0):
		_fail("The presentation migration unexpectedly changed authoritative sword tuning.")
		return
	print("Equipment preview smoke test passed.")
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
