extends SceneTree

## Deterministic ingestion of modular body art; no runtime image generation.
const SOURCE := "res://art_source/generated/characters/king/greatsword_connected_2026_10_05/"
const DEST := "res://assets/characters/playable/king/greatsword_connected/"
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const STEEL = preload("res://assets/characters/playable/king/huge_greatsword_proof/greatsword.png")
const PROFILE = preload("res://data/weapons/families/royal_greatsword/presentation.tres")
## Protected identity/boots come from the installed cels, not the generator.
const HEADS := [Rect2i(87,41,25,24),Rect2i(90,40,25,24),Rect2i(98,45,25,23),Rect2i(95,43,28,24),Rect2i(82,43,29,24),Rect2i(85,40,29,24),Rect2i(83,41,29,24),Rect2i(83,43,29,23),Rect2i(82,41,29,27),Rect2i(85,39,29,27),Rect2i(85,40,29,27),Rect2i(86,37,29,27)]
const SOCKETS := [Vector2(91,65),Vector2(103,64),Vector2(92,65),Vector2(104,65),Vector2(101,69),Vector2(110,67),Vector2(98,67),Vector2(110,66),Vector2(89,68),Vector2(105,68),Vector2(91,65),Vector2(106,65),Vector2(90,66),Vector2(105,66),Vector2(90,68),Vector2(106,68),Vector2(89,67),Vector2(105,67),Vector2(91,65),Vector2(106,65),Vector2(91,66),Vector2(106,66),Vector2(92,64),Vector2(107,64)]
const NAMES := ["sweep","rise","slam","turn","return"]
## Blade headings, deliberately unwrapped across each stroke.
const ANGLES := [
	[-153.435,-165,-145,-115,-90,-70,-70,-40,-5,30,65,80,80,90,100,105,110,112.5,114,115],
	[115,120,125,115,100,85,85,55,25,-5,-40,-75,-75,-82,-88,-93,-96,-98,-99.5,-100],
	[-100,-120,-145,-130,-110,-90,-90,-55,-20,25,65,90,90,102,114,126,132,136,138.5,140],
	[140,155,175,195,215,230,230,255,280,305,330,350,350,352.5,355,357.5,360,362,363.5,365],
	[365,365,365,368,372,375,375,392,412,435,455,470,470,495,520,540,555,565,566.565,566.565]
]
const GRIPS := [
	[Vector2(-12,-6),Vector2(-10,-7),Vector2(-7,-11),Vector2(-4,-15),Vector2(0,-16),Vector2(3,-14),Vector2(3,-14),Vector2(7,-10),Vector2(11,-4),Vector2(14,3),Vector2(14,8),Vector2(12,12),Vector2(12,12),Vector2(10,13),Vector2(8,13),Vector2(6,13),Vector2(5,13),Vector2(4,13),Vector2(4,13),Vector2(4,13)],
	[Vector2(4,13),Vector2(3,12),Vector2(3,10),Vector2(5,9),Vector2(7,7),Vector2(9,5),Vector2(9,5),Vector2(12,1),Vector2(14,-4),Vector2(14,-9),Vector2(11,-13),Vector2(7,-16),Vector2(7,-16),Vector2(6,-16),Vector2(5,-16),Vector2(4,-16),Vector2(4,-16),Vector2(4,-16),Vector2(4,-16),Vector2(4,-16)],
	[Vector2(4,-16),Vector2(1,-18),Vector2(-3,-18),Vector2(-4,-20),Vector2(-2,-20),Vector2(0,-18),Vector2(0,-18),Vector2(4,-12),Vector2(8,-5),Vector2(11,3),Vector2(11,10),Vector2(8,14),Vector2(8,14),Vector2(5,14),Vector2(1,13),Vector2(-2,12),Vector2(-5,11),Vector2(-5,11),Vector2(-5,11),Vector2(-5,11)],
	[Vector2(-5,11),Vector2(-8,8),Vector2(-10,3),Vector2(-9,-3),Vector2(-6,-7),Vector2(-2,-9),Vector2(-2,-9),Vector2(3,-9),Vector2(8,-6),Vector2(12,-2),Vector2(14,2),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5)],
	[Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(13,5),Vector2(14,7),Vector2(13,10),Vector2(10,13),Vector2(6,14),Vector2(2,13),Vector2(2,13),Vector2(-3,12),Vector2(-7,9),Vector2(-10,5),Vector2(-12,0),Vector2(-12,-4),Vector2(-12,-6),Vector2(-12,-6)]
]
const CELLS := [
	[0,0,1,1,1,1,1,2,2,2,3,3,3,3,3,3,3,3,3,3],
	[3,3,3,3,2,2,2,2,2,0,0,0,0,0,0,0,0,0,0,0],
	[0,0,1,1,1,0,0,2,2,3,3,3,3,3,3,3,3,3,3,3],
	[3,3,1,1,1,1,1,1,2,2,2,2,2,2,2,2,2,2,2,2],
	[2,2,2,2,2,2,2,2,2,3,3,3,3,3,3,3,0,0,0,0]
]
var bodies: Array[Image] = []
var sockets: Array[PackedVector2Array] = []
var density := 0.0
var audit: Array[Dictionary] = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var source := Image.load_from_file(SOURCE+"modular_source.png")
	var protected := Image.load_from_file(SOURCE+"protected_body_reference.png")
	assert(source!=null)
	_binary(source)
	var cell := Vector2i(source.get_width()/4,source.get_height()/4)
	# The generator's row baselines are not equal to nominal 256px cells.
	# Explicit empty-gutter bands preserve complete boots and detached limbs.
	var bands := [0,256,512,768,1024]
	var first := source.get_region(Rect2i(0,0,cell.x,bands[1])).get_used_rect()
	density = 54.0/first.size.y
	for row in 3:
		for column in 4:
			var part := source.get_region(Rect2i(column*cell.x,bands[row],cell.x,bands[row+1]-bands[row]))
			var bounds := part.get_used_rect()
			assert(bounds.size.y>50 and bounds.size.x<cell.x-10,"Source has an opaque background or crossed cells")
			var crop := part.get_region(bounds)
			crop.resize(roundi(bounds.size.x*density),roundi(bounds.size.y*density),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i(roundi(96+(bounds.position.x-cell.x*.5)*density),95-crop.get_height()+1)
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),offset)
			var body_key := row*4+column
			var original := protected.get_region(Rect2i(column*192,row*128,192,128))
			# Keep all original head/face pixels and planted boots. Clear the
			# remaining upper space so no raised baked fist survives the edit.
			for y in HEADS[body_key].end.y:
				for x in 192: body.set_pixel(x,y,Color.TRANSPARENT)
			body.blit_rect(original,HEADS[body_key],HEADS[body_key].position)
			body.blit_rect(original,Rect2i(0,86,192,42),Vector2i(0,86))
			# Preserve the original scarf and compact central cloth, excluding
			# brown skin/gloves that would duplicate the new rig's hands.
			for y in range(64,86):
				for x in range(91,108):
					var c := original.get_pixel(x,y)
					var leather := c.r>c.g*1.35 and c.g>c.b*1.2
					if c.a>.5 and not leather: body.set_pixel(x,y,c)
			var shoulders := PackedVector2Array([SOCKETS[body_key*2],SOCKETS[body_key*2+1]])
			if shoulders.size()!=2:
				push_error("Missing sockets in row %d column %d"%[row,column])
				quit(1)
				return
			bodies.append(body)
			sockets.append(shoulders)
			audit.append({"row":row,"column":column,"crop":var_to_str(bounds),"offset":var_to_str(offset),"sockets":var_to_str(shoulders),"protected_head":var_to_str(HEADS[body_key]),"protected_boots_y":86})
	for column in 3:
		var part := source.get_region(Rect2i(column*cell.x,bands[3],cell.x,bands[4]-bands[3]))
		var limb := part.get_region(part.get_used_rect())
		limb.resize([7,6,5][column],[14,15,5][column],Image.INTERPOLATE_NEAREST)
		assert(limb.save_png(DEST+["upper","forearm","glove"][column]+".png")==OK)
	for direction in ["side","up","down"]: _direction(direction)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"body_density":density,"foot_y":95,"limb_sizes":[[7,14],[6,15],[5,5]],"steel":STEEL.resource_path,"steel_size":[30,140],"source_frames":audit},"\t")+"\n")
	print("CONNECTED_GREATSWORD_BUILD fifteen twenty-key tracks / rigid original steel / registered modular arms")
	quit()

