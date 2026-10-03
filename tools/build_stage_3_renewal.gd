extends "res://tools/build_stage_1_renewal.gd"

## Offline scene authoring; west-side decay never generates during gameplay.
const HOLLOW_SOURCE := "res://art_source/generated/environment/forest/hollow_renewal_2026_10_03/"
const HOLLOW_OUTPUT := "res://assets/environment/forest/hollow_renewal/"
const HOLLOW_PROPS := "res://environment/props/hollow/"
const HOLLOW_SCENE := "res://levels/stage_3/stage_3.tscn"

func _prop_texture_directory() -> String:
	return HOLLOW_OUTPUT

func _prop_scene_directory() -> String:
	return HOLLOW_PROPS

func _normalize_art() -> void:
	var source := Image.load_from_file(HOLLOW_SOURCE+"props_source.png")
	var specs := [
		["blighted_ash",Rect2i(0,60,484,580),Vector2i(110,118),Vector2(18,14),true],
		["root_elm",Rect2i(488,60,366,580),Vector2i(100,118),Vector2(18,14),true],
		["seal",Rect2i(856,300,424,350),Vector2i(150,90),Vector2(140,40),false],
		["memory_tablet",Rect2i(1284,320,252,330),Vector2i(32,44),Vector2(24,14),false],
		["fallen_root",Rect2i(0,675,484,349),Vector2i(66,32),Vector2(48,16),false],
		["root_mound",Rect2i(488,670,366,354),Vector2i(44,34),Vector2(36,18),false],
		["fungi",Rect2i(858,700,318,324),Vector2i(26,22),Vector2.ZERO,false],
		["masonry",Rect2i(1180,670,356,354),Vector2i(44,38),Vector2(36,18),false],
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
		assert(image.save_png(HOLLOW_OUTPUT+spec[0]+".png") == OK)
		manifest.append({"asset":spec[0],"crop":str(spec[1]),"native_size":str(image.get_size()),"alpha_threshold":.7})
		if not "--art-only" in OS.get_cmdline_user_args(): _save_prop(spec,image.get_size())
	var file := FileAccess.open(HOLLOW_SOURCE+"normalization.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t"))
	_build_terrain_art()

func _build_terrain_art() -> void:
	# Normalize the established Hollow ground to the approved 32px density.
	var old_set: TileSet = load("res://assets/environment/forest/rootbound_hollow/tiles/rootbound_ground_tileset.tres")
	var source := Image.load_from_file(old_set.get_source(0).texture.resource_path)
	source.resize(128,128,Image.INTERPOLATE_NEAREST)
	assert(source.save_png(HOLLOW_OUTPUT+"rootbound_32.png") == OK)
	var living := Image.load_from_file("res://assets/environment/forest/grove_renewal/ground_32.png")
	var transition := Image.create(256,64,false,Image.FORMAT_RGBA8)
	for row in 2:
		for side in 2:
			for variant in 4:
				for y in 32:
					for x in 32:
						var coverage := clampf(float(side*32+x+posmod(y/4+variant*3,5)-2)/63.0,0,1)
						var pixel := source.get_pixel(variant*32+x,row*32+y).lerp(living.get_pixel(variant*32+x,row*32+y),coverage)
						transition.set_pixel((side*4+variant)*32+x,row*32+y,pixel)
	assert(transition.save_png(HOLLOW_OUTPUT+"transition_32.png") == OK)

