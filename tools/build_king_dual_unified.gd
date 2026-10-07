extends "res://tools/build_king_dual_polish.gd"

## One offline body calibration across carry, gait and all five cuts.
const UNIFIED := "res://art_source/generated/characters/king/dual_unified_2026_10_05/"
const INPUT := "res://art_source/archive/dual_existing_gait_rejected_2026_10_05/dual_twinsteel/"
const REFERENCES := {
	"side":["greatsword_confidence_v2/idle.tres",Rect2i(87,41,25,24)],
	"up":["greatsword_cardinal/up/run.tres",Rect2i(84,41,23,22)],
	"down":["greatsword_cardinal/down/run.tres",Rect2i(84,40,24,24)]}
const SIDE_RUN_SEAM := 77
const SIDE_RUN_BOB := [0,1,0,-1,0,1,0,-1]
const COMPACT_BLADE_SIZE := Vector2i(16,62)
const COMPACT_BLADE_GRIP := Vector2(8,50)
const COMPACT_BLADE_TIP := Vector2(8,0)
const SIDE_CARRY_GRIP := Vector2(8,44)
const SIDE_REAR_TEXTURE := OUTPUT+"twinsteel_side_rear.png"
const NEAR_ARM_SHIFT := Vector2i(3,1)
const NEAR_SOURCE_PALM := Vector2(84,73)
const REAR_CARRY_PALM := Vector2(91,69)
var refs := {}
var canonical_head := Rect2i()
var side_rear_blade: Texture2D

