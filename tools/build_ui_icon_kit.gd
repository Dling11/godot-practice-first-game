extends SceneTree

const TRANSPARENT := Color(0, 0, 0, 0)
const VOID_INK := Color("090b10")
const BONE_TEXT := Color("d9ddce")
const MUTED_MOSS := Color("74806b")
const DIVINE_VIOLET := Color("765aa3")
const RELIC_GOLD := Color("d6c171")
const SPIRIT_BLUE := Color("66a4d8")
const DANGER_RED := Color("d65c50")

const ICONS := {
	"res://assets/ui/icons/actions/icon_action_primary_attack_24x24.png": [24, "sword"],
	"res://assets/ui/icons/actions/icon_action_dash_24x24.png": [24, "dash"],
	"res://assets/ui/icons/skills/icon_skill_sweeping_cut_24x24.png": [24, "sweep"],
	"res://assets/ui/icons/skills/icon_skill_piercing_rush_24x24.png": [24, "piercing_rush"],
	"res://assets/ui/icons/economy/icon_currency_coin_16x16.png": [16, "coin"],
	"res://assets/ui/icons/status/icon_status_health_16x16.png": [16, "health"],
	"res://assets/ui/icons/status/icon_status_experience_16x16.png": [16, "experience"],
	"res://assets/ui/icons/interactions/icon_interaction_portal_16x16.png": [16, "portal"],
	"res://assets/ui/icons/interactions/icon_interaction_talk_16x16.png": [16, "talk"],
	"res://assets/ui/icons/states/icon_slot_locked_16x16.png": [16, "locked"],
	"res://assets/ui/icons/inventory/icon_inventory_bag_24x24.png": [24, "bag"],
}


func _initialize() -> void:
	for path: String in ICONS:
		var specification: Array = ICONS[path]
		var size: int = specification[0]
		var image := Image.create_empty(size, size, false, Image.FORMAT_RGBA8)
		image.fill(TRANSPARENT)
		_draw_icon(image, specification[1])
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(path.get_base_dir()))
		var error := image.save_png(path)
		if error != OK:
			push_error("Could not save UI icon %s (error %d)." % [path, error])
			quit(1)
			return
	print("Built %d named UI icons." % ICONS.size())
	quit(0)


func _draw_icon(image: Image, icon_name: String) -> void:
	match icon_name:
		"sword": _draw_sword(image)
		"dash": _draw_dash(image)
		"sweep": _draw_sweep(image)
		"piercing_rush": _draw_piercing_rush(image)
		"coin": _draw_coin(image)
		"health": _draw_health(image)
		"experience": _draw_experience(image)
		"portal": _draw_portal(image)
		"talk": _draw_talk(image)
		"locked": _draw_locked(image)
		"bag": _draw_bag(image)


func _draw_sword(image: Image) -> void:
	_draw_line(image, Vector2i(6, 18), Vector2i(17, 7), BONE_TEXT, 2)
	_fill_rect(image, Rect2i(16, 5, 3, 4), BONE_TEXT)
	_draw_line(image, Vector2i(5, 15), Vector2i(9, 19), RELIC_GOLD, 2)
	_fill_rect(image, Rect2i(3, 19, 4, 3), MUTED_MOSS)


func _draw_dash(image: Image) -> void:
	for offset in [0, 5, 10]:
		_draw_line(image, Vector2i(4 + offset, 7), Vector2i(9 + offset, 12), SPIRIT_BLUE, 2)
		_draw_line(image, Vector2i(9 + offset, 12), Vector2i(4 + offset, 17), SPIRIT_BLUE, 2)
	_fill_rect(image, Rect2i(2, 10, 10, 4), DIVINE_VIOLET)


func _draw_sweep(image: Image) -> void:
	for point in [Vector2i(3, 15), Vector2i(4, 11), Vector2i(7, 7), Vector2i(11, 5), Vector2i(16, 5), Vector2i(20, 8)]:
		_fill_rect(image, Rect2i(point, Vector2i(2, 2)), RELIC_GOLD)
	_draw_line(image, Vector2i(8, 19), Vector2i(17, 10), BONE_TEXT, 2)
	_fill_rect(image, Rect2i(6, 18, 4, 3), MUTED_MOSS)


func _draw_piercing_rush(image: Image) -> void:
	# Narrow white spirit blade with gold rim and blue-gold speed fragments.
	_draw_line(image, Vector2i(4, 12), Vector2i(19, 12), RELIC_GOLD, 4)
	_draw_line(image, Vector2i(5, 12), Vector2i(20, 12), BONE_TEXT, 2)
	_fill_rect(image, Rect2i(19, 10, 3, 5), BONE_TEXT)
	_fill_rect(image, Rect2i(2, 10, 4, 5), MUTED_MOSS)
	_draw_line(image, Vector2i(3, 6), Vector2i(11, 8), SPIRIT_BLUE, 1)
	_draw_line(image, Vector2i(3, 18), Vector2i(11, 16), SPIRIT_BLUE, 1)
	_fill_rect(image, Rect2i(14, 6, 2, 2), RELIC_GOLD)
	_fill_rect(image, Rect2i(15, 17, 2, 2), RELIC_GOLD)


