extends "res://tools/build_stage_1_renewal.gd"

const DEAD_SOURCE := "res://art_source/generated/environment/forest/dead_forest_renewal_2026_10_03/"
const DEAD_OUTPUT := "res://assets/environment/forest/dead_forest_renewal/"
const DEAD_PROPS := "res://environment/props/dead_forest/"
const DEAD_SCENE := "res://levels/stage_5/stage_5.tscn"

func _prop_texture_directory() -> String: return DEAD_OUTPUT
func _prop_scene_directory() -> String: return DEAD_PROPS

func _normalize_art() -> void:
	var source := Image.load_from_file(DEAD_SOURCE+"props_source.png")
	var specs := [
		["ash",Rect2i(0,0,444,710),Vector2i(110,118),Vector2(18,14),true],
		["snag",Rect2i(450,0,284,710),Vector2i(74,118),Vector2(16,14),true],
		["gateway",Rect2i(740,180,446,520),Vector2i(128,118),Vector2.ZERO,false],
		["stump",Rect2i(1190,360,346,350),Vector2i(44,38),Vector2(32,18),false],
		["log",Rect2i(0,730,518,294),Vector2i(66,32),Vector2(48,16),false],
		["rubble",Rect2i(522,730,340,294),Vector2i(44,34),Vector2(32,18),false],
		["carrion",Rect2i(866,800,318,224),Vector2i(38,20),Vector2.ZERO,false],
		["bracken",Rect2i(1188,730,348,294),Vector2i(28,24),Vector2.ZERO,true],
	]
	var manifest: Array[Dictionary] = []
	for spec: Array in specs:
		var image := source.get_region(spec[1])
		image.convert(Image.FORMAT_RGBA8)
		for y in image.get_height():
			for x in image.get_width():
				var c := image.get_pixel(x,y)
				image.set_pixel(x,y,Color.TRANSPARENT if c.a < 0.7 else Color(c.r,c.g,c.b,1))
		image = image.get_region(image.get_used_rect())
		var ratio: float = minf(float(spec[2].x)/image.get_width(),float(spec[2].y)/image.get_height())
		image.resize(roundi(image.get_width()*ratio),roundi(image.get_height()*ratio),Image.INTERPOLATE_NEAREST)
		assert(image.save_png(DEAD_OUTPUT+spec[0]+".png") == OK)
		manifest.append({"name":spec[0],"crop":str(spec[1]),"size":str(image.get_size()),"alpha_threshold":0.7})
		if not "--art-only" in OS.get_cmdline_user_args():
			if spec[0] == "gateway": _save_dead_gateway(image.get_size())
			else: _save_prop(spec,image.get_size())
	FileAccess.open(DEAD_SOURCE+"normalization.json",FileAccess.WRITE).store_string(JSON.stringify(manifest,"\t"))
	var material := Image.load_from_file(DEAD_SOURCE+"ground_source.png")
	material.convert(Image.FORMAT_RGBA8)
	material.resize(128,128,Image.INTERPOLATE_NEAREST)
	var terrain := Image.create(128,384,false,Image.FORMAT_RGBA8)
	terrain.blit_rect(material,Rect2i(0,0,128,128),Vector2i.ZERO)
	for mask in 16:
		for y in 32:
			for x in 32:
				var sx := float(x)/31
				var sy := float(y)/31
				var top := lerpf(float(mask&1),float((mask>>1)&1),sx)
				var bottom := lerpf(float((mask>>3)&1),float((mask>>2)&1),sx)
				var coverage := lerpf(top,bottom,sy)
				var pixel := material.get_pixel(x,y)
				if coverage > 0.5: pixel = material.get_pixel(x,32+y)
				terrain.set_pixel((mask%4)*32+x,(8+mask/4)*32+y,pixel)
	assert(terrain.save_png(DEAD_OUTPUT+"dead_ground_32.png") == OK)

