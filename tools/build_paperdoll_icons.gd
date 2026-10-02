extends SceneTree

const SOURCE := "res://art_source/generated/ui/centered_paperdoll_2026_10_02/"
const OUTPUT := "res://assets/ui/inventory/"
const NAMES := ["head", "weapon", "plate", "bracer", "gloves", "amulet", "leggings", "ring", "boots", "talisman"]
# Source gutters inspected before packing; generated rows are not exact fifths.
const ROW_EDGES := [0, 380, 675, 981, 1265, 1536]

func _initialize() -> void:
	var source := Image.load_from_file(SOURCE + "icons_source.png")
	assert(source != null)
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x, y)
			source.set_pixel(x, y, Color.TRANSPARENT if color.a < .65 else Color(color.r, color.g, color.b, 1))
	var cells := []
	for index in NAMES.size():
		var row: int = index / 2
		var column := index % 2
		var x := roundi(column * source.get_width() / 2.0)
		var y: int = ROW_EDGES[row]
		var bottom: int = ROW_EDGES[row + 1]
		var cell := Rect2i(x, y, source.get_width() / 2, bottom - y)
		var image := source.get_region(cell)
		var crop := image.get_used_rect()
		assert(crop.has_area(), "Empty icon: " + NAMES[index])
		var icon := image.get_region(crop)
		_write_icon(icon, 24, OUTPUT + "slot_" + NAMES[index] + ".png")
		if index == 1:
			_write_icon(icon, 64, OUTPUT + "king_sword_64.png")
		cells.append({"name": NAMES[index], "cell": str(cell), "crop": str(crop)})
	var manifest := FileAccess.open(SOURCE + "icons_normalization.json", FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"source_size": str(source.get_size()), "cells": cells, "slot_size": "24x24", "sword_size": "64x64", "alpha": "binary", "sampling": "nearest", "aspect": "preserved"}, "\t"))
	print("PAPERDOLL_ICONS: ten 24px icons and 64px signature sword")
	quit()

func _write_icon(source: Image, edge: int, path: String) -> void:
	var icon := source.duplicate() as Image
	var factor := float(edge) / maxi(icon.get_width(), icon.get_height())
	icon.resize(maxi(1, roundi(icon.get_width() * factor)), maxi(1, roundi(icon.get_height() * factor)), Image.INTERPOLATE_NEAREST)
	var canvas := Image.create(edge, edge, false, Image.FORMAT_RGBA8)
	canvas.fill(Color.TRANSPARENT)
	canvas.blit_rect(icon, Rect2i(Vector2i.ZERO, icon.get_size()), (Vector2i(edge, edge) - icon.get_size()) / 2)
	assert(canvas.save_png(path) == OK)
