extends SceneTree

const ROOT := "res://art_source/generated/characters/king/equipment_design_v2_2026_10_04/"

func _initialize() -> void:
	var records: Array[Dictionary] = []
	for family in ["armor", "axe", "scythe"]:
		var path: String = ROOT + family + "/source.png"
		if not FileAccess.file_exists(path):
			continue
		var source := Image.load_from_file(path)
		var fractional := 0
		var transparent := 0
		var opaque := 0
		for y in source.get_height():
			for x in source.get_width():
				var alpha := source.get_pixel(x, y).a
				if alpha == 0.0:
					transparent += 1
				elif alpha == 1.0:
					opaque += 1
				else:
					fractional += 1
		var samples: Array[Dictionary] = []
		for point in [Vector2i(0, 0), Vector2i(50, 300), Vector2i(180, 500), Vector2i(source.get_width() / 2, source.get_height() / 2)]:
			var color := source.get_pixelv(point)
			samples.append({"position": [point.x, point.y], "rgba": [color.r, color.g, color.b, color.a]})
		var record := {"study": family, "size": [source.get_width(), source.get_height()], "opaque_pixels": opaque, "transparent_pixels": transparent, "fractional_alpha_pixels": fractional, "samples": samples, "runtime_ready": false}
		records.append(record)
		print("DESIGN_SOURCE ", JSON.stringify(record))
	FileAccess.open(ROOT + "source_audit.json", FileAccess.WRITE).store_string(JSON.stringify({"status": "appearance/weapon-only studies; not runtime assets", "sources": records}, "\t") + "\n")
	quit()
