extends "res://tools/build_king_oathbound_greatsword.gd"

## Greatsword-only study. Accepted production art/data and locomotion stay intact.
const FRONT_SOURCE := "res://art_source/generated/characters/king/greatsword_front_combo_2026_10_06/"
const FRONT_DEST := "res://assets/characters/playable/king/greatsword_front_combo_preview/"
const FRONT_NAMES := ["front","return","spin","jump"]
const FRONT_GUIDES := [
	[Vector2(.2,.62),Vector2(.24,.38),Vector2(.85,.12),Vector2(.90,.42),Vector2(.91,.45),Vector2(.91,.76),Vector2(.20,.55),Vector2(.2,.5)],
	[Vector2(.9,.8),Vector2(.79,.55),Vector2(.9,.76),Vector2(.9,.43),Vector2(.9,.14),Vector2(.9,.12),Vector2(.9,.32),Vector2(.18,.35)],
	[Vector2(.2,.4),Vector2(.9,.50),Vector2(.85,.53),Vector2(.15,.63),Vector2(.1,.5),Vector2(.14,.63),Vector2(.91,.46),Vector2(.19,.4)],
	[Vector2(.25,.33),Vector2(.18,.69),Vector2(.18,.25),Vector2(.2,.18),Vector2(.9,.59),Vector2(.91,.77),Vector2(.18,.68),Vector2(.15,.63)]
]
const FRONT_ACTIVE_ANGLES := [
	[-60,-36,-12,12,36,60],
	[60,36,12,-12,-36,-60],
	[30,102,174,246,318,390],
	[-85,-50,-10,30,60,70]
]
const FRONT_LOAD_ANGLES := [
	[-145,-105,-75,-60],
	[60,70,65,60],
	[-60,-15,0,30],
	[30,-100,-100,-90]
]
var views: Array[PackedStringArray] = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FRONT_DEST))
	var rows := extract_bodies(Image.load_from_file(FRONT_SOURCE+"body_source.png"),4)
	for row in rows:
		if row.size()!=8:
			push_error("Expected four rows of eight full bodies, found "+str(row.size()))
			quit(1)
			return
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var carry_hand: Image = idle.hand_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var head := Rect2i(87,41,25,24)
	var density: float = float(carry.get_used_rect().size.y)/rows[0][0].image.get_height()
	var identities := {"side":{"image":carry,"head":head}}
	var left: Image = carry.duplicate()
	left.flip_x()
	identities.left = {"image":left,"head":Rect2i(80,41,25,24)}
	for direction in ["up","down"]:
		var resource: Resource = load("res://assets/characters/playable/king/greatsword_readability/"+direction+"/idle.tres")
		var image: Image = resource.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var region := Rect2i(resource.identity_source_region)
		if direction=="up": region = hair_bounds(image,red_center_y(image)-2)
		identities[direction] = {"image":image,"head":region}
	for identity in identities.values():
		var image: Image = identity.image
		for y in 128:
			for x in 192:
				var c := image.get_pixel(x,y)
				if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	var clips: Array[Resource] = []
	var bodies: Array[Image] = []
	var hands: Array[Image] = []
	for cut in 4:
		var clip := Definition.new()
		clip.pose_count = 16
		clip.pose_order = PackedInt32Array(range(16))
		clip.primary_hands.clear(); clip.secondary_hands.clear(); clip.lift_pixels.clear()
		clip.weapon_behind_body.clear(); clip.single_hand_poses.clear(); clip.stowed_poses.clear()
		clip.released_poses.clear(); clip.ground_clipped_poses.clear()
		clip.weapon_texture = STEEL
		clip.weapon_primary_grip = Vector2(15,113)
		clip.weapon_tip = Vector2(15,0)
		clip.mirror_cutting_edge = false
		clip.phase_windows = PackedVector2Array([Vector2(0,3),Vector2(4,9),Vector2(10,12)])
		clip.queued_recovery_window = Vector2(13,15)
		clip.identity_source_region = Rect2(head)
		clip.pose_weights = PackedFloat32Array([.2,.6,.8,1,1,1,1,1,1,1,.6,.8,1,.6,.8,1])
		var atlas := Image.create(768,512,false,Image.FORMAT_RGBA8)
		var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
		var clip_views := PackedStringArray()
		for key in 16:
			var source_key: int = [0,1,2,3,3,4,4,5,5,6,6,7,7,6,7,7][key]
			if cut==2: source_key = [0,0,1,1,2,3,4,5,6,7,7,7,7,7,7,7][key]
			if cut==3: source_key = [0,1,2,3,4,4,5,5,6,6,6,7,7,6,7,7][key]
			var component: Dictionary = rows[cut][source_key]
			# The generated fifth spin source faced right again; use a real
			# mirrored left body instead of pretending a head swap turns its torso.
			var mirrored_source := cut==2 and source_key==4
			if mirrored_source: component = rows[cut][1]
			var image: Image = component.image.duplicate()
			if mirrored_source: image.flip_x()
			image.resize(roundi(image.get_width()*density),roundi(image.get_height()*density),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i((foot_anchor(carry)-foot_anchor(image)).round())
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
			quantize(body)
			var view := "side"
			if cut==2: view = ["side","side","down","left","left","up","up","side"][source_key]
			var identity: Dictionary = identities[view]
			var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
			var placed := attach_back_head(body,identity.image,identity.head,foreground) if view=="up" else attach_head(body,identity.image,identity.head,view,foreground)
			if failed: quit(1); return
			remove_specks(body)
			var expected: Vector2 = Vector2(offset)+FRONT_GUIDES[cut][source_key]*Vector2(image.get_size())
			var primary := find_glove(body,expected,placed,12)
			if primary==Vector2.ZERO:
				body.save_png(FRONT_SOURCE+"missing_glove.png")
				push_error("Missing drawn glove "+str(cut)+"/"+str(key)+" view "+view)
				quit(1)
				return
			var angle: float = FRONT_LOAD_ANGLES[cut][key] if key<4 else FRONT_ACTIVE_ANGLES[cut][mini(5,key-4)]
			clip.primary_hands.append(primary)
			clip.secondary_hands.append(primary-Vector2.from_angle(deg_to_rad(angle))*7)
			clip.lift_pixels.append([0,-3,-16,-24,-12,-6,0,0,0,0,0,0,0,0,0,0][key] if cut==3 else 0)
			clip.weapon_behind_body.append(1 if view=="up" else 0)
			clip.single_hand_poses.append(1); clip.stowed_poses.append(0)
			clip.released_poses.append(0); clip.ground_clipped_poses.append(0)
			clip.identity_regions.append(Rect2(placed))
			clip_views.append(view)
			var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
			atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
			mask.blit_rect(foreground,Rect2i(0,0,192,128),origin)
			var palm := Rect2i(Vector2i(primary)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,palm,origin+palm.position)
			audit.append({"cut":cut,"key":key,"source_key":source_key,"view":view,"density":density,"grip":[primary.x,primary.y],"head":var_to_str(placed),"mirrored_source":mirrored_source})
		copy_slot(clip,atlas,mask,12,idle,carry,carry_hand,0,head)
		clip_views[12] = "side"
		clips.append(clip); bodies.append(atlas); hands.append(mask); views.append(clip_views)
	copy_slot(clips[0],bodies[0],hands[0],0,idle,carry,carry_hand,0,head)
	for cut in 3:
		copy_slot(clips[cut],bodies[cut],hands[cut],15,clips[cut+1],bodies[cut+1],hands[cut+1],0,head)
		views[cut][15] = views[cut+1][0]
	copy_slot(clips[3],bodies[3],hands[3],15,idle,carry,carry_hand,0,head)
	views[3][15] = "side"
	for cut in 4:
		for key in 16:
			var record: Dictionary = audit[cut*16+key]
			record["final_head"] = var_to_str(clips[cut].identity_regions[key])
			record["final_grip"] = var_to_str(clips[cut].primary_hands[key])
			record["final_view"] = views[cut][key]
			record["copied_endpoint"] = key==12 or key==15 or (cut==0 and key==0)
		bodies[cut].save_png(FRONT_DEST+FRONT_NAMES[cut]+"_body.png")
		hands[cut].save_png(FRONT_DEST+FRONT_NAMES[cut]+"_hands.png")
		write_clip(FRONT_DEST,FRONT_NAMES[cut],clips[cut],FRONT_NAMES.slice(1) if cut==0 else [])
	build_front_effects()
	for name in DirAccess.get_files_at(FRONT_DEST):
		if name.ends_with(".png.import"):
			var path: String = FRONT_DEST+name
			var settings := FileAccess.get_file_as_string(path).replace("process/fix_alpha_border=true","process/fix_alpha_border=false")
			FileAccess.open(path,FileAccess.WRITE).store_string(settings)
	var reference_records := {}
	for view in identities:
		reference_records[view] = var_to_str(identities[view].head)
	FileAccess.open(FRONT_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"records":audit,"final_views":views,"reference_heads":reference_records},"\t")+"\n")
	print("FRONT_COMBO_BUILD four cuts / 64 keys; exact120-degree front/return and360-degree spin")
	quit()

func build_front_effects() -> void:
	var source := Image.load_from_file(FRONT_SOURCE+"slash_source.png")
	var atlas := Image.create(768,768,false,Image.FORMAT_RGBA8)
	for row in 4:
		for key in 4:
			var cell := source.get_region(Rect2i(key*source.get_width()/4,row*source.get_height()/4,source.get_width()/4,source.get_height()/4))
			cell.resize(192,192,Image.INTERPOLATE_NEAREST)
			for y in 192:
				for x in 192:
					var c := cell.get_pixel(x,y)
					# Drop generated cyan glow/noise; keep the silver-white ribbon.
					if c.a<.65 or (c.b-c.r>.25) or (c.g-c.r>.25): c = Color.TRANSPARENT
					elif c.r>.82 and c.g>.82: c = Color(.98,.99,1,c.a)
					elif c.r>.5: c = Color(.67,.71,.75,c.a)
					else: c = Color(.18,.22,.26,c.a)
					cell.set_pixel(x,y,c)
			atlas.blit_rect(cell,Rect2i(0,0,192,192),Vector2i(key*192,row*192))
	atlas.save_png(FRONT_DEST+"slash.png")
