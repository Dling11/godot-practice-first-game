extends SceneTree

## Generated-source extraction and atlas packing for the opt-in Lab only.
const SOURCE := "res://art_source/generated/characters/king/spellward_lab_2026_09_14/"
const OUT := "res://assets/characters/playable/king/spellward_preview/"
const REVIEW := "res://art_source/review/characters/king/spellward_lab_2026_09_14/"
const LOCOMOTION_SOURCE := "res://art_source/generated/characters/king/spellward_locomotion_2026_09_14/"
const LOCOMOTION_REVIEW := "res://art_source/review/characters/king/spellward_locomotion_2026_09_14/"
const CELL := Vector2i(192, 128)
var report: Dictionary = {}

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	DirAccess.make_dir_recursive_absolute(REVIEW)
	if "--frames-only" in OS.get_cmdline_user_args():
		_build_frames()
		quit()
		return
	if "--locomotion-only" in OS.get_cmdline_user_args():
		_build_locomotion()
		quit()
		return
	if "--side-body-only" in OS.get_cmdline_user_args():
		_build_side_body()
		quit()
		return
	var states := _extract("states", 8, 3, 0)
	var walk := _extract("walk", 4, 3, 0)
	var stride := _extract("stride", 2, 2, 0)
	# Authored opposite-foot drawings, not a translated standing sprite.
	# Contact poses settle between each lifted-foot pose.
	walk[0] = [states[0][0], walk[0][1], states[0][1], walk[0][2]]
	walk[1] = [walk[1][0], walk[1][1], stride[0][0], stride[0][1]]
	walk[2] = [walk[2][0], walk[2][1], stride[1][1], stride[1][0]]
	var opening := _extract("opening", 8, 3, 7)
	var reverse := _extract("return", 8, 3, 7)
	var finisher := _extract("finisher", 8, 3, 7)
	# Reject generated poses whose blade disappeared behind an impossible grip.
	opening[1][1] = opening[1][0]
	for row in 3:
		finisher[row][6] = states[row][0]
		for action in [opening, reverse, finisher]:
			action[row][7] = states[row][0]
	var families := {
		"idle": _select(states, [0, 1]), "walk": walk,
		"attack": opening, "return_cut": reverse, "heavy_cleave": finisher,
		"dash": _select(states, [2, 3]), "hurt": _select(states, [3, 5]),
		"stagger": _select(states, [5]), "defeat": _select(states, [6, 7]),
		"interact": _select(states, [0, 1])
	}
	for key: String in families:
		var data: Array = families[key]
		var atlas := Image.create(CELL.x * data[0].size(), CELL.y * 4, false, Image.FORMAT_RGBA8)
		for row in 4:
			for col in data[0].size():
				var cell: Image = data[[0, 1, 1, 2][row]][col].duplicate()
				if row == 1:
					cell.flip_x()
				atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, CELL), Vector2i(col * CELL.x, row * CELL.y))
		atlas.save_png(OUT + key + ".png")
	FileAccess.open(REVIEW + "asset_measurements.json", FileAccess.WRITE).store_string(JSON.stringify(report, "\t"))
	_build_locomotion()
	print("SPELLWARD_ATLASES_BUILT: 56px standing body, 192x128 cells, foot y96")
	quit()

func _select(rows: Array, indices: Array) -> Array:
	var result: Array = []
	for row: Array in rows:
		var selected: Array = []
		for index: int in indices:
			selected.append(row[index])
		result.append(selected)
	return result

