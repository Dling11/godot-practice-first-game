extends SceneTree

## Offline atlas normalization and authored scene bake. Never generates at runtime.
const SOURCE := "res://art_source/generated/environment/forest/grove_renewal_2026_10_02/"
const OUTPUT := "res://assets/environment/forest/grove_renewal/"
const PROPS := "res://environment/props/woodland/"
const SCENE := "res://levels/test_arena/test_arena.tscn"
const PropScript = preload("res://environment/props/woodland/woodland_prop.gd")
const Cutout = preload("res://gameplay/navigation/navigation_cutout.gd")

func _initialize() -> void:
	call_deferred("_build")

func _build() -> void:
	_normalize_art()
	if "--art-only" in OS.get_cmdline_user_args():
		quit()
		return
	var scene: Node = load(SCENE).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground: TileMapLayer = scene.get_node("World/Level/Ground")
	_build_ground(ground)
	var actors := scene.get_node("World/Actors")
	for child in actors.get_children():
		if child is StaticBody2D:
			actors.remove_child(child)
			child.free()
	# The approach, central glade and threshold stay broad. Groups explain the
	# terrain: woodland edge, fallen-log pocket, then an old paired-stone shrine.
	var placements := [
		["oak",390,820,"AncientTreeSouthWest"], ["oak",510,420,"AncientTreeWest"],
		["fir",1420,440,"AncientTreeEast"], ["oak",680,210,"AncientTreeNorthWest"],
		["fir",1250,220,"AncientTreeNorthEast"],
		["waystone",832,416,"WestGateShrine"], ["waystone",1088,416,"EastGateShrine"],
		["oak",736,1008], ["fir",1168,1024], ["oak",704,680], ["fir",1216,704],
		["fir",304,744], ["fir",432,352], ["oak",1504,512], ["oak",1520,816],
		["fir",1648,868], ["oak",416,176], ["fir",1440,208],
		["fir",176,384], ["oak",1760,368], ["oak",192,896], ["fir",1744,1072],
		["oak",576,1088], ["fir",1360,1104], ["fir",928,176],
		["boulder",336,864], ["log",440,764], ["boulder",536,476],
		["log",728,848], ["boulder",1152,824], ["log",1408,776],
		["boulder",1504,560], ["boulder",688,264], ["boulder",1272,284],
		["masonry",784,344], ["masonry",1136,344],
		["fern",432,840], ["fern",360,744], ["fern",552,408], ["fern",472,360],
		["fern",736,700], ["fern",664,644], ["fern",752,1000], ["fern",688,1024],
		["fern",1176,712], ["fern",1232,672], ["fern",1192,1008],
		["fern",1472,480], ["fern",1440,432], ["fern",1480,832],
		["fern",792,432], ["fern",1136,440], ["fern",736,288], ["fern",1200,272],
		["mushrooms",720,860], ["mushrooms",1168,840], ["mushrooms",424,824],
		["mushrooms",536,440], ["mushrooms",1200,720], ["mushrooms",1440,792],
		["mushrooms",1104,424], ["mushrooms",808,400],
		["fir",112,160], ["oak",208,240], ["fir",96,480], ["oak",224,656],
		["oak",104,752], ["fir",272,1040], ["oak",432,1080],
		["oak",1760,144], ["fir",1840,256], ["oak",1760,576], ["fir",1840,704],
		["oak",1760,848], ["oak",1552,1080], ["fir",1856,992],
		["fir",336,112], ["oak",536,144], ["fir",768,112], ["oak",1120,144],
		["oak",1360,128], ["fir",1616,160], ["oak",352,544], ["fir",1600,688],
		["fern",256,660], ["fern",128,772], ["fern",1704,592], ["fern",1520,1072],
	]
	for index in placements.size():
		var spec: Array = placements[index]
		var prop: StaticBody2D = load(PROPS+spec[0]+".tscn").instantiate()
		prop.name = spec[3] if spec.size() > 3 else "%s_%02d" % [spec[0].capitalize(),index]
		prop.position = Vector2(spec[1],spec[2])
		prop.phase = float(index)*1.7
		actors.add_child(prop)
		prop.owner = scene
	var previous := scene.get_node_or_null("World/GroveAmbience")
	if previous != null:
		previous.get_parent().remove_child(previous)
		previous.free()
	var ambience := Node2D.new()
	ambience.name = "GroveAmbience"
	ambience.set_script(preload("res://environment/props/woodland/grove_ambience.gd"))
	scene.get_node("World").add_child(ambience)
	ambience.owner = scene
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,SCENE) == OK)
	print("STAGE_1_RENEWAL_BAKED: ",ground.get_used_cells().size()," cells, ",placements.size()," props")
	scene.free()
	quit()

