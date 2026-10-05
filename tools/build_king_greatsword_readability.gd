extends "res://tools/build_king_oathbound_greatsword.gd"

## Offline additions; original accepted sources are left intact.
const READABILITY_SOURCE := "res://art_source/generated/characters/king/greatsword_readability_2026_10_05/"
const READABILITY_DEST := "res://assets/characters/playable/king/greatsword_readability/"
const Planting = preload("res://data/weapons/weapon_planting_definition.gd")
var registrations: Array[Dictionary] = []

func _initialize() -> void:
	var rows := extract_bodies(Image.load_from_file(READABILITY_SOURCE+"vertical_pride_source.png"),2)
	if rows.size()!=2 or rows[0].size()!=4 or rows[1].size()!=4:
		push_error("Proud idle requires four complete front bodies and four back bodies")
		quit(1)
		return
	for view in 2:
		build_idle("down" if view==0 else "up",rows[view])
		if failed: quit(1); return
	build_side_run()
	if failed: quit(1); return
	FileAccess.open(READABILITY_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(registrations,"\t")+"\n")
	print("GREATSWORD_READABILITY two centered vertical proud idles / side gait identity")
	quit()

func build_idle(direction: String,frames: Array) -> void:
	var original: Resource = load("res://assets/characters/playable/king/greatsword_cardinal/"+direction+"/idle.tres")
	var carry: Image = original.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var glove: Image = original.hand_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var delta := Vector2i((Vector2(96,95)-foot_anchor(carry)).round())
	carry = translated(carry,delta)
	glove = translated(glove,delta)
	var head := (Rect2i(80,45,32,29) if direction=="down" else Rect2i(89,44,28,27))
	head.position += delta
	set_palette(carry)
	var density: float = float(carry.get_used_rect().size.y)/float(frames[0].image.get_height())
	var clip: Resource = original.duplicate(true)
	clip.primary_hands.clear()
	clip.secondary_hands.clear()
	clip.identity_regions.clear()
	clip.identity_source_region = Rect2(head)
	clip.allow_rest = true
	clip.planting = Planting.new()
	clip.planting.ground_anchor = Vector2(74,95)
	clip.released_poses = PackedByteArray([0,0,0,0,0,1,1,1])
	clip.ground_clipped_poses = PackedByteArray([0,0,0,0,0,1,1,1])
	clip.weapon_behind_body = PackedByteArray([0,0,0,0,0,0,1,1])
	var bodies: Array[Image] = []
	var hands: Array[Image] = []
	for key in 8:
		if key<4:
			bodies.append(carry)
			hands.append(glove)
			clip.primary_hands.append(original.primary_hands[0]+Vector2(delta))
			clip.secondary_hands.append(original.secondary_hands[0]+Vector2(delta))
			clip.identity_regions.append(Rect2(head))
			continue
		var part: Image = frames[key-4].image.duplicate()
		part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
		var shift := Vector2i((Vector2(96,95)-foot_anchor(part)).round())
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),shift)
		quantize(body)
		var hand := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var placed := attach_head(body,carry,head,direction,hand)
		if failed: return
		remove_specks(body)
		var p: Vector2 = find_glove(body,Vector2(shift)+Vector2(.16,.28)*Vector2(part.get_size()),placed,24) if key==4 else clip.primary_hands[4]
		if key==4 and p==Vector2.ZERO:
			push_error("Proud preparation has no visible glove: "+direction)
			failed = true
			return
		clip.primary_hands.append(p)
		clip.secondary_hands.append(p+Vector2(8,4))
		clip.identity_regions.append(Rect2(placed))
		if key==4:
			var rect := Rect2i(Vector2i(p)-Vector2i(3,3),Vector2i(7,7))
			hand.blit_rect(body,rect,rect.position)
		else:
			hand.fill(Color.TRANSPARENT) # Arms are released; no false steel grip.
		bodies.append(body)
		hands.append(hand)
		registrations.append({"view":direction,"key":key,"head":var_to_str(placed),"foot":var_to_str(foot_anchor(body)),"density":density})
	write_readability_clip(direction,"idle",clip,bodies,hands)

func build_side_run() -> void:
	var original: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/greatsword_run.tres")
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var clip: Resource = original.duplicate(true)
	clip.identity_source_region = Rect2(87,41,25,24)
	clip.identity_regions.clear()
	var bodies: Array[Image] = []
	var hands: Array[Image] = []
	for key in 8:
		var body: Image = original.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
		var drawn: Image = body.duplicate()
		var hand := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var placed := attach_head(body,carry,Rect2i(87,41,25,24),"side",hand,false)
		if failed: return
		# Restore only the authored brown holding glove where it occludes the
		# head, rather than copying a rectangle of the old face back over it.
		var p: Vector2 = original.primary_hands[key]
		for y in range(int(p.y)-3,int(p.y)+4):
			for x in range(int(p.x)-3,int(p.x)+4):
				var c := drawn.get_pixel(x,y)
				if c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25: body.set_pixel(x,y,c)
		var rect := Rect2i(Vector2i(p)-Vector2i(3,3),Vector2i(7,7))
		hand.blit_rect(body,rect,rect.position)
		remove_specks(body)
		bodies.append(body)
		hands.append(hand)
		clip.identity_regions.append(Rect2(placed))
		registrations.append({"view":"side_run","key":key,"head":var_to_str(placed),"foot":var_to_str(foot_anchor(body)),"grip":var_to_str(p)})
	write_readability_clip("side","run",clip,bodies,hands)

func set_palette(reference: Image) -> void:
	palette.clear()
	color_cache.clear()
	for y in 128:
		for x in 192:
			var c := reference.get_pixel(x,y)
			if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))

func translated(image: Image,shift: Vector2i) -> Image:
	var result := Image.create(192,128,false,Image.FORMAT_RGBA8)
	result.blit_rect(image,Rect2i(0,0,192,128),shift)
	return result

func write_readability_clip(direction: String,label: String,clip: Resource,bodies: Array[Image],hands: Array[Image]) -> void:
	var folder := READABILITY_DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,256,false,Image.FORMAT_RGBA8)
	for key in 8:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(bodies[key],Rect2i(0,0,192,128),origin)
		mask.blit_rect(hands[key],Rect2i(0,0,192,128),origin)
	assert(atlas.save_png(folder+label+"_body.png")==OK)
	assert(mask.save_png(folder+label+"_hands.png")==OK)
	var output := "[gd_resource type=\"Resource\" load_steps="+str(7 if clip.planting!=null else 5)+" format=3]\n"
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",STEEL.resource_path]
	for index in paths.size(): output += "[ext_resource type=\""+("Script" if index==0 else "Texture2D")+"\" path=\""+paths[index]+"\" id=\""+str(index+1)+"\"]\n"
	if clip.planting!=null:
		output += "[ext_resource type=\"Script\" path=\"res://data/weapons/weapon_planting_definition.gd\" id=\"5\"]\n[sub_resource type=\"Resource\" id=\"Planting\"]\nscript = ExtResource(\"5\")\nground_anchor = Vector2(74,95)\nburial_depth_pixels = 10.0\n"
	output += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	if clip.planting!=null: output += "planting = SubResource(\"Planting\")\n"
	for property in ["primary_hands","secondary_hands","weapon_primary_grip","weapon_tip","mirror_cutting_edge","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","lift_pixels","allow_rest","identity_regions","identity_source_region"]: output += property+" = "+var_to_str(clip.get(property))+"\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(output)
