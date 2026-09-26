extends SceneTree

const SOURCE := "res://art_source/generated/vfx/king/worldsplitter_summoned_2026_09_27/"
const DEST := "res://assets/vfx/abilities/king/worldsplitter/summoned/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(DEST)
	for kind in ["impact", "summon"]:
		var source := Image.load_from_file(SOURCE+kind+"_source.png")
		source.convert(Image.FORMAT_RGBA8)
		source.resize(1024,1024,Image.INTERPOLATE_NEAREST)
		var output := Image.create(2048,2048,false,Image.FORMAT_RGBA8)
		for index in 16:
			var frame := source.get_region(Rect2i(Vector2i(index%4,index/4)*256,Vector2i(256,256)))
			for y in 256:
				for x in 256:
					var color := frame.get_pixel(x,y)
					if color.a < .65: continue
					color.a = 1.0
					output.set_pixelv(Vector2i(index%4,index/4)*512+Vector2i(128,128)+Vector2i(x,y),color)
		assert(output.save_png(DEST+kind+".png") == OK)
		if kind == "impact":
			for index in [3,4,5,6]:
				print("Impact frame ",index," bounds: ",output.get_region(Rect2i(Vector2i(index%4,index/4)*512,Vector2i(512,512))).get_used_rect())
	print("WORLDSPLITTER_SUMMONED_BUILT")
	quit()
