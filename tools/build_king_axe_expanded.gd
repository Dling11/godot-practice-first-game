extends SceneTree

## Deterministic registration of untouched generated sources, not painted art.
const SOURCE := "res://art_source/generated/characters/king/axe_expanded_v3_2026_10_04/"
const DEST := "res://assets/characters/playable/king/axe_proof_v3/"
const OLD := "res://assets/characters/playable/king/axe_proof/"
const CARRY_HANDS := [Vector2(305,335),Vector2(266,298),Vector2(282,331),Vector2(283,329),Vector2(131,131),Vector2(131,171),Vector2(122,174),Vector2(101,178)]
const HANDS := [Vector2(110,222),Vector2(88,212),Vector2(273,174),Vector2(270,170),Vector2(307,128),Vector2(280,161),Vector2(270,183),Vector2(104,198),Vector2(105,209),Vector2(245,169),Vector2(273,143),Vector2(45,138),Vector2(62,122),Vector2(282,146),Vector2(270,150),Vector2(221,199)]
const SUPPORT := [Vector2(81,196),Vector2(67,194),Vector2(197,194),Vector2(237,172),Vector2(260,148),Vector2(228,185),Vector2(215,172),Vector2(79,171),Vector2(72,171),Vector2(179,174),Vector2(238,143),Vector2(80,138),Vector2(95,122),Vector2(250,155),Vector2(219,157),Vector2(198,180)]
var records: Array[Dictionary] = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var carry := Image.load_from_file(SOURCE+"carry_source.png")
	var actions := Image.load_from_file(SOURCE+"actions_source.png")
	_register("carry",carry,0,Vector2i(384,512),0.13,CARRY_HANDS,[],PackedByteArray([1,1,1,1,1,1,1,1]),true)
	_register("side",actions,0,Vector2i(305,322),0.22,HANDS,SUPPORT,PackedByteArray([0,0,0,1,0,0,0,0]),false)
	_register("spin",actions,8,Vector2i(305,322),0.22,HANDS,SUPPORT,PackedByteArray([0,0,1,1,1,0,0,0]),false)
	var down := FileAccess.get_file_as_string(OLD+"poses.tres")
	down = down.replace("load_steps=7","load_steps=5")
	var filtered := PackedStringArray()
	for line in down.split("\n"):
		if not line.contains("follow_up_clips") and not line.contains("id=\"5\"") and not line.contains("id=\"6\""): filtered.append(line)
	FileAccess.open(DEST+"down.tres",FileAccess.WRITE).store_string("\n".join(filtered))
	var side := FileAccess.get_file_as_string(DEST+"side.tres").replace("load_steps=5","load_steps=9")
	var extras := ""
	for pair in [[OLD+"return.tres","5"],[DEST+"down.tres","6"],[OLD+"finisher.tres","7"],[DEST+"spin.tres","8"]]:
		extras += "[ext_resource type=\"Resource\" path=\""+pair[0]+"\" id=\""+pair[1]+"\"]\n"
	side = side.replace("[resource]",extras+"\n[resource]")
	side += "follow_up_clips = Array[Resource]([ExtResource(\"5\"),ExtResource(\"6\"),ExtResource(\"7\"),ExtResource(\"8\")])\n"
	FileAccess.open(DEST+"side.tres",FileAccess.WRITE).store_string(side)
	var new_trails := Image.load_from_file(SOURCE+"trail_source.png")
	var old_trails := Image.load_from_file("res://art_source/generated/characters/king/axe_combo_v2_2026_10_04/trail_source.png")
	var atlas := Image.create(512,640,false,Image.FORMAT_RGBA8)
	for row in 5:
		for frame in 4:
			var new_row := 0 if row==0 else 1
			var old_row: int = [0,1,0,2,0][row]
			var crop: Image
			if row in [0,4]:
				crop = new_trails.get_region(Rect2i(Vector2i(frame*443+10,new_row*443+10),Vector2i(423,423)))
			else:
				crop = old_trails.get_region(Rect2i(Vector2i(frame*362,old_row*362),Vector2i(362,362)))
			_binary(crop)
			crop.resize(112,112,Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(crop,Rect2i(0,0,112,112),Vector2i(frame*128+8,row*128+8))
	assert(atlas.save_png(DEST+"swing.png")==OK)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"frames":records,"trail_cell":[128,128],"trail_rows":["side","rise","down","hop","spin"],"world_pixels_per_texel":1.4,"contact_forward_reach":72,"spin_radius":68,"alpha_threshold":0.65},"\t")+"\n")
	print("AXE_EXPANDED_BUILD 24 new poses / 20 FX frames; shared V2 preserved")
	quit()

