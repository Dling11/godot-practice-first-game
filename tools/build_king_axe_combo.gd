extends SceneTree

const SOURCE := "res://art_source/generated/characters/king/axe_combo_v2_2026_10_04/"
const DEST := "res://assets/characters/playable/king/axe_proof/"
const CELL := Vector2i(192,128)
const SCALE := 0.20
const HANDS := [Vector2(110,284),Vector2(203,294),Vector2(242,214),Vector2(226,151),Vector2(236,83),Vector2(233,118),Vector2(240,261),Vector2(111,284),Vector2(111,103),Vector2(131,151),Vector2(94,60),Vector2(144,52),Vector2(238,258),Vector2(240,260),Vector2(237,212),Vector2(219,255)]
const SUPPORT := [Vector2(85,263),Vector2(163,269),Vector2(222,237),Vector2(184,185),Vector2(208,117),Vector2(208,138),Vector2(197,235),Vector2(87,260),Vector2(108,135),Vector2(127,180),Vector2(89,92),Vector2(105,46),Vector2(201,227),Vector2(204,230),Vector2(197,201),Vector2(178,225)]

func _initialize() -> void:
	var body := Image.load_from_file(SOURCE+"body_source.png")
	var records: Array[Dictionary] = []
	for action in 2:
		var name: String = ["return","finisher"][action]
		var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
		var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
		var primary := PackedVector2Array()
		var secondary := PackedVector2Array()
		for pose in 8:
			var index := action*8+pose
			var start := Vector2i(floori((index%4)*body.get_width()/4.0),floori((index/4)*body.get_height()/4.0))
			var crop := body.get_region(Rect2i(start,Vector2i(271,362)))
			_binary(crop)
			var bounds: Rect2i = crop.get_used_rect()
			var foot := Vector2((bounds.position.x+bounds.end.x)*0.5,bounds.end.y-1)
			crop.resize(roundi(271*SCALE),roundi(362*SCALE),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i(96,96)-Vector2i((foot*SCALE).round())
			var frame := Image.create(192,128,false,Image.FORMAT_RGBA8)
			frame.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),offset)
			var p: Vector2 = (HANDS[index]*SCALE).round()+Vector2(offset)
			var s: Vector2 = (SUPPORT[index]*SCALE).round()+Vector2(offset)
			primary.append(p)
			secondary.append(s)
			var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
			for point in [p,s]:
				var rect := Rect2i(Vector2i(point)-Vector2i(3,3),Vector2i(7,7))
				mask.blit_rect(frame,rect,rect.position)
			var destination := Vector2i(pose%4,pose/4)*CELL
			atlas.blit_rect(frame,Rect2i(Vector2i.ZERO,CELL),destination)
			masks.blit_rect(mask,Rect2i(Vector2i.ZERO,CELL),destination)
			records.append({"action":name,"pose":pose,"source_crop":[start.x,start.y,271,362],"source_floor":[foot.x,foot.y],"offset":[offset.x,offset.y],"primary_hand":[p.x,p.y],"secondary_hand":[s.x,s.y]})
		assert(atlas.save_png(DEST+name+"_body.png")==OK)
		assert(masks.save_png(DEST+name+"_hands.png")==OK)
		var text := "[gd_resource type=\"Resource\" load_steps=5 format=3]\n\n[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
		text += "[ext_resource type=\"Texture2D\" path=\""+DEST+name+"_body.png\" id=\"2\"]\n[ext_resource type=\"Texture2D\" path=\""+DEST+name+"_hands.png\" id=\"3\"]\n[ext_resource type=\"Texture2D\" path=\""+DEST+"iron_beard.png\" id=\"4\"]\n\n[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
		text += "primary_hands = "+_points(primary)+"\nsecondary_hands = "+_points(secondary)+"\nweapon_primary_grip = Vector2(39,33)\nweapon_handle_axis = Vector2(4,10)\nmirror_cutting_edge = "+("false" if action==0 else "true")+"\n"
		if action==0: text += "phase_windows = PackedVector2Array(0,1,2,4,5,7)\n"
		if action==1: text += "lift_pixels = PackedFloat32Array(0,0,-10,-16,0,0,0,0)\nweapon_behind_body = PackedByteArray(0,0,1,1,0,0,0,0)\n"
		FileAccess.open(DEST+name+".tres",FileAccess.WRITE).store_string(text)
	var source := Image.load_from_file(SOURCE+"trail_source.png")
	var trails := Image.create(384,288,false,Image.FORMAT_RGBA8)
	var blue := 0
	for index in 12:
		var crop := source.get_region(Rect2i(Vector2i(index%4,index/4)*362,Vector2i(362,362)))
		_binary(crop)
		crop.resize(84,84,Image.INTERPOLATE_NEAREST)
		for y in 84:
			for x in 84:
				var c := crop.get_pixel(x,y)
				if c.a>0 and c.b-c.r>0.2: blue += 1
		trails.blit_rect(crop,Rect2i(0,0,84,84),Vector2i(index%4,index/4)*96+Vector2i(6,6))
	assert(trails.save_png(DEST+"swing.png")==OK)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"body_source_size":[body.get_width(),body.get_height()],"uniform_body_scale":SCALE,"alpha_threshold":0.65,"frames":records,"trail_source_size":[source.get_width(),source.get_height()],"trail_uniform_size":[84,84],"trail_cell_size":96,"trail_origins":[[48,48],[48,64],[48,48]],"visible_blue_pixels":blue,"lift_logical_pixels":[0,0,-10,-16,0,0,0,0]},"\t")+"\n")
	print("AXE_COMBO_BUILD 16 new body poses / 12 raster slash frames; blue_pixels=",blue)
	quit()

func _binary(picture: Image) -> void:
	for y in picture.get_height():
		for x in picture.get_width():
			var c := picture.get_pixel(x,y)
			c.a = 1 if c.a>=0.65 else 0
			if c.a==0: c = Color(0,0,0,0)
			picture.set_pixel(x,y,c)

func _points(points: PackedVector2Array) -> String:
	var values := PackedStringArray()
	for point in points:
		values.append(str(point.x))
		values.append(str(point.y))
	return "PackedVector2Array("+", ".join(values)+")"