func _draw_coin(image: Image) -> void:
	_fill_rect(image, Rect2i(5, 2, 6, 1), RELIC_GOLD)
	_fill_rect(image, Rect2i(3, 4, 10, 8), RELIC_GOLD)
	_fill_rect(image, Rect2i(5, 13, 6, 1), RELIC_GOLD)
	_fill_rect(image, Rect2i(5, 5, 6, 6), Color("9c7f35"))
	_fill_rect(image, Rect2i(7, 6, 2, 4), Color("f1dc82"))


func _draw_health(image: Image) -> void:
	_fill_rect(image, Rect2i(3, 4, 4, 5), DANGER_RED)
	_fill_rect(image, Rect2i(9, 4, 4, 5), DANGER_RED)
	_fill_rect(image, Rect2i(5, 3, 6, 8), DANGER_RED)
	_fill_rect(image, Rect2i(6, 11, 4, 2), DANGER_RED)
	_set_safe(image, 5, 5, Color("ef8a78"))


func _draw_experience(image: Image) -> void:
	_fill_rect(image, Rect2i(7, 1, 2, 14), SPIRIT_BLUE)
	_fill_rect(image, Rect2i(3, 5, 10, 6), SPIRIT_BLUE)
	_fill_rect(image, Rect2i(5, 3, 6, 10), SPIRIT_BLUE)
	_fill_rect(image, Rect2i(7, 5, 2, 6), Color("b7e3f6"))


func _draw_portal(image: Image) -> void:
	for point in [Vector2i(6, 1), Vector2i(8, 1), Vector2i(3, 3), Vector2i(11, 3), Vector2i(2, 6), Vector2i(12, 6), Vector2i(2, 8), Vector2i(12, 8), Vector2i(3, 11), Vector2i(11, 11), Vector2i(6, 13), Vector2i(8, 13)]:
		_fill_rect(image, Rect2i(point, Vector2i(2, 2)), DIVINE_VIOLET)
	_fill_rect(image, Rect2i(6, 5, 4, 6), Color("b99bea"))
	_fill_rect(image, Rect2i(7, 6, 2, 4), VOID_INK)


func _draw_talk(image: Image) -> void:
	_fill_rect(image, Rect2i(2, 3, 12, 8), BONE_TEXT)
	_fill_rect(image, Rect2i(4, 11, 4, 3), BONE_TEXT)
	_fill_rect(image, Rect2i(4, 5, 2, 2), VOID_INK)
	_fill_rect(image, Rect2i(7, 5, 2, 2), VOID_INK)
	_fill_rect(image, Rect2i(10, 5, 2, 2), VOID_INK)


func _draw_locked(image: Image) -> void:
	_fill_rect(image, Rect2i(4, 7, 8, 7), MUTED_MOSS)
	_fill_rect(image, Rect2i(5, 3, 2, 5), MUTED_MOSS)
	_fill_rect(image, Rect2i(9, 3, 2, 5), MUTED_MOSS)
	_fill_rect(image, Rect2i(7, 2, 2, 2), MUTED_MOSS)
	_fill_rect(image, Rect2i(7, 9, 2, 3), VOID_INK)


func _draw_bag(image: Image) -> void:
	# A compact travel satchel: pale handle, violet body, and gold clasp.
	_fill_rect(image, Rect2i(8, 4, 8, 2), BONE_TEXT)
	_fill_rect(image, Rect2i(6, 6, 3, 5), BONE_TEXT)
	_fill_rect(image, Rect2i(15, 6, 3, 5), BONE_TEXT)
	_fill_rect(image, Rect2i(4, 9, 16, 11), DIVINE_VIOLET)
	_fill_rect(image, Rect2i(6, 11, 12, 7), Color("38284f"))
	_fill_rect(image, Rect2i(10, 10, 4, 5), RELIC_GOLD)
	_fill_rect(image, Rect2i(11, 11, 2, 2), Color("f2df8c"))
	_fill_rect(image, Rect2i(4, 18, 16, 2), MUTED_MOSS)


func _draw_line(image: Image, from: Vector2i, to: Vector2i, color: Color, width := 1) -> void:
	var x := from.x
	var y := from.y
	var dx := absi(to.x - from.x)
	var sx := 1 if from.x < to.x else -1
	var dy := -absi(to.y - from.y)
	var sy := 1 if from.y < to.y else -1
	var error := dx + dy
	while true:
		_fill_rect(image, Rect2i(x, y, width, width), color)
		if x == to.x and y == to.y:
			break
		var doubled_error := error * 2
		if doubled_error >= dy:
			error += dy
			x += sx
		if doubled_error <= dx:
			error += dx
			y += sy


func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(rect.position.y, rect.end.y):
		for x in range(rect.position.x, rect.end.x):
			_set_safe(image, x, y, color)


func _set_safe(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < image.get_width() and y < image.get_height():
		image.set_pixel(x, y, color)