func _initialize() -> void:
	# Always resize the immutable source, never the previous build's blade.
	var compact := Image.load_from_file(ProjectSettings.globalize_path(INPUT+"twinsteel.png"))
	compact.resize(COMPACT_BLADE_SIZE.x,COMPACT_BLADE_SIZE.y,Image.INTERPOLATE_NEAREST)
	var native: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres")
	var ink: Color = native.body_atlas.get_image().get_pixel(79,74)
	compact=outlined_pixels(compact,ink)
	assert(compact.save_png(OUTPUT+"twinsteel.png")==OK)
	blade=ImageTexture.create_from_image(compact)
	# The far side-running hand is hidden by the torso. Keep the registered
	# blade/guard pixels, but do not expose a second handle behind that hand.
	var rear := compact.duplicate()
	rear.fill_rect(Rect2i(0,43,16,19),Color.TRANSPARENT)
	assert(rear.save_png(SIDE_REAR_TEXTURE)==OK)
	side_rear_blade=ImageTexture.create_from_image(rear)
	# The normal catalog can already own the imported output texture in the
	# resource cache. Keep this offline image anonymous; write_dual emits its
	# runtime path explicitly, without conflicting with that loaded resource.
	if not FileAccess.file_exists(INPUT+"metadata.cfg"):
		for direction in ["side","up","down"]:
			for label in CUTS+["idle","run"]:
				var clip: Resource = load(OUTPUT+("" if direction=="side" else direction+"/")+label+".tres")
				for property in META_FIELDS+["interpolate_blade_angles"]: meta.set_value(direction+"/"+label,property,clip.get(property))
				for property in ["hands","axes","behind_body","visible_poses"]: meta.set_value(direction+"/"+label,"off_"+property,clip.offhand.get(property))
		assert(meta.save(INPUT+"metadata.cfg")==OK)
	else: assert(meta.load(INPUT+"metadata.cfg")==OK)
	for direction in REFERENCES:
		var resource: Resource = load("res://assets/characters/playable/king/"+REFERENCES[direction][0])
		var body: Image = resource.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		refs[direction]=body
		for y in 128:
			for x in 192:
				var c := body.get_pixel(x,y)
				if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	refs["left"]=refs["side"].duplicate()
	refs["left"].flip_x()
	if "--side-run-only" in OS.get_cmdline_user_args():
		view="side"
		identity=refs[view]
		canonical_head=REFERENCES[view][1]
		var run := source_clip(view,"run")
		make_side_run(run)
		write_dual("run",run,[],OUTPUT,SIDE_REAR_TEXTURE)
		print("DUAL_SIDE_RUN: sketch-guided lower-hand carry")
		quit(1 if failed else 0)
		return
	var rows := extract_bodies(Image.load_from_file(ProjectSettings.globalize_path(UNIFIED+"thrust_source.png")),3)
	var original_cuts := extract_bodies(Image.load_from_file(ProjectSettings.globalize_path(RAW+"body_source.png")))
	for row in rows:
		if row.size()!=8:
			push_error("Unified source needs eight complete cels in each row")
			quit(1); return
	for direction in ["side","up","down"]:
		view=direction
		identity=refs[view]
		canonical_head=REFERENCES[view][1]
		var row: Array = rows[["side","down","up"].find(view)]
		var density := 54.0/float(row[0].image.get_height())
		# Fit standing anatomy once per source row, never zoom each frame.
		var initial_density := density
		var best_error := 999
		for attempt in 121:
			var candidate := initial_density*(0.7+attempt*.005)
			var sample := generated_body(row[0].image,candidate)
			var height: int = sample.body.get_used_rect().size.y
			if absi(54-height)<best_error:
				density=candidate
				best_error=absi(54-height)
			if best_error==0: break
		var idle := source_clip(view,"idle")
		var run := source_clip(view,"run")
		var clips: Array[Resource] = []
		for label in CUTS: clips.append(source_clip(view,label))
		if view=="side": restore_crosscut_sleeves(clips[1],original_cuts)
		make_idle(idle,row[0].image,density)
		make_thrust(clips[0],row,density)
		if view=="side": make_side_run(run)
		elif view=="down": make_front_run(run)
		else:
			calibrate(run,1.0,"run")
			steady_cardinal_run(run)
		for cut in range(1,5):
			var factor := (0.82 if view=="up" else (0.88 if view=="down" else 1.0))
			if cut==3:
				var widths: Array[int] = []
				for key in range(1,9): widths.append(hair_bounds(cel(clips[cut],key),red_center_y(cel(clips[cut],key))-2).size.x)
				widths.sort()
				factor=float(canonical_head.size.x)/float(widths[4])
			calibrate(clips[cut],factor,CUTS[cut])
			if cut==3:
				clips[cut].lift_pixels=PackedFloat32Array([0,-2,-8,-12,-12,-10,-8,-4,0,0,-4,0,0])
			elif cut==4:
				clips[cut].lift_pixels=PackedFloat32Array([0,0,-4,-8,-6,0,0,0,0,0,0,0,0])
			if cut in [1,2]: alternate_angles(clips[cut],cut)
		for clip in clips: register_attack_ground(clip)
		for cut in 5:
			copy_dual_slot(clips[cut],0,idle if cut==0 else clips[cut-1],0 if cut==0 else 12)
			copy_dual_slot(clips[cut],9,idle,0)
			if cut==4: copy_dual_slot(clips[cut],12,idle,0)
			var folder: String = OUTPUT+("" if view=="side" else view+"/")
			write_dual(CUTS[cut],clips[cut],CUTS.slice(1) if cut==0 else [],folder)
		var folder: String = OUTPUT+("" if view=="side" else view+"/")
		write_dual("idle",idle,[],folder)
		write_dual("run",run,[],folder,SIDE_REAR_TEXTURE if view=="side" else "")
		if failed: quit(1); return
	FileAccess.open(UNIFIED+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	var colors := []
	for c in palette: colors.append(c.to_html(true))
	FileAccess.open(UNIFIED+"palette.json",FileAccess.WRITE).store_string(JSON.stringify(colors,"\t")+"\n")
	print("DUAL_UNIFIED: one identity scale/palette; thrust / alternating cuts / hopping spin / X")
	quit()

func source_clip(direction: String,label: String) -> Resource:
	var section := direction+"/"+label
	var clip := Definition.new()
	for property in META_FIELDS+["interpolate_blade_angles"]: clip.set(property,meta.get_value(section,property))
	var path: String = INPUT+("" if direction=="side" else direction+"/")+label
	clip.body_atlas=ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path+"_body.png")))
	clip.hand_atlas=ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(path+"_hands.png")))
	clip.weapon_texture=blade
	clip.weapon_primary_grip=COMPACT_BLADE_GRIP
	clip.weapon_tip=COMPACT_BLADE_TIP
	clip.offhand=Offhand.new()
	clip.offhand.texture=blade
	clip.offhand.grip=clip.weapon_primary_grip
	clip.offhand.tip=clip.weapon_tip
	for property in ["hands","axes","behind_body","visible_poses"]: clip.offhand.set(property,meta.get_value(section,"off_"+property))
	return clip

