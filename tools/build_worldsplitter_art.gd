extends SceneTree

## Offline registration of generated drawings, never procedural replacement art.
const SOURCE := "res://art_source/generated/vfx/king/worldsplitter_detail_2026_09_27/"
const DEST := "res://assets/vfx/abilities/king/worldsplitter/detailed/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(DEST)
	for kind in ["sword", "ground"]:
		var source := Image.load_from_file(SOURCE+kind+"_source.png")
		source.convert(Image.FORMAT_RGBA8)
		source.resize(1024,1024,Image.INTERPOLATE_NEAREST)
		var output := Image.create(2048,2048,false,Image.FORMAT_RGBA8)
		for index in 16:
			var origin := Vector2i(index%4,index/4)*256
			var frame := source.get_region(Rect2i(origin,Vector2i(256,256)))
			var anchor := Vector2i(128,219)
			if kind == "sword" and index < 10:
				# Tip/core rather than scattered aura motes establishes contact.
				var tip := 0
				for y in 248:
					for x in range(122,135):
						var color := frame.get_pixel(x,y)
						if color.a > .7 and color.r > .65 and color.g > .7: tip = maxi(tip,y)
				if tip > 0: anchor.y = tip
			elif kind == "ground":
				anchor.y = roundi([224,224,228,232,222,218,224,222,202,206,208,204,190,190,190,190][index]*.8)
				frame.resize(205,205,Image.INTERPOLATE_NEAREST)
				anchor = Vector2i(Vector2(anchor)*.8)
			for y in frame.get_height():
				for x in frame.get_width():
					var color := frame.get_pixel(x,y)
					if color.a < .55: continue
					color.a = 1.0
					output.set_pixelv(Vector2i(index%4,index/4)*512+Vector2i(256,256)+Vector2i(x,y)-anchor,color)
			print(kind," frame ",index," anchor ",anchor)
		assert(output.save_png(DEST+kind+".png") == OK)
	print("WORLDSPLITTER_ART_BUILT")
	quit()
