extends SceneTree

## Offline registration only: unchanged generation remains in art_source.
const SOURCE := "res://art_source/generated/characters/king/iron_beard_motion_proof_2026_10_04/"
const DEST := "res://assets/characters/playable/king/axe_proof/"
const CELL := Vector2i(192,128)
const SCALE := 0.16
const HANDS := [Vector2(161,68),Vector2(153,132),Vector2(151,64),Vector2(332,302),Vector2(306,319),Vector2(351,315),Vector2(324,269),Vector2(157,63)]
const SUPPORT := [Vector2(149,108),Vector2(149,179),Vector2(141,111),Vector2(240,272),Vector2(239,269),Vector2(269,283),Vector2(253,261),Vector2(149,106)]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var source := Image.load_from_file(SOURCE+"body_source.png")
	var atlas := Image.create(CELL.x*4,CELL.y*2,false,Image.FORMAT_RGBA8)
	var hands := Image.create(CELL.x*4,CELL.y*2,false,Image.FORMAT_RGBA8)
	var primary := PackedVector2Array()
	var secondary := PackedVector2Array()
	var records: Array[Dictionary] = []
	for index in 8:
		var start := Vector2i(floori((index%4)*source.get_width()/4.0),floori((index/4)*source.get_height()/2.0))
		var crop := source.get_region(Rect2i(start,Vector2i(443,443)))
		_binary(crop)
		var bounds: Rect2i = crop.get_used_rect()
		var foot := Vector2((bounds.position.x+bounds.end.x)*0.5,bounds.end.y-1)
		crop.resize(roundi(443*SCALE),roundi(443*SCALE),Image.INTERPOLATE_NEAREST)
		var offset := Vector2i(96,96)-Vector2i((foot*SCALE).round())
		var frame := Image.create(CELL.x,CELL.y,false,Image.FORMAT_RGBA8)
		frame.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),offset)
		var p := Vector2((Vector2(HANDS[index])*SCALE).round())+Vector2(offset)
		var s := Vector2((Vector2(SUPPORT[index])*SCALE).round())+Vector2(offset)
		primary.append(p)
		secondary.append(s)
		var mask := Image.create(CELL.x,CELL.y,false,Image.FORMAT_RGBA8)
		for point in [p,s]:
			var rect := Rect2i(Vector2i(point)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(frame,rect,rect.position)
		var destination := Vector2i(index%4,index/4)*CELL
		atlas.blit_rect(frame,Rect2i(Vector2i.ZERO,CELL),destination)
		hands.blit_rect(mask,Rect2i(Vector2i.ZERO,CELL),destination)
		records.append({"index":index,"source_crop":[start.x,start.y,443,443],"source_floor":[foot.x,foot.y],"offset":[offset.x,offset.y],"primary_hand":[p.x,p.y],"secondary_hand":[s.x,s.y],"bounds":str(frame.get_used_rect())})
	assert(atlas.save_png(DEST+"body.png")==OK)
	assert(hands.save_png(DEST+"hands.png")==OK)
	var weapon := Image.load_from_file(SOURCE+"references/iron_beard.png").get_region(Rect2i(48,158,438,514))
	_binary(weapon)
	weapon.resize(55,64,Image.INTERPOLATE_NEAREST)
	assert(weapon.save_png(DEST+"iron_beard.png")==OK)
	var text := "[gd_resource type=\"Resource\" load_steps=7 format=3]\n\n[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_family_pose_definition.gd\" id=\"1\"]\n"
	for item in [["body.png","2"],["hands.png","3"],["iron_beard.png","4"]]:
		text += "[ext_resource type=\"Texture2D\" path=\""+DEST+item[0]+"\" id=\""+item[1]+"\"]\n"
	text += "[ext_resource type=\"Resource\" path=\""+DEST+"return.tres\" id=\"5\"]\n[ext_resource type=\"Resource\" path=\""+DEST+"finisher.tres\" id=\"6\"]\n"
	text += "\n[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	text += "primary_hands = "+_points(primary)+"\nsecondary_hands = "+_points(secondary)+"\nweapon_primary_grip = Vector2(39, 33)\nweapon_handle_axis = Vector2(4, 10)\n"
	text += "mirror_cutting_edge = true\nfollow_up_clips = Array[Resource]([ExtResource(\"5\"), ExtResource(\"6\")])\n"
	FileAccess.open(DEST+"poses.tres",FileAccess.WRITE).store_string(text)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"body_source_size":[source.get_width(),source.get_height()],"uniform_body_scale":SCALE,"alpha_threshold":0.65,"cell_size":[192,128],"actor_body_scale":0.5,"actor_body_offset":[0,-16],"weapon_source_crop":[48,158,438,514],"weapon_logical_size":[55,64],"frames":records},"\t")+"\n")
	print("AXE_PROOF_BUILD eight registered body/hand poses; one rigid axe")
	quit()

func _binary(picture: Image) -> void:
	for y in picture.get_height():
		for x in picture.get_width():
			var c := picture.get_pixel(x,y)
			c.a = 1 if c.a>=0.65 else 0
			if c.a == 0: c = Color(0,0,0,0)
			picture.set_pixel(x,y,c)

func _points(points: PackedVector2Array) -> String:
	var values := PackedStringArray()
	for point in points:
		values.append(str(point.x))
		values.append(str(point.y))
	return "PackedVector2Array("+", ".join(values)+")"