func _save_dead_gateway(size: Vector2i) -> void:
	var gate := Node2D.new()
	gate.name = "DeadGateway"
	gate.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var sprite := Sprite2D.new()
	sprite.name = "Sprite"
	sprite.texture = load(DEAD_OUTPUT+"gateway.png")
	sprite.position.y = -size.y*0.5+5
	gate.add_child(sprite)
	sprite.owner = gate
	for side in [-1,1]:
		var body := StaticBody2D.new()
		body.name = "WestPillar" if side < 0 else "EastPillar"
		body.position = Vector2(side*44,-3)
		body.collision_mask = 0
		gate.add_child(body)
		body.owner = gate
		var shape := CollisionShape2D.new()
		var rectangle := RectangleShape2D.new()
		rectangle.size = Vector2(12,20)
		shape.shape = rectangle
		body.add_child(shape)
		shape.owner = gate
		var cutout := Node.new()
		cutout.name = "NavigationCutout"
		cutout.set_script(Cutout)
		cutout.derive_from_collision_shapes = true
		cutout.add_to_group("navigation_cutout",true)
		body.add_child(cutout)
		cutout.owner = gate
	var packed := PackedScene.new()
	assert(packed.pack(gate) == OK)
	assert(ResourceSaver.save(packed,DEAD_PROPS+"gateway.tscn") == OK)
	gate.free()

