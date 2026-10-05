extends "res://tools/weapon_sprite_sheet_extractor.gd"

## Offline ingestion of generated body cels. Steel is the accepted rigid asset.
const SOURCE := "res://art_source/generated/characters/king/greatsword_cardinal_2026_10_05/"
const DEST := "res://assets/characters/playable/king/greatsword_cardinal/"
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const STEEL = preload("res://assets/characters/playable/king/huge_greatsword_proof/greatsword.png")
const NAMES := ["sweep","rise","slam","turn","return"]
const SOURCE_DENSITY := 54.0/136.0 # One scale for both48-key source sheets.
const HEADINGS := [
	[225,225,240,340,30,70,110,225],
	[100,100,90,70,25,-20,-70,225],
	[-90,-90,-90,-90,90,90,145,225],
	[210,200,160,90,60,30,110,225],
	[30,60,90,120,160,200,220,225],
]
const DOWN_HANDS := [
	[Vector2(.34,.35),Vector2(.30,.47),Vector2(.33,.57),Vector2(.55,.65),Vector2(.53,.73),Vector2(.53,.71),Vector2(.50,.70),Vector2(.5,.71)],
	[Vector2(.60,.58),Vector2(.55,.55),Vector2(.68,.19),Vector2(.68,.18),Vector2(.55,.11),Vector2(.30,.25),Vector2(.48,.6),Vector2(.49,.58)],
	[Vector2(.53,.70),Vector2(.49,.23),Vector2(.49,.1),Vector2(.50,.14),Vector2(.50,.69),Vector2(.51,.74),Vector2(.50,.65),Vector2(.50,.64)],
	[Vector2(.34,.22),Vector2(.32,.24),Vector2(.43,.48),Vector2(.57,.55),Vector2(.57,.62),Vector2(.67,.59),Vector2(.66,.71),Vector2(.57,.70)],
	[Vector2(.70,.66),Vector2(.63,.62),Vector2(.51,.61),Vector2(.5,.63),Vector2(.49,.63),Vector2(.44,.65),Vector2(.35,.38),Vector2(.35,.65)],
]
const UP_HANDS := [
	[Vector2(.63,.29),Vector2(.30,.44),Vector2(.31,.50),Vector2(.31,.51),Vector2(.31,.60),Vector2(.35,.65),Vector2(.35,.70),Vector2(.40,.70)],
	[Vector2(.63,.62),Vector2(.66,.51),Vector2(.68,.40),Vector2(.68,.22),Vector2(.44,.11),Vector2(.3,.24),Vector2(.67,.66),Vector2(.67,.65)],
	[Vector2(.5,.76),Vector2(.5,.19),Vector2(.5,.08),Vector2(.5,.15),Vector2(.5,.77),Vector2(.5,.78),Vector2(.5,.65),Vector2(.5,.63)],
	[Vector2(.29,.30),Vector2(.27,.39),Vector2(.30,.43),Vector2(.31,.46),Vector2(.30,.49),Vector2(.29,.53),Vector2(.28,.55),Vector2(.68,.68)],
	[Vector2(.70,.59),Vector2(.67,.66),Vector2(.65,.68),Vector2(.63,.70),Vector2(.58,.69),Vector2(.63,.69),Vector2(.68,.34),Vector2(.60,.64)],
]

var _ingestion_failed := false

func _initialize() -> void:
	for direction in ["down","up"]:
		build_direction(direction)
		if _ingestion_failed:
			quit(1)
			return
	print("KING_GREATSWORD_CARDINAL built 96 body keys / ten cuts / two run and carry clips")
	quit()

