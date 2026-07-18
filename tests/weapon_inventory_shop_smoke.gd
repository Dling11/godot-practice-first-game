extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const ShopScene = preload("res://ui/shops/weapon_shop_menu.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")
const IronItem: EquipmentDefinition = preload("res://data/items/equipment/iron_sword.tres")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var inventory := root.get_node("WeaponInventory")
	root.get_node("RunSession").reset_run()
	inventory.reset_inventory()

	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	await process_frame
	var ashwood := player.weapon_catalog.default_weapon
	if player.get_equipped_weapon_item() != ashwood or not inventory.owns_weapon(ashwood.item_id):
		_fail("Opaw did not begin with the permanent Ashwood fallback equipped and owned.")
		return
	if inventory.owns_weapon(IronItem.item_id):
		_fail("Iron Sword should not be owned before purchase.")
		return

	player.progression_component.grant_rewards(0, 17)
	var shop := ShopScene.instantiate() as WeaponShopMenu
	shop.player = player
	root.add_child(shop)
	await process_frame
	shop.open_menu()
	if not shop.visible or not paused or shop.stock_buttons.size() != 1:
		_fail("Orren's shop did not open as a focused one-item paused purchase surface.")
		return
	if shop.purchase_selected() or inventory.owns_weapon(IronItem.item_id):
		_fail("Orren sold the Iron Sword without enough coins.")
		return
	player.progression_component.grant_rewards(0, 1)
	if not shop.purchase_selected():
		_fail("Orren did not sell the Iron Sword for its authored eighteen-coin price.")
		return
	if player.progression_component.coins != 0 or not inventory.owns_weapon(IronItem.item_id):
		_fail("Iron Sword purchase did not deduct coins and store ownership atomically.")
		return
	if player.get_equipped_weapon_item() != ashwood:
		_fail("Purchasing Iron Sword equipped it automatically instead of respecting inventory choice.")
		return
	shop.close_menu()

	var character_menu := CharacterMenuScene.instantiate() as CharacterMenu
	character_menu.player = player
	root.add_child(character_menu)
	await process_frame
	if character_menu._equipment_cards.size() != 2:
		_fail("Character inventory did not reveal both owned swords after purchase.")
		return
	var iron_card: EquipmentItemCard
	for card: EquipmentItemCard in character_menu._equipment_cards:
		if card.definition == IronItem:
			iron_card = card
			break
	if iron_card == null:
		_fail("Character inventory is missing the purchased Iron Sword card.")
		return
	iron_card.pressed.emit()
	if (
		player.get_equipped_weapon_item() != IronItem
		or player.attack_component.weapon != IronItem.weapon_definition
		or player.weapon_visual.weapon != IronItem.weapon_definition
	):
		_fail("Clicking Iron Sword did not switch both gameplay and detached weapon presentation.")
		return
	var replacement := PlayerScene.instantiate() as Player
	root.add_child(replacement)
	replacement.set_physics_process(false)
	await process_frame
	if replacement.get_equipped_weapon_item() != IronItem:
		_fail("Equipped weapon choice did not survive a scene-style Player replacement.")
		return

	var mage_item := IronItem.duplicate(true) as EquipmentDefinition
	mage_item.item_id = &"weapon_test_mage_focus"
	mage_item.compatible_classes = PackedStringArray(["mage"])
	mage_item.weapon_definition = IronItem.weapon_definition.duplicate(true) as WeaponDefinition
	mage_item.weapon_definition.weapon_id = mage_item.item_id
	if not inventory.acquire_weapon(mage_item):
		_fail("Shared inventory could not store a valid weapon belonging to another class.")
		return
	if inventory.equip_weapon(&"opaw", &"warrior", mage_item):
		_fail("Warrior Opaw equipped a Mage-only weapon.")
		return

	inventory.reset_inventory()
	if not inventory.owns_weapon(ashwood.item_id) or inventory.owns_weapon(IronItem.item_id):
		_fail("A new journey did not restore Ashwood-only ownership.")
		return
	print("Weapon inventory and shop smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	paused = false
	push_error(message)
	quit(1)
