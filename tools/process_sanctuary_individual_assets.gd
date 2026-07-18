extends SceneTree

## Normalizes approved standalone Sanctuary landmarks, compact service NPCs,
## and service structures into exact hard-pixel runtime assets.

const CLEAR := Color(0, 0, 0, 0)
const VOID_INK := Color("090b10")

const ASSET_SPECS := {
	"portal": {
		"source": "res://art_source/generated/environment/sanctuary/portal/angel_expedition_portal_source.png",
		"clean": "res://art_source/generated/environment/sanctuary/portal/angel_expedition_portal_clean.png",
		"runtime": "res://assets/environment/sanctuary/landmarks/angel_expedition_portal_192x192.png",
		"ground_runtime": "res://assets/environment/sanctuary/landmarks/angel_expedition_portal_ground_192x192.png",
		"canvas": Vector2i(192, 192),
		"content": Vector2i(186, 186),
		"bottom_margin": 2,
	},
	"fountain": {
		"source": "res://art_source/generated/environment/sanctuary/fountain/divine_fountain_source.png",
		"clean": "res://art_source/generated/environment/sanctuary/fountain/divine_fountain_clean.png",
		"runtime": "res://assets/environment/sanctuary/landmarks/divine_fountain_112x96.png",
		"canvas": Vector2i(112, 96),
		"content": Vector2i(108, 92),
		"bottom_margin": 2,
	},
	"skillkeeper": {
		"source": "res://art_source/generated/characters/npcs/skillkeeper/skillkeeper_compact_source.png",
		"clean": "res://art_source/generated/characters/npcs/skillkeeper/skillkeeper_compact_clean.png",
		"runtime": "res://assets/characters/npcs/skillkeeper/skillkeeper_idle_sheet_48x48.png",
		"canvas": Vector2i(48, 48),
		"content": Vector2i(44, 42),
		"bottom_margin": 3,
		"sheet": true,
		"pulse": "violet",
		"keep_largest": false,
	},
	"merchant": {
		"source": "res://art_source/generated/characters/npcs/armskeeper/armskeeper_compact_source.png",
		"clean": "res://art_source/generated/characters/npcs/armskeeper/armskeeper_compact_clean.png",
		"runtime": "res://assets/characters/npcs/armskeeper/armskeeper_idle_sheet_48x48.png",
		"canvas": Vector2i(48, 48),
		"content": Vector2i(44, 42),
		"bottom_margin": 3,
		"sheet": true,
		"pulse": "ember",
		"keep_largest": false,
	},
	"skillkeeper_lodge": {
		"source": "res://art_source/generated/environment/sanctuary/services/skillkeeper_lodge_source.png",
		"clean": "res://art_source/generated/environment/sanctuary/services/skillkeeper_lodge_clean.png",
		"runtime": "res://assets/environment/sanctuary/buildings/skillkeeper_lodge_128x192.png",
		"canvas": Vector2i(128, 192),
		"content": Vector2i(124, 150),
		"bottom_margin": 2,
		"keep_largest": false,
	},
	"armskeeper_workshop": {
		"source": "res://art_source/generated/environment/sanctuary/services/armskeeper_workshop_source.png",
		"clean": "res://art_source/generated/environment/sanctuary/services/armskeeper_workshop_clean.png",
		"runtime": "res://assets/environment/sanctuary/buildings/armskeeper_workshop_176x192.png",
		"canvas": Vector2i(176, 192),
		"content": Vector2i(170, 180),
		"bottom_margin": 2,
		"keep_largest": false,
	},
	"armskeeper_cart": {
		"source": "res://art_source/generated/environment/sanctuary/services/armskeeper_cart_source.png",
		"clean": "res://art_source/generated/environment/sanctuary/services/armskeeper_cart_clean.png",
		"runtime": "res://assets/environment/sanctuary/shops/armskeeper_cart_128x96.png",
		"canvas": Vector2i(128, 96),
		"content": Vector2i(124, 92),
		"bottom_margin": 2,
		"keep_largest": false,
	},
}


func _initialize() -> void:
	for asset_name: String in ASSET_SPECS:
		var spec: Dictionary = ASSET_SPECS[asset_name]
		var image := Image.load_from_file(ProjectSettings.globalize_path(String(spec.source)))
		if image == null or image.is_empty():
			push_error("Could not load standalone Sanctuary source: %s" % spec.source)
			quit(1)
			return
		image.convert(Image.FORMAT_RGBA8)
		_remove_chroma_background(image)
		if bool(spec.get("keep_largest", true)):
			_keep_largest_component(image)
		if not _save(image, String(spec.clean)):
			return
		var runtime := _fit_to_canvas(
			image,
			spec.canvas as Vector2i,
			spec.content as Vector2i,
			int(spec.bottom_margin)
		)
		if asset_name == "portal":
			var portal_layers := _split_portal_layers(runtime)
			if not _save(portal_layers.ground as Image, String(spec.ground_runtime)):
				return
			runtime = portal_layers.structure as Image
		if bool(spec.get("sheet", false)):
			runtime = _build_npc_idle_sheet(runtime, String(spec.get("pulse", "ember")))
		if not _save(runtime, String(spec.runtime)):
			return
	print("Processed %d standalone Sanctuary assets." % ASSET_SPECS.size())
	quit(0)


