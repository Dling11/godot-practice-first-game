extends SceneTree

## Rebuilds Rootweaver Nema's approved Sanctuary service assets from the
## generated source board and the accepted grove-smith concept. Runtime output
## is hard-pixel, binary-alpha, nearest-neighbor art with exact canvas sizes.

const CLEAR := Color(0, 0, 0, 0)
const VOID_INK := Color("090b10")

const ACTOR_SOURCE := "res://art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_source.png"
const ACTOR_CLEAN := "res://art_source/generated/characters/npcs/rootweaver/rootweaver_nema_service_clean.png"
const ACTOR_RUNTIME := "res://assets/characters/npcs/rootweaver/rootweaver_nema_service_sheet_48x48.png"

const CONCEPT_SOURCE := "res://art_source/generated/characters/npcs/rootweaver/rootweaver_nema_grove_smith_concept_v3_source.png"
const PORTRAIT_SOURCE := "res://art_source/generated/characters/npcs/rootweaver/rootweaver_nema_portrait_source.png"
const PORTRAIT_CLEAN := "res://art_source/generated/characters/npcs/rootweaver/rootweaver_nema_portrait_clean.png"
const PORTRAIT_RUNTIME := "res://assets/characters/npcs/rootweaver/rootweaver_nema_portrait_96x96.png"
const ROOTFORGE_SOURCE := "res://art_source/generated/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_source.png"
const ROOTFORGE_CLEAN := "res://art_source/generated/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_clean.png"
const ROOTFORGE_RUNTIME := "res://assets/environment/sanctuary/services/rootweaver/rootweaver_living_rootforge_176x144.png"

const PORTRAIT_RECT := Rect2i(680, 176, 312, 332)
const ROOTFORGE_RECT := Rect2i(1010, 132, 654, 664)


func _initialize() -> void:
	if not _build_actor_sheet():
		return
	if not _build_concept_derivatives():
		return
	print("Processed Rootweaver Nema actor, portrait, and Living Rootforge assets.")
	quit(0)


func _build_actor_sheet() -> bool:
	var source := _load_rgba(ACTOR_SOURCE)
	if source == null:
		return false
	var clean := source.duplicate()
	_remove_cyan_background(clean)
	_harden_runtime_pixels(clean)
	if not _save(clean, ACTOR_CLEAN):
		return false

	var actor_rects := _find_actor_component_rects(clean)
	if actor_rects.size() != 8:
		push_error("Expected eight Rootweaver actor components, found %d." % actor_rects.size())
		quit(1)
		return false
	var frames: Array[Image] = []
	var used_rects: Array[Rect2i] = []
	var largest_used := Vector2i.ZERO
	for actor_rect: Rect2i in actor_rects:
		var frame: Image = clean.get_region(actor_rect)
		var used_rect: Rect2i = frame.get_used_rect()
		frames.append(frame)
		used_rects.append(used_rect)
		largest_used.x = maxi(largest_used.x, used_rect.size.x)
		largest_used.y = maxi(largest_used.y, used_rect.size.y)

	var scale_factor := minf(44.0 / float(largest_used.x), 43.0 / float(largest_used.y))
	var sheet := _new_image(Vector2i(192, 96))
	for frame_index in frames.size():
		var used_rect: Rect2i = used_rects[frame_index]
		var trimmed := frames[frame_index].get_region(used_rect)
		var scaled_size := Vector2i(
			maxi(1, floori(trimmed.get_width() * scale_factor)),
			maxi(1, floori(trimmed.get_height() * scale_factor))
		)
		trimmed.resize(scaled_size.x, scaled_size.y, Image.INTERPOLATE_NEAREST)
		_harden_runtime_pixels(trimmed)
		_add_hard_outline(trimmed)
		var frame_canvas := _new_image(Vector2i(48, 48))
		var destination := Vector2i(
			(48 - scaled_size.x) / 2,
			46 - scaled_size.y
		)
		frame_canvas.blit_rect(
			trimmed,
			Rect2i(Vector2i.ZERO, trimmed.get_size()),
			destination
		)
		var sheet_position := Vector2i((frame_index % 4) * 48, (frame_index / 4) * 48)
		sheet.blit_rect(
			frame_canvas,
			Rect2i(Vector2i.ZERO, frame_canvas.get_size()),
			sheet_position
		)
	return _save(sheet, ACTOR_RUNTIME)