func cel(clip: Resource,key: int) -> Image:
	return clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))

func generated_body(source: Image,density: float,front_thrust := false) -> Dictionary:
	var part: Image = source.duplicate()
	part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
	var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
	body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),Vector2i((Vector2(96,94)-foot_anchor(part)).round()))
	quantize(body)
	var original: Image = body.duplicate()
	var drawn_head := hair_bounds(body,red_center_y(body)-2)
	var original_gloves := glove_centers(body,drawn_head)
	var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
	var head: Rect2i
	if front_thrust:
		head=attach_front_thrust_head(body,drawn_head)
	else:
		head=attach_back_head(body,identity,canonical_head,foreground) if view=="up" else attach_head(body,identity,canonical_head,view,foreground)
	# A gray cuff connected to the scalp can enter its rectangular bounds.
	# Restore original arm pixels in empty space outside the new head only.
	for glove in original_gloves:
		for y in range(maxi(0,int(glove.y)-8),mini(128,int(glove.y)+9)):
			for x in range(maxi(0,int(glove.x)-8),mini(192,int(glove.x)+9)):
				if not head.has_point(Vector2i(x,y)) and body.get_pixel(x,y).a<.5 and original.get_pixel(x,y).a>.65:
					body.set_pixel(x,y,original.get_pixel(x,y))
	remove_specks(body)
	return {"body":body,"head":head}

func attach_front_thrust_head(body: Image,scalp: Rect2i) -> Rect2i:
	# The native front reference's red pixels are asymmetric. Matching one
	# crimson pixel had shifted the complete face toward the right glove.
	# Register its center to the drawn crown/neck axis instead; retain the
	# original complete scarf and actual fists around that smaller head.
	var socket := nearest_crimson(body,Vector2(scalp.get_center().x,scalp.end.y+2),Rect2i(scalp.position.x-3,scalp.end.y-2,scalp.size.x+6,12))
	var native_socket := nearest_crimson(identity,Vector2(canonical_head.get_center().x,canonical_head.end.y-1),canonical_head)
	assert(socket!=Vector2i(-1,-1) and native_socket!=Vector2i(-1,-1))
	var destination := Vector2i(roundi(scalp.get_center().x-canonical_head.size.x*.5),canonical_head.position.y+socket.y-native_socket.y)
	var erase := Rect2i(scalp.position,Vector2i(scalp.size.x,maxi(scalp.size.y,socket.y-scalp.position.y)))
	for y in range(erase.position.y,erase.end.y):
		for x in range(erase.position.x,erase.end.x):
			var color := body.get_pixel(x,y)
			# Brown gauntlets at either shoulder remain real foreground arms.
			var fist := color.r<.8 and color.r>color.g*1.35 and color.g>color.b*1.25
			if is_crimson(color): continue
			if y>=scalp.end.y-2 and (color.b>color.r+.005 or (fist and absf(x-scalp.get_center().x)>scalp.size.x*.28)): continue
			body.set_pixel(x,y,Color.TRANSPARENT)
	# This is an alpha composite, never a rectangular cutout around the neck.
	body.blend_rect(identity,canonical_head,destination)
	return Rect2i(destination,canonical_head.size)

