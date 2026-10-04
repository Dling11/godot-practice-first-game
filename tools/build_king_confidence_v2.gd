extends "res://tools/build_king_huge_greatsword.gd"

const V2_SOURCE := "res://art_source/generated/characters/king/greatsword_confidence_v2_2026_10_04/"
const V2_DEST := "res://assets/characters/playable/king/greatsword_confidence_v2/"
const ACTION_PRIMARY := [Vector2(184,177),Vector2(150,110),Vector2(125,60),Vector2(260,112),Vector2(260,120),Vector2(254,177),Vector2(206,170),Vector2(211,166),Vector2(132,82),Vector2(128,86),Vector2(125,81),Vector2(126,83),Vector2(120,61),Vector2(151,141),Vector2.ZERO,Vector2.ZERO]
const ACTION_SUPPORT := [Vector2(167,159),Vector2(190,115),Vector2(217,81),Vector2(222,123),Vector2(234,148),Vector2(231,155),Vector2(178,155),Vector2(185,151)]
const RUN_PRIMARY := [Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2.ZERO,Vector2(163,103),Vector2(160,100),Vector2(155,108),Vector2(163,104),Vector2(155,108),Vector2(159,107),Vector2(160,109),Vector2(168,105)]
var v2_records: Array[Dictionary] = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(V2_DEST))
	var image := Image.load_from_file(V2_SOURCE+"action_source.png")
	_binary(image)
	var components := _bodies(image)
	var calibration: Rect2i = components[8]
	var density := 54.0/calibration.size.y
	_export_clip("opening",image,components,0,ACTION_PRIMARY,ACTION_SUPPORT,density)
	_export_clip("idle",image,components,8,ACTION_PRIMARY,[],density)
	image = Image.load_from_file(V2_SOURCE+"run_source.png")
	_binary(image)
	components = _bodies(image)
	var run_height := 0.0
	for index in 8: run_height += (components[index] as Rect2i).size.y
	density = 54.0/(run_height/8.0)
	_export_clip("axe_run",image,components,0,RUN_PRIMARY,[],density)
	_export_clip("greatsword_run",image,components,8,RUN_PRIMARY,[],density)
	var text := FileAccess.get_file_as_string(V2_DEST+"opening.tres").replace("load_steps=5","load_steps=8")
	var references := ""
	for index in 3: references += "[ext_resource type=\"Resource\" path=\""+DEST+["rise","meteor","turn"][index]+".tres\" id=\""+str(index+5)+"\"]\n"
	text = text.replace("[resource]",references+"\n[resource]")
	text += "follow_up_clips = Array[Resource]([ExtResource(\"5\"),ExtResource(\"6\"),ExtResource(\"7\")])\n"
	FileAccess.open(V2_DEST+"opening.tres",FileAccess.WRITE).store_string(text)
	FileAccess.open(V2_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(v2_records,"\t")+"\n")
	print("KING_CONFIDENCE_V2_BUILD 8 opening / 8 pride / 16 genuine alternating run poses")
	quit()