func _extract(key: String, columns: int, rows: int, reference_column: int, source: String = SOURCE, register_head: bool = false, shared_scale: bool = false) -> Array:
	var image := Image.load_from_file(source + key + ".png")
	image.convert(Image.FORMAT_RGBA8)
	var w := image.get_width()
	var h := image.get_height()
	var seen := PackedByteArray()
	seen.resize(w * h)
	for y in h:
		for x in w:
			var c := image.get_pixel(x, y)
			if c.a < .5 or (c.r > .12 and c.b > .12 and c.r > c.g * 1.55 and c.b > c.g * 1.55):
				seen[y * w + x] = 1
	var islands: Array = []
	for row in rows:
		var group: Array = []
		group.resize(columns)
		islands.append(group)
	for start in w * h:
		if seen[start]:
			continue
		var points := PackedInt32Array([start])
		seen[start] = 1
		var cursor := 0
		var bounds := Rect2i(start % w, start / w, 1, 1)
		while cursor < points.size():
			var index := points[cursor]
			cursor += 1
			var p := Vector2i(index % w, index / w)
			bounds = bounds.expand(p)
			for delta in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				var next: Vector2i = p + delta
				if next.x < 0 or next.y < 0 or next.x >= w or next.y >= h:
					continue
				var n := next.y * w + next.x
				if not seen[n]:
					seen[n] = 1
					points.append(n)
		if points.size() < 180:
			continue
		bounds.size += Vector2i.ONE
		var row := clampi(int(bounds.get_center().y * rows / h), 0, rows - 1)
		var col := clampi(int(bounds.get_center().x * columns / w), 0, columns - 1)
		if islands[row][col] == null or islands[row][col].points.size() < points.size():
			islands[row][col] = {"points": points, "bounds": bounds}
	var result: Array = []
	var measures: Array = []
	for row in rows:
		var reference: Dictionary = islands[0 if shared_scale else row][reference_column]
		assert(not reference.is_empty(), "Missing source cell " + key + str(row))
		var scale_factor: float = 56.0 / (_boot_y(image, reference) - reference.bounds.position.y + 1)
		var output: Array = []
		for col in columns:
			assert(islands[row][col] != null, "Missing source pose " + key + str(row) + str(col))
			var island: Dictionary = islands[row][col]
			var bounds: Rect2i = island.bounds
			var boot := _boot_y(image, island)
			var cut := Image.create(bounds.size.x, bounds.size.y, false, Image.FORMAT_RGBA8)
			for index: int in island.points:
				var p := Vector2i(index % w, index / w)
				var c := image.get_pixelv(p)
				c.a = 1.0
				cut.set_pixelv(p - bounds.position, c)
			cut.resize(maxi(1, roundi(bounds.size.x * scale_factor)), maxi(1, roundi(bounds.size.y * scale_factor)), Image.INTERPOLATE_NEAREST)
			var origin_x := (col + .5) * w / columns
			if register_head:
				origin_x = _head_x(image, island)
			var dest := Vector2i(96 + roundi((bounds.position.x - origin_x) * scale_factor), 96 - roundi((boot - bounds.position.y + 1) * scale_factor))
			assert(dest.x > 0 and dest.y > 0 and dest.x + cut.get_width() < CELL.x and dest.y + cut.get_height() < CELL.y, "Clipped " + key + str(row) + str(col))
			var cell := Image.create(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
			cell.blit_rect(cut, Rect2i(Vector2i.ZERO, cut.get_size()), dest)
			output.append(cell)
			measures.append({"row": row, "column": col, "scale": scale_factor, "bounds": [dest.x, dest.y, cut.get_width(), cut.get_height()]})
		result.append(output)
	report[key] = measures
	return result

func _head_x(image: Image, island: Dictionary) -> float:
	# The upper hair band excludes the shoulder blade, scarf and swinging limbs.
	# Source cell centers are layout metadata, never a character registration point.
	var bounds: Rect2i = island.bounds
	var left := bounds.end.x
	var right := bounds.position.x
	for index: int in island.points:
		var p := Vector2i(index % image.get_width(), index / image.get_width())
		if p.y >= bounds.position.y + bounds.size.y * .20:
			continue
		left = mini(left, p.x)
		right = maxi(right, p.x)
	return (left + right) * .5

func _build_locomotion() -> void:
	var poses := _extract("locomotion", 8, 3, 0, LOCOMOTION_SOURCE, true)
	var side_pass := _extract("side_pass", 2, 1, 0, LOCOMOTION_SOURCE, true)
	var idle := _select(poses, [0, 1])
	# Choose contact/passing/opposite-contact/passing from the coherent sheet.
	var walk: Array = [
		[poses[0][2], poses[0][6], poses[0][7], poses[0][5]],
		[poses[1][2], poses[1][4], side_pass[0][0], side_pass[0][1]],
		[poses[2][2], poses[2][3], poses[2][4], poses[2][5]]
	]
	for key: String in ["idle", "walk", "interact"]:
		var data: Array = walk if key == "walk" else idle
		var atlas := Image.create(CELL.x * data[0].size(), CELL.y * 4, false, Image.FORMAT_RGBA8)
		for row in 4:
			for col in data[0].size():
				var cell: Image = data[[0, 1, 1, 2][row]][col].duplicate()
				if row == 1:
					cell.flip_x()
				atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, CELL), Vector2i(col * CELL.x, row * CELL.y))
		atlas.save_png(OUT + key + ".png")
	FileAccess.open(LOCOMOTION_REVIEW + "asset_measurements.json", FileAccess.WRITE).store_string(JSON.stringify({"locomotion": report.locomotion}, "\t"))
	FileAccess.open("res://art_source/review/characters/king/spellward_sidewalk_2026_09_14/asset_measurements.json", FileAccess.WRITE).store_string(JSON.stringify({"side_pass": report.side_pass}, "\t"))
	print("SPELLWARD_LOCOMOTION_BUILT: head registration, coherent shoulder carry, attacks preserved")
	_build_side_body()

