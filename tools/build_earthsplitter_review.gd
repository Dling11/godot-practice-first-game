extends SceneTree

const DIR := "res://assets/vfx/abilities/king/earthsplitter/"
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(DIR)
	_build("sword", 512)
	_build("rupture", 256)
	print("EARTHSPLITTER_ATLASES_BUILT")
	quit()

func _build(kind: String, size: int) -> void:
	var source := Image.load_from_file("res://art_source/generated/vfx/king/earthsplitter/" + kind + "_source.png")
	source.convert(Image.FORMAT_RGBA8)
	source.resize(1024, 1024, Image.INTERPOLATE_NEAREST)
	var output := Image.create(size * 4, size * 4, false, Image.FORMAT_RGBA8)
	# Register the blade grip through windup, then the actual tip through contact.
	var grips := [Vector2i(184,180), Vector2i(183,180), Vector2i(174,178), Vector2i(171,177), Vector2i(168,174), Vector2i(121,184), Vector2i(92,186)]
	var tips := [Vector2i(172,210), Vector2i(180,204), Vector2i(181,205), Vector2i(184,208), Vector2i(182,208), Vector2i(182,208), Vector2i(182,208), Vector2i(182,208), Vector2i(182,208)]
	for index in 16:
		var cell := Vector2i(index % 4, index / 4)
		var anchor := Vector2i(128, 145 if index < 4 else 148)
		if kind == "sword":
			anchor = grips[index] + Vector2i(110,110) if index < 7 else tips[index-7]
		else:
			anchor.y = 141 if index < 4 else (145 if index < 8 else 143)
		for y in 256:
			for x in 256:
				var color := source.get_pixelv(cell * 256 + Vector2i(x,y))
				if color.a < .05 or maxf(color.r,maxf(color.g,color.b)) < .07:
					continue
				var at := Vector2i(x,y) - anchor + Vector2i(size/2,size/2)
				if Rect2i(0,0,size,size).has_point(at):
					color.a = 1.0
					output.set_pixelv(cell * size + at, color)
	output.save_png(DIR + kind + ".png")

