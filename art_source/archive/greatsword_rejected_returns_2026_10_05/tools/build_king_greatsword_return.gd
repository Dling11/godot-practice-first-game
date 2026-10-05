extends SceneTree

const SOURCE := "res://art_source/generated/characters/king/greatsword_return_v6_2026_10_04/"
const DEST := "res://assets/characters/playable/king/greatsword_return_v6/"
const TURN = preload("res://assets/characters/playable/king/huge_greatsword_proof/turn.tres")
const IDLE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const PRIMARY := [Vector2(297,276),Vector2(848,281),Vector2(1477,210),Vector2(2029,201),Vector2(290,405),Vector2(765,433),Vector2(1450,545),Vector2(1900,580)]
const SECONDARY := [Vector2(311,252),Vector2(848,281),Vector2(1413,221),Vector2(1950,201),Vector2(290,440),Vector2(799,456),Vector2(1436,560),Vector2(1920,560)]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var source := Image.load_from_file(SOURCE+"return_source.png")
	for y in source.get_height():
		for x in source.get_width():
			var c := source.get_pixel(x,y)
			c.a = 1.0 if c.a>=0.65 else 0.0
			source.set_pixel(x,y,c if c.a>0 else Color(0,0,0,0))
	var rects: Array[Rect2i] = []
	var mean_height := 0.0
	for index in 8:
		var start := Vector2i(floori(index%4*source.get_width()/4.0),floori(index/4*source.get_height()/2.0))
		var end := Vector2i(floori((index%4+1)*source.get_width()/4.0),floori((index/4+1)*source.get_height()/2.0))
		var used := source.get_region(Rect2i(start,end-start)).get_used_rect()
		used.position += start
		rects.append(used)
		mean_height += used.size.y
	var density := 54.0/(mean_height/8.0)
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var clip := Definition.new()
	clip.weapon_texture = TURN.weapon_texture
	clip.weapon_primary_grip = TURN.weapon_primary_grip
	clip.weapon_tip = Vector2(15,0)
	clip.mirror_cutting_edge = false
	clip.phase_windows = PackedVector2Array([Vector2(0,1),Vector2(2,4),Vector2(5,7)])
	var records: Array[Dictionary] = []
	for index in 8:
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var hand := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var p: Vector2
		var s: Vector2
		if index in [0,6,7]:
			var boundary: Resource = TURN if index==0 else IDLE
			var key := 7 if index==0 else 2 if index==6 else 0
			var cell := Rect2i(Vector2i(key%4,key/4)*Vector2i(192,128),Vector2i(192,128))
			body = boundary.body_atlas.get_image().get_region(cell)
			hand = boundary.hand_atlas.get_image().get_region(cell)
			p = boundary.primary_hands[key]
			s = boundary.secondary_hands[key]
			clip.single_hand_poses[index] = boundary.single_hand_poses[key]
			clip.weapon_behind_body[index] = boundary.weapon_behind_body[key]
		else:
			var rect := rects[index]
			var part := source.get_region(rect)
			var foot := Vector2(rect.size.x*0.5,rect.size.y-1)
			part.resize(roundi(rect.size.x*density),roundi(rect.size.y*density),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i(96,96)-Vector2i((foot*density).round())
			body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
			p = ((PRIMARY[index]-Vector2(rect.position))*density).round()+Vector2(offset)
			s = ((SECONDARY[index]-Vector2(rect.position))*density).round()+Vector2(offset)
			p = _snap(body,p)
			s = _snap(body,s)
			# One-hand load and middle key give a monotonic rising blade arc.
			# The secondary landmark is explicitly an axis, not a fake glove.
			if index in [1,3]:
				s = p+(Vector2(-5,-1) if index==1 else Vector2(-8,8))
				clip.single_hand_poses[index] = 1
			var anchors := [p] if clip.single_hand_poses[index]>0 else [p,s]
			for anchor in anchors:
				var region := Rect2i(Vector2i(anchor)-Vector2i(3,3),Vector2i(7,7))
				hand.blit_rect(body,region,region.position)
			clip.weapon_behind_body[index] = 1 if index==5 else 0
		clip.primary_hands.append(p)
		clip.secondary_hands.append(s)
		var destination := Vector2i(index%4,index/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),destination)
		masks.blit_rect(hand,Rect2i(0,0,192,128),destination)
		records.append({"pose":index,"density":density,"primary":[p.x,p.y],"secondary":[s.x,s.y],"source_rect":[rects[index].position.x,rects[index].position.y,rects[index].size.x,rects[index].size.y],"boundary":index in [0,6,7]})
	assert(atlas.save_png(DEST+"return_body.png")==OK)
	assert(masks.save_png(DEST+"return_hands.png")==OK)
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(masks)
	assert(clip.has_valid_layout())
	# Write external textures, not embedded image bytes.
	var serialized := FileAccess.get_file_as_string("res://assets/characters/playable/king/huge_greatsword_proof/turn.tres")
	serialized = serialized.replace("huge_greatsword_proof/turn_body.png","greatsword_return_v6/return_body.png").replace("huge_greatsword_proof/turn_hands.png","greatsword_return_v6/return_hands.png")
	var lines := serialized.split("\n")
	for index in lines.size():
		if lines[index].begins_with("primary_hands = "): lines[index] = "primary_hands = "+_points(clip.primary_hands)
		if lines[index].begins_with("secondary_hands = "): lines[index] = "secondary_hands = "+_points(clip.secondary_hands)
		if lines[index].begins_with("phase_windows = "): lines[index] = "phase_windows = PackedVector2Array(0,1,2,4,5,7)"
		if lines[index].begins_with("weapon_behind_body = "): lines[index] = "weapon_behind_body = PackedByteArray(0,0,0,0,0,1,0,0)"
	serialized = "\n".join(lines)+"\nweapon_tip = Vector2(15,0)\nsingle_hand_poses = PackedByteArray(0,1,0,1,0,0,1,1)\n"
	FileAccess.open(DEST+"return.tres",FileAccess.WRITE).store_string(serialized)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("GREATSWORD_RETURN_BUILD eight chronological cells, shared density=",density," exact turn-end/carry boundaries")
	quit()

func _snap(image: Image,point: Vector2) -> Vector2:
	if image.get_pixelv(Vector2i(point)).a>0: return point
	var closest := point
	var distance := INF
	for y in range(int(point.y)-5,int(point.y)+6):
		for x in range(int(point.x)-5,int(point.x)+6):
			if x<0 or y<0 or x>=192 or y>=128 or image.get_pixel(x,y).a==0: continue
			var candidate := Vector2(x,y)
			if candidate.distance_squared_to(point)<distance:
				closest = candidate
				distance = candidate.distance_squared_to(point)
	assert(distance<INF,"Unregistered glove")
	return closest

func _points(points: PackedVector2Array) -> String:
	var values := PackedStringArray()
	for point in points:
		values.append(str(point.x))
		values.append(str(point.y))
	return "PackedVector2Array("+", ".join(values)+")"
