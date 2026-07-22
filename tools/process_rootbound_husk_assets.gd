extends SceneTree

const WALK_SOURCE_RAW := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_walk_board_source_v4.png"
const WALK_SOURCE := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_walk_board_clean_v4.png"
const ROOT_ATTACK_SOURCE_RAW := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_board_source_v4.png"
const ROOT_ATTACK_SOURCE := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_board_clean_v4.png"
const ROOT_VFX_SOURCE_RAW := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_root_ground_attack_board_source_v2.png"
const ROOT_VFX_SOURCE := "res://art_source/generated/characters/enemies/rootbound_husk/rootbound_husk_root_ground_attack_board_clean_v2.png"
const WALK_OUTPUT := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64.png"
const ROOT_ATTACK_OUTPUT := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_sheet_96x64.png"
const ROOT_VFX_OUTPUT := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sheet_128x64.png"
const TARGET_UPRIGHT_HEIGHT := 56
const FOOT_MARGIN := 2
const SOURCE_OVERLAP := 64


func _initialize() -> void:
	for source_pair in [
		[WALK_SOURCE_RAW, WALK_SOURCE],
		[ROOT_ATTACK_SOURCE_RAW, ROOT_ATTACK_SOURCE],
		[ROOT_VFX_SOURCE_RAW, ROOT_VFX_SOURCE],
	]:
		var clean_result := _prepare_chroma_clean_source(source_pair[0], source_pair[1])
		if clean_result != OK:
			quit(1)
			return
	var builds := [
		{
			"source": WALK_SOURCE,
			"output": WALK_OUTPUT,
			"columns": 4,
			"rows": 4,
			"cell_size": Vector2i(72, 64),
			"preserve_horizontal_origin": false,
			"minimum_component_size": 32,
			"source_overlap": 0,
		},
		{
			"source": ROOT_ATTACK_SOURCE,
			"output": ROOT_ATTACK_OUTPUT,
			"columns": 6,
			"rows": 4,
			"cell_size": Vector2i(96, 64),
			"preserve_horizontal_origin": true,
			"minimum_component_size": 11,
			"source_overlap": 0,
		},
	]
	for build in builds:
		var result := _build_sheet(
			build.source,
			build.output,
			build.columns,
			build.rows,
			build.cell_size,
			build.preserve_horizontal_origin,
			build.minimum_component_size,
			build.source_overlap
		)
		if result != OK:
			quit(1)
			return
	for mirror_build in [
		{"sheet": WALK_OUTPUT, "cell_size": Vector2i(72, 64), "columns": 4},
		{"sheet": ROOT_ATTACK_OUTPUT, "cell_size": Vector2i(96, 64), "columns": 6},
	]:
		var mirror_result := _mirror_runtime_row(
			mirror_build.sheet,
			mirror_build.cell_size,
			1,
			2,
			mirror_build.columns
		)
		if mirror_result != OK:
			quit(1)
			return
	var vfx_result := _build_root_vfx_sheet()
	if vfx_result != OK:
		quit(1)
		return
	quit(0)


func _prepare_chroma_clean_source(source_path: String, output_path: String) -> Error:
	var source := Image.load_from_file(source_path)
	if source == null or source.is_empty():
		return _fail("Unable to load Rootbound Husk generated source: %s" % source_path)
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var pixel := source.get_pixel(x, y)
			if pixel.r > 0.72 and pixel.g < 0.42 and pixel.b > 0.72:
				source.set_pixel(x, y, Color.TRANSPARENT)
			else:
				pixel.a = 1.0
				source.set_pixel(x, y, pixel)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_path.get_base_dir()))
	var save_error := source.save_png(output_path)
	if save_error != OK:
		return _fail("Unable to save Rootbound Husk clean source: %s" % output_path)
	return OK


func _mirror_runtime_row(
	sheet_path: String,
	cell_size: Vector2i,
	source_row: int,
	destination_row: int,
	columns: int
) -> Error:
	var sheet := Image.load_from_file(ProjectSettings.globalize_path(sheet_path))
	if sheet == null or sheet.is_empty():
		return _fail("Unable to load Rootbound Husk sheet for side mirroring: %s" % sheet_path)
	for column in columns:
		var source_rect := Rect2i(
			Vector2i(column * cell_size.x, source_row * cell_size.y),
			cell_size
		)
		var mirrored_cell := sheet.get_region(source_rect)
		mirrored_cell.flip_x()
		var destination := Vector2i(column * cell_size.x, destination_row * cell_size.y)
		sheet.blit_rect(mirrored_cell, Rect2i(Vector2i.ZERO, cell_size), destination)
		var mirrored_result := sheet.get_region(Rect2i(destination, cell_size))
		if mirrored_cell.get_data() != mirrored_result.get_data():
			return _fail("Rootbound Husk runtime side mirror differs at frame %d." % column)
	var save_error := sheet.save_png(sheet_path)
	if save_error != OK:
		return _fail("Unable to save mirrored Rootbound Husk side row: %s" % sheet_path)
	return OK


