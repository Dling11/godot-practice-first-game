extends SceneTree

## Offline atlas registration only. Source drawings come from image generation.
const SOURCE := "res://art_source/generated/vfx/king/molten_crash_2026_09_26/"
const DEST := "res://assets/vfx/abilities/king/molten_crash/"
func _initialize() -> void:
	for kind in ["sword","burst","aftershock","caldera_core"]:
		var source := Image.load_from_file(SOURCE+kind+"_source.png")
		source.convert(Image.FORMAT_RGBA8)
		source.resize(1024,1024,Image.INTERPOLATE_NEAREST)
		var output := Image.create(2048,2048,false,Image.FORMAT_RGBA8)
		for index in 16:
			var cell := Vector2i(index%4,index/4)
			var anchor := Vector2i(128,[174,181,170,156][index/4])
			if kind=="sword":
				anchor.y = [223,228,224,222,226,226,232,244,232,236,232,224,232,232,222,218][index]
			elif kind=="aftershock":
				anchor.y = [180,174,160,150][index/4]
			elif kind=="caldera_core":
				anchor.y = [180,186,185,180][index/4]
			for y in 256:
				for x in 256:
					var color := source.get_pixelv(cell*256+Vector2i(x,y))
					if color.a<.5:
						continue
					color.a = 1.0
					output.set_pixelv(cell*512+Vector2i(256,256)+Vector2i(x,y)-anchor,color)
		output.save_png(DEST+kind+".png")
	print("MOLTEN_CRASH_ATLASES_BUILT")
	quit()
