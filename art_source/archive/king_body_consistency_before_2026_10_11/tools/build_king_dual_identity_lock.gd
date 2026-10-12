extends "res://tools/build_king_dual_v2_cardinal.gd"

const Identity = preload("res://tools/king_native_identity.gd")
const LOCK_DEST := "res://assets/characters/playable/king/dual_identity_lock/"
const PROOF := "res://art_source/review/combat/king_dual_identity_lock_2026_10_08/"
const KEYS := [0,1,2,2,3,4,5,6,7,8,5,6,7]
var native_identity := Identity.new()
var records: Array[Dictionary] = []

func _initialize() -> void:
	setup_references()
	blade=load(STEEL_PATH)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PROOF))
	FileAccess.open(PROOF+".gdignore",FileAccess.WRITE).store_string("")
	for view in ["side","down"]: _gait(view)
	# These body-only drawings overlap nominal row bands. Their connected,
	# scarf-labelled silhouettes own the complete cel rather than a grid crop.
	var idle_rows := extract_bodies(Image.load_from_file(V2_SOURCE+"idle_source.png"),3)
	var front_rows := extract_bodies(Image.load_from_file(V2_SOURCE+"down_source.png"),5)
	for row in idle_rows:
		if row.size()!=8: push_error("Idle source lacks eight complete bodies"); quit(1); return
	for row in front_rows:
		if row.size()!=9: push_error("Front source lacks nine complete bodies"); quit(1); return
	var idle := _front_clip(-1,idle_rows[1],native_identity.density(idle_rows[1][0].image,"down"))
	if failed or idle==null: quit(1); return
	var scale := native_identity.density(front_rows[0][0].image,"down")
	var clips: Array[Resource] = []
	for cut in 5:
		var clip := _front_clip(cut,front_rows[cut],scale)
		if failed or clip==null: quit(1); return
		clips.append(clip)
	for cut in 5:
		copy_dual_slot(clips[cut],0,idle if cut==0 else clips[cut-1],0 if cut==0 else 12)
		copy_dual_slot(clips[cut],9,idle,0)
		if cut==4: copy_dual_slot(clips[cut],12,idle,0)
	for cut in 5: native_identity.save_clip(clips[cut],LOCK_DEST+"down/",STUDY_NAMES[cut],STUDY_NAMES.slice(1) if cut==0 else [])
	native_identity.save_clip(idle,LOCK_DEST+"down/","idle")
	var text := FileAccess.get_file_as_string("res://data/weapons/families/twinsteel_v2/presentation.tres")
	text=text.replace(V2_DEST+"run.tres",LOCK_DEST+"run.tres")
	for lane in ["diagonal","idle","run"]: text=text.replace(V2_DEST+"down/"+lane+".tres",LOCK_DEST+"down/"+lane+".tres")
	FileAccess.open(LOCK_DEST+"presentation.tres",FileAccess.WRITE).store_string(text)
	FileAccess.open(PROOF+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("DUAL_IDENTITY_LOCK approved Greatsword strides / complete front cels / frozen heads / calm front planted idle")
	quit(1 if failed else 0)

func _front_clip(cut: int,cells: Array,scale: Vector2) -> Resource:
	var old: Resource = load(V2_DEST+"down/"+("idle" if cut<0 else STUDY_NAMES[cut])+".tres")
	var clip: Resource = old.duplicate(true)
	clip.follow_up_clips.clear()
	clip.pose_count=8 if cut<0 else 13
	clip.pose_order=PackedInt32Array(range(clip.pose_count))
	clip.pose_weights=PackedFloat32Array()
	clip.identity_regions.clear()
	if cut>=0:
		clip.phase_windows=PackedVector2Array([Vector2(0,3),Vector2(4,6),Vector2(7,9)])
		clip.queued_recovery_window=Vector2(10,12)
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","primary_visible_poses"]: clip.set(property,clip.get(property).slice(0,0))
	for property in ["hands","axes","behind_body","visible_poses"]: clip.offhand.set(property,clip.offhand.get(property).slice(0,0))
	var atlas := Image.create(768,128*ceili(clip.pose_count/4.0),false,Image.FORMAT_RGBA8)
	var masks := Image.create(atlas.get_width(),atlas.get_height(),false,Image.FORMAT_RGBA8)
	for key in clip.pose_count:
		var source_key: int = KEYS[key] if cut>=0 else mini(key,4)
		var placed := native_identity.place(cells[source_key].image,scale,"down")
		var body: Image = placed.body
		quantize(body)
		var planted: bool = cut<0 and key>=3
		var preliminary := Rect2i(roundi(placed.socket.x)-9,roundi(placed.socket.y)-24,18,22)
		var palms := glove_centers(body,preliminary)
		if palms.size()<2 and not planted: push_error("Complete front palms missing"); failed=true; return clip
		var head_view: String = ("left" if key==5 else ("right" if key==6 else "down")) if cut<0 else (["down","down","down","left","up","up","right","down","down"][source_key] if cut==3 else "down")
		var head := native_identity.freeze_head(body,head_view,placed.socket,palms if not planted else [])
		remove_specks(body)
		var shift := 95-body.get_used_rect().end.y
		if shift!=0:
			var grounded := Image.create(192,128,false,Image.FORMAT_RGBA8)
			grounded.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,shift))
			body=grounded; head.position.y+=shift
			for index in palms.size(): palms[index].y+=shift
		var near := Vector2(72,44) if planted else palms[0]
		var far := Vector2(120,44) if planted else palms[1]
		var motion_key := roundi(source_key/8.0*7) if cut>=0 else 0
		var angle: float = STUDY_MAIN[cut][motion_key]+90 if cut>=0 else ([165.0,-90.0,150.0,90.0,90.0,90.0,90.0,90.0][key])
		var other: float = STUDY_OFF[cut][motion_key]+90 if cut>=0 else ([15.0,-90.0,30.0,90.0,90.0,90.0,90.0,90.0][key])
		clip.primary_hands.append(near); clip.secondary_hands.append(near-Vector2.from_angle(deg_to_rad(angle))*7)
		clip.offhand.hands.append(far); clip.offhand.axes.append(far-Vector2.from_angle(deg_to_rad(other))*7)
		clip.offhand.behind_body.append(1 if head_view=="up" else 0); clip.offhand.visible_poses.append(0 if offhand_occluded and not planted else 1)
		clip.primary_visible_poses.append(1); clip.single_hand_poses.append(1)
		clip.weapon_behind_body.append(1 if head_view=="up" else 0); clip.stowed_poses.append(0)
		clip.released_poses.append(1 if planted else 0); clip.ground_clipped_poses.append(0)
		clip.lift_pixels.append(-10.0 if cut==4 and key in [2,3] else (-7.0 if cut==3 and key in [2,3,4,5,6,10] else 0.0))
		clip.identity_regions.append(Rect2(head)); clip.pose_weights.append(.3 if cut>=0 and key==0 else 1.0)
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		var hands := Image.create(192,128,false,Image.FORMAT_RGBA8)
		if not planted:
			for grip in [near,far]:
				var box := Rect2i(Vector2i(grip.round())-Vector2i(3,3),Vector2i(7,7))
				hands.blit_rect(body,box,box.position)
		masks.blit_rect(hands,Rect2i(0,0,192,128),origin)
		records.append({"lane":"idle" if cut<0 else STUDY_NAMES[cut],"key":key,"source_key":source_key,"head_view":head_view,"scale":var_to_str(scale),"head":var_to_str(head)})
	clip.identity_source_region=clip.identity_regions[0]
	clip.body_atlas=ImageTexture.create_from_image(atlas); clip.hand_atlas=ImageTexture.create_from_image(masks)
	return clip