func _export_clip(name: String,image: Image,components: Dictionary,first: int,hands: Array,support: Array,density: float) -> void:
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var primary := PackedVector2Array()
	var secondary := PackedVector2Array()
	for pose in 8:
		var index := first+pose
		var rect: Rect2i = components[index]
		var part := image.get_region(rect)
		var low := rect.size.x
		var high := 0
		for y in range(maxi(0,rect.size.y-18),rect.size.y):
			for x in rect.size.x:
				if part.get_pixel(x,y).a>0:
					low = mini(low,x)
					high = maxi(high,x)
		var foot := Vector2((low+high)*0.5,rect.size.y-1)
		part.resize(roundi(rect.size.x*density),roundi(rect.size.y*density),Image.INTERPOLATE_NEAREST)
		var offset := Vector2i(96,96)-Vector2i((foot*density).round())
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
		var nominal := Vector2(floorf(index%4*image.get_width()/4.0),floorf(index/4*image.get_height()/4.0))
		var p: Vector2 = ((Vector2(hands[index])+nominal-Vector2(rect.position))*density).round()+Vector2(offset)
		var s := Vector2.ZERO
		if name=="axe_run":
			p = Vector2(91,78)
			s = Vector2(97,81)
		elif name=="idle" and pose>=6:
			p = primary[5]
			s = secondary[5]
		else:
			p = _snap_glove(body,p,name+"/"+str(pose))
			if name=="opening":
				s = ((Vector2(support[index])+nominal-Vector2(rect.position))*density).round()+Vector2(offset)
				s = _snap_glove(body,s,name+" support/"+str(pose))
			elif name=="idle" and pose==5: s = p+Vector2(8,-8)
			else: s = p+Vector2(8,4)
		primary.append(p)
		secondary.append(s)
		var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
		if name!="axe_run" and not (name=="idle" and pose>=5):
			var points: Array = [p,s] if name=="opening" else [p]
			for point in points:
				var glove := Rect2i(Vector2i(point)-Vector2i(3,3),Vector2i(7,7))
				mask.blit_rect(body,glove,glove.position)
		var cell := Vector2i(pose%4,pose/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),cell)
		masks.blit_rect(mask,Rect2i(0,0,192,128),cell)
		v2_records.append({"clip":name,"pose":pose,"source_crop":[rect.position.x,rect.position.y,rect.size.x,rect.size.y],"density":density,"primary":[p.x,p.y],"secondary":[s.x,s.y],"released":name=="idle" and pose>=6})
	assert(atlas.save_png(V2_DEST+name+"_body.png")==OK)
	assert(masks.save_png(V2_DEST+name+"_hands.png")==OK)
	var weapon := "res://assets/characters/playable/king/axe_proof/iron_beard.png" if name=="axe_run" else DEST+"greatsword.png"
	var text := "[gd_resource type=\"Resource\" load_steps="+str(7 if name=="idle" else 5)+" format=3]\n\n[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+V2_DEST+name+"_body.png\" id=\"2\"]\n[ext_resource type=\"Texture2D\" path=\""+V2_DEST+name+"_hands.png\" id=\"3\"]\n[ext_resource type=\"Texture2D\" path=\""+weapon+"\" id=\"4\"]\n\n[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	if name=="idle":
		text = text.replace("[resource]","[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_planting_definition.gd\" id=\"5\"]\n\n[sub_resource type=\"Resource\" id=\"Planting\"]\nscript = ExtResource(\"5\")\nground_anchor = Vector2(74,96)\nburial_depth_pixels = 10.0\n\n[resource]")
	text += "primary_hands = "+_points(primary)+"\nsecondary_hands = "+_points(secondary)+"\n"
	if name=="axe_run":
		text += "weapon_primary_grip = Vector2(39,33)\nweapon_handle_axis = Vector2(4,10)\nsingle_hand_poses = PackedByteArray(1,1,1,1,1,1,1,1)\nstowed_poses = PackedByteArray(1,1,1,1,1,1,1,1)\nweapon_behind_body = PackedByteArray(1,1,1,1,1,1,1,1)\n"
	else:
		text += "weapon_primary_grip = Vector2(15,113)\nweapon_handle_axis = Vector2(0,1)\nmirror_cutting_edge = false\n"
		if name!="opening": text += "single_hand_poses = PackedByteArray(1,1,1,1,1,1,1,1)\n"
		if name=="greatsword_run": text += "weapon_behind_body = PackedByteArray(1,1,1,1,1,1,1,1)\n"
		if name=="idle": text += "weapon_tip = Vector2(15,0)\nplanting = SubResource(\"Planting\")\nreleased_poses = PackedByteArray(0,0,0,0,0,1,1,1)\nground_clipped_poses = PackedByteArray(0,0,0,0,0,1,1,1)\nweapon_behind_body = PackedByteArray(0,0,0,0,0,0,1,1)\n"
	FileAccess.open(V2_DEST+name+".tres",FileAccess.WRITE).store_string(text)

func _snap_glove(image: Image,point: Vector2,label: String) -> Vector2:
	var snapped := point
	var distance := 999.0
	for y in range(-5,6):
		for x in range(-5,6):
			var candidate := point+Vector2(x,y)
			if Rect2(Vector2.ZERO,Vector2(image.get_size())).has_point(candidate) and image.get_pixelv(Vector2i(candidate)).a>0 and point.distance_to(candidate)<distance:
				distance = point.distance_to(candidate)
				snapped = candidate
	assert(distance<999,"Authored glove misses body: "+label)
	return snapped