func restore_crosscut_sleeves(clip: Resource,rows: Array) -> void:
	# The immutable side archive already contains the first ingestion's
	# erased neutral sleeves. Repair from the actual source arm, before grip
	# registration, without replacing the accepted face or attack poses.
	var density: float = 54.0/rows[0][0].image.get_height()
	var atlas: Image = clip.body_atlas.get_image()
	for key in [4,5,6,7,8,10,11,12]:
		var source_key: int = key if key<10 else mini(key-3,8)
		var part: Image = rows[1][source_key].image.duplicate()
		part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
		var drawn := Image.create(192,128,false,Image.FORMAT_RGBA8)
		drawn.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),Vector2i((Vector2(96,94)-foot_anchor(part)).round()))
		quantize(drawn)
		var body := cel(clip,key)
		var head := Rect2i(clip.identity_regions[key])
		var glove: Vector2 = clip.offhand.hands[key]
		var shoulder := Vector2(head.get_center().x+5,head.end.y+5)
		for y in range(maxi(0,roundi(glove.y)-7),mini(128,roundi(shoulder.y)+6)):
			for x in range(maxi(0,roundi(shoulder.x)-6),mini(192,roundi(glove.x)+7)):
				var point := Vector2(x,y)
				if point.distance_to(Geometry2D.get_closest_point_to_segment(point,glove,shoulder))>6: continue
				# At crown height the original hair also occupies this corridor;
				# only the arm's outside edge belongs there. Below it, restore
				# neutral sleeve/outline pixels too, not only blue highlights.
				if y<head.position.y+head.size.y*.55 and x<head.end.x-2: continue
				var color := drawn.get_pixel(x,y)
				if body.get_pixel(x,y).a<.65 and color.a>.65 and not is_crimson(color):
					body.set_pixel(x,y,color)
		atlas.blit_rect(body,Rect2i(0,0,192,128),Vector2i(key%4*192,key/4*128))
	clip.body_atlas=ImageTexture.create_from_image(atlas)

func put_cel(clip: Resource,key: int,body: Image,head: Rect2i,main: Vector2,off: Vector2,a: float,b: float,stowed := false) -> void:
	var origin := Vector2i(key%4*192,key/4*128)
	var atlas: Image = clip.body_atlas.get_image()
	var mask: Image = clip.hand_atlas.get_image()
	atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
	mask.fill_rect(Rect2i(origin,Vector2i(192,128)),Color.TRANSPARENT)
	if not stowed:
		for grip in [main,off] if clip.offhand.visible_poses[key] else [main]:
			var rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,rect,origin+rect.position)
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)
	clip.identity_regions[key]=Rect2(head)
	clip.primary_hands[key]=main
	clip.secondary_hands[key]=main-Vector2.from_angle(deg_to_rad(a))*7
	clip.offhand.hands[key]=off
	clip.offhand.axes[key]=off-Vector2.from_angle(deg_to_rad(b))*7
	clip.stowed_poses[key]=1 if stowed else 0
	audit.append({"view":view,"key":key,"head":var_to_str(head),"height":body.get_used_rect().size.y,"main":var_to_str(main),"off":var_to_str(off),"a":a,"b":b,"stowed":stowed})

func make_idle(clip: Resource,source: Image,density: float) -> void:
	# Keep the front identity and torso as one existing cel. Matching height
	# alone had made a wider generated body look large and its head displaced.
	var registered: Dictionary
	if view=="down":
		var native: Image = refs["down"].duplicate()
		var shift := Vector2i(0,94-(native.get_used_rect().end.y-1))
		var grounded := Image.create(192,128,false,Image.FORMAT_RGBA8)
		grounded.blit_rect(native,Rect2i(0,0,192,128),shift)
		# The first native gait cel staggered the feet. Reuse its planted
		# foreground leg on both sides, leaving the accepted upper body intact.
		var leg := grounded.get_region(Rect2i(93,77,12,18))
		grounded.fill_rect(Rect2i(0,77,192,51),Color.TRANSPARENT)
		grounded.blit_rect(leg,Rect2i(0,0,12,18),Vector2i(97,77))
		leg.flip_x()
		grounded.blit_rect(leg,Rect2i(0,0,12,18),Vector2i(84,77))
		registered={"body":grounded,"head":Rect2i(canonical_head.position+shift,canonical_head.size)}
	else:
		registered=generated_body(source,density)
	clip.allow_rest=false
	clip.lift_pixels.fill(0)
	for key in 8:
		# Up shows King's actual back: blades belong OVER the visible back.
		# Down shows his chest: back blades belong behind that silhouette.
		clip.weapon_behind_body[key]=0 if view=="up" else 1
		clip.offhand.behind_body[key]=clip.weapon_behind_body[key]
		clip.offhand.visible_poses[key]=1
		put_cel(clip,key,registered.body,registered.head,Vector2(88,56),Vector2(104,56),35,145,true)

