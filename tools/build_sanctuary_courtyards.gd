extends SceneTree

## Offline crop/nearest normalization; generated originals are retained unchanged.
const SOURCE := "res://art_source/generated/"
var manifest: Array[Dictionary] = []

func _initialize() -> void:
	_actor("nema", "rootweaver", false)
	if FileAccess.file_exists(SOURCE + "characters/npcs/umi/renewal_2026_10_01/work_source.png"):
		_actor("umi", "umi", true)
	_courier()
	_birds()
	var file := FileAccess.open(SOURCE + "environment/sanctuary/courtyards_2026_10_01/normalization.json", FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest, "\t"))
	print("COURTYARD_ART_BUILT: ", manifest)
	quit()

func _actor(identity: String, folder: String, hat: bool) -> void:
	var source := Image.load_from_file(SOURCE + "characters/npcs/" + identity + "/renewal_2026_10_01/work_source.png")
	var poses := _cells(source, 4, 2)
	var ratio := (66.0 if hat else 60.0) / poses[0].get_used_rect().size.y
	var atlas := Image.create(384, 192, false, Image.FORMAT_RGBA8)
	for index in 8:
		var pose := poses[index].duplicate() as Image
		pose.resize(roundi(pose.get_width()*ratio), roundi(pose.get_height()*ratio), Image.INTERPOLATE_NEAREST)
		var bounds := pose.get_used_rect()
		var feet := pose.get_region(Rect2i(0, bounds.end.y-8, pose.get_width(), 8)).get_used_rect()
		var offset := Vector2i(48-feet.get_center().x, 80-bounds.end.y)
		assert(bounds.position.y+offset.y > 2)
		atlas.blit_rect(pose, Rect2i(Vector2i.ZERO, pose.get_size()), Vector2i(index%4,index/4)*96+offset)
		manifest.append({"identity":identity,"frame":index,"bounds":str(Rect2i(bounds.position+offset,bounds.size)),"scale":ratio})
	var output := "res://assets/characters/npcs/"+folder+"/renewal/"
	DirAccess.make_dir_recursive_absolute(output)
	assert(atlas.save_png(output+"idle_work.png") == OK)
	# Portrait derives from the same generated character, preserving identity.
	var bounds := poses[0].get_used_rect()
	var side := mini(poses[0].get_width(), roundi(bounds.size.y*.72))
	var region := Rect2i(clampi(bounds.get_center().x-side/2,0,poses[0].get_width()-side),maxi(0,bounds.position.y-5),side,side)
	var portrait := poses[0].get_region(region)
	portrait.resize(96,96,Image.INTERPOLATE_NEAREST)
	assert(portrait.save_png(output+"portrait.png") == OK)

func _courier() -> void:
	var source := Image.load_from_file(SOURCE+"characters/npcs/courier/locomotion_v2_2026_10_01/walk_source.png")
	var poses := _cells(source,4,4)
	var ratio := 58.0/poses[0].get_used_rect().size.y
	var vertical := _cells(Image.load_from_file(SOURCE+"characters/npcs/courier/locomotion_v2_2026_10_01/vertical_source.png"),4,2)
	var vertical_ratio := 58.0/vertical[0].get_used_rect().size.y
	var atlas := Image.create(384,384,false,Image.FORMAT_RGBA8)
	for index in 16:
		var pose := poses[index]
		var factor := ratio
		if index < 4 or index >= 12:
			pose = vertical[index if index < 4 else index-8]
			factor = vertical_ratio
		pose.resize(roundi(pose.get_width()*factor),roundi(pose.get_height()*factor),Image.INTERPOLATE_NEAREST)
		var bounds := pose.get_used_rect()
		var offset := Vector2i(48-bounds.get_center().x,80-bounds.end.y)
		atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i(index%4,index/4)*96+offset)
		manifest.append({"identity":"courier_v2","frame":index,"bounds":str(Rect2i(bounds.position+offset,bounds.size)),"scale":factor})
	assert(atlas.save_png("res://assets/characters/npcs/courier/walk_v2.png") == OK)
	var first := atlas.get_region(Rect2i(0,0,96,96))
	var face := first.get_region(Rect2i(28,18,40,40))
	face.resize(96,96,Image.INTERPOLATE_NEAREST)
	assert(face.save_png("res://assets/characters/npcs/courier/portrait.png") == OK)

func _birds() -> void:
	var source := Image.load_from_file(SOURCE+"environment/sanctuary/courtyards_2026_10_01/swallow_source.png")
	var poses := _cells(source,4,1)
	var ratio := 32.0/poses[0].get_used_rect().size.x
	var atlas := Image.create(160,40,false,Image.FORMAT_RGBA8)
	for index in 4:
		var pose := poses[index]
		pose.resize(roundi(pose.get_width()*ratio),roundi(pose.get_height()*ratio),Image.INTERPOLATE_NEAREST)
		# Source beak is near each cell's right edge and body near 57% image height.
		var bounds := pose.get_used_rect()
		var offset := Vector2i(36-bounds.end.x,24-roundi(pose.get_height()*.57))
		atlas.blit_rect(pose,Rect2i(Vector2i.ZERO,pose.get_size()),Vector2i(index*40,0)+offset)
	DirAccess.make_dir_recursive_absolute("res://assets/environment/sanctuary/courtyards/")
	assert(atlas.save_png("res://assets/environment/sanctuary/courtyards/swallow.png") == OK)

func _cells(source: Image, columns: int, rows: int) -> Array[Image]:
	var poses: Array[Image] = []
	for row in rows:
		for column in columns:
			var start := Vector2i(roundi(column*source.get_width()/float(columns)),roundi(row*source.get_height()/float(rows)))
			var end := Vector2i(roundi((column+1)*source.get_width()/float(columns)),roundi((row+1)*source.get_height()/float(rows)))
			poses.append(_binary(source.get_region(Rect2i(start,end-start))))
	return poses

func _binary(source: Image) -> Image:
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var c := source.get_pixel(x,y)
			source.set_pixel(x,y,Color(0,0,0,0) if c.a < .65 else Color(c.r,c.g,c.b,1))
	return source
