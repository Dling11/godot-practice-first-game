extends SceneTree

## Offline registration; preserve original PNGs and use a shared body pixel scale.
const SOURCE := "res://art_source/generated/characters/king/huge_greatsword_2026_10_04/"
const DEST := "res://assets/characters/playable/king/huge_greatsword_proof/"
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const SCALE := 0.20
## Reviewed glove edge corrections after nearest-neighbor registration.
const HAND_CORRECTIONS := {"sweep/3":[Vector2(-1,-1),Vector2.ZERO],"rise/3":[Vector2(-1,0),Vector2.ZERO],"turn/3":[Vector2(-2,-1),Vector2.ZERO],"turn/6":[Vector2(0,-1),Vector2.ZERO],"turn/7":[Vector2(0,-4),Vector2(0,-2)]}
const HANDS_1 := [Vector2(175,236),Vector2(95,217),Vector2(220,215),Vector2(262,184),Vector2(328,199),Vector2(289,244),Vector2(241,211),Vector2(167,226),Vector2(172,228),Vector2(180,228),Vector2(250,194),Vector2(254,144),Vector2(290,43),Vector2(255,33),Vector2(255,180),Vector2(170,185)]
const SUPPORT_1 := [Vector2(147,228),Vector2(117,233),Vector2(200,215),Vector2(223,187),Vector2(300,176),Vector2(260,228),Vector2(225,185),Vector2(140,216),Vector2(148,209),Vector2(193,248),Vector2(227,201),Vector2(234,152),Vector2(250,90),Vector2(236,55),Vector2(227,160),Vector2(138,165)]
const HANDS_2 := [Vector2(191,244),Vector2(166,62),Vector2(166,44),Vector2(145,43),Vector2(186,70),Vector2(242,274),Vector2(268,256),Vector2(178,263),Vector2(165,220),Vector2(90,222),Vector2(80,195),Vector2(270,226),Vector2(307,184),Vector2(310,169),Vector2(198,233),Vector2(176,247)]
const SUPPORT_2 := [Vector2(168,229),Vector2(199,78),Vector2(199,55),Vector2(180,48),Vector2(221,74),Vector2(220,254),Vector2(242,234),Vector2(151,248),Vector2(141,203),Vector2(120,229),Vector2(105,213),Vector2(246,215),Vector2(281,180),Vector2(284,161),Vector2(174,221),Vector2(154,233)]
var records: Array[Dictionary] = []
var grip := Vector2.ZERO

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var sword := Image.load_from_file(SOURCE+"weapon_source.png")
	_binary(sword)
	var bounds := sword.get_used_rect()
	var ratio := 140.0/bounds.size.y
	var crop := sword.get_region(bounds)
	crop.resize(roundi(bounds.size.x*ratio),140,Image.INTERPOLATE_NEAREST)
	grip = ((Vector2(512,1220)-Vector2(bounds.position))*ratio).round()
	assert(crop.save_png(DEST+"greatsword.png")==OK)
	for sheet in 2:
		var image := Image.load_from_file(SOURCE+"body_%d_source.png" % (sheet+1))
		_binary(image)
		var components := _bodies(image)
		for action in 2:
			_register(["sweep","rise","meteor","turn"][sheet*2+action],image,components,action*8,HANDS_1 if sheet==0 else HANDS_2,SUPPORT_1 if sheet==0 else SUPPORT_2)
	var text := FileAccess.get_file_as_string(DEST+"sweep.tres").replace("load_steps=5","load_steps=8")
	var references := ""
	for index in 3: references += "[ext_resource type=\"Resource\" path=\""+DEST+["rise","meteor","turn"][index]+".tres\" id=\""+str(index+5)+"\"]\n"
	text = text.replace("[resource]",references+"\n[resource]")
	text += "follow_up_clips = Array[Resource]([ExtResource(\"5\"),ExtResource(\"6\"),ExtResource(\"7\")])\n"
	FileAccess.open(DEST+"sweep.tres",FileAccess.WRITE).store_string(text)
	var slash := Image.load_from_file(SOURCE+"slash_source.png")
	_binary(slash)
	var trails := Image.create(1024,1024,false,Image.FORMAT_RGBA8)
	for index in 16:
		var start := Vector2i(floori(index%4*slash.get_width()/4.0),floori(index/4*slash.get_height()/4.0))
		var part := slash.get_region(Rect2i(start,Vector2i(336,291)))
		part.resize(202,175,Image.INTERPOLATE_NEAREST)
		trails.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),Vector2i(index%4,index/4)*256+Vector2i(27,40))
	assert(trails.save_png(DEST+"swing.png")==OK)
	var impact := Image.load_from_file(SOURCE+"impact_source.png")
	_binary(impact)
	var impacts := Image.create(768,384,false,Image.FORMAT_RGBA8)
	for index in 8:
		var part := impact.get_region(Rect2i(Vector2i(index%4,index/4)*443,Vector2i(443,443)))
		var origin := Vector2(221,290) if index<4 else Vector2(221,[342,363,360,356][index-4])
		var target := Vector2i(96,96) if index<4 else Vector2i(96,148)
		part.resize(168,168,Image.INTERPOLATE_NEAREST)
		var offset := target-Vector2i((origin*(168.0/443.0)).round())
		impacts.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),Vector2i(index%4,index/4)*192+offset)
	assert(impacts.save_png(DEST+"impact.png")==OK)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"body_scale":SCALE,"alpha_threshold":0.65,"frames":records,"weapon_source_crop":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"weapon_size":[crop.get_width(),140],"weapon_grip":[grip.x,grip.y],"slash_cell_size":256,"slash_world_scale":1.0,"impact_origins":[[96,96],[96,148]]},"\t")+"\n")
	print("HUGE_GREATSWORD_BUILD 32 registered body poses / 16 slash / 8 impact frames; rigid blade=",crop.get_size()," grip=",grip)
	quit()