func make_side_run(clip: Resource) -> void:
	clip.weapon_primary_grip=SIDE_CARRY_GRIP
	clip.offhand.grip=SIDE_CARRY_GRIP
	clip.weapon_texture=blade
	clip.offhand.texture=side_rear_blade
	var source: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres")
	var steady := cel(source,0)
	var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
	var steady_head := attach_head(steady,identity,canonical_head,"side",foreground,false)
	var intact := steady.duplicate()
	# The visible lower forearm owns the front sword. Preserve its original
	# closed fist instead of using the other, raised hand as its attachment.
	var near := Image.create(192,128,false,Image.FORMAT_RGBA8)
	var shape := PackedVector2Array([
		Vector2(83,66),Vector2(88,66),Vector2(90,69),Vector2(89,76),
		Vector2(83,78),Vector2(77,74),Vector2(79,70)])
	for y in range(66,79):
		for x in range(77,91):
			if Geometry2D.is_point_in_polygon(Vector2(x,y),shape):
				near.set_pixel(x,y,intact.get_pixel(x,y))
				steady.set_pixel(x,y,Color.TRANSPARENT)
	# The far fist is tucked behind the vest. Remove its projecting raised
	# pose, retaining the scarf and the complete central chest plate.
	for y in range(66,77):
		for x in range(105,121):
			if not is_crimson(steady.get_pixel(x,y)):
				steady.set_pixel(x,y,Color.TRANSPARENT)
	steady.blit_rect(intact,Rect2i(90,65,15,12),Vector2i(90,65))
	near=outlined_pixels(near,intact.get_pixel(79,74))
	var main := NEAR_SOURCE_PALM+Vector2(NEAR_ARM_SHIFT)
	for key in clip.pose_count:
		var bob := Vector2i(0,SIDE_RUN_BOB[key])
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(steady,Rect2i(0,0,192,77),bob)
		body.fill_rect(Rect2i(0,77,192,51),Color.TRANSPARENT)
		body.blit_rect(cel(source,key),Rect2i(0,77,192,51),Vector2i(0,77))
		# Composite the complete foreground fist AFTER the leg seam. A hand
		# reaching below the seam must not lose its fingers or outline there.
		var arm_origin := NEAR_ARM_SHIFT+bob
		body.blend_rect(near,Rect2i(0,0,192,128),arm_origin)
		clip.weapon_behind_body[key]=0
		clip.offhand.behind_body[key]=1
		clip.offhand.visible_poses[key]=1
		put_cel(clip,key,body,Rect2i(steady_head.position+bob,steady_head.size),main+Vector2(bob),REAR_CARRY_PALM+Vector2(bob),5,-8)
		# This is actual outlined forearm/finger art, not a rectangle of vest
		# pixels. It covers the hilt while leaving the crossguard legible.
		var mask: Image = clip.hand_atlas.get_image()
		var origin := Vector2i(key%4*192,key/4*128)
		mask.fill_rect(Rect2i(origin,Vector2i(192,128)),Color.TRANSPARENT)
		mask.blend_rect(near,Rect2i(0,0,192,128),origin+arm_origin)
		clip.hand_atlas=ImageTexture.create_from_image(mask)
		audit[-1]["clip"]="run"
		audit[-1]["steady_carry_bob"]=bob.y
		audit[-1]["front_sword_lower_hand"]=true
		audit[-1]["rear_hand_occluded"]=true
		audit[-1]["near_arm_shift"]=var_to_str(NEAR_ARM_SHIFT)
		audit[-1]["outlined_native_forearm"]=true

