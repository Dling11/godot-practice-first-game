extends SceneTree

## Reinterpret the generated matched source into hard-pixel native UI assets.
## Rebuild with: godot --headless --path . --script res://tools/build_divine_dragon_hud_art.gd

const SOURCE := "res://art_source/generated/ui/divine_dragon_hotbar/dragon_hotbar_source.png"
const OUTPUT_DIR := "res://assets/ui/hud/divine_dragon"

const PALETTE: Array[Color] = [
	Color("0b1521"), Color("1c2b39"), Color("344a59"), Color("5d7c8a"),
	Color("765b35"), Color("a47e47"), Color("d6c171"), Color("f0e2ae"),
	Color("fff5dd"), Color("2e738f"), Color("66a4d8"), Color("9edcea"),
	Color("654887"), Color("a884d1"),
]


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE)
	if source == null or source.is_empty():
		push_error("Missing generated divine dragon source")
		quit(1)
		return
	var left_bounds := _occupied_bounds(source, Rect2i(0, 0, 800, source.get_height()))
	var dash_bounds := _occupied_bounds(source, Rect2i(800, 225, 350, 400))
	print("Dragon source bounds: left=%s dash=%s" % [left_bounds, dash_bounds])
	if not left_bounds.has_area() or not dash_bounds.has_area():
		push_error("Generated ornament regions could not be isolated")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var left := _make_runtime(source, left_bounds.grow(8), Vector2i(72, 68))
	var right: Image = left.duplicate()
	right.flip_x()
	var dash := _make_runtime(source, dash_bounds.grow(8), Vector2i(24, 24))
	var outputs := {
		"dragon_left_72x68.png": left,
		"dragon_right_72x68.png": right,
		"dragon_dash_24.png": dash,
	}
	for filename: String in outputs:
		var result: int = (outputs[filename] as Image).save_png(ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename]))
		if result != OK:
			push_error("Could not save %s" % filename)
			quit(1)
			return
	print("Built matched divine-dragon HUD assets")
	quit(0)


func _occupied_bounds(source: Image, area: Rect2i) -> Rect2i:
	var minimum := area.end
	var maximum := area.position - Vector2i.ONE
	for y in range(area.position.y, mini(area.end.y, source.get_height())):
		for x in range(area.position.x, mini(area.end.x, source.get_width())):
			if source.get_pixel(x, y).a < 0.65:
				continue
			minimum.x = mini(minimum.x, x)
			minimum.y = mini(minimum.y, y)
			maximum.x = maxi(maximum.x, x)
			maximum.y = maxi(maximum.y, y)
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)


func _make_runtime(source: Image, bounds: Rect2i, size: Vector2i) -> Image:
	var safe_bounds := bounds.intersection(Rect2i(Vector2i.ZERO, source.get_size()))
	var native := source.get_region(safe_bounds)
	native.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	native.convert(Image.FORMAT_RGBA8)
	var original: Image = native.duplicate()
	for y in size.y:
		for x in size.x:
			var pixel: Color = original.get_pixel(x, y)
			if pixel.a < 0.52:
				native.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var chosen := PALETTE[0]
			var best := INF
			for candidate: Color in PALETTE:
				var difference: Color = pixel - candidate
				var distance: float = difference.r * difference.r + difference.g * difference.g + difference.b * difference.b
				if distance < best:
					best = distance
					chosen = candidate
			native.set_pixel(x, y, chosen)
	# Clear stray single pixels created by the high-resolution source sampling.
	var quantized: Image = native.duplicate()
	for y in range(1, size.y - 1):
		for x in range(1, size.x - 1):
			if quantized.get_pixel(x, y).a == 0.0:
				continue
			var neighbors := 0
			for offset in [Vector2i.LEFT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN]:
				if quantized.get_pixelv(Vector2i(x, y) + offset).a > 0.0:
					neighbors += 1
			if neighbors <= 1:
				native.set_pixel(x, y, Color.TRANSPARENT)
	return native
