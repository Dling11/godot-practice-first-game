extends "res://tools/weapon_sprite_sheet_extractor.gd"

## Retained source builder for cardinal carry/run only. Oathbound owns attacks.
const SOURCE := "res://art_source/generated/characters/king/greatsword_cardinal_2026_10_05/"
const DEST := "res://assets/characters/playable/king/greatsword_cardinal/"
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const STEEL = preload("res://assets/characters/playable/king/huge_greatsword_proof/greatsword.png")
const SOURCE_DENSITY := 54.0/136.0 # One scale for both48-key source sheets.
const SOURCE_KEYS := [7,40,41,42,43,44,45,46,47]

var _ingestion_failed := false

func _initialize() -> void:
	for direction in ["down","up"]:
		build_direction(direction)
		if _ingestion_failed:
			quit(1)
			return
	print("KING_GREATSWORD_CARDINAL retained18 source keys / two run and carry clips; attacks belong to Oathbound")
	quit()

func build_direction(direction: String) -> void:
	var folder := DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var sheet := Image.load_from_file(SOURCE+direction+"_body_source.png")
	var frames := _extract_frames(sheet,8,6)
	var feet := _foot_heights.duplicate()
	var density := SOURCE_DENSITY
	var cell := Vector2(sheet.get_width()/8.0,sheet.get_height()/6.0)
	var bodies: Array[Image] = []
	bodies.resize(48)
	var carry_primary := Vector2.ZERO
	var audit: Array[Dictionary] = []
	for index in SOURCE_KEYS:
		var image := frames[index].duplicate()
		image.resize(roundi(image.get_width()*density),roundi(image.get_height()*density),Image.INTERPOLATE_NEAREST)
		var offset := Vector2i(roundi(96-(96+cell.x*.5)*density),roundi(95-feet[index]*density))
		var registered := Image.create(192,128,false,Image.FORMAT_RGBA8)
		registered.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
		for y in 128:
			for x in 192:
				var color := registered.get_pixel(x,y)
				registered.set_pixel(x,y,Color(color.r,color.g,color.b,1) if color.a>=.65 else Color.TRANSPARENT)
		var carry_guide := Vector2(.4,.70) if direction=="up" else Vector2(.5,.71)
		var expected: Vector2 = (Vector2(96,96)+carry_guide*cell)*density+Vector2(offset)
		var hand := find_glove(registered,expected) if index==7 else Vector2(103,66)
		if hand==Vector2.ZERO:
			registered.save_png(SOURCE+"missing_glove.png")
			push_error("Missing glove: "+direction+" key "+str(index)+" expected "+str(expected))
			_ingestion_failed = true
			return
		bodies[index] = registered
		if index==7: carry_primary = hand
		audit.append({"source_key":index,"primary":[hand.x,hand.y],"body_bounds":var_to_str(registered.get_used_rect())})
	var idle := make_clip()
	idle.allow_rest = false
	var idle_bodies: Array[Image] = []
	for index in 8:
		idle_bodies.append(bodies[7])
		register_hand(idle,carry_primary,225)
	write_clip(folder,"idle",idle,idle_bodies)
	var running := make_clip()
	var running_bodies: Array[Image] = []
	for key in 8:
		running_bodies.append(bodies[40+key])
		register_hand(running,Vector2(102,67),225)
		running.stowed_poses[key] = 1
		running.weapon_behind_body[key] = 1
	write_clip(folder,"run",running,running_bodies)
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

func register_hand(clip: Resource, hand: Vector2, heading: float) -> void:
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

func write_clip(folder: String, label: String, clip: Resource, bodies: Array[Image]) -> void:
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
	var text := "[gd_resource type=\"Resource\" load_steps=5 format=3]\n"
	text += "[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+folder+label+"_body.png\" id=\"2\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+folder+label+"_hands.png\" id=\"3\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+STEEL.resource_path+"\" id=\"4\"]\n"
	text += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in ["primary_hands","secondary_hands","weapon_primary_grip","weapon_tip","mirror_cutting_edge","phase_windows","weapon_behind_body","single_hand_poses","stowed_poses","lift_pixels","interpolate_weapon","linked_recovery_pose","allow_rest"]:
		text += property+" = "+var_to_str(clip.get(property))+"\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(text)
