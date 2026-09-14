extends SceneTree

## Packs the new ground sheet only. The approved sword atlas is untouched.
func _initialize() -> void:
	var source := Image.load_from_file("res://art_source/generated/vfx/king/earthsplitter/pressure_source_v2.png")
	source.convert(Image.FORMAT_RGBA8)
	source.resize(2048,1280,Image.INTERPOLATE_NEAREST)
	var output := Image.create(2048,1280,false,Image.FORMAT_RGBA8)
	for row in 5:
		for frame in 8:
			var cell := Vector2i(frame,row)*256
			# Center on each row's visible ground contact, not airborne flecks.
			var contact := Vector2i(128, [146,124,165,133,163][row])
			for y in 256:
				for x in 256:
					var color := source.get_pixelv(cell + Vector2i(x,y))
					if color.a < .1 or maxf(color.r,maxf(color.g,color.b)) < .12:
						continue
					var at := Vector2i(x,y)-contact+Vector2i(128,128)
					if Rect2i(3,3,250,250).has_point(at):
						# Remove the almost-black baked halo and keep pixel alpha.
						color.a = 1.0
						output.set_pixelv(cell+at,color)
	output.save_png("res://assets/vfx/abilities/king/earthsplitter/pressure_v2.png")
	print("EARTHSPLITTER_PRESSURE_BUILT")
	quit()

