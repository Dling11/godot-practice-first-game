extends SceneTree

const SOURCE := "res://art_source/generated/environment/chests/renewal_2026_10_03/"
const OUTPUT := "res://assets/gameplay/loot/stage_clear_chest/renewed/"

func _initialize() -> void:
	call_deferred("_build")

func _build() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var source := Image.load_from_file(SOURCE+"chests_source.png")
	source.convert(Image.FORMAT_RGBA8)
	var manifest: Array[Dictionary] = []
	var specs := [
		["forest",Vector2i(64,48),Vector2i(58,40),43],
		["rootbound",Vector2i(72,64),Vector2i(66,54),60],
		["varkuun",Vector2i(74,66),Vector2i(68,58),63],
	]
	for row in 3:
		var cells: Array[Image] = []
		var maximum := Vector2i.ZERO
		for column in 2:
			var left := floori(float(column)*source.get_width()/2)
			var right := floori(float(column+1)*source.get_width()/2)
			var top := floori(float(row)*source.get_height()/3)
			var bottom := floori(float(row+1)*source.get_height()/3)
			var image := source.get_region(Rect2i(left,top,right-left,bottom-top))
			assert(image.get_pixel(0,0).a < .7)
			for y in image.get_height():
				for x in image.get_width():
					var color := image.get_pixel(x,y)
					image.set_pixel(x,y,Color.TRANSPARENT if color.a < .7 else Color(color.r,color.g,color.b,1))
			image = image.get_region(image.get_used_rect())
			maximum.x = maxi(maximum.x,image.get_width())
			maximum.y = maxi(maximum.y,image.get_height())
			cells.append(image)
		var spec: Array = specs[row]
		var canvas: Vector2i = spec[1]
		var limit: Vector2i = spec[2]
		var ratio := minf(float(limit.x)/maximum.x,float(limit.y)/maximum.y)
		for column in 2:
			var image := cells[column]
			image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_NEAREST)
			var output := Image.create(canvas.x,canvas.y,false,Image.FORMAT_RGBA8)
			var origin := Vector2i((canvas.x-image.get_width())/2,int(spec[3])-image.get_height())
			output.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),origin)
			var key: String = spec[0]+("_closed" if column == 0 else "_open")
			assert(output.save_png(OUTPUT+key+".png") == OK)
			manifest.append({"key":key,"size":str(image.get_size()),"origin":str(origin),"pair_scale":ratio})
	FileAccess.open(SOURCE+"normalization.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
	print("CHEST_ART: six states, pair scale retained, binary alpha and fixed feet")
	quit()
