extends "res://tools/weapon_sprite_sheet_extractor.gd"

const LOW_SOURCE := "res://art_source/generated/characters/king/greatsword_low_return_2026_10_05/"
const DEST := "res://assets/characters/playable/king/greatsword_low_return/"
const TURN = preload("res://assets/characters/playable/king/huge_greatsword_proof/turn.tres")
const IDLE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
# Source5 resets the arms toward the front; omit it from the chronological path.
const SOURCE_ORDER := [0,1,2,3,4,6,7,8,9,10,11]
const ANGLES := [15,30,50,75,100,130,155,170,185,200,207]
const GLOVE_CENTERS := [Vector2(286,207),Vector2(287,235),Vector2(263,261),Vector2(225,280),Vector2(180,285),Vector2.ZERO,Vector2(155,279),Vector2(127,270),Vector2(154,256),Vector2(149,248),Vector2(266,171),Vector2(170,117)]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var endpoint := _cell(TURN,5)
	var carry := _cell(IDLE,0)
	var source := Image.load_from_file(LOW_SOURCE+"body_source.png")
	var frames := _extract_frames(source,4,3)
	var feet := _foot_heights.duplicate()
	var faces := _face_centers.duplicate()
	var old_face := _skin_center(endpoint)
	var density := (95.0-old_face.y)/(feet[0]-faces[0].y)
	var atlas := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var masks := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var clip := Definition.new()
	clip.pose_count = 16
	clip.pose_order.resize(16)
	for index in 16: clip.pose_order[index] = index
	for property in ["lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		var values = clip.get(property)
		values.resize(16)
		values.fill(0)
		clip.set(property,values)
	clip.weapon_texture = TURN.weapon_texture
	clip.weapon_primary_grip = TURN.weapon_primary_grip
	clip.weapon_tip = Vector2(15,0)
	clip.mirror_cutting_edge = false
	clip.phase_windows = PackedVector2Array([Vector2(0,1),Vector2(2,6),Vector2(7,15)])
	clip.pose_weights = PackedFloat32Array([1,1,1,1,1,1,1,0.08,0.08,0.08,0.08,0.22,0.24,0.10,0.04,0.08])
	clip.interpolate_weapon = true
	var audit: Array[Dictionary] = []
	for index in 16:
		var body: Image
		var hands := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var primary: Vector2
		var secondary: Vector2
		var recorded_source := -1
		if index<2 or index>=13:
			var existing: Resource = TURN if index<2 else IDLE
			var key := 5 if index<2 else 0
			body = _cell(existing,key)
			hands = existing.hand_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*Vector2i(192,128),Vector2i(192,128)))
			primary = existing.primary_hands[key]
			secondary = existing.secondary_hands[key]
			clip.single_hand_poses[index] = existing.single_hand_poses[key]
		else:
			var source_index: int = 11 if index>=11 else SOURCE_ORDER[index-2]
			recorded_source = source_index
			var part: Image = frames[source_index].duplicate()
			var offset := Vector2i(roundi(old_face.x-(faces[source_index].x)*density),roundi(95-feet[source_index]*density))
			var expected: Vector2 = GLOVE_CENTERS[source_index]*float(source.get_width())/4.0/360.0+Vector2(96,96)
			expected = expected*density+Vector2(offset)
			part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
			var generated := Image.create(192,128,false,Image.FORMAT_RGBA8)
			generated.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
			if index>=11:
				var raised := _brown_near(generated,expected,8)
				var target := Vector2(89,71) if index==11 else Vector2(85,61)
				var shifted := Image.create(192,128,false,Image.FORMAT_RGBA8)
				shifted.blit_rect(generated,Rect2i(0,0,192,128),Vector2i(target-raised))
				generated = shifted
				expected = target
			# Keep the actual King's head and planted boots, rather than accepting
			# a generated replacement character. Only torso/arm motion is new.
			body = endpoint.duplicate()
			body.blit_rect(generated,Rect2i(74,67,60,14),Vector2i(74,67))
			# Local arm patches retain the entire accepted planted stance, avoiding
			# disconnected boots when generated knee/foot positions differ.
			var hand_patch := Rect2i(Vector2i(expected)-Vector2i(9,9),Vector2i(19,19))
			body.blend_rect(generated,hand_patch,hand_patch.position)
			if index>=11: body.blit_rect(generated,Rect2i(73,49,21,20),Vector2i(73,49))
			var head_rect := Rect2i(94,44,28,23)
			body.blit_rect(endpoint,head_rect,head_rect.position)
			for y in 128:
				for x in 192:
					var color := body.get_pixel(x,y)
					color.a = 1 if color.a>=0.65 else 0
					body.set_pixel(x,y,color if color.a>0 else Color.TRANSPARENT)
			var angle := deg_to_rad(ANGLES[index-2])
			primary = _brown_near(body,expected,8)
			# Late lift becomes one-handed, as in the accepted shoulder carry.
			if index>=6:
				secondary = primary-Vector2.from_angle(angle)*7
				clip.single_hand_poses[index] = 1
			else:
				var pair := _grip_pair(body,expected,-Vector2.from_angle(angle))
				if pair.is_empty():
					quit(1)
					return
				primary = pair[0]
				secondary = pair[1]
			for point in ([primary] if clip.single_hand_poses[index]>0 else [primary,secondary]):
				var rect := Rect2i(Vector2i(point)-Vector2i(3,3),Vector2i(7,7))
				hands.blit_rect(body,rect,rect.position)
		clip.primary_hands.append(primary)
		clip.secondary_hands.append(secondary)
		var destination := Vector2i(index%4,index/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),destination)
		masks.blit_rect(hands,Rect2i(0,0,192,128),destination)
		audit.append({"pose":index,"source":recorded_source,"primary":[primary.x,primary.y],"secondary":[secondary.x,secondary.y],"blade_degrees":rad_to_deg((primary-secondary).angle()),"one_hand":clip.single_hand_poses[index]>0,"verbatim_boundary":index<2 or index>=13})
	assert(atlas.save_png(DEST+"return_body.png")==OK)
	assert(masks.save_png(DEST+"return_hands.png")==OK)
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(masks)
	assert(clip.has_valid_layout())
	var text := "[gd_resource type=\"Resource\" load_steps=5 format=3]\n\n[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	text += "[ext_resource type=\"Texture2D\" path=\""+DEST+"return_body.png\" id=\"2\"]\n[ext_resource type=\"Texture2D\" path=\""+DEST+"return_hands.png\" id=\"3\"]\n[ext_resource type=\"Texture2D\" path=\""+TURN.weapon_texture.resource_path+"\" id=\"4\"]\n\n[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\npose_count = 16\n"
	for property in ["pose_order","primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		text += property+" = "+var_to_str(clip.get(property))+"\n"
	text += "weapon_primary_grip = Vector2(15,113)\nweapon_handle_axis = Vector2(0,1)\nweapon_tip = Vector2(15,0)\nmirror_cutting_edge = false\nphase_windows = PackedVector2Array(0,1,2,6,7,15)\n"
	text += "pose_weights = "+var_to_str(clip.pose_weights)+"\ninterpolate_weapon = true\n"
	FileAccess.open(DEST+"return.tres",FileAccess.WRITE).store_string(text)
	FileAccess.open(LOW_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"density":density,"head_protection":[94,44,28,23],"stance_base":"existing fourth, local torso/arm patches only","keys":audit},"\t")+"\n")
	var large := atlas.duplicate()
	large.resize(1536,1024,Image.INTERPOLATE_NEAREST)
	assert(large.save_png(LOW_SOURCE+"registered_body_gallery.png")==OK)
	print("KING_LOW_RETURN_BUILD 16 registered keys, original blade and exact endpoint/carry; density=",density)
	quit()