func _build_sheet(
	source_path: String,
	output_path: String,
	columns: int,
	rows: int,
	cell_size: Vector2i,
	preserve_horizontal_origin: bool,
	minimum_component_size: int,
	source_overlap: int
) -> Error:
	var source := Image.load_from_file(source_path)
	if source == null or source.is_empty():
		return _fail("Unable to load Rootbound Husk source: %s" % source_path)
	var output := Image.create_empty(
		cell_size.x * columns,
		cell_size.y * rows,
		false,
		Image.FORMAT_RGBA8
	)
	output.fill(Color.TRANSPARENT)
	for row in rows:
		var reference_cell := _source_cell_rect(source, 0, row, columns, rows)
		var reference := _extract_actor(source, reference_cell, source_overlap)
		if reference.is_empty():
			return _fail("Rootbound Husk direction reference %d is empty." % row)
		var fixed_scale := float(TARGET_UPRIGHT_HEIGHT) / float((reference.image as Image).get_height())
		for column in columns:
			var source_cell := _source_cell_rect(source, column, row, columns, rows)
			var extracted := _extract_actor(source, source_cell, source_overlap)
			if extracted.is_empty():
				return _fail("Rootbound Husk source frame %d,%d is empty." % [column, row])
			var frame := (extracted.image as Image).duplicate()
			frame.resize(
				maxi(1, roundi(frame.get_width() * fixed_scale)),
				maxi(1, roundi(frame.get_height() * fixed_scale)),
				Image.INTERPOLATE_NEAREST
			)
			_harden_alpha(frame)
			frame = _retain_readable_components(frame, minimum_component_size)
			var source_offset := extracted.source_offset as Vector2i
			var destination_x := column * cell_size.x + roundi((cell_size.x - frame.get_width()) * 0.5)
			if preserve_horizontal_origin:
				destination_x = column * cell_size.x + roundi(
					(cell_size.x - source_cell.size.x * fixed_scale) * 0.5
					+ source_offset.x * fixed_scale
				)
			var destination := Vector2i(
				destination_x,
				row * cell_size.y + cell_size.y - FOOT_MARGIN - frame.get_height()
			)
			var cell_bounds := Rect2i(Vector2i(column * cell_size.x, row * cell_size.y), cell_size)
			var frame_bounds := Rect2i(destination, frame.get_size())
			if not cell_bounds.encloses(frame_bounds):
				return _fail(
					"Rootbound Husk frame %d,%d exceeds its runtime cell: %s"
					% [column, row, frame_bounds]
				)
			output.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), destination)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output_path.get_base_dir()))
	var save_error := output.save_png(output_path)
	if save_error != OK:
		return _fail("Unable to save Rootbound Husk sheet: %s" % output_path)
	print("Processed Rootbound Husk sheet: %s" % output_path)
	return OK


func _source_cell_rect(source: Image, column: int, row: int, columns: int, rows: int) -> Rect2i:
	var left := roundi(float(column) * source.get_width() / float(columns))
	var right := roundi(float(column + 1) * source.get_width() / float(columns))
	var top := roundi(float(row) * source.get_height() / float(rows))
	var bottom := roundi(float(row + 1) * source.get_height() / float(rows))
	return Rect2i(left, top, right - left, bottom - top)


