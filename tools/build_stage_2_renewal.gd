extends "res://tools/build_stage_1_renewal.gd"

## Reuses footprint/canopy scene authoring, with a distinct kit and authored route.
const THORN_SOURCE := "res://art_source/generated/environment/forest/thorns_renewal_2026_10_03/"
const THORN_OUTPUT := "res://assets/environment/forest/thorns_renewal/"
const THORN_PROPS := "res://environment/props/thorns/"
const THORN_SCENE := "res://levels/stage_2/stage_2.tscn"

func _prop_texture_directory() -> String:
	return THORN_OUTPUT

func _prop_scene_directory() -> String:
	return THORN_PROPS

func _normalize_art() -> void:
	var source := Image.load_from_file(THORN_SOURCE+"props_source.png")
	var specs := [
		["birch",Rect2i(0,60,408,570),Vector2i(102,118),Vector2(18,14),true],
		["thorn_tree",Rect2i(408,80,388,550),Vector2i(98,112),Vector2(20,14),true],
		["shrine",Rect2i(804,100,360,530),Vector2i(56,76),Vector2(46,22),false],
		["bramble",Rect2i(1164,280,372,350),Vector2i(54,40),Vector2(40,18),true],
		["root",Rect2i(0,680,484,330),Vector2i(66,36),Vector2(48,16),false],
		["stones",Rect2i(490,680,365,330),Vector2i(46,32),Vector2(36,18),false],
		["thorn_fern",Rect2i(864,660,310,364),Vector2i(30,28),Vector2.ZERO,true],
		["flowers",Rect2i(1180,700,356,324),Vector2i(24,18),Vector2.ZERO,false],
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
		assert(image.save_png(THORN_OUTPUT+spec[0]+".png") == OK)
		manifest.append({"asset":spec[0],"crop":str(spec[1]),"native_size":str(image.get_size()),"alpha_threshold":.7})
		if not "--art-only" in OS.get_cmdline_user_args(): _save_prop(spec,image.get_size())
	var file := FileAccess.open(THORN_SOURCE+"normalization.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))

func _build() -> void:
	_normalize_art()
	if "--art-only" in OS.get_cmdline_user_args():
		quit()
		return
	var scene: Node = load(THORN_SCENE).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground: TileMapLayer = scene.get_node("World/Level/Ground")
	_build_ground(ground)
	var actors := scene.get_node("World/Actors")
	for child in actors.get_children():
		if child is StaticBody2D:
			actors.remove_child(child)
			child.free()
	# Bramble clusters live at borders/pockets. The central ruin splits the worn
	# approach into two wide lanes; all six reinforcement entrances stay open.
	var placements := [
		["birch",505,690,"EntryTreeWest"], ["thorn_tree",1030,690,"EntryTreeEast"],
		["birch",310,420,"WestGrove"], ["thorn_tree",1230,420,"EastGrove"],
		["thorn_tree",570,220,"NorthGroveWest"], ["birch",960,215,"NorthGroveEast"],
		["shrine",768,416,"BrokenHeart"],
		["birch",96,152], ["thorn_tree",224,240], ["birch",432,96],
		["thorn_tree",112,340], ["birch",112,600], ["thorn_tree",208,680],
		["birch",160,800], ["thorn_tree",432,816], ["birch",592,832],
		["thorn_tree",960,832], ["birch",1104,816], ["thorn_tree",1392,784],
		["birch",1424,632], ["thorn_tree",1424,328], ["birch",1312,256],
		["thorn_tree",1424,160], ["birch",1120,96],
		["birch",288,104], ["thorn_tree",672,96], ["thorn_tree",864,96],
		["bramble",480,650], ["bramble",552,688], ["bramble",1000,648], ["bramble",1072,680],
		["bramble",280,380], ["bramble",368,416], ["bramble",1200,374], ["bramble",1296,400],
		["bramble",520,180], ["bramble",600,224], ["bramble",984,224],
		["bramble",184,244], ["bramble",104,296], ["bramble",96,544],
		["bramble",240,680], ["bramble",128,804], ["bramble",408,832],
		["bramble",1104,832], ["bramble",1360,784], ["bramble",1392,576],
		["bramble",1344,260], ["bramble",1408,192],
		["root",544,592], ["root",1024,576], ["root",408,328], ["root",1120,312],
		["stones",680,336], ["stones",872,344], ["stones",704,472], ["stones",840,464],
		["stones",464,736], ["stones",1064,736], ["stones",208,560], ["stones",1328,552],
		["thorn_fern",544,720], ["thorn_fern",464,648], ["thorn_fern",992,720],
		["thorn_fern",1064,648], ["thorn_fern",272,424], ["thorn_fern",360,376],
		["thorn_fern",1280,432], ["thorn_fern",1192,344], ["thorn_fern",632,240],
		["thorn_fern",1024,232], ["thorn_fern",704,336], ["thorn_fern",848,328],
		["flowers",480,704], ["flowers",1048,708], ["flowers",336,448], ["flowers",1208,444],
		["flowers",720,448], ["flowers",816,432], ["flowers",688,356], ["flowers",856,364],
		["flowers",256,680], ["flowers",1312,596],
	]
	for index in placements.size():
		var spec: Array = placements[index]
		var prop: StaticBody2D = load(THORN_PROPS+spec[0]+".tscn").instantiate()
		prop.name = spec[3] if spec.size() > 3 else "%s_%02d" % [spec[0].capitalize(),index]
		prop.position = Vector2(spec[1],spec[2])
		prop.phase = float(index)*1.7
		actors.add_child(prop)
		prop.owner = scene
	var previous := scene.get_node_or_null("World/GroveAmbience")
	if previous != null:
		previous.get_parent().remove_child(previous)
		previous.free()
	var birds := Node2D.new()
	birds.name = "GroveAmbience"
	birds.set_script(preload("res://environment/props/woodland/grove_ambience.gd"))
	scene.get_node("World").add_child(birds)
	birds.owner = scene
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,THORN_SCENE) == OK)
	assert(ResourceSaver.set_uid(THORN_SCENE,ResourceUID.text_to_id("uid://cyt2xiknp3b3b")) == OK)
	print("STAGE_2_RENEWAL_BAKED: ",ground.get_used_cells().size()," cells, ",placements.size()," props")
	scene.free()
	quit()