func _build_side_body() -> void:
	# One complete authored stride, including hips/chest/free-arm motion.
	# Both source rows are one direction and must share one anatomy scale.
	var source := _extract("side_body", 4, 2, 0, LOCOMOTION_SOURCE, true, true)
	var poses: Array = source[0] + source[1]
	var atlas := Image.create(CELL.x * 8, CELL.y * 2, false, Image.FORMAT_RGBA8)
	for row in 2:
		for col in 8:
			var cell: Image = poses[col].duplicate()
			if row == 0:
				cell.flip_x()
			atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, CELL), Vector2i(col * CELL.x, row * CELL.y))
	# Keep the authored study reproducible without overwriting the corrected rig.
	# Final side atlas is rendered by tools/build_king_side_leg_cycle.gd.
	atlas.save_png(LOCOMOTION_SOURCE + "side_body_normalized.png")
	FileAccess.open("res://art_source/review/characters/king/spellward_bodywalk_2026_09_14/asset_measurements.json", FileAccess.WRITE).store_string(JSON.stringify({"side_body": report.side_body}, "\t"))
	print("SPELLWARD_BODY_SOURCE_BUILT: run build_king_side_leg_cycle.gd for the final side atlas")

func _boot_y(image: Image, island: Dictionary) -> int:
	var bounds: Rect2i = island.bounds
	var lowest := bounds.position.y
	for index: int in island.points:
		var p := Vector2i(index % image.get_width(), index / image.get_width())
		if p.y < bounds.position.y + bounds.size.y * .65:
			continue
		var c := image.get_pixelv(p)
		if c.r > .12 and c.r > c.g * 1.15 and c.r < c.g * 2.8 and c.g > c.b * 1.25:
			lowest = maxi(lowest, p.y)
	return mini(bounds.end.y - 1, lowest + maxi(2, roundi(bounds.size.y * .02)))

func _build_frames() -> void:
	var frames := SpriteFrames.new()
	frames.remove_animation("default")
	var aliases := {"echoing_sever": "attack", "riftbreak": "attack", "sovereign_pursuit": "return_cut", "worldsplitter": "heavy_cleave", "oath_spin": "heavy_cleave"}
	var keys: Array = ["idle", "walk", "attack", "return_cut", "heavy_cleave", "dash", "hurt", "stagger", "defeat", "interact"]
	keys.append_array(aliases.keys())
	for key: String in keys:
		var family: String = aliases.get(key, key)
		var texture := load(OUT + family + ".png") as Texture2D
		var count := texture.get_width() / CELL.x
		for row in 4:
			var side_walk := key == "walk" and row in [1, 2]
			var clip_texture := load(OUT + "walk_side.png") as Texture2D if side_walk else texture
			var clip_count := 8 if side_walk else count
			var texture_row := row - 1 if side_walk else row
			var clip: StringName = key + "_" + ["down", "left", "right", "up"][row]
			frames.add_animation(clip)
			frames.set_animation_loop(clip, key in ["idle", "walk", "stagger"])
			frames.set_animation_speed(clip, 14.0 if side_walk else (7.0 if key == "walk" else (1.0 if key == "idle" else 10.0)))
			for col in clip_count:
				var atlas := AtlasTexture.new()
				atlas.atlas = clip_texture
				atlas.region = Rect2(col * CELL.x, texture_row * CELL.y, CELL.x, CELL.y)
				frames.add_frame(clip, atlas)
	ResourceSaver.save(frames, OUT + "spellward_frames.tres")
	print("SPELLWARD_FRAMES_BUILT: ", frames.get_animation_names().size(), " clips")
