extends "res://tools/build_stage_1_renewal.gd"

const ROT_SOURCE := "res://art_source/generated/environment/forest/eastern_rot_renewal_2026_10_03/"
const ROT_OUTPUT := "res://assets/environment/forest/eastern_rot_renewal/"
const ROT_PROPS := "res://environment/props/eastern_rot/"
const ROT_SCENE := "res://levels/stage_4/stage_4.tscn"

func _prop_texture_directory() -> String:
	return ROT_OUTPUT

func _prop_scene_directory() -> String:
	return ROT_PROPS

func _normalize_art() -> void:
	var source := Image.load_from_file(ROT_SOURCE+"props_source.png")
	var specs := [
		["alder",Rect2i(0,90,422,590),Vector2i(106,118),Vector2(18,14),true],
		["fungal_ash",Rect2i(426,90,336,590),Vector2i(90,118),Vector2(18,14),true],
		["gateway",Rect2i(766,180,420,490),Vector2i(140,128),Vector2.ZERO,false],
		["stump",Rect2i(1190,370,346,310),Vector2i(44,36),Vector2(34,18),false],
		["fallen_root",Rect2i(0,720,484,304),Vector2i(66,32),Vector2(48,16),false],
		["rubble",Rect2i(490,740,324,284),Vector2i(48,36),Vector2(36,18),false],
		["fern",Rect2i(818,750,356,274),Vector2i(28,26),Vector2.ZERO,true],
		["fungi",Rect2i(1178,750,358,274),Vector2i(26,24),Vector2.ZERO,false],
	]
	var manifest: Array[Dictionary] = []
	for spec: Array in specs:
		var image := source.get_region(spec[1])
		image.convert(Image.FORMAT_RGBA8)
		for y in image.get_height():
			for x in image.get_width():
				var c := image.get_pixel(x,y)
				image.set_pixel(x,y,Color.TRANSPARENT if c.a < .7 else Color(c.r,c.g,c.b,1))
		image = image.get_region(image.get_used_rect())
		var ratio: float = minf(float(spec[2].x)/image.get_width(),float(spec[2].y)/image.get_height())
		image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_NEAREST)
		assert(image.save_png(ROT_OUTPUT+spec[0]+".png") == OK)
		manifest.append({"asset":spec[0],"crop":str(spec[1]),"size":str(image.get_size()),"alpha_threshold":.7})
		if not "--art-only" in OS.get_cmdline_user_args():
			if spec[0] == "gateway": _save_gateway(image.get_size())
			else: _save_prop(spec,image.get_size())
	FileAccess.open(ROT_SOURCE+"normalization.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
	var dark := Image.load_from_file("res://assets/environment/forest/hollow_renewal/rootbound_32.png")
	var living := Image.load_from_file("res://assets/environment/forest/grove_renewal/ground_32.png")
	var blend := Image.create(256,64,false,Image.FORMAT_RGBA8)
	for row in 2:
		for side in 2:
			for variant in 4:
				for y in 32:
					for x in 32:
						var t := clampf(float(side*32+x+posmod(y/4+variant*3,5)-2)/63,0,1)
						blend.set_pixel((side*4+variant)*32+x,row*32+y,living.get_pixel(variant*32+x,row*32+y).lerp(dark.get_pixel(variant*32+x,row*32+y),t))
	assert(blend.save_png(ROT_OUTPUT+"transition_32.png") == OK)

func _save_gateway(size: Vector2i) -> void:
	var gate := Node2D.new()
	gate.name = "EasternGateway"
	gate.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = load(ROT_OUTPUT+"gateway.png")
	sprite.position.y = -size.y*.5+5
	gate.add_child(sprite)
	sprite.owner = gate
	# Separate bodies avoid a convex-hull obstruction across the open doorway.
	for side in [-1,1]:
		var pillar := StaticBody2D.new()
		pillar.name = "WestPillar" if side < 0 else "EastPillar"
		pillar.position = Vector2(side*44,-3)
		pillar.collision_mask = 0
		gate.add_child(pillar)
		pillar.owner = gate
		var base := CollisionShape2D.new()
		base.name = "Footprint"
		var shape := RectangleShape2D.new()
		shape.size = Vector2(16,20)
		base.shape = shape
		pillar.add_child(base)
		base.owner = gate
		var cutout := Node.new()
		cutout.name = "NavigationCutout"
		cutout.set_script(Cutout)
		cutout.derive_from_collision_shapes = true
		cutout.add_to_group("navigation_cutout",true)
		pillar.add_child(cutout)
		cutout.owner = gate
	var packed := PackedScene.new()
	assert(packed.pack(gate) == OK)
	assert(ResourceSaver.save(packed,ROT_PROPS+"gateway.tscn") == OK)
	gate.free()

func _build_ground(ground: TileMapLayer) -> void:
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(32,32)
	for spec in [["res://assets/environment/forest/hollow_renewal/rootbound_32.png",4,0],["res://assets/environment/forest/grove_renewal/ground_32.png",12,1],[ROT_OUTPUT+"transition_32.png",2,3]]:
		var atlas := TileSetAtlasSource.new()
		atlas.texture = load(spec[0])
		atlas.texture_region_size = Vector2i(32,32)
		for y in spec[1]:
			for x in atlas.texture.get_width()/32: atlas.create_tile(Vector2i(x,y))
		tiles.add_source(atlas,spec[2])
	assert(ResourceSaver.save(tiles,ROT_OUTPUT+"eastern_rot_tileset.tres") == OK)
	ground.tile_set = load(ROT_OUTPUT+"eastern_rot_tileset.tres")
	var layout := AuthoredGroundLayout.new()
	layout.map_size = Vector2i(48,28)
	var keys := {}
	var next := 0
	for spec in [[0,4,4],[1,4,12],[3,8,2]]:
		for y in spec[2]:
			for x in spec[1]:
				var coord := Vector3i(x,y,spec[0])
				var key := String.chr(0x100+next)
				keys[coord] = key
				layout.tile_legend[key] = coord
				next += 1
	var paths := [
		PackedVector2Array([Vector2(768,896),Vector2(768,650),Vector2(720,500),Vector2(768,350),Vector2(800,175)]),
		PackedVector2Array([Vector2(720,500),Vector2(944,480),Vector2(1104,496),Vector2(1200,470)]),
		PackedVector2Array([Vector2(720,500),Vector2(520,472),Vector2(310,440),Vector2(165,440)]),
	]
	for y in 28:
		var row := ""
		var edge: int = [30,30,31,31,32,32,30,30,29,29,30,30,30,30][y/2]
		for x in 48:
			var v := posmod(x*17+y*29+x*y,4)
			var mask := 0
			for corner in 4:
				var point: Vector2 = Vector2(Vector2i(x,y)*32)+[Vector2.ZERO,Vector2(32,0),Vector2(32,32),Vector2(0,32)][corner]
				var distance := INF
				for path: PackedVector2Array in paths:
					for index in path.size()-1: distance = minf(distance,point.distance_to(Geometry2D.get_closest_point_to_segment(point,path[index],path[index+1])))
				if distance < 40: mask |= 1<<corner
			var coord := Vector3i(v,0,1)
			if mask > 0: coord = Vector3i(mask%4,8+mask/4,1)
			if mask == 15: coord = Vector3i(v,1,1)
			if x >= edge+2: coord = Vector3i(v,1 if mask > 0 else 0,0)
			elif x >= edge: coord = Vector3i((x-edge)*4+v,1 if mask > 0 else 0,3)
			row += keys[coord]
		layout.rows.append(row)
	assert(ResourceSaver.save(layout,"res://data/environment/layouts/stage_4_eastern_rot_ground.tres") == OK)
	ground.layout = ResourceLoader.load("res://data/environment/layouts/stage_4_eastern_rot_ground.tres","",ResourceLoader.CACHE_MODE_REPLACE)
	ground.rebuild_from_layout()

func _build() -> void:
	_normalize_art()
	if "--art-only" in OS.get_cmdline_user_args():
		quit()
		return
	var scene: Node = load(ROT_SCENE).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground: TileMapLayer = scene.get_node("World/Level/Ground")
	_build_ground(ground)
	var actors := scene.get_node("World/Actors")
	for child in actors.get_children():
		if child is StaticBody2D or child.name == "EastRuin":
			actors.remove_child(child)
			child.free()
	var placements := [
		["alder",505,690,"EntryTreeWest"], ["fungal_ash",1030,690,"RottedTreeSouthEast"],
		["alder",310,360,"WestGrove"], ["fungal_ash",1296,360,"RottedTreeEast"],
		["alder",570,220,"NorthGroveWest"], ["fungal_ash",1040,215,"RottedTreeNorthEast"],
		["gateway",1200,470,"EastRuin"],
		["alder",112,176],["alder",208,280],["alder",112,576],["alder",160,792],
		["alder",448,96],["alder",672,96],["alder",880,104],["alder",432,816],
		["alder",640,816],["alder",880,816],["alder",528,384],["alder",944,328],
		["fungal_ash",1248,96],["fungal_ash",1424,192],["fungal_ash",1424,600],
		["fungal_ash",1392,792],["fungal_ash",1088,816],["fungal_ash",1264,800],
		["stump",144,232],["stump",320,312],["stump",464,664],["stump",1040,640],
		["stump",1328,320],["stump",1392,576],["stump",1328,760],
		["fallen_root",448,560],["fallen_root",928,592],["fallen_root",1200,288],
		["fallen_root",1360,704],["fallen_root",192,624],
		["rubble",1144,416],["rubble",1264,424],["rubble",1264,520],["rubble",1128,528],
		["rubble",272,520],["rubble",592,288],["rubble",1008,768],
		["fern",472,704],["fern",536,664],["fern",336,360],["fern",288,328],
		["fern",560,368],["fern",496,408],["fern",640,224],["fern",432,592],
		["fern",864,784],["fern",624,792],["fern",192,792],["fern",128,592],
		["fern",960,352],["fern",912,304],
		["fungi",1040,712],["fungi",1088,664],["fungi",1328,360],["fungi",1248,336],
		["fungi",1136,392],["fungi",1264,400],["fungi",1272,544],["fungi",1104,544],
		["fungi",1392,632],["fungi",1344,712],["fungi",1088,792],["fungi",1296,784],
	]
	for index in placements.size():
		var spec: Array = placements[index]
		var prop: Node2D = load(ROT_PROPS+spec[0]+".tscn").instantiate()
		prop.name = spec[3] if spec.size() > 3 else "%s_%02d" % [spec[0].capitalize(),index]
		prop.position = Vector2(spec[1],spec[2])
		if prop is StaticBody2D: prop.phase = float(index)*1.7
		actors.add_child(prop)
		prop.owner = scene
	var previous := scene.get_node_or_null("World/GroveAmbience")
	if previous != null:
		previous.get_parent().remove_child(previous)
		previous.free()
	var birds := Node2D.new()
	birds.name = "GroveAmbience"
	birds.set_script(preload("res://environment/props/woodland/grove_ambience.gd"))
	birds.bird_origin = Vector2(96,120)
	birds.flight_bounds = Rect2(48,180,680,260)
	scene.get_node("World").add_child(birds)
	birds.owner = scene
	scene.get_node("World/NavigationRegion2D").navigation_agent_radius = 12.0
	for name in ["OutdoorAudio","LivingWestAudio","EasternRotAudio"]:
		var old := scene.get_node_or_null("World/"+name)
		if old != null:
			old.get_parent().remove_child(old)
			old.free()
	for spec in [["LivingWestAudio",Vector2(448,440),"eastern_west_audio",PackedVector2Array([Vector2(-160,-220),Vector2(-260,140),Vector2(128,-192)])],["EasternRotAudio",Vector2(1280,440),"eastern_rot_audio",PackedVector2Array([Vector2(-176,-144),Vector2(96,128),Vector2(-96,256)])]]:
		var audio := Node2D.new()
		audio.name = spec[0]
		audio.position = spec[1]
		audio.set_script(preload("res://gameplay/audio/biome_ambience.gd"))
		audio.profile = load("res://data/environment/"+spec[2]+".tres")
		audio.encounter = scene.encounter_controller
		audio.spatial_bed = true
		audio.bed_max_distance = 1050.0
		audio.cue_positions = spec[3]
		scene.get_node("World").add_child(audio)
		audio.owner = scene
	var music := scene.get_node("StageMusic")
	music.encounter = scene.encounter_controller
	music.exploration_volume_db = -16.0
	music.combat_volume_db = -13.0
	music.cleared_volume_db = -17.0
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,ROT_SCENE) == OK)
	print("STAGE_4_RENEWAL: ",ground.get_used_cells().size()," cells, ",placements.size()," props")
	scene.free()
	quit()