func _register(name: String,source: Image,first: int,source_cell: Vector2i,ratio: float,hands: Array,support: Array,one_hand: PackedByteArray,idle: bool) -> void:
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var primary := PackedVector2Array()
	var secondary := PackedVector2Array()
	for pose in 8:
		var index := first+pose
		var stowed := idle and pose>=6
		var source_index := 0 if stowed else index
		var start := Vector2i(floori(source_index%4*source.get_width()/4.0),floori(source_index/4*source.get_height()/(2.0 if idle else 4.0)))
		# Generated fist in side pose4 crosses the nominal cell edge by 9px.
		var size := source_cell
		if not idle and index==4: size.x = 331
		var crop := source.get_region(Rect2i(start,size))
		_binary(crop)
		var bounds := crop.get_used_rect()
		var foot := Vector2((bounds.position.x+bounds.end.x)*0.5,bounds.end.y-1)
		crop.resize(roundi(size.x*ratio),roundi(size.y*ratio),Image.INTERPOLATE_NEAREST)
		var offset := Vector2i(96,96)-Vector2i((foot*ratio).round())
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),offset)
		var p: Vector2 = (Vector2(hands[index])*ratio).round()+Vector2(offset)
		var s: Vector2
		if idle:
			var axis := Vector2(-28,4) if pose<4 else Vector2(24,5)
			s = p+(axis*ratio).round()
		else: s = (Vector2(support[index])*ratio).round()+Vector2(offset)
		if stowed:
			p = Vector2(91,78)
			s = Vector2(97,81)
		primary.append(p)
		secondary.append(s)
		var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
		for point in ([] if stowed else ([p] if one_hand[pose] else [p,s])):
			var rect := Rect2i(Vector2i(point)-Vector2i(2,2),Vector2i(5,5))
			mask.blit_rect(body,rect,rect.position)
		var destination := Vector2i(pose%4,pose/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),destination)
		masks.blit_rect(mask,Rect2i(0,0,192,128),destination)
		records.append({"clip":name,"pose":pose,"source_crop":[start.x,start.y,size.x,size.y],"scale":ratio,"floor":[foot.x,foot.y],"offset":[offset.x,offset.y],"primary":[p.x,p.y],"secondary":[s.x,s.y],"single_hand":bool(one_hand[pose]),"stowed":stowed})
	assert(atlas.save_png(DEST+name+"_body.png")==OK)
	assert(masks.save_png(DEST+name+"_hands.png")==OK)
	var text := "[gd_resource type=\"Resource\" load_steps=5 format=3]\n\n[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+DEST+name+"_body.png\" id=\"2\"]\n[ext_resource type=\"Texture2D\" path=\""+DEST+name+"_hands.png\" id=\"3\"]\n[ext_resource type=\"Texture2D\" path=\""+OLD+"iron_beard.png\" id=\"4\"]\n\n[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	text += "primary_hands = "+_points(primary)+"\nsecondary_hands = "+_points(secondary)+"\nweapon_primary_grip = Vector2(39,33)\nweapon_handle_axis = Vector2(4,10)\n"
	text += "single_hand_poses = PackedByteArray("+", ".join(Array(one_hand).map(func(v):return str(v)))+")\n"
	if idle: text += "weapon_behind_body = PackedByteArray(0,0,0,0,1,1,1,1)\nstowed_poses = PackedByteArray(0,0,0,0,0,0,1,1)\n"
	if name=="spin": text += "phase_windows = PackedVector2Array(0,1,2,5,6,7)\nweapon_behind_body = PackedByteArray(0,0,0,0,1,1,0,0)\n"
	if name=="side": text += "phase_windows = PackedVector2Array(0,1,2,5,6,7)\n"
	FileAccess.open(DEST+name+".tres",FileAccess.WRITE).store_string(text)

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