func outlined_pixels(source: Image,ink: Color) -> Image:
	# One extra native outline texel makes the existing dark edge readable
	# at 0.5 scale. Start from the immutable source so builds never grow it.
	var result := source.duplicate()
	for y in source.get_height():
		for x in source.get_width():
			if source.get_pixel(x,y).a>.1: continue
			var edge := false
			for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
				var point: Vector2i = Vector2i(x,y)+offset
				if point.x<0 or point.y<0 or point.x>=source.get_width() or point.y>=source.get_height(): continue
				if source.get_pixelv(point).a>.65:
					edge=true
					break
			if edge: result.set_pixel(x,y,ink)
	return result

func steady_cardinal_run(clip: Resource) -> void:
	var steady := cel(clip,0)
	var head := Rect2i(clip.identity_regions[0])
	var main: Vector2 = clip.primary_hands[0]
	var off: Vector2 = clip.offhand.hands[0]
	var pelvis_x := back_pelvis_center(steady)
	for key in clip.pose_count:
		var legs := cel(clip,key)
		# The original complete gait moves sideways with its own upper body.
		# A steady carrying torso needs each pelvis registered to its fixed
		# centre, otherwise later keys leave the feet beside that torso.
		var stride_x := roundi(pelvis_x-back_pelvis_center(legs))
		var bob := Vector2i(0,SIDE_RUN_BOB[key])
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(steady,Rect2i(0,0,192,80),bob)
		body.fill_rect(Rect2i(0,SIDE_RUN_SEAM,192,128-SIDE_RUN_SEAM),Color.TRANSPARENT)
		body.blit_rect(legs,Rect2i(0,SIDE_RUN_SEAM,192,128-SIDE_RUN_SEAM),Vector2i(stride_x,SIDE_RUN_SEAM))
		# Three degrees only: a shallow outward V, never crossed hilts.
		var a := -93.0 if view=="up" else 93.0
		var b := -87.0 if view=="up" else 87.0
		put_cel(clip,key,body,Rect2i(head.position+bob,head.size),main+Vector2(bob),off+Vector2(bob),a,b)
		audit[-1]["clip"]="run"
		audit[-1]["steady_carry_bob"]=bob.y
		audit[-1]["cardinal_tilt_degrees"]=3
		audit[-1]["back_stride_x"]=stride_x
		audit[-1]["back_pelvis_x"]=back_pelvis_center(body)

func back_pelvis_center(body: Image) -> float:
	# Read the trouser band below the seam, excluding the moving gloves.
	# Two rows resist one-pixel outline differences without rescaling legs.
	var sum := 0.0
	for y in [SIDE_RUN_SEAM+1,SIDE_RUN_SEAM+2]:
		var low := 192
		var high := -1
		for x in range(70,125):
			if body.get_pixel(x,y).a>.65: low=mini(low,x); high=maxi(high,x)
		assert(high>=low,"Back gait has no connected pelvis band")
		sum+=(low+high)*.5
	return sum*.5

