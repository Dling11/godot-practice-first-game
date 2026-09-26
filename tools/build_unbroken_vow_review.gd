extends SceneTree

## Review-only extraction of generated Skill 4 aura over the unchanged King C idle cell.
## godot --headless --path . --script res://tools/build_unbroken_vow_review.gd

const SOURCE := "res://art_source/generated/characters/king/unbroken_vow_2026_09_27/activation_source.png"
const KING_IDLE := "res://assets/characters/playable/king/spellward/idle.png"
const REVIEW_DIR := "res://art_source/review/characters/king/unbroken_vow_2026_09_27"
const CELL := Vector2i(112, 112)
const PALETTE: Array[Color] = [
	Color("172440"), Color("243f83"), Color("235cc4"), Color("3e7ee2"),
	Color("6aaef5"), Color("93d7ff"), Color("eef8ff"), Color("4730a2"),
	Color("6748cc"), Color("a277ef"), Color("d7b7ff"),
]


func _initialize() -> void:
	var shield_review := OS.get_cmdline_user_args().has("--shield-v2")
	var source_path := SOURCE.replace("unbroken_vow_", "unbroken_vow_v2_") if shield_review else SOURCE
	var review_dir := REVIEW_DIR.replace("unbroken_vow_", "unbroken_vow_v2_") if shield_review else REVIEW_DIR
	var source := Image.load_from_file(source_path)
	var king_texture := load(KING_IDLE) as Texture2D
	var king := king_texture.get_image() if king_texture != null else null
	if source == null or king == null or source.is_empty() or king.is_empty():
		push_error("Missing Unbroken Vow concept or King C source")
		quit(1)
		return
	if source.get_width() % 3 != 0 or source.get_height() % 2 != 0:
		push_error("VFX concept is not a regular 3x2 layout")
		quit(1)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(review_dir))
	var source_cell := Vector2i(source.get_width() / 3, source.get_height() / 2)
	var native_sheet := Image.create_empty(CELL.x * 3, CELL.y * 2, false, Image.FORMAT_RGBA8)
	var preview := Image.create_empty(192 * 3, 128 * 2, false, Image.FORMAT_RGBA8)
	preview.fill(Color("17212e"))
	var body := king.get_region(Rect2i(0, 0, 192, 128))
	for index in 6:
		var region := source.get_region(Rect2i(
			(index % 3) * source_cell.x,
			(index / 3) * source_cell.y,
			source_cell.x,
			source_cell.y
		))
		var native := _extract_pixels(region, shield_review)
		if shield_review:
			# Register generated ground-ring centers to King's y96 foot baseline.
			var registered := Image.create_empty(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
			registered.blit_rect(native, Rect2i(Vector2i.ZERO, CELL), Vector2i(0, -4 if index < 3 else 2))
			native = registered
		native_sheet.blit_rect(native, Rect2i(Vector2i.ZERO, CELL), Vector2i(index % 3 * CELL.x, index / 3 * CELL.y))
		var view_origin := Vector2i(index % 3 * 192, index / 3 * 128)
		preview.blend_rect(native, Rect2i(Vector2i.ZERO, CELL), view_origin + Vector2i(40, 8))
		preview.blend_rect(body, Rect2i(0, 0, 192, 128), view_origin)
		if shield_review:
			# Foreground lip crosses in front of the boots: the shield encloses King.
			preview.blend_rect(native, Rect2i(0, 86, CELL.x, CELL.y - 86), view_origin + Vector2i(40, 94))
		var preview_frame := preview.get_region(Rect2i(view_origin, Vector2i(192, 128)))
		preview_frame.save_png(ProjectSettings.globalize_path("%s/preview_frame_%02d.png" % [review_dir, index + 1]))
		var frame_path := ProjectSettings.globalize_path("%s/frame_%02d.png" % [review_dir, index + 1])
		if native.save_png(frame_path) != OK:
			push_error("Could not save %s" % frame_path)
			quit(1)
			return
	for output in [
		["activation_native_3x2.png", native_sheet],
		["king_c_overlay_review.png", preview],
	]:
		if (output[1] as Image).save_png(ProjectSettings.globalize_path("%s/%s" % [review_dir, output[0]])) != OK:
			push_error("Could not save %s" % output[0])
			quit(1)
			return
	print("Built six Unbroken Vow review frames from %s source and unchanged King C" % source.get_size())
	quit(0)


func _extract_pixels(region: Image, shield_review: bool = false) -> Image:
	region.convert(Image.FORMAT_RGBA8)
	for y in region.get_height():
		for x in region.get_width():
			var color := region.get_pixel(x, y)
			var visible := color.b >= 0.53 and maxf(color.r, color.g) >= 0.40
			if shield_review:
				visible = color.b >= 0.65 and (color.g >= 0.53 or color.r >= 0.56)
			if not visible:
				region.set_pixel(x, y, Color.TRANSPARENT)
	region.resize(CELL.x, CELL.y, Image.INTERPOLATE_LANCZOS)
	for y in CELL.y:
		for x in CELL.x:
			var pixel := region.get_pixel(x, y)
			if pixel.a < 0.38:
				region.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var chosen := PALETTE[0]
			var closest := INF
			for candidate: Color in PALETTE:
				var dr := pixel.r - candidate.r
				var dg := pixel.g - candidate.g
				var db := pixel.b - candidate.b
				var distance := dr * dr + dg * dg + db * db
				if distance < closest:
					closest = distance
					chosen = candidate
			region.set_pixel(x, y, chosen)
	return region
