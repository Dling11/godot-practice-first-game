extends SceneTree

## Native raster appearance comparison. Does not instantiate or equip a Player.
const ROOT := "res://art_source/generated/characters/king/equipment_design_v2_2026_10_04/"
const SOURCE_SCALE := 1.0 / 16.0
const BODY_SCALE := 0.5

func _initialize() -> void:
	root.size = Vector2i(960, 540)
	root.content_scale_size = Vector2i(960, 540)
	root.content_scale_mode = Window.CONTENT_SCALE_MODE_CANVAS_ITEMS
	call_deferred("_show_comparison")

func _show_comparison() -> void:
	var ui := Control.new()
	ui.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(ui)
	ui.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var background := ColorRect.new()
	background.color = Color("161d22")
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	ui.add_child(background)
	_label(ui, "Compact armor — current King and three proposed outfits", Vector2(24, 20), 20)
	_label(ui, "Appearance comparison only. Original holds his sword; proposed outfits are unarmed.", Vector2(24, 50), 14)
	_label(ui, "1x gameplay scale", Vector2(24, 88), 14)
	_label(ui, "4x nearest enlargement of the same scale", Vector2(24, 275), 14)
	var armor := Image.load_from_file(ROOT + "armor/source.png")
	var texture := ImageTexture.create_from_image(armor)
	var old_image := Image.load_from_file("res://assets/characters/playable/king/spellward/idle.png")
	var old_frame := old_image.get_region(Rect2i(0, 0, 192, 128))
	var old_texture := ImageTexture.create_from_image(old_frame)
	var old_bounds := old_frame.get_used_rect()
	var old_floor := Vector2(old_bounds.get_center().x, old_bounds.end.y)
	var names := ["Current King", "Light Leather", "Heartwood", "Forged Guard"]
	for index in 4:
		var x := 120.0 + index * 240.0
		_label(ui, names[index], Vector2(x - 65, 120), 16)
		for multiplier in [1.0, 4.0]:
			var sprite := Sprite2D.new()
			sprite.centered = false
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.position = Vector2(x, 207 if multiplier == 1.0 else 456)
			if index == 0:
				sprite.texture = old_texture
				sprite.offset = -old_floor
				sprite.scale = Vector2.ONE * BODY_SCALE * multiplier
			else:
				var atlas := AtlasTexture.new()
				atlas.atlas = texture
				atlas.region = Rect2(224 + (index - 1) * 384, 40, 320, 480)
				atlas.filter_clip = true
				sprite.texture = atlas
				# Authored front-row foot centers from the unchanged study. One
				# uniform source scale; no per-outfit resize or alpha alteration.
				sprite.offset = -Vector2(160, 460)
				sprite.scale = Vector2.ONE * SOURCE_SCALE * multiplier
			ui.add_child(sprite)
	_label(ui, "Candidate styling; no equipment layers, attack frames or unlock changes are installed.", Vector2(24, 505), 14)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	var capture := root.get_texture().get_image()
	var result := capture.save_png(ROOT + "armor/native_readability.png")
	print("ARMOR_READABILITY capture=", result, " size=", capture.get_size(), " uniform_source_scale=", SOURCE_SCALE, " current_body_scale=", BODY_SCALE)
	quit(0 if result == OK else 1)

func _label(parent: Control, value: String, location: Vector2, font_size: int) -> void:
	var label := Label.new()
	label.text = value
	label.position = location
	label.add_theme_font_size_override("font_size", font_size)
	parent.add_child(label)
