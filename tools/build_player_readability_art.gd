extends SceneTree

const SOURCE := "res://art_source/generated/ui/player_readability_2026_10_02/"
const OUTPUT := "res://assets/ui/player_readability/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var records: Array[Dictionary] = []
	for recipe in [["vitality",Vector2i(288,104)],["satchel",Vector2i(24,24)]]:
		var source := Image.load_from_file(SOURCE+recipe[0]+"_source.png")
		source.convert(Image.FORMAT_RGBA8)
		for y in source.get_height():
			for x in source.get_width():
				var color := source.get_pixel(x,y)
				source.set_pixel(x,y,Color.TRANSPARENT if color.a < .65 else Color(color.r,color.g,color.b,1))
		var used := source.get_used_rect()
		var image := source.get_region(used)
		var target: Vector2i = recipe[1]
		if recipe[0] == "satchel":
			var ratio := minf(float(target.x)/image.get_width(),float(target.y)/image.get_height())
			image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_NEAREST)
			var canvas := Image.create(target.x,target.y,false,Image.FORMAT_RGBA8)
			canvas.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),(target-image.get_size())/2)
			image = canvas
		else:
			image.resize(target.x,target.y,Image.INTERPOLATE_NEAREST)
		for y in image.get_height():
			for x in image.get_width():
				var color := image.get_pixel(x,y)
				image.set_pixel(x,y,Color.TRANSPARENT if color.a < .65 else Color(color.r,color.g,color.b,1))
		assert(image.save_png(OUTPUT+recipe[0]+".png") == OK)
		records.append({"asset":recipe[0],"source_size":str(source.get_size()),"crop":str(used),"size":str(target),"alpha":"binary","sampling":"nearest"})
	var manifest := FileAccess.open(SOURCE+"normalization.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify(records,"\t"))
	print("PLAYER_READABILITY_ART: ",records)
	quit()
