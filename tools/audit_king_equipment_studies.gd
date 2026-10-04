extends SceneTree

## Offline source audit only. Never imports, registers, or promotes character art.
const SOURCE := "res://art_source/generated/characters/king/equipment_families_2026_10_04/"
const FAMILIES := ["sword", "greatsword", "dual_swords", "axe", "scythe", "armor"]

func _initialize() -> void:
	var records: Array[Dictionary] = []
	for family in FAMILIES:
		var source := Image.load_from_file(SOURCE + family + "/source.png")
		if source == null or source.is_empty():
			push_error("Missing equipment source: " + family)
			quit(1)
			return
		var columns := 3 if family == "armor" else 4
		var rows := 3
		var fractional_alpha := 0
		var opaque_pixels := 0
		var transparent_pixels := 0
		for y in source.get_height():
			for x in source.get_width():
				var alpha := source.get_pixel(x, y).a
				if alpha == 0.0:
					transparent_pixels += 1
				elif alpha == 1.0:
					opaque_pixels += 1
				else:
					fractional_alpha += 1
		var cells: Array[Dictionary] = []
		for row in rows:
			for column in columns:
				var start := Vector2i(column * source.get_width() / columns, row * source.get_height() / rows)
				var end := Vector2i((column + 1) * source.get_width() / columns, (row + 1) * source.get_height() / rows)
				var crop := Rect2i(start, end - start)
				# Ignore faint generation residue when measuring occupied content. The
				# original remains unchanged; raw alpha counts above include all residue.
				var measured := source.get_region(crop)
				measured.convert(Image.FORMAT_RGBA8)
				for y in measured.get_height():
					for x in measured.get_width():
						if measured.get_pixel(x, y).a < 0.65:
							measured.set_pixel(x, y, Color.TRANSPARENT)
				var bounds := measured.get_used_rect()
				var touches_edge := bounds.has_area() and (bounds.position.x == 0 or bounds.position.y == 0 or bounds.end.x == crop.size.x or bounds.end.y == crop.size.y)
				cells.append({"index": row * columns + column, "nominal_crop": [start.x, start.y, crop.size.x, crop.size.y], "used_bounds": [bounds.position.x, bounds.position.y, bounds.size.x, bounds.size.y], "touches_nominal_edge": touches_edge})
		var record := {"family": family, "source_size": [source.get_width(), source.get_height()], "nominal_grid": [columns, rows], "exact_grid_divisibility": source.get_width() % columns == 0 and source.get_height() % rows == 0, "opaque_pixels": opaque_pixels, "transparent_pixels": transparent_pixels, "fractional_alpha_pixels": fractional_alpha, "cells": cells, "runtime_ready": false}
		records.append(record)
		print("EQUIPMENT_SOURCE ", family, " size=", source.get_size(), " fractional_alpha=", fractional_alpha, " edge_cells=", cells.filter(func(cell: Dictionary) -> bool: return cell.touches_nominal_edge).size())
	var file := FileAccess.open(SOURCE + "source_audit.json", FileAccess.WRITE)
	if file == null:
		push_error("Cannot write equipment source audit")
		quit(1)
		return
	file.store_string(JSON.stringify({"status": "concept studies, not runtime sprites", "method": "raw alpha counts; occupied bounds at alpha >= 0.65 in equal nominal cells; no anatomical segmentation or registration", "bounds_alpha_threshold": 0.65, "sources": records}, "\t") + "\n")
	quit()