func _binary(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			image.set_pixel(x,y,Color(c.r,c.g,c.b,1) if c.a>=.65 else Color.TRANSPARENT)

func _direction(direction: String) -> void:
	var folder := DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var row := 0 if direction=="side" else (2 if direction=="up" else 1)
	var idle: Resource = PROFILE.idle_for(Vector2.RIGHT if direction=="side" else (Vector2.UP if direction=="up" else Vector2.DOWN))
	var clips: Array[Resource] = []
	for cut in 5:
		var clip := Definition.new()
		clip.pose_count = 20
		clip.pose_order = PackedInt32Array(range(20))
		clip.weapon_texture = STEEL
		clip.weapon_primary_grip = Vector2(15,113)
		clip.weapon_support_grip = Vector2(15,126)
		clip.weapon_tip = Vector2(15,0)
		clip.mirror_cutting_edge = false
		clip.maximum_lift_pixels = 48
		clip.lift_pixels = PackedFloat32Array()
		clip.phase_windows = PackedVector2Array([Vector2(0,5),Vector2(6,11),Vector2(12,19)])
		for property in ["weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
			var flags := PackedByteArray()
			flags.resize(20)
			clip.set(property,flags)
		var atlas := Image.create(768,640,false,Image.FORMAT_RGBA8)
		var mask := Image.create(768,640,false,Image.FORMAT_RGBA8)
		for key in 20:
			var body_key: int = row*4+CELLS[cut][key]
			var primary: Vector2 = GRIPS[cut][key]+Vector2(96,64)
			var blade_angle: float = deg_to_rad(ANGLES[cut][key])
			# Front/back views use their own bodies with a projected stroke;
			# retain the same descending/rising sense and continuous grips.
			if direction!="side":
				primary.x = 96+(primary.x-96)*.65
				blade_angle += PI*.5 if direction=="down" else -PI*.5
			if cut==0 and key==0:
				primary = idle.primary_hands[0]
				var target: float = (idle.secondary_hands[0]-primary).angle()+PI
				blade_angle += wrapf(target-blade_angle,-PI,PI)
			if cut==0 and key>0 and key<5 and direction!="side":
				primary = idle.primary_hands[0].lerp(primary,float(key)/5)
				var target: float = (idle.secondary_hands[0]-idle.primary_hands[0]).angle()+PI
				var initial: float = deg_to_rad(ANGLES[0][0])+(PI*.5 if direction=="down" else -PI*.5)
				initial += wrapf(target-initial,-PI,PI)
				blade_angle = lerpf(initial,deg_to_rad(ANGLES[0][5])+(PI*.5 if direction=="down" else -PI*.5),float(key)/5)
			if cut==4 and key>=18:
				primary = idle.primary_hands[0]
				var target: float = (idle.secondary_hands[0]-primary).angle()+PI
				blade_angle += wrapf(target-blade_angle,-PI,PI)
			var shaft := Vector2.from_angle(blade_angle+PI)
			clip.primary_hands.append(primary)
			clip.secondary_hands.append(primary+shaft*13)
			clip.weapon_angles.append(blade_angle+PI*.5)
			clip.near_shoulders.append(sockets[body_key][0])
			clip.far_shoulders.append(sockets[body_key][1])
			clip.support_weights.append([0,.35,.7,1,1,1][key] if cut==0 and key<6 else ([.5,.1,0][key-17] if cut==4 and key>=17 else 1.0))
			clip.lift_pixels.append([0,-2,-6,-12,-6,0][key] if cut==2 and key<6 else 0.0)
			# Exposure gives the load a readable hold and accelerates through
			# the center of contact. Recovery retains motion rather than a hold.
			clip.pose_weights.append([1.1,1.1,1.2,1.2,.9,.5, .5,.8,1.2,1.3,1.3,.9, 1.1,1.1,1.1,1.1,1,1,.8,.8][key])
			atlas.blit_rect(bodies[body_key],Rect2i(0,0,192,128),Vector2i(key%4,key/4)*Vector2i(192,128))
		# Register reachable wrists against both adjacent torso cels. The
		# physical hilt spacing stays fixed; move the whole grip a few pixels
		# instead of stretching an arm or inventing another hand position.
		for key in range(1,18):
			var primary: Vector2 = clip.primary_hands[key]
			var offset := Vector2.DOWN.rotated(clip.weapon_angles[key])*13
			for iteration in 8:
				for socket_key in [key,key-1]:
					for socket in [clip.near_shoulders[socket_key],clip.far_shoulders[socket_key]-offset]:
						var delta: Vector2 = primary-socket
						if delta.length()>26.5: primary = socket+delta.normalized()*26.5
			clip.primary_hands[key] = primary
			clip.secondary_hands[key] = primary+offset
		# Exact complete recovery→opening body/sockets/grips, for all four
		# links. Unlike the previous hold, recovery travels into this endpoint.
		if cut>0:
			var previous: Resource = clips[cut-1]
			for property in ["primary_hands","secondary_hands","near_shoulders","far_shoulders","weapon_angles","support_weights","lift_pixels"]:
				var values = clip.get(property)
				values[0] = previous.get(property)[19]
				clip.set(property,values)
			var previous_body: Image = previous.get_meta("atlas")
			atlas.blit_rect(previous_body,Rect2i(3*192,4*128,192,128),Vector2i.ZERO)
		clip.set_meta("atlas",atlas)
		assert(atlas.save_png(folder+NAMES[cut]+"_body.png")==OK)
		assert(mask.save_png(folder+NAMES[cut]+"_hands.png")==OK)
		clips.append(clip)
	for cut in 5: _write(folder,NAMES[cut],clips[cut],NAMES.slice(1) if cut==0 else [])

func _write(folder: String, label: String, clip: Resource, followups: Array) -> void:
	var text := "[gd_resource type=\"Resource\" load_steps="+str(8+followups.size())+" format=3]\n"
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",STEEL.resource_path,DEST+"upper.png",DEST+"forearm.png",DEST+"glove.png"]
	for index in paths.size(): text += "[ext_resource type=\""+("Script" if index==0 else "Texture2D")+"\" path=\""+paths[index]+"\" id=\""+str(index+1)+"\"]\n"
	for index in followups.size(): text += "[ext_resource type=\"Resource\" path=\""+folder+followups[index]+".tres\" id=\""+str(index+8)+"\"]\n"
	text += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\narm_upper_texture = ExtResource(\"5\")\narm_forearm_texture = ExtResource(\"6\")\narm_hand_texture = ExtResource(\"7\")\n"
	for property in ["pose_count","pose_order","primary_hands","secondary_hands","weapon_primary_grip","weapon_support_grip","weapon_tip","mirror_cutting_edge","phase_windows","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","lift_pixels","maximum_lift_pixels","pose_weights","weapon_angles","near_shoulders","far_shoulders","support_weights"]:
		text += property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		text += "follow_up_clips = Array[Resource](["
		for index in followups.size(): text += ("," if index>0 else "")+"ExtResource(\""+str(index+8)+"\")"
		text += "])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(text)
	if folder.ends_with("side/") and label=="sweep":
		FileAccess.open("res://data/weapons/families/royal_greatsword/poses.tres",FileAccess.WRITE).store_string(text)
