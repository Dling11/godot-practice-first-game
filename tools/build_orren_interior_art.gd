extends SceneTree

const SOURCE := "res://art_source/generated/environment/sanctuary/orren_interior_2026_10_02/"
const OUTPUT := "res://assets/environment/sanctuary/interiors/orren/v2/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUTPUT)
	var source := Image.load_from_file(SOURCE+"kit_alpha.png")
	source.convert(Image.FORMAT_RGBA8)
	var recipes := [
		["shell",Rect2i(48,24,1440,504),Vector2i(480,168),false],
		["forge",Rect2i(24,530,464,470),Vector2i(56,62),true],
		["workbench",Rect2i(510,684,550,314),Vector2i(56,30),true],
		["rack",Rect2i(1080,634,448,364),Vector2i(48,40),true],
	]
	var manifest: Array[Dictionary] = []
	for recipe in recipes:
		var image := source.get_region(recipe[1])
		image = _binary(image)
		if recipe[3]: image = image.get_region(image.get_used_rect())
		var size: Vector2i = recipe[2]
		if recipe[3]:
			var ratio := minf(float(size.x)/image.get_width(),float(size.y)/image.get_height())
			image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_NEAREST)
		else: image.resize(size.x,size.y,Image.INTERPOLATE_NEAREST)
		assert(image.save_png(OUTPUT+recipe[0]+".png") == OK)
		manifest.append({"name":recipe[0],"source_crop":str(recipe[1]),"size":str(image.get_size()),"binary_alpha":true})
	var file := FileAccess.open(SOURCE+"normalization_v2.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))
	print("ORREN_INTERIOR_ART: ",manifest)
	quit()

func _binary(image: Image) -> Image:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x,y)
			image.set_pixel(x,y,Color(0,0,0,0) if color.a < .65 else Color(color.r,color.g,color.b,1))
	return image
