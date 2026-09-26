extends SceneTree

## Rebuild native hard-pixel HUD art from the approved generated frame and dash source.
## godot --headless --path . --script res://tools/build_eclipse_bind_hud_art.gd

const FRAME_SOURCE := "res://art_source/generated/ui/eclipse_bind_hotbar/eclipse_bind_frame_source.png"
const DASH_SOURCE := "res://art_source/generated/ui/eclipse_bind_hotbar/eclipse_dash_source.png"
const OUTPUT_DIR := "res://assets/ui/hud/eclipse_bind"
const PALETTE: Array[Color] = [
	Color("09080f"), Color("14111b"), Color("211c28"), Color("322b36"),
	Color("48404a"), Color("655963"), Color("897f84"), Color("b9afb0"),
	Color("e2d8d5"), Color("301449"), Color("4e2274"), Color("7433a8"),
	Color("a260d0"), Color("d09cf2"), Color("eee3fc"),
]


func _initialize() -> void:
	var frame_source := Image.load_from_file(FRAME_SOURCE)
	var dash_source := Image.load_from_file(DASH_SOURCE)
	if frame_source == null or dash_source == null or frame_source.is_empty() or dash_source.is_empty():
		push_error("Missing Eclipse Bind generated source art")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT_DIR))
	var outputs := {
		"eclipse_frame_760x120.png": _make_runtime(frame_source, Vector2i(760, 120)),
		"eclipse_dash_24.png": _make_runtime(dash_source, Vector2i(24, 24)),
	}
	for filename: String in outputs:
		var result: int = (outputs[filename] as Image).save_png(ProjectSettings.globalize_path("%s/%s" % [OUTPUT_DIR, filename]))
		if result != OK:
			push_error("Could not save Eclipse Bind art: %s" % filename)
			quit(1)
			return
	print("Built Eclipse Bind hard-pixel HUD art")
	quit(0)


func _make_runtime(source: Image, size: Vector2i) -> Image:
	var bounds := _occupied_bounds(source).grow(4).intersection(Rect2i(Vector2i.ZERO, source.get_size()))
	var native := source.get_region(bounds)
	native.resize(size.x, size.y, Image.INTERPOLATE_LANCZOS)
	native.convert(Image.FORMAT_RGBA8)
	for y in size.y:
		for x in size.x:
			var pixel := native.get_pixel(x, y)
			if pixel.a < 0.55:
				native.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var chosen := PALETTE[0]
			var best := INF
			for candidate: Color in PALETTE:
				var dr := pixel.r - candidate.r
				var dg := pixel.g - candidate.g
				var db := pixel.b - candidate.b
				var distance := dr * dr + dg * dg + db * db
				if distance < best:
					best = distance
					chosen = candidate
			native.set_pixel(x, y, chosen)
	return native


func _occupied_bounds(source: Image) -> Rect2i:
	var minimum := source.get_size()
	var maximum := Vector2i(-1, -1)
	for y in source.get_height():
		for x in source.get_width():
			if source.get_pixel(x, y).a < 0.55:
				continue
			minimum.x = mini(minimum.x, x)
			minimum.y = mini(minimum.y, y)
			maximum.x = maxi(maximum.x, x)
			maximum.y = maxi(maximum.y, y)
	return Rect2i(minimum, maximum - minimum + Vector2i.ONE)