func make_front_run(clip: Resource) -> void:
	# Down idle already uses this complete native cel. A second head graft
	# shifted the run crown five texels sideways from its chest. Preserve
	# the head/neck/scarf/torso as one cel instead of registering them apart.
	var source: Resource = load("res://assets/characters/playable/king/greatsword_cardinal/down/run.tres")
	var native := cel(source,0)
	var shift := Vector2i(0,94-(native.get_used_rect().end.y-1))
	var steady := Image.create(192,128,false,Image.FORMAT_RGBA8)
	steady.blit_rect(native,Rect2i(0,0,192,128),shift)
	var head := Rect2i(canonical_head.position+shift,canonical_head.size)
	var hands := glove_centers(steady,head)
	if hands.size()!=2:
		push_error("Native front carry needs two actual gloves")
		failed=true
		return
	clip.lift_pixels.fill(0)
	for key in clip.pose_count:
		var bob := Vector2i(0,SIDE_RUN_BOB[key])
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(steady,Rect2i(0,0,192,80),bob)
		body.fill_rect(Rect2i(0,SIDE_RUN_SEAM,192,128-SIDE_RUN_SEAM),Color.TRANSPARENT)
		var stride := Image.create(192,128,false,Image.FORMAT_RGBA8)
		stride.blit_rect(cel(source,key),Rect2i(0,0,192,128),shift)
		body.blit_rect(stride,Rect2i(0,SIDE_RUN_SEAM,192,128-SIDE_RUN_SEAM),Vector2i(0,SIDE_RUN_SEAM))
		clip.weapon_behind_body[key]=0
		clip.offhand.behind_body[key]=0
		clip.offhand.visible_poses[key]=1
		put_cel(clip,key,body,Rect2i(head.position+bob,head.size),hands[0]+Vector2(bob),hands[1]+Vector2(bob),93,87)
		audit[-1]["clip"]="run"
		audit[-1]["steady_carry_bob"]=bob.y
		audit[-1]["cardinal_tilt_degrees"]=3
		audit[-1]["native_front_upper_unchanged"]=true
		audit[-1]["native_front_legs_unchanged"]=true

func make_thrust(clip: Resource,row: Array,density: float) -> void:
	var order := [0,1,2,3,4,5,5,6,7,0,6,7,7]
	var rotation := -90.0 if view=="up" else (90.0 if view=="down" else 0.0)
	clip.interpolate_blade_angles=true
	clip.lift_pixels.fill(0)
	for key in 13:
		var registered := generated_body(row[order[key]].image,density,view=="down")
		var hands := glove_centers(registered.body,registered.head)
		if hands.size()!=2:
			push_error("Thrust needs visible hands: "+view+"/"+str(key)); failed=true; return
		clip.offhand.visible_poses[key]=0 if offhand_occluded else 1
		clip.weapon_behind_body[key]=1 if view=="up" else 0
		clip.offhand.behind_body[key]=clip.weapon_behind_body[key]
		put_cel(clip,key,registered.body,registered.head,hands[0],hands[1],rotation-6,rotation+6)

func calibrate(clip: Resource,factor: float,label: String) -> void:
	if not is_equal_approx(factor,1): scale_body_clip(clip,factor)
	for key in clip.pose_count:
		var body := cel(clip,key)
		quantize(body)
		var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var head := hair_bounds(body,red_center_y(body)-2)
		# Turning body cels use the matching canonical front/profile/back head.
		var facing := view
		if label=="spin" and key in [1,2,3,4,5,6,7,8,10,11,12]:
			var cycle := ["side","down","left","left","up","up","side","side"] if view=="side" else (["up","left","down","down","side","side","up","up"] if view=="up" else ["down","side","up","up","left","left","down","down"])
			facing=cycle[mini(key-1 if key<10 else key-4,7)]
		var ref: Image = refs[facing]
		var region: Rect2i = REFERENCES["side" if facing=="left" else facing][1]
		if facing=="left": region.position.x=192-region.end.x
		if label=="spin" or label=="run":
			if facing=="up": head=attach_back_head(body,ref,region,foreground)
			else: head=attach_head(body,ref,region,facing,foreground)
		elif view=="side":
			# Accepted side cuts already contain the exact installed head.
			# Preserve their original forearms and anatomy intact.
			head=Rect2i(clip.identity_regions[key])
		else:
			# Scale complete existing vertical bodies together, keeping cuffs.
			# The original head is already installed identity; no second graft.
			head=hair_bounds(body,red_center_y(body)-2)
			head.size=Vector2i(canonical_head.size.x,canonical_head.size.y)
		remove_specks(body)
		var main: Vector2 = find_glove(body,clip.primary_hands[key],head,6)
		var off: Vector2 = find_glove(body,clip.offhand.hands[key],head,6)
		if main==Vector2.ZERO: main=clip.primary_hands[key]
		if off==Vector2.ZERO: off=clip.offhand.hands[key]
		var a := rad_to_deg((clip.primary_hands[key]-clip.secondary_hands[key]).angle())
		var b := rad_to_deg((clip.offhand.hands[key]-clip.offhand.axes[key]).angle())
		if label=="run":
			# Cardinal carry keeps separate parallel blades in their own hand
			# lanes. Opposed diagonal angles crossed over the head/boots.
			a=-90 if view=="up" else 90
			b=a
			clip.weapon_behind_body[key]=1 if view in ["side","up"] else 0
			clip.offhand.behind_body[key]=1 if view=="up" else 0
		put_cel(clip,key,body,head,main,off,a,b,clip.stowed_poses[key]>0)
		# Calibration is clip-wide; stance crouch remains actual anatomy.
		audit[-1]["clip"]=label
		audit[-1]["density_factor"]=factor