func _build_ground(ground: TileMapLayer) -> void:
	ground.tile_set = load("res://assets/environment/forest/grove_renewal/grove_ground_tileset.tres")
	var layout := AuthoredGroundLayout.new()
	layout.map_size = Vector2i(48,28)
	var legend := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV"
	for index in 48: layout.tile_legend[legend[index]] = Vector2i(index%4,index/4)
	var paths := [
		PackedVector2Array([Vector2(768,896),Vector2(784,736),Vector2(768,624),Vector2(648,528),Vector2(624,416),Vector2(688,304),Vector2(768,150)]),
		PackedVector2Array([Vector2(768,624),Vector2(904,536),Vector2(920,416),Vector2(848,304),Vector2(768,150)]),
		PackedVector2Array([Vector2(648,528),Vector2(448,536),Vector2(328,464),Vector2(165,440)]),
		PackedVector2Array([Vector2(904,536),Vector2(1096,520),Vector2(1224,464),Vector2(1370,440)]),
	]
	var stones := {}
	for y in 28:
		for x in 48:
			var cell := Vector2i(x,y)
			var p := Vector2(cell*32)+Vector2(16,16)
			if ((p-Vector2(768,416))/Vector2(132,84)).length_squared() < 1: stones[cell] = true
	for y in 28:
		var row := ""
		for x in 48:
			var cell := Vector2i(x,y)
			var variant := posmod(x*17+y*29+x*y,4)
			var coordinate := Vector2i(variant,0)
			var mask := 0
			var corners := [Vector2(0,0),Vector2(32,0),Vector2(32,32),Vector2(0,32)]
			for corner in 4:
				var point: Vector2 = Vector2(cell*32)+corners[corner]
				var distance := INF
				for path: PackedVector2Array in paths:
					for index in path.size()-1:
						distance = minf(distance,point.distance_to(Geometry2D.get_closest_point_to_segment(point,path[index],path[index+1])))
				if distance < 32: mask |= 1<<corner
			if mask > 0: coordinate = Vector2i(mask%4,8+mask/4)
			if mask == 15: coordinate = Vector2i(variant,1)
			if stones.has(cell):
				mask = 0
				for index in 4:
					if stones.has(cell+[Vector2i.UP,Vector2i.RIGHT,Vector2i.DOWN,Vector2i.LEFT][index]): mask |= 1<<index
				coordinate = Vector2i(mask%4,4+mask/4) if mask != 15 else Vector2i(variant,3)
			row += legend[coordinate.y*4+coordinate.x]
		layout.rows.append(row)
	assert(ResourceSaver.save(layout,"res://data/environment/layouts/stage_2_forest_ground.tres") == OK)
	ground.layout = ResourceLoader.load("res://data/environment/layouts/stage_2_forest_ground.tres", "", ResourceLoader.CACHE_MODE_REPLACE)
	ground.rebuild_from_layout()
