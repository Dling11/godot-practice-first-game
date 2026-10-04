extends SceneTree

## Native scale comparison of standalone concepts, never equipped Player art.
const ROOT := "res://art_source/generated/characters/king/equipment_design_v2_2026_10_04/"
const SCALE := 1.0 / 16.0

func _initialize() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	call_deferred("_render")

func _render() -> void:
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(ui)
	ui.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var background := ColorRect.new()
	background.color = Color("161d22")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(background)
	_label(ui, "Weapon designs — size beside current King", Vector2(24, 20), 20)
	_label(ui, "All weapons use one 1/16 source scale. Lower row is a 4x enlargement of the same crop.", Vector2(24, 50), 14)
	_label(ui, "1x gameplay scale", Vector2(24, 84), 14)
	_label(ui, "4x nearest enlargement", Vector2(24, 263), 14)
	var old_image := Image.load_from_file("res://assets/characters/playable/king/spellward/idle.png").get_region(Rect2i(0, 0, 192, 128))
	var old_bounds := old_image.get_used_rect()
	var old_floor := Vector2(old_bounds.get_center().x, old_bounds.end.y)
	_label(ui, "King", Vector2(55, 120), 14)
	for multiplier in [1.0, 4.0]:
		_sprite(ui, old_image, old_floor, Vector2(75, 217 if multiplier == 1.0 else 467), 0.5 * multiplier)
	var names := ["Iron Beard", "Split Crown", "Rootforged", "Iron Reaper", "Ash Hook", "Rootspine"]
	var measurements: Array[Dictionary] = []
	for family_index in 2:
		var family: String = ["axe", "scythe"][family_index]
		var source := Image.load_from_file(ROOT + family + "/source.png")
		var height := 704 if family == "axe" else 760
		for option in 3:
			var index := family_index * 3 + option
			var x := 220.0 + index * 122.0
			_label(ui, names[index], Vector2(x - 45, 120), 13)
			var crop := Rect2i(option * 512, 0, 512, height)
			var drawing := source.get_region(crop)
			var measured: Image = drawing.duplicate()
			measured.convert(Image.FORMAT_RGBA8)
			for y in measured.get_height():
				for px in measured.get_width():
					if measured.get_pixel(px, y).a < 0.65:
						measured.set_pixel(px, y, Color.TRANSPARENT)
			var bounds: Rect2i = measured.get_used_rect()
			var floor_point := Vector2(bounds.get_center().x, bounds.end.y)
			for multiplier in [1.0, 4.0]:
				_sprite(ui, drawing, floor_point, Vector2(x, 217 if multiplier == 1.0 else 467), SCALE * multiplier)
			measurements.append({"family": family, "option": names[index], "source_crop": [crop.position.x, crop.position.y, crop.size.x, crop.size.y], "occupied_bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "native_occupied_size": [bounds.size.x * SCALE, bounds.size.y * SCALE]})
	_label(ui, "Standalone choices only; grips, body contact and swing frames are not implemented.", Vector2(24, 505), 14)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var capture := root.get_texture().get_image()
	var result := capture.save_png(ROOT + "native_weapons.png")
	FileAccess.open(ROOT + "weapon_readability.json", FileAccess.WRITE).store_string(JSON.stringify({"uniform_source_scale": SCALE, "bounds_alpha_threshold": 0.65, "source_alpha_unchanged": true, "measurements": measurements}, "\t") + "\n")
	print("WEAPON_READABILITY capture=", result, " size=", capture.get_size(), " records=", measurements.size())
	quit(0 if result == OK else 1)

func _sprite(parent: Control, drawing: Image, floor_point: Vector2, location: Vector2, scale_value: float) -> void:
	var sprite := Sprite2D.new()
	sprite.texture = ImageTexture.create_from_image(drawing)
	sprite.centered = false
	sprite.offset = -floor_point
	sprite.position = location
	sprite.scale = Vector2.ONE * scale_value
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)

func _label(parent: Control, value: String, location: Vector2, font_size: int) -> void:
	var label := Label.new()
	label.text = value
	label.position = location
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