func scale_body_clip(clip: Resource,factor: float) -> void:
	var atlas := Image.create(clip.body_atlas.get_width(),clip.body_atlas.get_height(),false,Image.FORMAT_RGBA8)
	var offset := Vector2i((Vector2(96,94)*(1.0-factor)).round())
	for key in clip.pose_count:
		var part := cel(clip,key)
		part.resize(roundi(192*factor),roundi(128*factor),Image.INTERPOLATE_NEAREST)
		atlas.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),Vector2i(key%4*192,key/4*128)+offset)
		clip.primary_hands[key]=(clip.primary_hands[key]*factor+Vector2(offset)).round()
		clip.secondary_hands[key]=clip.secondary_hands[key]*factor+Vector2(offset)
		clip.offhand.hands[key]=(clip.offhand.hands[key]*factor+Vector2(offset)).round()
		clip.offhand.axes[key]=clip.offhand.axes[key]*factor+Vector2(offset)
	clip.body_atlas=ImageTexture.create_from_image(atlas)

func alternate_angles(clip: Resource,cut: int) -> void:
	var main := [-95,-110,-100,-50,20,65,105,130,100,50,-20,-50,-75]
	var off := [60,40,10,-35,-70,-105,-130,-150,-120,-90,40,65,85]
	var rotation := -90.0 if view=="up" else (90.0 if view=="down" else 0.0)
	for key in 13:
		var a: float = (main[key] if cut==1 else off[key])+rotation
		var b: float = (off[key] if cut==1 else main[key])+rotation
		clip.secondary_hands[key]=clip.primary_hands[key]-Vector2.from_angle(deg_to_rad(a))*7
		clip.offhand.axes[key]=clip.offhand.hands[key]-Vector2.from_angle(deg_to_rad(b))*7

func register_attack_ground(clip: Resource) -> void:
	var atlas: Image = clip.body_atlas.get_image()
	var mask: Image = clip.hand_atlas.get_image()
	for key in clip.pose_count:
		var origin := Vector2i(key%4*192,key/4*128)
		var part := atlas.get_region(Rect2i(origin,Vector2i(192,128)))
		var delta := Vector2i(0,94-(part.get_used_rect().end.y-1))
		if delta.y==0: continue
		var shifted := Image.create(192,128,false,Image.FORMAT_RGBA8)
		shifted.blit_rect(part,Rect2i(0,0,192,128),delta)
		atlas.blit_rect(shifted,Rect2i(0,0,192,128),origin)
		shifted.fill(Color.TRANSPARENT)
		shifted.blit_rect(mask.get_region(Rect2i(origin,Vector2i(192,128))),Rect2i(0,0,192,128),delta)
		mask.blit_rect(shifted,Rect2i(0,0,192,128),origin)
		clip.primary_hands[key]+=Vector2(delta)
		clip.secondary_hands[key]+=Vector2(delta)
		clip.offhand.hands[key]+=Vector2(delta)
		clip.offhand.axes[key]+=Vector2(delta)
		clip.identity_regions[key].position+=Vector2(delta)
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)
