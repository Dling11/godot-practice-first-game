extends "res://tools/build_king_dual_twinsteel_cardinal.gd"
const POLISH := "res://art_source/generated/characters/king/dual_polish_2026_10_05/"
const BASE := "res://art_source/archive/dual_cardinal_before_polish_2026_10_05/dual_twinsteel/"
const META_FIELDS := ["pose_count","pose_order","primary_hands","secondary_hands","weapon_primary_grip","weapon_tip","mirror_cutting_edge","phase_windows","queued_recovery_window","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","lift_pixels","pose_weights","identity_regions","allow_rest"]
var meta := ConfigFile.new()

func _initialize() -> void:
	blade=load(OUTPUT+"twinsteel.png")
	if not FileAccess.file_exists(BASE+"metadata.cfg"):
		for direction in ["side","up","down"]:
			for label in CUTS+["idle","run"]:
				var clip: Resource = load(OUTPUT+("" if direction=="side" else direction+"/")+label+".tres")
				for property in META_FIELDS: meta.set_value(direction+"/"+label,property,clip.get(property))
				for property in ["hands","axes","behind_body","visible_poses"]: meta.set_value(direction+"/"+label,"off_"+property,clip.offhand.get(property))
		assert(meta.save(BASE+"metadata.cfg")==OK)
	else:
		assert(meta.load(BASE+"metadata.cfg")==OK)
	var rows := extract_bodies(Image.load_from_file(ProjectSettings.globalize_path(POLISH+"gait_source.png")),3)
	var old_source := extract_bodies(Image.load_from_file(ProjectSettings.globalize_path(RAW+"body_source.png")))
	for row in rows:
		if row.size()!=8:
			push_error("Run polish requires eight complete bodies per facing")
			quit(1)
			return
	for direction in ["side","down","up"]:
		view=direction
		var folder := OUTPUT+("" if view=="side" else view+"/")
		var idle := archived_clip(view,"idle")
		var factor: float = 55.0/idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128)).get_used_rect().size.y
		if view!="side": scale_clip(idle,factor)
		identity=idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		reference_head=Rect2i(idle.identity_regions[0])
		palette.clear()
		color_cache.clear()
		for y in 128:
			for x in 192:
				var c := identity.get_pixel(x,y)
				if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
		var row_index := ["side","down","up"].find(view)
		var run := make_run(rows[row_index])
		if failed:
			quit(1)
			return
		var clips: Array[Resource] = []
		for label in CUTS:
			var clip := archived_clip(view,label)
			if view!="side": scale_clip(clip,factor)
			elif label in ["rising","scissors"]: restore_source_forearms(clip,label,old_source)
			clip.interpolate_blade_angles=true
			# Same action timings, less duplicate endpoint exposure. Recovery
			# spends its time moving steel rather than holding the guard twice.
			clip.pose_weights[0]=.05
			clip.pose_weights[11]=.5
			clip.pose_weights[12]=.05
			clips.append(clip)
		for cut in 5:
			copy_dual_slot(clips[cut],0,idle if cut==0 else clips[cut-1],0 if cut==0 else 12)
			copy_dual_slot(clips[cut],9,idle,0)
			if cut==4: copy_dual_slot(clips[cut],12,idle,0)
			write_dual(CUTS[cut],clips[cut],CUTS.slice(1) if cut==0 else [],folder)
		write_dual("idle",idle,[],folder)
		write_dual("run",run,[],folder)
	FileAccess.open(POLISH+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	var fx := Image.load_from_file(ProjectSettings.globalize_path(POLISH+"fx_source.png"))
	print("FX_ALPHA_CORNERS ",fx.get_pixel(0,0).a," / ",fx.get_pixel(fx.get_width()-1,fx.get_height()-1).a)
	print("DUAL_POLISH built matched cardinal height / root-stable gait / moving blade angles")
	quit()

func archived_clip(direction: String,label: String) -> Resource:
	var section := direction+"/"+label
	var clip := Definition.new()
	for property in META_FIELDS: clip.set(property,meta.get_value(section,property))
	var path := BASE+("" if direction=="side" else direction+"/")+label
	clip.body_atlas=ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path+"_body.png")))
	clip.hand_atlas=ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path+"_hands.png")))
	clip.weapon_texture=blade
	clip.offhand=Offhand.new()
	clip.offhand.texture=blade
	clip.offhand.grip=clip.weapon_primary_grip
	clip.offhand.tip=clip.weapon_tip
	for property in ["hands","axes","behind_body","visible_poses"]: clip.offhand.set(property,meta.get_value(section,"off_"+property))
	return clip

func scale_clip(clip: Resource,factor: float) -> void:
	var atlas := Image.create(clip.body_atlas.get_width(),clip.body_atlas.get_height(),false,Image.FORMAT_RGBA8)
	var mask := Image.create(atlas.get_width(),atlas.get_height(),false,Image.FORMAT_RGBA8)
	for key in clip.pose_count:
		var origin := Vector2i(key%4*192,key/4*128)
		for pair in [[clip.body_atlas,atlas],[clip.hand_atlas,mask]]:
			var image: Image = pair[0].get_image().get_region(Rect2i(origin,Vector2i(192,128)))
			image.resize(roundi(192*factor),roundi(128*factor),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i((Vector2(96,94)*(1.0-factor)).round())
			pair[1].blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),origin+offset)
		var actual: Image = atlas.get_region(Rect2i(origin,Vector2i(192,128)))
		var head := Rect2i(clip.identity_regions[key])
		head=Rect2i(Vector2i((Vector2(head.position-Vector2i(96,94))*factor+Vector2(96,94)).round()),Vector2i((Vector2(head.size)*factor).round()))
		clip.identity_regions[key]=Rect2(head)
		for property in ["primary_hands","secondary_hands"]:
			var values = clip.get(property)
			values[key]=(values[key]-Vector2(96,94))*factor+Vector2(96,94)
			clip.set(property,values)
		for property in ["hands","axes"]:
			var values = clip.offhand.get(property)
			values[key]=(values[key]-Vector2(96,94))*factor+Vector2(96,94)
			clip.offhand.set(property,values)
		# Nearest resize moves a brown glove onto an integer pixel. Snap the
		# hilt to the final painted fist and retain the original shaft angle.
		for off in [false,true]:
			if off and clip.offhand.visible_poses[key]==0: continue
			var old: Vector2 = clip.offhand.hands[key] if off else clip.primary_hands[key]
			var grip := find_glove(actual,old,Rect2i(),4)
			assert(grip!=Vector2.ZERO)
			var delta := grip-old
			if off:
				clip.offhand.hands[key]+=delta
				clip.offhand.axes[key]+=delta
			else:
				clip.primary_hands[key]+=delta
				clip.secondary_hands[key]+=delta
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)