func _gait(view: String) -> void:
	var great: Resource = load("res://assets/characters/playable/king/greatsword_readability/side/run.tres" if view=="side" else "res://assets/characters/playable/king/greatsword_v2_cardinal_carry/down/run.tres")
	var clip: Resource = load(V2_DEST+("" if view=="side" else "down/")+"run.tres").duplicate(true)
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var masks := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var scale := Vector2.ONE if view=="side" else native_identity.density(great.body_atlas.get_image().get_region(Rect2i(0,0,192,128)),"down")
	for key in 8:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		var original: Image = great.body_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
		var body: Image = original.duplicate()
		var head := Rect2i(great.identity_regions[key])
		var primary: Vector2 = great.primary_hands[key]
		var far: Vector2 = great.secondary_hands[key]
		if view=="down":
			var placed := native_identity.place(body,scale,"down")
			body=placed.body
			primary=Vector2(placed.offset)+primary*scale; far=Vector2(placed.offset)+far*scale
			head=native_identity.freeze_head(body,"down",placed.socket,[primary,far])
		var palms := glove_centers(body,head)
		if palms.size()>=2: primary=palms[0]; far=palms[1]
		# Hands from the exact accepted gait; neither blade is a back mount.
		clip.primary_hands[key]=primary; clip.offhand.hands[key]=far
		var main_angle := 10.0 if view=="side" else 110.0
		var other_angle := -6.0 if view=="side" else 70.0
		clip.secondary_hands[key]=primary-Vector2.from_angle(deg_to_rad(main_angle))*7
		clip.offhand.axes[key]=far-Vector2.from_angle(deg_to_rad(other_angle))*7
		if view=="down": clip.offhand.texture=blade
		clip.offhand.behind_body[key]=1 if view=="side" else 0
		clip.offhand.visible_poses[key]=1
		clip.identity_regions[key]=Rect2(head)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		var hands := Image.create(192,128,false,Image.FORMAT_RGBA8)
		for grip in [primary,far]:
			var box := Rect2i(Vector2i(grip.round())-Vector2i(3,3),Vector2i(7,7))
			hands.blit_rect(body,box,box.position)
		masks.blit_rect(hands,Rect2i(0,0,192,128),origin)
	clip.body_atlas=ImageTexture.create_from_image(atlas); clip.hand_atlas=ImageTexture.create_from_image(masks)
	clip.identity_source_region=clip.identity_regions[0]
	native_identity.save_clip(clip,LOCK_DEST+("" if view=="side" else "down/"),"run")