func build_direction(direction: String) -> void:
	var folder := DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var sheet := Image.load_from_file(SOURCE+direction+"_body_source.png")
	var frames := _extract_frames(sheet,8,6)
	var feet := _foot_heights.duplicate()
	var density := SOURCE_DENSITY
	var cell := Vector2(sheet.get_width()/8.0,sheet.get_height()/6.0)
	var hand_points: Array = UP_HANDS if direction=="up" else DOWN_HANDS
	var bodies: Array[Image] = []
	var primary: Array[Vector2] = []
	var audit: Array[Dictionary] = []
	for index in 48:
		var image := frames[index].duplicate()
		image.resize(roundi(image.get_width()*density),roundi(image.get_height()*density),Image.INTERPOLATE_NEAREST)
		var offset := Vector2i(roundi(96-(96+cell.x*.5)*density),roundi(95-feet[index]*density))
		var registered := Image.create(192,128,false,Image.FORMAT_RGBA8)
		registered.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
		for y in 128:
			for x in 192:
				var color := registered.get_pixel(x,y)
				registered.set_pixel(x,y,Color(color.r,color.g,color.b,1) if color.a>=.65 else Color.TRANSPARENT)
		var expected: Vector2 = (Vector2(96,96)+hand_points[index/8][index%8]*cell)*density+Vector2(offset) if index<40 else Vector2(103,66)
		var hand := find_glove(registered,expected) if index<40 else Vector2(103,66)
		if hand==Vector2.ZERO:
			registered.save_png(SOURCE+"missing_glove.png")
			push_error("Missing glove: "+direction+" key "+str(index)+" expected "+str(expected))
			_ingestion_failed = true
			return
		bodies.append(registered)
		primary.append(hand)
		audit.append({"source_key":index,"primary":[hand.x,hand.y],"body_bounds":var_to_str(registered.get_used_rect())})
	var idle := make_clip()
	idle.allow_rest = false
	var idle_bodies: Array[Image] = []
	for index in 8:
		idle_bodies.append(bodies[7])
		register_hand(idle,primary[7],225,index)
	write_clip(folder,"idle",idle,idle_bodies)
	var clips: Array[Resource] = []
	for cut in 5:
		var clip := make_clip()
		clip.interpolate_weapon = true
		clip.phase_windows = PackedVector2Array([Vector2(0,2),Vector2(3,5),Vector2(6,7)])
		var cut_bodies: Array[Image] = []
		for key in 8:
			cut_bodies.append(bodies[cut*8+key])
			var heading: float = float(HEADINGS[cut][key])*( -1 if direction=="up" else 1)
			register_hand(clip,primary[cut*8+key],heading,key)
			clip.weapon_behind_body[key] = 1 if direction=="up" else 0
			if cut==2: clip.lift_pixels[key] = [0,-4,-16,-12,0,0,0,0][key]
		# Last carry is exactly shared, not an unrelated generated stance.
		cut_bodies[7] = idle_bodies[0]
		clip.primary_hands[7] = idle.primary_hands[0]
		clip.secondary_hands[7] = idle.secondary_hands[0]
		clip.weapon_behind_body[7] = idle.weapon_behind_body[0]
		if cut<4: clip.linked_recovery_pose = 5
		# Queued cuts keep the actual preceding endpoint. Never reload a
		# different generated pose or briefly show idle between connected cuts.
		var entry: Resource = idle if cut==0 else clips[cut-1]
		var entry_key := 0 if cut==0 else 5
		cut_bodies[0] = idle_bodies[0] if cut==0 else clips[cut-1].get_meta("cut_bodies")[5]
		clip.primary_hands[0] = entry.primary_hands[entry_key]
		clip.secondary_hands[0] = entry.secondary_hands[entry_key]
		clip.weapon_behind_body[0] = entry.weapon_behind_body[entry_key]
		clip.set_meta("cut_bodies",cut_bodies)
		clips.append(clip)
	var running := make_clip()
	var running_bodies: Array[Image] = []
	for key in 8:
		running_bodies.append(bodies[40+key])
		register_hand(running,Vector2(102,67),225,key)
		running.stowed_poses[key] = 1
		running.weapon_behind_body[key] = 1
	write_clip(folder,"run",running,running_bodies)
	for cut in 5:
		write_clip(folder,NAMES[cut],clips[cut],clips[cut].get_meta("cut_bodies"),NAMES.slice(1) if cut==0 else [])
	FileAccess.open(SOURCE+direction+"_registration.json",FileAccess.WRITE).store_string(JSON.stringify({"density":density,"ground_y":95,"cell_size":[192,128],"rigid_steel":STEEL.resource_path,"keys":audit},"\t")+"\n")
	print("CARDINAL ",direction," source=",sheet.get_size()," density=",density)

func make_clip() -> Resource:
	var clip := Definition.new()
	clip.weapon_texture = STEEL
	clip.weapon_primary_grip = Vector2(15,113)
	clip.weapon_tip = Vector2(15,0)
	clip.mirror_cutting_edge = false
	clip.single_hand_poses = PackedByteArray([1,1,1,1,1,1,1,1])
	return clip

func register_hand(clip: Resource, hand: Vector2, heading: float, _index: int) -> void:
	clip.primary_hands.append(hand)
	clip.secondary_hands.append(hand-Vector2.from_angle(deg_to_rad(heading))*7)

func find_glove(image: Image, expected: Vector2) -> Vector2:
	var nearest := Vector2.ZERO
	var distance := INF
	for y in range(maxi(0,roundi(expected.y)-14),mini(95,roundi(expected.y)+15)):
		for x in range(maxi(0,roundi(expected.x)-14),mini(192,roundi(expected.x)+15)):
			var c := image.get_pixel(x,y)
			if c.a<.5 or c.r<.20 or c.r>.78 or c.r<c.g*1.3 or c.g<c.b*1.2: continue
			var candidate := Vector2(x,y)
			if candidate.distance_squared_to(expected)<distance:
				nearest = candidate
				distance = candidate.distance_squared_to(expected)
	# A missing visible glove must stop ingestion, not silently use the origin.
	return nearest

func write_clip(folder: String, label: String, clip: Resource, bodies: Array[Image], followups: Array = []) -> void:
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,256,false,Image.FORMAT_RGBA8)
	for key in 8:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(bodies[key],Rect2i(0,0,192,128),origin)
		if clip.stowed_poses[key]==0:
			var rect := Rect2i(Vector2i(clip.primary_hands[key])-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(bodies[key],rect,origin+rect.position)
	if atlas.save_png(folder+label+"_body.png")!=OK or mask.save_png(folder+label+"_hands.png")!=OK:
		_ingestion_failed = true
		push_error("Cannot write cardinal atlas: "+folder+label)
		return
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(mask)
	if not clip.has_valid_layout():
		_ingestion_failed = true
		push_error("Invalid cardinal registration: "+folder+label)
		return
	var text := "[gd_resource type=\"Resource\" load_steps="+str(5+followups.size())+" format=3]\n"
	text += "[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+folder+label+"_body.png\" id=\"2\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+folder+label+"_hands.png\" id=\"3\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+STEEL.resource_path+"\" id=\"4\"]\n"
	for index in followups.size(): text += "[ext_resource type=\"Resource\" path=\""+folder+followups[index]+".tres\" id=\""+str(5+index)+"\"]\n"
	text += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in ["primary_hands","secondary_hands","weapon_primary_grip","weapon_tip","mirror_cutting_edge","phase_windows","weapon_behind_body","single_hand_poses","stowed_poses","lift_pixels","interpolate_weapon","linked_recovery_pose","allow_rest"]:
		text += property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		text += "follow_up_clips = Array[Resource](["
		for index in followups.size(): text += ("," if index>0 else "")+"ExtResource(\""+str(5+index)+"\")"
		text += "])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(text)