func _build() -> void:
	_normalize_art()
	if "--art-only" in OS.get_cmdline_user_args():
		quit()
		return
	var scene: Node = load(DEAD_SCENE).instantiate(PackedScene.GEN_EDIT_STATE_INSTANCE)
	var ground: TileMapLayer = scene.get_node("World/Level/Ground")
	var layout := AuthoredGroundLayout.new()
	layout.map_size = Vector2i(48,36)
	var legend := "abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUV"
	for index in 48: layout.tile_legend[legend[index]] = Vector2i(index%4,index/4)
	var approach := PackedVector2Array([Vector2(768,1152),Vector2(768,1010),Vector2(736,890),Vector2(800,746),Vector2(768,560),Vector2(768,320)])
	for y in 36:
		var row := ""
		for x in 48:
			var mask := 0
			for corner in 4:
				var point: Vector2 = Vector2(x*32,y*32)+[Vector2.ZERO,Vector2(32,0),Vector2(32,32),Vector2(0,32)][corner]
				var distance := INF
				for index in approach.size()-1: distance = minf(distance,point.distance_to(Geometry2D.get_closest_point_to_segment(point,approach[index],approach[index+1])))
				if distance < 42 or ((point-Vector2(768,330))/Vector2(230,145)).length_squared() < 1: mask |= 1<<corner
			var variant := posmod(x*17+y*29+x*y,4)
			var coord := Vector2i(variant,2 if x < 6 or x > 41 else 0)
			if mask == 15: coord = Vector2i(variant,1)
			elif mask > 0: coord = Vector2i(mask%4,8+mask/4)
			row += legend[coord.y*4+coord.x]
		layout.rows.append(row)
	assert(ResourceSaver.save(layout,"res://data/environment/layouts/stage_5_dead_forest_ground.tres") == OK)
	var tiles := TileSet.new()
	tiles.tile_size = Vector2i(32,32)
	var atlas := TileSetAtlasSource.new()
	atlas.texture = load(DEAD_OUTPUT+"dead_ground_32.png")
	atlas.texture_region_size = Vector2i(32,32)
	for y in 12:
		for x in 4: atlas.create_tile(Vector2i(x,y))
	tiles.add_source(atlas,0)
	assert(ResourceSaver.save(tiles,DEAD_OUTPUT+"dead_ground_tileset.tres") == OK)
	ground.tile_set = load(DEAD_OUTPUT+"dead_ground_tileset.tres")
	ground.layout = ResourceLoader.load("res://data/environment/layouts/stage_5_dead_forest_ground.tres","",ResourceLoader.CACHE_MODE_REPLACE)
	ground.rebuild_from_layout()
	var actors: Node2D = scene.get_node("World/Actors")
	for child in actors.get_children():
		if child is StaticBody2D and child.name != "DeadAnimalLandmark" or child.name == "ArrivalGateway":
			actors.remove_child(child)
			child.free()
	var placements := [["ash",326,690,"ApproachTallTreeWest"],["snag",1212,744,"ApproachSnagEast"],["log",955,880,"ApproachFallenLog"],["stump",460,560,"MidUprootedLog"],["log",1090,480,"BasinFallenLogEast"],["gateway",768,1110,"ArrivalGateway"]]
	for side in [80,1456]:
		for y in [200,368,536,704,872,1040]: placements.append(["ash" if y%3 == 0 else "snag",side,y,"Edge_%d_%d" % [side,y]])
	for x in [256,448,640,896,1088,1280]:
		placements.append(["ash" if x%3 == 0 else "snag",x,128,"EdgeTop_%d" % x])
		placements.append(["snag",x,1110,"EdgeBottom_%d" % x])
	for spec in [["ash",448,340],["snag",1136,288],["stump",350,816],["rubble",1190,810],["log",290,420],["rubble",480,190],["rubble",1056,208],["stump",1280,584],["bracken",370,730],["bracken",1148,748],["bracken",990,908],["bracken",422,590],["bracken",1120,502],["bracken",550,734],["bracken",648,764],["bracken",416,336],["bracken",1168,312],["bracken",336,846],["bracken",1168,838],["bracken",944,1080]]: placements.append(spec)
	for index in placements.size():
		var spec: Array = placements[index]
		var prop: Node2D = load(DEAD_PROPS+spec[0]+".tscn").instantiate()
		prop.name = spec[3] if spec.size() > 3 else "%s_%02d" % [spec[0].capitalize(),index]
		prop.position = Vector2(spec[1],spec[2])
		if prop is StaticBody2D: prop.phase = index*1.7
		actors.add_child(prop)
		prop.owner = scene
	actors.get_node("DeadAnimalLandmark/Carcass").texture = load(DEAD_OUTPUT+"carrion.png")
	actors.get_node("DeadAnimalLandmark/Carcass").position.y = -9
	var prior := scene.get_node_or_null("Services/ApproachEncounter")
	if prior != null:
		prior.get_parent().remove_child(prior)
		prior.free()
	var points := scene.get_node_or_null("ApproachSpawnPoints")
	if points != null:
		scene.remove_child(points)
		points.free()
	points = Node2D.new()
	points.name = "ApproachSpawnPoints"
	scene.add_child(points)
	points.owner = scene
	for position in [Vector2(640,920),Vector2(880,920),Vector2(656,800),Vector2(896,800),Vector2(768,752)]:
		var marker := Marker2D.new()
		marker.position = position
		points.add_child(marker)
		marker.owner = scene
	var encounter := EncounterController.new()
	encounter.set_script(preload("res://gameplay/encounters/stage_approach_encounter.gd"))
	encounter.name = "ApproachEncounter"
	encounter.player = scene.player
	encounter.actors = actors
	encounter.spawn_points_root = points
	encounter.waves = [load("res://data/encounters/stage_5_approach.tres")]
	encounter.auto_start = false
	encounter.max_active_enemies = 5
	encounter.effects_parent = scene.get_node("World/Effects")
	encounter.projectiles_parent = scene.get_node("World/Projectiles")
	encounter.summon_effect_scene = load("res://gameplay/encounters/summon_effect.tscn")
	scene.get_node("Services").add_child(encounter)
	encounter.owner = scene
	scene.approach_encounter = encounter
	var old_audio := scene.get_node_or_null("World/OutdoorAudio")
	if old_audio != null:
		old_audio.get_parent().remove_child(old_audio)
		old_audio.free()
	var audio := Node2D.new()
	audio.name = "OutdoorAudio"
	audio.set_script(preload("res://gameplay/audio/biome_ambience.gd"))
	audio.profile = load("res://data/environment/dead_forest_audio.tres")
	audio.encounter = encounter
	audio.cue_positions = PackedVector2Array([Vector2(326,690),Vector2(1212,744),Vector2(448,340)])
	scene.get_node("World").add_child(audio)
	audio.owner = scene
	scene.outdoor_audio = audio
	var music := scene.get_node("StageMusic")
	music.music_stream = load("res://assets/audio/music/dead_forest_dark_place.ogg")
	music.encounter = encounter
	music.exploration_volume_db = -19.0
	music.combat_volume_db = -16.0
	music.cleared_volume_db = -20.0
	var packed := PackedScene.new()
	assert(packed.pack(scene) == OK)
	assert(ResourceSaver.save(packed,DEAD_SCENE) == OK)
	print("STAGE_5_RENEWAL: ",ground.get_used_cells().size()," cells, ",placements.size()," props + carrion, finite six-enemy approach")
	scene.free()
	quit()