func _bodies(image: Image) -> Dictionary:
	# Generated anatomy crosses nominal cell boundaries: isolate real silhouettes.
	var width := image.get_width()
	var height := image.get_height()
	var visited := PackedByteArray()
	visited.resize(width*height)
	var output := {}
	for pixel in width*height:
		if visited[pixel]: continue
		visited[pixel] = 1
		if image.get_pixel(pixel%width,pixel/width).a==0: continue
		var pending := PackedInt32Array([pixel])
		var head := 0
		var minimum := Vector2i(pixel%width,pixel/width)
		var maximum := minimum
		while head<pending.size():
			var current := pending[head]
			head += 1
			var point := Vector2i(current%width,current/width)
			minimum = minimum.min(point)
			maximum = maximum.max(point)
			for dy in range(-1,2):
				for dx in range(-1,2):
					var next := point+Vector2i(dx,dy)
					if next.x<0 or next.y<0 or next.x>=width or next.y>=height: continue
					var id := next.y*width+next.x
					if visited[id]: continue
					visited[id] = 1
					if image.get_pixelv(next).a>0: pending.append(id)
		if pending.size()<2000: continue
		var rect := Rect2i(minimum,maximum-minimum+Vector2i.ONE)
		var center := rect.get_center()
		var index := clampi(int(center.y/(height/4.0)),0,3)*4+clampi(int(center.x/(width/4.0)),0,3)
		assert(not output.has(index),"Overlapping main silhouettes; manual source review required")
		output[index] = rect
	assert(output.size()==16,"Missing body silhouettes")
	return output

func _register(name: String,image: Image,components: Dictionary,first: int,hands: Array,support: Array) -> void:
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
		part.resize(roundi(rect.size.x*SCALE),roundi(rect.size.y*SCALE),Image.INTERPOLATE_NEAREST)
		var offset := Vector2i(96,96)-Vector2i((foot*SCALE).round())
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
		var nominal := Vector2(floorf(index%4*image.get_width()/4.0),floorf(index/4*image.get_height()/4.0))
		var p: Vector2 = ((Vector2(hands[index])+nominal-Vector2(rect.position))*SCALE).round()+Vector2(offset)
		var s: Vector2 = ((Vector2(support[index])+nominal-Vector2(rect.position))*SCALE).round()+Vector2(offset)
		var correction: Array = HAND_CORRECTIONS.get(name+"/"+str(pose),[Vector2.ZERO,Vector2.ZERO])
		p += correction[0]
		s += correction[1]
		primary.append(p)
		secondary.append(s)
		var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
		for point in [p,s]:
			var glove := Rect2i(Vector2i(point)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,glove,glove.position)
		var destination := Vector2i(pose%4,pose/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),destination)
		masks.blit_rect(mask,Rect2i(0,0,192,128),destination)
		records.append({"clip":name,"pose":pose,"source_crop":[rect.position.x,rect.position.y,rect.size.x,rect.size.y],"support_floor":[foot.x,foot.y],"offset":[offset.x,offset.y],"primary":[p.x,p.y],"secondary":[s.x,s.y]})
	assert(atlas.save_png(DEST+name+"_body.png")==OK)
	assert(masks.save_png(DEST+name+"_hands.png")==OK)
	var text := "[gd_resource type=\"Resource\" load_steps=5 format=3]\n\n[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+DEST+name+"_body.png\" id=\"2\"]\n[ext_resource type=\"Texture2D\" path=\""+DEST+name+"_hands.png\" id=\"3\"]\n[ext_resource type=\"Texture2D\" path=\""+DEST+"greatsword.png\" id=\"4\"]\n\n[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	text += "primary_hands = "+_points(primary)+"\nsecondary_hands = "+_points(secondary)+"\nweapon_primary_grip = Vector2("+str(grip.x)+","+str(grip.y)+")\nweapon_handle_axis = Vector2(0,1)\nmirror_cutting_edge = false\n"
	if name=="meteor": text += "maximum_lift_pixels = 48.0\nlift_pixels = PackedFloat32Array(0,0,-12,-36,-16,0,0,0)\nphase_windows = PackedVector2Array(0,4,5,6,7,7)\nweapon_behind_body = PackedByteArray(0,1,1,1,1,0,0,0)\n"
	elif name=="turn": text += "phase_windows = PackedVector2Array(0,2,3,5,6,7)\nweapon_behind_body = PackedByteArray(0,1,1,0,0,0,0,0)\n"
	elif name=="rise": text += "phase_windows = PackedVector2Array(0,1,2,5,6,7)\n"
	FileAccess.open(DEST+name+".tres",FileAccess.WRITE).store_string(text)

func _binary(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x,y)
			color.a = 1 if color.a>=0.65 else 0
			if color.a==0: color = Color(0,0,0,0)
			image.set_pixel(x,y,color)

func _points(points: PackedVector2Array) -> String:
	var values := PackedStringArray()
	for point in points:
		values.append(str(point.x))
		values.append(str(point.y))
	return "PackedVector2Array("+", ".join(values)+")"