func _cell(clip: Resource,key: int) -> Image:
	return clip.body_atlas.get_image().get_region(Rect2i(Vector2i(key%4,key/4)*Vector2i(192,128),Vector2i(192,128)))

func _skin_center(image: Image) -> Vector2:
	var total := Vector2.ZERO
	var count := 0
	for y in range(44,69):
		for x in range(94,124):
			var c := image.get_pixel(x,y)
			if c.a>0.5 and c.r>0.72 and c.g>0.50 and c.b>0.22 and c.b<0.72:
				total += Vector2(x,y)
				count += 1
	assert(count>0)
	return total/count

func _brown(color: Color) -> bool:
	return color.a>0.5 and color.r>0.22 and color.g>0.08 and color.r>color.g*1.35 and color.g>color.b*1.3

func _brown_near(image: Image,expected: Vector2,radius: int) -> Vector2:
	var best := Vector2.ZERO
	var distance := INF
	for y in range(roundi(expected.y)-radius,roundi(expected.y)+radius+1):
		for x in range(roundi(expected.x)-radius,roundi(expected.x)+radius+1):
			if not Rect2i(0,0,192,128).has_point(Vector2i(x,y)) or not _brown(image.get_pixel(x,y)): continue
			var p := Vector2(x,y)
			if p.distance_squared_to(expected)<distance:
				best = p
				distance = p.distance_squared_to(expected)
	assert(distance<INF,"Missing registered brown glove")
	return best

func _grip_pair(image: Image,center: Vector2,axis: Vector2) -> Array[Vector2]:
	var points: Array[Vector2] = []
	for y in range(roundi(center.y)-7,roundi(center.y)+8):
		for x in range(roundi(center.x)-7,roundi(center.x)+8):
			if Rect2i(0,0,192,128).has_point(Vector2i(x,y)) and _brown(image.get_pixel(x,y)):
				points.append(Vector2(x,y))
	var best: Array[Vector2] = []
	var score := INF
	for p in points:
		for s in points:
			var delta := s-p
			if delta.length()<4 or delta.length()>8: continue
			var candidate := pow(absf(delta.angle_to(axis)),2)*160+((p+s)*0.5).distance_squared_to(center)+pow(delta.length()-5,2)
			if candidate<score:
				score = candidate
				best = [p,s]
	if best.size()!=2:
		push_error("Missing two-hand grip pair at "+str(center)+"; pixels="+str(points.size()))
		return []
	return best
