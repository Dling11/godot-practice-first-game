extends SceneTree

const OUTPUT_PATH := "res://assets/ui/backgrounds/title/title_forest_sanctuary.png"
const WIDTH := 960
const HEIGHT := 540

const VOID_INK := Color("090b10")
const OBSIDIAN := Color("12151d")
const DEEP_MOSS := Color("365a3b")
const GROVE_GREEN := Color("5f8f47")
const MUTED_MOSS := Color("74806b")
const DIVINE_VIOLET := Color("765aa3")
const RELIC_GOLD := Color("d6c171")

var _random := RandomNumberGenerator.new()


func _initialize() -> void:
	_random.seed = 12292026
	var image := Image.create_empty(WIDTH, HEIGHT, false, Image.FORMAT_RGBA8)
	_draw_sky(image)
	_draw_distant_forest(image)
	_draw_grove_floor(image)
	_draw_sanctuary_path(image)
	_draw_distant_fountain(image)
	_draw_ground_detail(image)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_PATH.get_base_dir()))
	var error := image.save_png(OUTPUT_PATH)
	if error != OK:
		push_error("Could not save title background (error %d)." % error)
		quit(1)
		return
	print("Built replaceable 960x540 title background.")
	quit(0)


func _draw_sky(image: Image) -> void:
	var bands := [
		[0, 80, Color("111523")],
		[80, 150, Color("171d2b")],
		[150, 220, Color("1c2930")],
		[220, 294, Color("243631")],
	]
	for band: Array in bands:
		_fill_rect(image, Rect2i(0, band[0], WIDTH, band[1] - band[0]), band[2])
	# A restrained divine moon behind the grove, kept separate from title text.
	_fill_ellipse(image, Vector2i(480, 126), Vector2i(58, 58), Color("675782"))
	_fill_ellipse(image, Vector2i(486, 120), Vector2i(48, 48), Color("9b8ab2"))
	_fill_ellipse(image, Vector2i(496, 116), Vector2i(42, 42), Color("c1b7c8"))
	_fill_rect(image, Rect2i(438, 174, 84, 2), Color("493e5c"))


func _draw_distant_forest(image: Image) -> void:
	_fill_rect(image, Rect2i(0, 270, WIDTH, 64), Color("18271f"))
	for layer in range(3):
		var color: Color = [Color("1e3328"), Color("294633"), DEEP_MOSS][layer]
		var baseline := 308 + layer * 12
		var spacing := 34 - layer * 4
		for x in range(-20, WIDTH + 20, spacing):
			var height := _random.randi_range(30, 66) + layer * 6
			_draw_pine(image, Vector2i(x + _random.randi_range(-6, 6), baseline), height, color)


func _draw_grove_floor(image: Image) -> void:
	_fill_rect(image, Rect2i(0, 326, WIDTH, HEIGHT - 326), Color("294b35"))
	_fill_rect(image, Rect2i(0, 380, WIDTH, HEIGHT - 380), Color("315b3b"))
	_fill_rect(image, Rect2i(0, 462, WIDTH, HEIGHT - 462), Color("386440"))
	for y in range(326, HEIGHT):
		var edge_width := int((y - 326) * 0.48)
		_fill_rect(image, Rect2i(0, y, edge_width, 1), Color("203a2d"))
		_fill_rect(image, Rect2i(WIDTH - edge_width, y, edge_width, 1), Color("203a2d"))


func _draw_sanctuary_path(image: Image) -> void:
	for y in range(330, HEIGHT):
		var progress := float(y - 330) / float(HEIGHT - 330)
		var half_width := int(22 + progress * 154)
		var center := 480 + int(sin(progress * 5.2) * 12.0)
		var color := Color("59604a") if (y / 4) % 2 == 0 else Color("525a45")
		_fill_rect(image, Rect2i(center - half_width, y, half_width * 2, 1), color)
		if y % 18 == 0:
			_fill_rect(image, Rect2i(center - half_width + 8, y, half_width * 2 - 16, 2), Color("6a6b52"))


func _draw_distant_fountain(image: Image) -> void:
	# This is a title-screen landmark, not the future gameplay fountain asset.
	_fill_ellipse(image, Vector2i(480, 344), Vector2i(54, 15), Color("20251f"))
	_fill_ellipse(image, Vector2i(480, 337), Vector2i(46, 13), Color("777568"))
	_fill_ellipse(image, Vector2i(480, 334), Vector2i(39, 10), Color("343a3a"))
	_fill_ellipse(image, Vector2i(480, 332), Vector2i(34, 8), DIVINE_VIOLET)
	_fill_rect(image, Rect2i(475, 300, 10, 33), Color("68685f"))
	_fill_rect(image, Rect2i(471, 298, 18, 6), Color("858273"))
	_fill_rect(image, Rect2i(478, 306, 4, 25), Color("a79aaf"))
	_fill_rect(image, Rect2i(479, 286, 2, 14), Color("aa94c9"))
	_set_safe(image, 478, 284, RELIC_GOLD)
	_set_safe(image, 481, 284, RELIC_GOLD)


func _draw_ground_detail(image: Image) -> void:
	for index in range(320):
		var y := _random.randi_range(345, HEIGHT - 2)
		var x := _random.randi_range(8, WIDTH - 9)
		var path_half_width := int(22 + (float(y - 330) / 210.0) * 154.0)
		if absi(x - 480) < path_half_width + 12:
			continue
		var color := GROVE_GREEN if index % 4 else MUTED_MOSS
		_set_safe(image, x, y, color)
		if index % 5 == 0:
			_set_safe(image, x + 1, y - 1, color)


func _draw_pine(image: Image, foot: Vector2i, height: int, color: Color) -> void:
	_fill_rect(image, Rect2i(foot.x - 2, foot.y - height / 3, 4, height / 3), color.darkened(0.25))
	for y in range(height):
		var width := int((float(y) / height) * height * 0.34)
		if y < height / 4:
			width = maxi(width, 2)
		_fill_rect(image, Rect2i(foot.x - width, foot.y - height + y, width * 2 + 1, 1), color)


func _fill_ellipse(image: Image, center: Vector2i, radius: Vector2i, color: Color) -> void:
	for y in range(-radius.y, radius.y + 1):
		var normalized := float(y * y) / float(radius.y * radius.y)
		var x_extent := int(radius.x * sqrt(maxf(0.0, 1.0 - normalized)))
		_fill_rect(image, Rect2i(center.x - x_extent, center.y + y, x_extent * 2 + 1, 1), color)


func _fill_rect(image: Image, rect: Rect2i, color: Color) -> void:
	for y in range(maxi(rect.position.y, 0), mini(rect.end.y, HEIGHT)):
		for x in range(maxi(rect.position.x, 0), mini(rect.end.x, WIDTH)):
			image.set_pixel(x, y, color)


func _set_safe(image: Image, x: int, y: int, color: Color) -> void:
	if x >= 0 and y >= 0 and x < WIDTH and y < HEIGHT:
		image.set_pixel(x, y, color)
