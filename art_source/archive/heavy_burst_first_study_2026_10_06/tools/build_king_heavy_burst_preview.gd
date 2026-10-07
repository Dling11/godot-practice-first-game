extends "res://tools/build_king_oathbound_greatsword.gd"

## Isolated art study. Never writes the installed Oathbound family or locomotion.
const BURST_SOURCE := "res://art_source/generated/characters/king/heavy_burst_2026_10_06/"
const BURST_DEST := "res://assets/characters/playable/king/heavy_burst_preview/"
const BURST_ANGLES := [
	[-150,-165,-130,-25,35,55,65],
	[65,65,40,-35,-90,-110,-130],
	[-130,-110,-95,30,55,45,40],
	[40,30,-150,-20,40,65,80],
	[80,60,35,-30,-110,-140,-150]
]
const BURST_GUIDES := [
	[Vector2(.15,.39),Vector2(.16,.38),Vector2(.23,.2),Vector2(.88,.8),Vector2(.9,.89),Vector2(.9,.82),Vector2(.2,.24)],
	[Vector2(.91,.81),Vector2(.84,.7),Vector2(.91,.73),Vector2(.85,.18),Vector2(.87,.3),Vector2(.18,.14),Vector2(.2,.13)],
	[Vector2(.25,.21),Vector2(.9,.73),Vector2(.3,.27),Vector2(.25,.15),Vector2(.88,.75),Vector2(.88,.8),Vector2(.86,.53)],
	[Vector2(.17,.22),Vector2(.92,.44),Vector2(.24,.25),Vector2(.9,.32),Vector2(.9,.63),Vector2(.9,.87),Vector2(.87,.78)],
	[Vector2(.87,.62),Vector2(.92,.6),Vector2(.9,.49),Vector2(.19,.43),Vector2(.22,.55),Vector2(.22,.67),Vector2(.2,.36)]
]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(BURST_DEST))
	var rows := extract_bodies(Image.load_from_file(BURST_SOURCE+"body_source.png"))
	for row in rows:
		if row.size()!=7:
			push_error("Burst source must contain five rows of seven complete bodies; got "+str(row.size()))
			quit(1)
			return
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var carry_hand: Image = idle.hand_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var head := Rect2i(87,41,25,24)
	var density: float = float(carry.get_used_rect().size.y)/rows[0][0].image.get_height()
	for y in 128:
		for x in 192:
			var c := carry.get_pixel(x,y)
			if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	var clips: Array[Resource] = []
	var bodies: Array[Image] = []
	var hands: Array[Image] = []
	for cut in 5:
		var clip := Definition.new()
		clip.pose_count = 12
		clip.pose_order = PackedInt32Array(range(12))
		clip.primary_hands.clear()
		clip.secondary_hands.clear()
		clip.lift_pixels.clear()
		clip.weapon_behind_body.clear()
		clip.single_hand_poses.clear()
		clip.stowed_poses.clear()
		clip.released_poses.clear()
		clip.ground_clipped_poses.clear()
		clip.weapon_texture = STEEL
		clip.weapon_primary_grip = Vector2(15,113)
		clip.weapon_tip = Vector2(15,0)
		clip.mirror_cutting_edge = false
		clip.phase_windows = PackedVector2Array([Vector2(0,2),Vector2(3,5),Vector2(6,8)])
		clip.queued_recovery_window = Vector2(9,11)
		clip.identity_source_region = Rect2(head)
		clip.pose_weights = PackedFloat32Array([.25,.75,1,1,1,1,.5,.7,1,.5,.7,1])
		var atlas := Image.create(768,384,false,Image.FORMAT_RGBA8)
		var mask := Image.create(768,384,false,Image.FORMAT_RGBA8)
		for key in 12:
			var source_key: int = [0,1,2,3,4,4,5,6,6,5,6,6][key]
			var image: Image = rows[cut][source_key].image.duplicate()
			image.resize(roundi(image.get_width()*density),roundi(image.get_height()*density),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i((foot_anchor(carry)-foot_anchor(image)).round())
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
			quantize(body)
			var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
			var placed := attach_head(body,carry,head,"side",foreground)
			if failed: quit(1); return
			remove_specks(body)
			var expected: Vector2 = Vector2(offset)+BURST_GUIDES[cut][source_key]*Vector2(image.get_size())
			var primary := find_glove(body,expected,placed,10)
			if primary==Vector2.ZERO:
				body.save_png(BURST_SOURCE+"missing_glove.png")
				push_error("Burst glove missing: cut="+str(cut)+" key="+str(key)+" expected="+str(expected))
				quit(1)
				return
			var heading: float = BURST_ANGLES[cut][source_key]
			if key==5: heading += 12 if cut%2==0 else -12
			clip.primary_hands.append(primary)
			clip.secondary_hands.append(primary-Vector2.from_angle(deg_to_rad(heading))*7)
			clip.lift_pixels.append([0,-2,-12,-7,0,0,0,0,0,0,0,0][key] if cut==2 else 0)
			clip.weapon_behind_body.append(0)
			clip.single_hand_poses.append(1)
			clip.stowed_poses.append(0)
			clip.released_poses.append(0)
			clip.ground_clipped_poses.append(0)
			clip.identity_regions.append(Rect2(placed))
			var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
			atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
			mask.blit_rect(foreground,Rect2i(0,0,192,128),origin)
			var glove_rect := Rect2i(Vector2i(primary)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,glove_rect,origin+glove_rect.position)
			audit.append({"cut":cut,"pose":key,"source_key":source_key,"fixed_density":density,"grip":[primary.x,primary.y],"head":var_to_str(placed),"foot":var_to_str(foot_anchor(body))})
		copy_slot(clip,atlas,mask,8,idle,carry,carry_hand,0,head)
		clips.append(clip); bodies.append(atlas); hands.append(mask)
	copy_slot(clips[0],bodies[0],hands[0],0,idle,carry,carry_hand,0,head)
	# One continuous physical pose at each queued boundary, including final carry.
	for cut in 4:
		copy_slot(clips[cut],bodies[cut],hands[cut],11,clips[cut+1],bodies[cut+1],hands[cut+1],0,head)
	copy_slot(clips[4],bodies[4],hands[4],11,idle,carry,carry_hand,0,head)
	for cut in 5:
		bodies[cut].save_png(BURST_DEST+NAMES[cut]+"_body.png")
		hands[cut].save_png(BURST_DEST+NAMES[cut]+"_hands.png")
		write_clip(BURST_DEST,NAMES[cut],clips[cut],NAMES.slice(1) if cut==0 else [])
	build_effects()
	build_scythe(clips)
	for name in DirAccess.get_files_at(BURST_DEST):
		if name.ends_with(".png.import"):
			var import_path: String = BURST_DEST+name
			var settings := FileAccess.get_file_as_string(import_path).replace("process/fix_alpha_border=true","process/fix_alpha_border=false")
			FileAccess.open(import_path,FileAccess.WRITE).store_string(settings)
	FileAccess.open(BURST_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("HEAVY_BURST_BUILD five side clips / 60 registered keys; existing family untouched")
	quit()

func build_effects() -> void:
	var source := Image.load_from_file(BURST_SOURCE+"slash_source.png")
	var atlas := Image.create(512,384,false,Image.FORMAT_RGBA8)
	for row in 3:
		for key in 4:
			var cell := source.get_region(Rect2i(key*384,row*source.get_height()/3,384,source.get_height()/3))
			cell.resize(128,128,Image.INTERPOLATE_NEAREST)
			for y in 128:
				for x in 128:
					var c := cell.get_pixel(x,y)
					if c.a<.35: cell.set_pixel(x,y,Color.TRANSPARENT)
			atlas.blit_rect(cell,Rect2i(0,0,128,128),Vector2i(key*128,row*128))
	atlas.save_png(BURST_DEST+"slash.png")

func build_scythe(clips: Array[Resource]) -> void:
	var source := Image.load_from_file(BURST_SOURCE+"scythe_source.png")
	var bounds := source.get_used_rect()
	var image := source.get_region(bounds)
	var density := 160.0/image.get_height()
	image.resize(roundi(image.get_width()*density),160,Image.INTERPOLATE_NEAREST)
	image.save_png(BURST_DEST+"scythe.png")
	var grip := Vector2(roundi((193-bounds.position.x)*density),roundi((1410-bounds.position.y)*density))
	var folder := BURST_DEST+"scythe/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	for cut in 5:
		var clip: Resource = clips[cut].duplicate()
		clip.weapon_primary_grip = grip
		clip.weapon_tip = Vector2(image.get_width()-2,roundi(image.get_height()*.31))
		write_clip(folder,NAMES[cut],clip,NAMES.slice(1) if cut==0 else [])
		var path: String = folder+NAMES[cut]+".tres"
		var text := FileAccess.get_file_as_string(path).replace(STEEL.resource_path,BURST_DEST+"scythe.png")
		# Scythe borrows this motion study's bodies; it is not a finished sixth family.
		text = text.replace(folder+NAMES[cut]+"_body.png",BURST_DEST+NAMES[cut]+"_body.png").replace(folder+NAMES[cut]+"_hands.png",BURST_DEST+NAMES[cut]+"_hands.png")
		FileAccess.open(path,FileAccess.WRITE).store_string(text)
	FileAccess.open(BURST_SOURCE+"scythe_registration.json",FileAccess.WRITE).store_string(JSON.stringify({"source_bounds":var_to_str(bounds),"fixed_density":density,"grip":[grip.x,grip.y],"size":[image.get_width(),image.get_height()]},"\t")+"\n")