func make_run(parts: Array) -> Resource:
	var clip := archived_clip(view,"run")
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var density: float = 55.0/parts[0].image.get_height()
	# The approved complete head stays the same size as carry. Solve body
	# density once per facing after that registration, never per gait cel.
	for attempt in 3:
		var probe := registered_run_body(parts[0].image,density)
		var height: int = probe.body.get_used_rect().size.y
		if height==55: break
		density *= float(55-reference_head.size.y)/maxf(1,height-reference_head.size.y)
	for key in 8:
		var registered := registered_run_body(parts[key].image,density)
		var body: Image = registered.body
		var head: Rect2i = registered.head
		var hands := glove_centers(body,head)
		if hands.size()!=2 or offhand_occluded:
			failed=true
			push_error("Run requires both visible low gloves: "+view+"/"+str(key))
			return clip
		var main: Vector2 = hands[0]
		var off: Vector2 = hands[1]
		clip.primary_hands[key]=main
		clip.secondary_hands[key]=main-Vector2.from_angle(deg_to_rad(175))*7
		clip.offhand.hands[key]=off
		clip.offhand.axes[key]=off-Vector2.from_angle(deg_to_rad(172 if view=="side" else 5))*7
		clip.weapon_behind_body[key]=1 if view=="side" else 0
		clip.offhand.behind_body[key]=0
		clip.offhand.visible_poses[key]=1
		clip.identity_regions[key]=Rect2(head)
		var origin := Vector2i(key%4*192,key/4*128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		for grip in hands:
			var rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,rect,origin+rect.position)
		audit.append({"view":view,"key":key,"source_bounds":var_to_str(parts[key].bounds),"root_shift":var_to_str(registered.shift),"head":var_to_str(head),"body_height":body.get_used_rect().size.y,"density":density,"main":var_to_str(main),"off":var_to_str(off)})
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)
	return clip

func registered_run_body(source: Image,density: float) -> Dictionary:
	var part: Image = source.duplicate()
	part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
	var offset := Vector2i((Vector2(96,94)-foot_anchor(part)).round())
	var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
	body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
	quantize(body)
	var scalp := hair_bounds(body,red_center_y(body)-2)
	var shift := Vector2i(roundi(reference_head.get_center().x-scalp.get_center().x),0)
	var stable := Image.create(192,128,false,Image.FORMAT_RGBA8)
	stable.blit_rect(body,Rect2i(0,0,192,128),shift)
	body=stable
	var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
	var head := attach_back_head(body,identity,reference_head,foreground) if view=="up" else attach_head(body,identity,reference_head,view,foreground,false)
	remove_specks(body)
	return {"body":body,"head":head,"shift":shift}

func restore_source_forearms(clip: Resource,label: String,rows: Array) -> void:
	# The original head registration erased neutral armor just outside its
	# replacement rectangle. Restore the actual generated forearm pixels;
	# do not draw a substitute arm or move the accepted grip/attack anatomy.
	var atlas: Image = clip.body_atlas.get_image()
	var mask: Image = clip.hand_atlas.get_image()
	# Original side ingestion used the recorded 54px body reference. Its
	# historical density must not change if another family is later edited.
	var density: float = 54.0/rows[0][0].image.get_height()
	for key in ([8,11,12] if label=="rising" else [4]):
		var source_key: int = 8 if label=="rising" else 4
		var part: Image = rows[CUTS.find(label)][source_key].image.duplicate()
		part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
		var offset := Vector2i((Vector2(96,94)-foot_anchor(part)).round())
		var drawn := Image.create(192,128,false,Image.FORMAT_RGBA8)
		drawn.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
		quantize(drawn)
		var head := Rect2i(clip.identity_regions[key])
		var grip: Vector2 = clip.offhand.hands[key]
		var region := Rect2i(Vector2i(grip)-Vector2i(12,12),Vector2i(25,25))
		var origin := Vector2i(key%4*192,key/4*128)
		var body := atlas.get_region(Rect2i(origin,Vector2i(192,128)))
		for y in range(maxi(region.position.y,head.end.y-10),mini(region.end.y,128)):
			for x in range(maxi(region.position.x,roundi(head.get_center().x+head.size.x*.2)),mini(region.end.x,192)):
				if body.get_pixel(x,y).a<.65 and drawn.get_pixel(x,y).a>.65: body.set_pixel(x,y,drawn.get_pixel(x,y))
		remove_specks(body)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		for hilt in [clip.primary_hands[key],clip.offhand.hands[key]]:
			var rect := Rect2i(Vector2i(hilt)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,rect,origin+rect.position)
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)
