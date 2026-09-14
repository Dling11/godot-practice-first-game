extends SceneTree

const SOURCE := "res://art_source/generated/vfx/king/riftbreak_review_2026_09_14/rupture_source.png"
const OUT := "res://assets/vfx/abilities/king/riftbreak_review/"


func _initialize() -> void:
	var source := Image.load_from_file(SOURCE)
	source.convert(Image.FORMAT_RGBA8)
	source.resize(1024, 1024, Image.INTERPOLATE_NEAREST)
	var atlas := Image.create(1024, 1024, false, Image.FORMAT_RGBA8)
	# Authored source contact anchors; never center on flying-debris bounds.
	var anchors := [158, 158, 158, 158, 194, 194, 194, 194, 180, 180, 180, 180, 162, 162, 162, 162]
	for index in 16:
		var cell := Vector2i(index % 4, index / 4) * 256
		for y in 256:
			for x in 256:
				var color := source.get_pixelv(cell + Vector2i(x, y))
				if maxf(color.r, maxf(color.g, color.b)) <= .045:
					continue
				var destination := Vector2i(x, y + 128 - anchors[index])
				if Rect2i(0, 0, 256, 256).has_point(destination):
					color.a = 1.0
					atlas.set_pixelv(cell + destination, color)
	DirAccess.make_dir_recursive_absolute(OUT)
	atlas.save_png(OUT + "rupture_256.png")
	print("RIFTBREAK_REVIEW_ATLAS_BUILT")
	quit()