func _build_ground(ground: TileMapLayer) -> void:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(32,32)
	for spec in [[HOLLOW_OUTPUT+"rootbound_32.png",4],["res://assets/environment/forest/grove_renewal/ground_32.png",12],[HOLLOW_OUTPUT+"transition_32.png",2]]:
		var atlas := TileSetAtlasSource.new()
		atlas.texture = load(spec[0])
		atlas.texture_region_size = Vector2i(32,32)
		for y in spec[1]:
			for x in atlas.texture.get_width()/32: atlas.create_tile(Vector2i(x,y))
		tiles.add_source(atlas,tiles.get_source_count())
	assert(ResourceSaver.save(tiles,HOLLOW_OUTPUT+"hollow_ground_tileset.tres") == OK)
	ground.tile_set = load(HOLLOW_OUTPUT+"hollow_ground_tileset.tres")
	var layout := AuthoredGroundLayout.new()
	layout.map_size = Vector2i(48,28)
	var keys := {}
	var next := 0
	for source in 3:
		for y in [4,12,2][source]:
			for x in (8 if source == 2 else 4):
				var coordinate := Vector3i(x,y,source)
				var key := String.chr(0x100+next)
				keys[coordinate] = key
				layout.tile_legend[key] = coordinate
				next += 1
	var paths := [
		PackedVector2Array([Vector2(768,896),Vector2(800,720),Vector2(736,560),Vector2(800,424),Vector2(652,328),Vector2(672,224),Vector2(768,150)]),
		PackedVector2Array([Vector2(800,424),Vector2(888,328),Vector2(864,224),Vector2(768,150)]),
		PackedVector2Array([Vector2(736,560),Vector2(560,536),Vector2(380,472),Vector2(170,470)]),
		PackedVector2Array([Vector2(800,424),Vector2(1040,464),Vector2(1200,496),Vector2(1360,470)]),
	]
	for y in 28:
		var row := ""
		var edge: int = 11+[1,1,0,0,-1,-1,0,0,1,1,0,0,-1,-1][y/2]
		for x in 48:
			var variant := posmod(x*17+y*29+x*y,4)
			var mask := 0
			for corner in 4:
				var point: Vector2 = Vector2(Vector2i(x,y)*32)+[Vector2.ZERO,Vector2(32,0),Vector2(32,32),Vector2(0,32)][corner]
				var distance := INF
				for path: PackedVector2Array in paths:
					for index in path.size()-1:
						distance = minf(distance,point.distance_to(Geometry2D.get_closest_point_to_segment(point,path[index],path[index+1])))
				if distance < 32: mask |= 1<<corner
			var coordinate := Vector3i(variant,0,1)
			if mask > 0: coordinate = Vector3i(mask%4,8+mask/4,1)
			if mask == 15: coordinate = Vector3i(variant,1,1)
			if x < edge: coordinate = Vector3i(variant,1 if mask > 0 else 0,0)
			if x in [edge,edge+1]: coordinate = Vector3i((x-edge)*4+variant,1 if mask > 0 else 0,2)
			row += keys[coordinate]
		layout.rows.append(row)
	assert(ResourceSaver.save(layout,"res://data/environment/layouts/stage_3_rootbound_ground.tres") == OK)
	ground.layout = ResourceLoader.load("res://data/environment/layouts/stage_3_rootbound_ground.tres","",ResourceLoader.CACHE_MODE_REPLACE)
	ground.rebuild_from_layout()

func _build() -> void:
	_normalize_art()
	if "--art-only" in OS.get_cmdline_user_args():
		quit()
		return
	var scene: Node = load(HOLLOW_SCENE).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground: TileMapLayer = scene.get_node("World/Level/Ground")
	_build_ground(ground)
	var actors := scene.get_node("World/Actors")
	for child in actors.get_children():
		if child is StaticBody2D:
			actors.remove_child(child)
			child.free()
	# The new smaller seal keeps two readable dodge lanes and an unobstructed
	# southern Reliquary/portal approach. Decay props gather only on the west.
	var placements := [
		["seal",768,300,"RootboundArenaSeal"],
		["blighted_ash",245,360,"BlightedTreeWest"], ["blighted_ash",304,730,"BlightedTreeSouthWest"],
		["root_elm",1290,375,"AncientTreeEast"], ["root_elm",1160,725,"AncientTreeSouthEast"],
		["blighted_ash",96,176], ["blighted_ash",160,288], ["blighted_ash",104,568],
		["blighted_ash",144,800], ["blighted_ash",328,104], ["blighted_ash",368,616],
		["root_elm",496,816], ["root_elm",1056,816], ["root_elm",1360,784],
		["root_elm",1424,624], ["root_elm",1424,288], ["root_elm",1424,128],
		["root_elm",1104,96], ["root_elm",928,104], ["root_elm",608,112],
		["root_elm",496,360], ["root_elm",1104,336],
		["fallen_root",288,400], ["fallen_root",192,616], ["fallen_root",352,784],
		["fallen_root",544,672], ["fallen_root",1104,656], ["fallen_root",1200,288],
		["root_mound",144,208], ["root_mound",336,328], ["root_mound",96,680],
		["root_mound",384,664], ["root_mound",512,400], ["root_mound",1120,384],
		["root_mound",1184,752], ["root_mound",1360,688],
		["memory_tablet",400,448,"WesternMemory"],
		["masonry",696,272], ["masonry",848,272], ["masonry",688,340],
		["masonry",872,328], ["masonry",432,408], ["masonry",368,420],
		["fungi",240,392], ["fungi",320,372], ["fungi",176,616],
		["fungi",112,552], ["fungi",320,744], ["fungi",368,712],
		["fungi",352,664], ["fungi",176,804], ["fungi",112,280],
		["fungi",320,136], ["fungi",400,424], ["fungi",448,400],
		["fungi",512,664], ["fungi",552,700], ["fungi",1120,688],
		["fungi",1184,712], ["fungi",1248,336], ["fungi",1360,752],
		["fungi",1392,608], ["fungi",528,368], ["fungi",1088,352],
		["fungi",696,288], ["fungi",856,280],
	]
	for index in placements.size():
		var spec: Array = placements[index]
		var prop: StaticBody2D = load(HOLLOW_PROPS+spec[0]+".tscn").instantiate()
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
	birds.bird_origin = Vector2(544,120)
	birds.flight_bounds = Rect2(48,180,864,260)
	scene.get_node("World").add_child(birds)
	birds.owner = scene
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,HOLLOW_SCENE) == OK)
	print("STAGE_3_RENEWAL_BAKED: ",ground.get_used_cells().size()," cells, ",placements.size()," props")
	scene.free()
	quit()
