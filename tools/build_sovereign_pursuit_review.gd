extends SceneTree

## Packs the approved-style generated Pursuit comparison without changing its
## original campaign resources. Each source cell is registered to one contact.

const SOURCE_DIR := "res://art_source/generated/vfx/king/sovereign_pursuit_2026_09_26/"
const OUTPUT_DIR := "res://assets/vfx/abilities/king/sovereign_pursuit_review/"


func _initialize() -> void:
	call_deferred("_build")


func _build() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var landing := Image.load_from_file(SOURCE_DIR + "landing_source.png")
	var travel := Image.load_from_file(SOURCE_DIR + "travel_source.png")
	if landing == null or landing.get_size() != Vector2i(1268, 1241) or travel == null or travel.get_size() != Vector2i(1536, 1024):
		push_error("Pursuit source images have unexpected dimensions")
		quit(1)
		return
	if not _pack_landing(landing) or not _pack_travel(travel):
		quit(1)
		return
	print("PURSUIT_REVIEW_ATLASES_BUILT")
	quit()


func _pack_landing(source: Image) -> bool:
	var atlas := Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for frame in 16:
		var column := frame % 4
		var row := frame / 4
		var top := roundi(float(row) * float(source.get_height()) / 4.0)
		var bottom := roundi(float(row + 1) * float(source.get_height()) / 4.0)
		var cell := source.get_region(Rect2i(column * 317, top, 317, bottom - top))
		cell.resize(158, 155, Image.INTERPOLATE_NEAREST)
		_harden_alpha(cell)
		# Frame 15 is deliberately clear: the blade energy has vanished.
		if not cell.get_used_rect().has_area() and frame != 15:
			push_error("Empty Pursuit landing frame %d" % frame)
			return false
		# Source's ground point is approximately (160, 260). At half-size,
		# (48, -2) maps it to the runtime cell center (128, 128).
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(column * 256 + 48, row * 256 - 2))
	if atlas.save_png(OUTPUT_DIR + "landing.png") != OK:
		return false
	_write_frames("landing_frames.tres", "landing.png", 256, 4, 16, [
		_animation("launch", [0, 1], 14.0, false),
		_animation("impact", range(2, 14), 24.0, false),
		_animation("afterglow", [14, 15], 4.0, false),
	])
	return true


func _pack_travel(source: Image) -> bool:
	var atlas := Image.create(512, 256, false, Image.FORMAT_RGBA8)
	atlas.fill(Color.TRANSPARENT)
	for frame in 8:
		var column := frame % 4
		var row := frame / 4
		var cell := source.get_region(Rect2i(column * 384, row * 512, 384, 512))
		# Keep an eight-pixel gutter around even the tallest comet drawings.
		cell.resize(84, 112, Image.INTERPOLATE_NEAREST)
		_harden_alpha(cell)
		if not cell.get_used_rect().has_area():
			push_error("Empty Pursuit travel frame %d" % frame)
			return false
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), Vector2i(column * 128 + 22, row * 128 + 8))
	if atlas.save_png(OUTPUT_DIR + "travel.png") != OK:
		return false
	_write_frames("travel_frames.tres", "travel.png", 128, 4, 8, [
		_animation("travel", range(8), 30.0, false),
	])
	return true


func _harden_alpha(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if color.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
			else:
				color.a = 1.0
				image.set_pixel(x, y, color)


func _animation(name: String, frames: Array, speed: float, loop: bool) -> Dictionary:
	return {"name": name, "frames": frames, "speed": speed, "loop": loop}


func _write_frames(filename: String, atlas_filename: String, cell: int, columns: int, count: int, animations: Array) -> void:
	var data := '[gd_resource type="SpriteFrames" load_steps=%d format=3]\n\n' % (count + 2)
	data += '[ext_resource type="Texture2D" path="%s%s" id="1_sheet"]\n\n' % [OUTPUT_DIR, atlas_filename]
	for frame in count:
		data += '[sub_resource type="AtlasTexture" id="Frame_%02d"]\n' % frame
		data += 'atlas = ExtResource("1_sheet")\n'
		data += 'region = Rect2(%d, %d, %d, %d)\n\n' % [(frame % columns) * cell, (frame / columns) * cell, cell, cell]
	var records: Array[String] = []
	for animation in animations:
		var entries: Array[String] = []
		for frame in animation.frames:
			entries.append('{"duration": 1.0, "texture": SubResource("Frame_%02d")}' % frame)
		records.append('{"frames": [%s], "loop": %s, "name": &"%s", "speed": %.1f}' % [", ".join(entries), "true" if animation.loop else "false", animation.name, animation.speed])
	data += "[resource]\nanimations = [%s]\n" % ", ".join(records)
	var file := FileAccess.open(OUTPUT_DIR + filename, FileAccess.WRITE)
	assert(file != null)
	file.store_string(data)