func _build_root_vfx_sheet() -> Error:
	var source := Image.load_from_file(ROOT_VFX_SOURCE)
	if source == null or source.is_empty():
		return _fail("Unable to load Rootbound Husk root VFX source: %s" % ROOT_VFX_SOURCE)
	var output := Image.create_empty(128 * 6, 64, false, Image.FORMAT_RGBA8)
	output.fill(Color.TRANSPARENT)
	for frame_index in 6:
		var source_column := frame_index % 3
		var source_row := frame_index / 3
		var source_cell := _source_cell_rect(source, source_column, source_row, 3, 2)
		var extracted := _extract_actor(source, source_cell)
		if extracted.is_empty():
			return _fail("Rootbound Husk root VFX frame %d is empty." % frame_index)
		var frame := (extracted.image as Image).duplicate()
		var maximum_size := Vector2i(112, 46) if frame_index < 3 else Vector2i(92, 60)
		var scale_factor := minf(
			float(maximum_size.x) / float(frame.get_width()),
			float(maximum_size.y) / float(frame.get_height())
		)
		frame.resize(
			maxi(1, roundi(frame.get_width() * scale_factor)),
			maxi(1, roundi(frame.get_height() * scale_factor)),
			Image.INTERPOLATE_NEAREST
		)
		_harden_alpha(frame)
		frame = _isolate_largest_component(frame)
		var destination := Vector2i(
			frame_index * 128 + roundi((128 - frame.get_width()) * 0.5),
			roundi((64 - frame.get_height()) * 0.5)
		)
		output.blit_rect(frame, Rect2i(Vector2i.ZERO, frame.get_size()), destination)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(ROOT_VFX_OUTPUT.get_base_dir()))
	var save_error := output.save_png(ROOT_VFX_OUTPUT)
	if save_error != OK:
		return _fail("Unable to save Rootbound Husk root VFX sheet.")
	print("Processed Rootbound Husk sheet: %s" % ROOT_VFX_OUTPUT)
	return OK


func _extract_actor(source: Image, cell: Rect2i, overlap_pixels := SOURCE_OVERLAP) -> Dictionary:
	var source_bounds := Rect2i(Vector2i.ZERO, source.get_size())
	var expanded := cell.grow(overlap_pixels).intersection(source_bounds)
	var capture := source.get_region(expanded)
	_harden_alpha(capture)
	var isolated := (
		_retain_readable_components(capture, 64)
		if overlap_pixels == 0
		else _isolate_largest_component(capture)
	)
	var used := isolated.get_used_rect()
	if used.size == Vector2i.ZERO:
		return {}
	return {
		"image": isolated.get_region(used),
		"source_offset": expanded.position + used.position - cell.position,
	}


func _isolate_largest_component(image: Image) -> Image:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	visited.fill(0)
	var largest: Array[Vector2i] = []
	for y in height:
		for x in width:
			var start := Vector2i(x, y)
			var start_index := y * width + x
			if visited[start_index] == 1 or image.get_pixelv(start).a < 0.5:
				continue
			var pending: Array[Vector2i] = [start]
			var component: Array[Vector2i] = []
			visited[start_index] = 1
			while not pending.is_empty():
				var point: Vector2i = pending.pop_back()
				component.append(point)
				for offset_y in range(-1, 2):
					for offset_x in range(-1, 2):
						if offset_x == 0 and offset_y == 0:
							continue
						var neighbor: Vector2i = point + Vector2i(offset_x, offset_y)
						if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= width or neighbor.y >= height:
							continue
						var neighbor_index: int = neighbor.y * width + neighbor.x
						if visited[neighbor_index] == 1 or image.get_pixelv(neighbor).a < 0.5:
							continue
						visited[neighbor_index] = 1
						pending.append(neighbor)
			if component.size() > largest.size():
				largest = component
	var isolated := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	isolated.fill(Color.TRANSPARENT)
	for point in largest:
		isolated.set_pixelv(point, image.get_pixelv(point))
	return isolated


func _retain_readable_components(image: Image, minimum_size: int) -> Image:
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width * height)
	visited.fill(0)
	var retained := Image.create_empty(width, height, false, Image.FORMAT_RGBA8)
	retained.fill(Color.TRANSPARENT)
	for y in height:
		for x in width:
			var start := Vector2i(x, y)
			var start_index := y * width + x
			if visited[start_index] == 1 or image.get_pixelv(start).a < 0.5:
				continue
			var pending: Array[Vector2i] = [start]
			var component: Array[Vector2i] = []
			visited[start_index] = 1
			while not pending.is_empty():
				var point: Vector2i = pending.pop_back()
				component.append(point)
				for offset_y in range(-1, 2):
					for offset_x in range(-1, 2):
						if offset_x == 0 and offset_y == 0:
							continue
						var neighbor := point + Vector2i(offset_x, offset_y)
						if neighbor.x < 0 or neighbor.y < 0 or neighbor.x >= width or neighbor.y >= height:
							continue
						var neighbor_index := neighbor.y * width + neighbor.x
						if visited[neighbor_index] == 1 or image.get_pixelv(neighbor).a < 0.5:
							continue
						visited[neighbor_index] = 1
						pending.append(neighbor)
			if component.size() < minimum_size:
				continue
			for point in component:
				retained.set_pixelv(point, image.get_pixelv(point))
	return retained


func _harden_alpha(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var pixel := image.get_pixel(x, y)
			if pixel.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
			else:
				pixel.a = 1.0
				image.set_pixel(x, y, pixel)


func _fail(message: String) -> Error:
	push_error(message)
	return FAILED
