extends SceneTree

const SOURCE := "res://art_source/generated/ui/campfire_title_2026_10_03/"

func _initialize() -> void:
	var background := Image.load_from_file(ProjectSettings.globalize_path(SOURCE + "background_source.png"))
	background.resize(960, 540, Image.INTERPOLATE_NEAREST)
	background.save_png(SOURCE + "background.png")
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE + "flame_source.png"))
	var cells: Array[Image] = []
	var union := Rect2i()
	for index in 8:
		var bounds := Rect2i(index % 4 * source.get_width() / 4, index / 4 * source.get_height() / 2, source.get_width() / 4, source.get_height() / 2)
		var cell := source.get_region(bounds)
		for y in cell.get_height():
			for x in cell.get_width():
				var color := cell.get_pixel(x, y)
				cell.set_pixel(x, y, Color.TRANSPARENT if color.a < .7 else Color(color.r, color.g, color.b, 1))
		union = cell.get_used_rect() if index == 0 else union.merge(cell.get_used_rect())
		cells.append(cell)
	var ratio := minf(60.0 / union.size.x, 68.0 / union.size.y)
	var native_size := Vector2i(roundi(union.size.x * ratio), roundi(union.size.y * ratio))
	var atlas := Image.create(80 * 8, 80, false, Image.FORMAT_RGBA8)
	var registration: Array[Dictionary] = []
	for index in 8:
		var cell := cells[index].get_region(union)
		cell.resize(native_size.x, native_size.y, Image.INTERPOLATE_NEAREST)
		var used := cell.get_used_rect()
		var base_sum := 0
		var base_count := 0
		for y in range(maxi(used.end.y - 5, used.position.y), used.end.y):
			for x in cell.get_width():
				if cell.get_pixel(x, y).a > .9:
					base_sum += x
					base_count += 1
		var origin := Vector2i(40 - roundi(float(base_sum) / maxi(base_count, 1)), 72 - used.end.y)
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, cell.get_size()), origin + Vector2i(index * 80, 0))
		registration.append({"frame": index, "origin": str(origin), "base": 72, "used": str(used)})
	atlas.save_png(SOURCE + "flame.png")
	FileAccess.open(SOURCE + "normalization.json", FileAccess.WRITE).store_string(JSON.stringify({"shared_scale":ratio,"union":str(union),"cell":80,"registration":registration}, "\t"))
	print("CAMPFIRE_BUILD: fixed background; eight genuinely changing flame poses with shared scale and registered base")
	quit()
