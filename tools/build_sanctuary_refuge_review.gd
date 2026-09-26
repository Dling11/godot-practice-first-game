extends SceneTree

const SOURCE := "res://art_source/generated/environment/sanctuary/refuge_review_2026_09_27/"
const DEST := "res://assets/environment/sanctuary/refuge_review/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(DEST)
	_build_ground()
	var lodge := _opaque(Image.load_from_file(SOURCE+"lodge_source.png"))
	var bounds := lodge.get_used_rect()
	var crop := lodge.get_region(bounds)
	var ratio := 208.0/float(crop.get_width())
	crop.resize(208,roundi(crop.get_height()*ratio),Image.INTERPOLATE_NEAREST)
	var output := Image.create(256,224,false,Image.FORMAT_RGBA8)
	# Door threshold measured at x=42.2% of the original; preserve that anchor.
	var door_x := roundi((lodge.get_width()*.422-bounds.position.x)*ratio)
	output.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),Vector2i(128-door_x,208-crop.get_height()))
	output.save_png(DEST+"trainer_lodge.png")
	var props := Image.load_from_file(SOURCE+"props_source.png")
	var cell := props.get_size()/2
	var names := ["lantern","planter","bench","wall"]
	var sizes := [Vector2i(28,64),Vector2i(64,36),Vector2i(64,34),Vector2i(80,36)]
	for index in 4:
		var frame := _opaque(props.get_region(Rect2i(Vector2i(index%2,index/2)*cell,cell)))
		frame = frame.get_region(frame.get_used_rect())
		var limit: Vector2i = sizes[index]
		var scale_factor := minf(float(limit.x)/frame.get_width(),float(limit.y)/frame.get_height())
		frame.resize(roundi(frame.get_width()*scale_factor),roundi(frame.get_height()*scale_factor),Image.INTERPOLATE_NEAREST)
		var canvas := Image.create(96,80,false,Image.FORMAT_RGBA8)
		canvas.blit_rect(frame,Rect2i(Vector2i.ZERO,frame.get_size()),Vector2i(48-frame.get_width()/2,72-frame.get_height()))
		canvas.save_png(DEST+names[index]+".png")
	print("SANCTUARY_REFUGE_ASSETS_BUILT")
	quit()

func _opaque(image: Image) -> Image:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			# Reject soft generated halos before bounds/cropping; retain hard contours.
			if c.a < .85: c = Color(0,0,0,0)
			else: c.a = 1.0
			image.set_pixel(x,y,c)
	return image

func _build_ground() -> void:
	var source := Image.load_from_file(SOURCE+"ground_source.png")
	source.convert(Image.FORMAT_RGBA8)
	source.resize(128,128,Image.INTERPOLATE_NEAREST)
	var atlas := Image.create(128,256,false,Image.FORMAT_RGBA8)
	var grass_average := Color(0,0,0,1)
	for y in 32:
		for x in 128:
			var c := source.get_pixel(x,y)
			grass_average.r += c.r/4096.0
			grass_average.g += c.g/4096.0
			grass_average.b += c.b/4096.0
	for y in 128:
		for x in 128:
			var c := source.get_pixel(x,y)
			if y < 32: c = grass_average.lerp(c,.40)
			c.a = 1.0
			atlas.set_pixel(x,y,c)
	# Sixteen cardinal edge tiles. Their interiors use the generated stone;
	# a small irregular earth edge joins it to the same normalized meadow.
	for mask in 16:
		for y in 32:
			for x in 32:
				var edge := 3+((x*7+y*11)%3)
				var distance := 99
				if not mask&1: distance = mini(distance,y)
				if not mask&2: distance = mini(distance,31-x)
				if not mask&4: distance = mini(distance,31-y)
				if not mask&8: distance = mini(distance,x)
				var c := atlas.get_pixel(x,64+y)
				if distance < edge: c = atlas.get_pixel(x,y)
				elif distance == edge: c = atlas.get_pixel(x,32+y).darkened(.12)
				atlas.set_pixel((mask%4)*32+x,(4+mask/4)*32+y,c)
	atlas.save_png(DEST+"ground_32.png")