func _split_portal_layers(portal: Image) -> Dictionary:
	# The broad center stairs are ground-plane art. The arch, guardians, and
	# doorway remain one Y-sorted structure, preserving the exact combined image
	# while allowing actors to pass in front or behind at the correct baseline.
	var structure := portal.duplicate()
	var ground := _new_image(portal.get_size())
	for y in portal.get_height():
		for x in portal.get_width():
			if y < 133 or x < 45 or x > 146:
				continue
			ground.set_pixel(x, y, portal.get_pixel(x, y))
			structure.set_pixel(x, y, CLEAR)
	return {
		"structure": structure,
		"ground": ground,
	}


func _remove_chroma_background(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			var strongest_non_green := maxf(color.r, color.b)
			if (
				color.g > 0.55
				and color.g > strongest_non_green * 1.45
				and color.g - strongest_non_green > 0.24
			):
				image.set_pixel(x, y, CLEAR)
				continue
			image.set_pixel(x, y, _quantized_opaque(color))


func _keep_largest_component(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var largest_component: Array[Vector2i] = []
	for y in height:
		for x in width:
			var start_index := y * width + x
			if visited[start_index] == 1 or image.get_pixel(x, y).a < 0.999:
				continue
			var component: Array[Vector2i] = []
			var stack: Array[Vector2i] = [Vector2i(x, y)]
			while not stack.is_empty():
				var point: Vector2i = stack.pop_back()
				var index := point.y * width + point.x
				if visited[index] == 1:
					continue
				visited[index] = 1
				if image.get_pixelv(point).a < 0.999:
					continue
				component.append(point)
				for offset in [
					Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
					Vector2i(-1, 0), Vector2i(1, 0),
					Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
				]:
					var neighbor: Vector2i = point + offset
					if neighbor.x >= 0 and neighbor.y >= 0 and neighbor.x < width and neighbor.y < height:
						stack.append(neighbor)
			if component.size() > largest_component.size():
				largest_component = component
	var keep := PackedByteArray()
	keep.resize(width * height)
	for point: Vector2i in largest_component:
		keep[point.y * width + point.x] = 1
	for y in height:
		for x in width:
			if image.get_pixel(x, y).a >= 0.999 and keep[y * width + x] == 0:
				image.set_pixel(x, y, CLEAR)


func _fit_to_canvas(
	image: Image,
	canvas_size: Vector2i,
	content_limit: Vector2i,
	bottom_margin: int
) -> Image:
	var used_rect := image.get_used_rect()
	if used_rect.size == Vector2i.ZERO:
		return _new_image(canvas_size)
	var trimmed := image.get_region(used_rect)
	var scale_factor := minf(
		float(content_limit.x) / float(trimmed.get_width()),
		float(content_limit.y) / float(trimmed.get_height())
	)
	var scaled_size := Vector2i(
		maxi(1, floori(trimmed.get_width() * scale_factor)),
		maxi(1, floori(trimmed.get_height() * scale_factor))
	)
	trimmed.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_NEAREST)
	_harden_runtime_pixels(trimmed)
	_add_hard_outline(trimmed)
	var canvas := _new_image(canvas_size)
	var destination := Vector2i(
		(canvas_size.x - scaled_size.x) / 2,
		canvas_size.y - bottom_margin - scaled_size.y
	)
	canvas.blit_rect(trimmed, Rect2i(Vector2i.ZERO, scaled_size), destination)
	return canvas


func _build_npc_idle_sheet(base: Image, pulse: String) -> Image:
	var sheet := _new_image(Vector2i(base.get_width() * 4, base.get_height()))
	var pulse_strengths := [0.96, 1.0, 1.04, 1.0]
	for frame_index in 4:
		var frame := base.duplicate()
		for y in frame.get_height():
			for x in frame.get_width():
				var color: Color = frame.get_pixel(x, y)
				if color.a < 0.999 or not _is_npc_accent(color, pulse):
					continue
				var strength: float = pulse_strengths[frame_index]
				color.r = clampf(color.r * strength, 0.0, 1.0)
				color.g = clampf(color.g * strength, 0.0, 1.0)
				color.b = clampf(color.b * strength, 0.0, 1.0)
				frame.set_pixel(x, y, _quantized_opaque(color))
		sheet.blit_rect(
			frame,
			Rect2i(Vector2i.ZERO, frame.get_size()),
			Vector2i(frame_index * base.get_width(), 0)
		)
	return sheet


func _is_npc_accent(color: Color, pulse: String) -> bool:
	if pulse == "violet":
		return color.b > 0.35 and color.r > color.g * 1.08
	return color.r > 0.42 and color.g > 0.18 and color.r > color.b * 1.25


func _harden_runtime_pixels(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a < 0.5:
				image.set_pixel(x, y, CLEAR)
			else:
				image.set_pixel(x, y, _quantized_opaque(color))


func _add_hard_outline(image: Image) -> void:
	var source := image.duplicate()
	for y in image.get_height():
		for x in image.get_width():
			if source.get_pixel(x, y).a >= 0.999:
				continue
			for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var neighbor: Vector2i = Vector2i(x, y) + offset
				if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= image.get_width() or neighbor.y >= image.get_height():
					continue
				if source.get_pixelv(neighbor).a >= 0.999:
					image.set_pixel(x, y, VOID_INK)
					break


func _quantized_opaque(color: Color) -> Color:
	return Color(
		roundf(color.r * 15.0) / 15.0,
		roundf(color.g * 15.0) / 15.0,
		roundf(color.b * 15.0) / 15.0,
		1.0
	)


func _new_image(size: Vector2i) -> Image:
	return Image.create(size.x, size.y, false, Image.FORMAT_RGBA8)


func _save(image: Image, path: String) -> bool:
	var error := image.save_png(ProjectSettings.globalize_path(path))
	if error == OK:
		return true
	push_error("Could not save %s (error %d)." % [path, error])
	quit(1)
	return false
