extends "res://tools/build_king_confidence_v2.gd"

const REPAIR_SOURCE := "res://art_source/generated/characters/king/gait_repair_v3_2026_10_04/"
const BOB := [0,1,0,-1,0,1,0,-1]

func _initialize() -> void:
	var run := Image.load_from_file(REPAIR_SOURCE+"run_source.png")
	_binary(run)
	var components := _bodies(run)
	var mean_height := 0.0
	for index in 8: mean_height += (components[index] as Rect2i).size.y
	var density := 54.0/(mean_height/8.0)
	var passing := Image.load_from_file(REPAIR_SOURCE+"passing_source.png")
	_binary(passing)
	# The second sheet has one uniform density, calibrated to the same body height.
	var passing_parts: Array[Image] = []
	var passing_height := 0.0
	for index in 4:
		var half := Vector2i(passing.get_width()/2,passing.get_height()/2)
		var cell := passing.get_region(Rect2i(Vector2i(index%2,index/2)*half,half))
		var part := cell.get_region(cell.get_used_rect())
		passing_parts.append(part)
		passing_height += part.get_height()
	var passing_density := 54.0/(passing_height/4.0)
	for family in 2:
		var name := "axe_run" if family==0 else "greatsword_run"
		var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
		var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
		var primary := PackedVector2Array()
		var secondary := PackedVector2Array()
		for pose in 8:
			var is_passing := pose in [2,6]
			var source_index := family*2+(0 if pose==2 else 1)
			var rect: Rect2i = components[family*8+pose]
			var part: Image = passing_parts[source_index].duplicate() if is_passing else run.get_region(rect)
			var ratio := passing_density if is_passing else density
			var face := face_center(part)
			part.resize(roundi(part.get_width()*ratio),roundi(part.get_height()*ratio),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i(107,61+BOB[pose])-Vector2i((face*ratio).round())
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
			var p := Vector2(87,61+BOB[pose]) if family==0 else glove_center(body,BOB[pose])
			var s := p+(Vector2(-2,10) if family==0 else Vector2(8,4))
			primary.append(p)
			secondary.append(s)
			var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
			if family==1:
				var glove := Rect2i(Vector2i(p)-Vector2i(3,3),Vector2i(7,7))
				mask.blit_rect(body,glove,glove.position)
			var cell := Vector2i(pose%4,pose/4)*Vector2i(192,128)
			atlas.blit_rect(body,Rect2i(0,0,192,128),cell)
			masks.blit_rect(mask,Rect2i(0,0,192,128),cell)
			v2_records.append({"clip":name,"pose":pose,"source":"passing_source.png" if is_passing else "run_source.png","source_index":source_index if is_passing else family*8+pose,"density":ratio,"face_origin":[face.x,face.y],"registered_face":[107,61+BOB[pose]],"primary":[p.x,p.y],"ground_bounds":[body.get_used_rect().position.y,body.get_used_rect().end.y]})
		assert(atlas.save_png(V2_DEST+name+"_body.png")==OK)
		assert(masks.save_png(V2_DEST+name+"_hands.png")==OK)
		var text := FileAccess.get_file_as_string(V2_DEST+name+".tres")
		var lines := text.split("\n")
		for index in lines.size():
			if lines[index].begins_with("primary_hands = "): lines[index] = "primary_hands = "+_points(primary)
			if lines[index].begins_with("secondary_hands = "): lines[index] = "secondary_hands = "+_points(secondary)
			if lines[index].begins_with("weapon_behind_body = "): lines[index] = "weapon_behind_body = PackedByteArray(1,1,1,1,1,1,1,1)" if family==0 else "weapon_behind_body = PackedByteArray(0,0,0,0,0,0,0,0)"
			if family==0 and lines[index].begins_with("mirror_cutting_edge = "): lines[index] = "mirror_cutting_edge = false"
		var serialized := "\n".join(lines)
		if family==0 and not serialized.contains("mirror_cutting_edge = "): serialized += "\nmirror_cutting_edge = false\n"
		FileAccess.open(V2_DEST+name+".tres",FileAccess.WRITE).store_string(serialized)
	FileAccess.open(REPAIR_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(v2_records,"\t")+"\n")
	print("KING_GAIT_REPAIR stable face registration, 2 passing keys per family, fixed shoulder/back attachment")
	quit()

func glove_center(image: Image,bob: int) -> Vector2:
	var total := Vector2.ZERO
	var count := 0
	# Isolate the raised brown glove, not any nearby opaque cuff/scarf pixel.
	for y in range(54+bob,63+bob):
		for x in range(84,97):
			var color := image.get_pixel(x,y)
			if color.a>0 and color.r>0.25 and color.r<0.72 and color.g>0.10 and color.g<color.r*0.8 and color.b<color.g*0.8:
				total += Vector2(x,y)
				count += 1
	assert(count>=4,"No brown raised glove in run pose")
	return _snap_glove(image,(total/count).round(),"raised glove")

func face_center(image: Image) -> Vector2:
	var sum := Vector2.ZERO
	var count := 0
	for y in range(int(image.get_height()*0.16),int(image.get_height()*0.39)):
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			if c.a>0 and c.r>0.7 and c.g>0.48 and c.b>0.22 and c.b<0.7 and c.g>c.r*0.65:
				sum += Vector2(x,y)
				count += 1
	assert(count>40,"No face origin in source")
	return sum/count