func _normalize_art() -> void:
	var source := Image.load_from_file(SOURCE+"props_source.png")
	var specs := [
		["oak",Rect2i(0,40,384,540),Vector2i(96,112),Vector2(18,14),true],
		["fir",Rect2i(392,40,384,540),Vector2i(80,128),Vector2(16,14),true],
		["waystone",Rect2i(800,150,336,430),Vector2i(38,60),Vector2(28,16),false],
		["boulder",Rect2i(1160,260,376,320),Vector2i(44,30),Vector2(36,18),false],
		["log",Rect2i(0,640,384,384),Vector2i(64,36),Vector2(48,18),false],
		["masonry",Rect2i(408,640,368,384),Vector2i(64,36),Vector2(50,18),false],
		["fern",Rect2i(800,640,336,384),Vector2i(32,26),Vector2.ZERO,true],
		["mushrooms",Rect2i(1192,640,344,384),Vector2i(24,20),Vector2.ZERO,false],
	]
	var manifest: Array[Dictionary] = []
	for spec: Array in specs:
		var image := source.get_region(spec[1])
		image.convert(Image.FORMAT_RGBA8)
		for y in image.get_height():
			for x in image.get_width():
				var color := image.get_pixel(x,y)
				image.set_pixel(x,y,Color.TRANSPARENT if color.a < .7 else Color(color.r,color.g,color.b,1))
		image = image.get_region(image.get_used_rect())
		var ratio: float = minf(float(spec[2].x)/image.get_width(),float(spec[2].y)/image.get_height())
		image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_NEAREST)
		assert(image.save_png(OUTPUT+spec[0]+".png") == OK)
		manifest.append({"asset":spec[0],"crop":str(spec[1]),"native_size":str(image.get_size()),"alpha_threshold":.7})
		# Art-only pass lets the editor import textures before the scene bake.
		if not "--art-only" in OS.get_cmdline_user_args(): _save_prop(spec,image.get_size())
	var file := FileAccess.open(SOURCE+"normalization.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))
	_build_terrain_atlas()

func _build_terrain_atlas() -> void:
	# Native art is reused; sixteen dual-grid transition masks feather dirt into
	# the same meadow. This import-time derivative never paints at runtime.
	var source := Image.load_from_file("res://assets/environment/sanctuary/refuge_review/ground_32.png")
	var atlas := Image.create(128,384,false,Image.FORMAT_RGBA8)
	atlas.blit_rect(source,Rect2i(0,0,128,256),Vector2i.ZERO)
	for mask in 16:
		for y in 32:
			for x in 32:
				var u := float(x)/31.0
				var v := float(y)/31.0
				var top := lerpf(float(mask&1 != 0),float(mask&2 != 0),u)
				var bottom := lerpf(float(mask&8 != 0),float(mask&4 != 0),u)
				var coverage := lerpf(top,bottom,v)
				var roughness := float(posmod(x*7+y*11,5)-2)*.025
				var pixel := source.get_pixel(x,y)
				if coverage > .5+roughness: pixel = source.get_pixel(x,32+y)
				elif coverage > .43+roughness: pixel = pixel.darkened(.07)
				atlas.set_pixel((mask%4)*32+x,(8+mask/4)*32+y,pixel)
	assert(atlas.save_png(OUTPUT+"ground_32.png") == OK)

func _save_prop(spec: Array, size: Vector2i) -> void:
	var prop := StaticBody2D.new()
	prop.name = spec[0].capitalize()
	prop.set_script(PropScript)
	prop.foliage = spec[4]
	prop.collision_layer = 1 if spec[3] != Vector2.ZERO else 0
	prop.collision_mask = 0
	prop.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = load(OUTPUT+spec[0]+".png")
	sprite.position = Vector2(0,-size.y*.5+5)
	prop.add_child(sprite)
	sprite.owner = prop
	if spec[3] != Vector2.ZERO:
		var collision := CollisionShape2D.new()
		collision.name = "Footprint"
		var shape := RectangleShape2D.new()
		shape.size = spec[3]
		collision.shape = shape
		collision.position.y = -2
		prop.add_child(collision)
		collision.owner = prop
		var cutout := Node.new()
		cutout.name = "NavigationCutout"
		cutout.set_script(Cutout)
		cutout.derive_from_collision_shapes = true
		cutout.add_to_group("navigation_cutout",true)
		prop.add_child(cutout)
		cutout.owner = prop
	if spec[4] and size.y > 80:
		var area := Area2D.new()
		area.name = "CanopyFade"
		area.collision_layer = 0
		area.collision_mask = 2
		prop.add_child(area)
		area.owner = prop
		var collision := CollisionShape2D.new()
		collision.name = "CanopyVolume"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(size.x*.9,size.y*.7)
		collision.shape = shape
		collision.position.y = -size.y*.5
		area.add_child(collision)
		collision.owner = prop
	var packed := PackedScene.new()
	assert(packed.pack(prop) == OK)
	assert(ResourceSaver.save(packed,PROPS+spec[0]+".tscn") == OK)
	prop.free()

func _build_ground(ground: TileMapLayer) -> void:
	var tile_set := TileSet.new()
	tile_set.tile_size = Vector2i(32,32)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load(OUTPUT+"ground_32.png")
	atlas.texture_region_size = Vector2i(32,32)
	for y in 12:
		for x in 4: atlas.create_tile(Vector2i(x,y))
	tile_set.add_source(atlas,0)
	assert(ResourceSaver.save(tile_set,OUTPUT+"grove_ground_tileset.tres") == OK)
	ground.tile_set = load(OUTPUT+"grove_ground_tileset.tres")
	var layout := AuthoredGroundLayout.new()
	layout.map_size = Vector2i(60,36)
	var legend := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV"
	for index in 48: layout.tile_legend[legend[index]] = Vector2i(index%4,index/4)
	# One worn approach with two curved glade loops and a compact shrine apron.
	var paths := [
		PackedVector2Array([Vector2(960,1152),Vector2(944,960),Vector2(1008,816),Vector2(960,688),Vector2(912,576),Vector2(960,416)]),
		PackedVector2Array([Vector2(992,816),Vector2(832,800),Vector2(624,736),Vector2(576,576),Vector2(528,480)]),
		PackedVector2Array([Vector2(928,592),Vector2(1136,624),Vector2(1344,640),Vector2(1424,560)]),
	]
	var stones := {}
	for y in 36:
		for x in 60:
			var cell := Vector2i(x,y)
			var p := Vector2(cell*32)+Vector2(16,16)
			if ((p-Vector2(960,352))/Vector2(176,96)).length_squared() < 1: stones[cell] = true
	for y in 36:
		var row := ""
		for x in 60:
			var cell := Vector2i(x,y)
			var p := Vector2(cell*32)+Vector2(16,16)
			var variant := posmod(x*17+y*29+x*y,4)
			var coordinate := Vector2i(variant,0)
			var dirt_mask := 0
			var corners := [Vector2(0,0),Vector2(32,0),Vector2(32,32),Vector2(0,32)]
			for corner in 4:
				var point: Vector2 = Vector2(cell*32)+corners[corner]
				var distance := INF
				for path: PackedVector2Array in paths:
					for index in path.size()-1:
						distance = minf(distance,point.distance_to(Geometry2D.get_closest_point_to_segment(point,path[index],path[index+1])))
				if distance < 34: dirt_mask |= 1<<corner
			if dirt_mask > 0: coordinate = Vector2i(dirt_mask%4,8+dirt_mask/4)
			if dirt_mask == 15: coordinate = Vector2i(variant,1)
			if stones.has(cell):
				var mask := 0
				for index in 4:
					if stones.has(cell+[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT][index]): mask |= 1<<index
				coordinate = Vector2i(mask%4,4+mask/4) if mask != 15 else Vector2i(variant,3)
			row += legend[coordinate.y*4+coordinate.x]
		layout.rows.append(row)
	assert(ResourceSaver.save(layout,"res://data/environment/layouts/stage_1_forest_ground.tres") == OK)
	ground.layout = ResourceLoader.load("res://data/environment/layouts/stage_1_forest_ground.tres", "", ResourceLoader.CACHE_MODE_REPLACE)
	ground.rebuild_from_layout()