func _find_actor_component_rects(image: Image) -> Array[Rect2i]:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var top_row: Array[Rect2i] = []
	var bottom_row: Array[Rect2i] = []
	for y in height:
		for x in width:
			var start_index := y * width + x
			if visited[start_index] == 1 or image.get_pixel(x, y).a < 0.999:
				continue
			var stack: Array[Vector2i] = [Vector2i(x, y)]
			var pixel_count := 0
			var minimum := Vector2i(x, y)
			var maximum := Vector2i(x, y)
			while not stack.is_empty():
				var point: Vector2i = stack.pop_back()
				var index := point.y * width + point.x
				if visited[index] == 1:
					continue
				visited[index] = 1
				if image.get_pixelv(point).a < 0.999:
					continue
				pixel_count += 1
				minimum.x = mini(minimum.x, point.x)
				minimum.y = mini(minimum.y, point.y)
				maximum.x = maxi(maximum.x, point.x)
				maximum.y = maxi(maximum.y, point.y)
				for offset in [
					Vector2i(-1, -1), Vector2i(0, -1), Vector2i(1, -1),
					Vector2i(-1, 0), Vector2i(1, 0),
					Vector2i(-1, 1), Vector2i(0, 1), Vector2i(1, 1),
				]:
					var neighbor: Vector2i = point + offset
					if neighbor.x >= 0 and neighbor.y >= 0 and neighbor.x < width and neighbor.y < height:
						stack.append(neighbor)
			if pixel_count < 1000:
				continue
			var rect := Rect2i(minimum, maximum - minimum + Vector2i.ONE)
			if rect.get_center().y < height / 2:
				top_row.append(rect)
			else:
				bottom_row.append(rect)
	top_row.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.position.x < b.position.x)
	bottom_row.sort_custom(func(a: Rect2i, b: Rect2i) -> bool: return a.position.x < b.position.x)
	var ordered: Array[Rect2i] = []
	ordered.append_array(top_row)
	ordered.append_array(bottom_row)
	return ordered


func _build_concept_derivatives() -> bool:
	var concept := _load_rgba(CONCEPT_SOURCE)
	if concept == null:
		return false

	var portrait_source := concept.get_region(PORTRAIT_RECT)
	if not _save(portrait_source, PORTRAIT_SOURCE):
		return false
	var portrait_clean := portrait_source.duplicate()
	_remove_dark_border_background(portrait_clean)
	_harden_runtime_pixels(portrait_clean)
	if not _save(portrait_clean, PORTRAIT_CLEAN):
		return false
	var portrait_runtime := _fit_to_canvas(
		portrait_clean,
		Vector2i(96, 96),
		Vector2i(92, 92),
		2,
		false
	)
	if not _save(portrait_runtime, PORTRAIT_RUNTIME):
		return false

	var rootforge_source := concept.get_region(ROOTFORGE_RECT)
	if not _save(rootforge_source, ROOTFORGE_SOURCE):
		return false
	var rootforge_clean := rootforge_source.duplicate()
	_remove_dark_border_background(rootforge_clean)
	_harden_runtime_pixels(rootforge_clean)
	if not _save(rootforge_clean, ROOTFORGE_CLEAN):
		return false
	var rootforge_runtime := _fit_to_canvas(
		rootforge_clean,
		Vector2i(176, 144),
		Vector2i(172, 140),
		2,
		true
	)
	return _save(rootforge_runtime, ROOTFORGE_RUNTIME)


func _load_rgba(path: String) -> Image:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.is_empty():
		push_error("Could not load Rootweaver source: %s" % path)
		quit(1)
		return null
	image.convert(Image.FORMAT_RGBA8)
	return image


func _remove_cyan_background(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			var cyan_floor := minf(color.g, color.b)
			if (
				cyan_floor > 0.48
				and cyan_floor - color.r > 0.20
				and absf(color.g - color.b) < 0.30
			):
				image.set_pixel(x, y, CLEAR)


func _remove_dark_border_background(image: Image) -> void:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	var stack: Array[Vector2i] = []
	for x in width:
		stack.append(Vector2i(x, 0))
		stack.append(Vector2i(x, height - 1))
	for y in height:
		stack.append(Vector2i(0, y))
		stack.append(Vector2i(width - 1, y))
	while not stack.is_empty():
		var point: Vector2i = stack.pop_back()
		var index := point.y * width + point.x
		if visited[index] == 1:
			continue
		visited[index] = 1
		var color := image.get_pixelv(point)
		if maxf(color.r, maxf(color.g, color.b)) > 0.12:
			continue
		image.set_pixelv(point, CLEAR)
		for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
			var neighbor: Vector2i = point + offset
			if neighbor.x >= 0 and neighbor.y >= 0 and neighbor.x < width and neighbor.y < height:
				stack.append(neighbor)


func _fit_to_canvas(
	image: Image,
	canvas_size: Vector2i,
	content_limit: Vector2i,
	bottom_margin: int,
	add_outline: bool
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
	if add_outline:
		_add_hard_outline(trimmed)
	var canvas := _new_image(canvas_size)
	var destination := Vector2i(
		(canvas_size.x - scaled_size.x) / 2,
		canvas_size.y - bottom_margin - scaled_size.y
	)
	canvas.blit_rect(trimmed, Rect2i(Vector2i.ZERO, scaled_size), destination)
	return canvas


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
	var absolute_path := ProjectSettings.globalize_path(path)
	DirAccess.make_dir_recursive_absolute(absolute_path.get_base_dir())
	var error := image.save_png(absolute_path)
	if error == OK:
		return true
	push_error("Could not save %s (error %d)." % [path, error])
	quit(1)
	return false
