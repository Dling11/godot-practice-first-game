extends "res://tools/build_king_dual_twinsteel_cardinal.gd"

## Reuse accepted body cels verbatim. Only the two blade attachments differ.
const RECORDS := "res://art_source/registration/characters/king/dual_existing_gait_2026_10_05/"
const REFS := {
	"side": ["res://assets/characters/playable/king/axe_proof_v3/carry.tres",6,"res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres"],
	"up": ["res://assets/characters/playable/king/greatsword_readability/up/idle.tres",0,"res://assets/characters/playable/king/greatsword_cardinal/up/run.tres"],
	"down": ["res://assets/characters/playable/king/greatsword_readability/down/idle.tres",0,"res://assets/characters/playable/king/greatsword_cardinal/down/run.tres"]}

func _initialize() -> void:
	blade=load(OUTPUT+"twinsteel.png")
	for direction in ["side","up","down"]:
		view=direction
		var folder: String = OUTPUT+("" if direction=="side" else direction+"/")
		var idle := reuse_body(load(REFS[direction][0]),REFS[direction][1],false)
		var run := reuse_body(load(REFS[direction][2]),0,true)
		if failed: quit(1); return
		var clips: Array[Resource] = []
		for label in CUTS: clips.append(load(folder+label+".tres").duplicate(true))
		for cut in 5:
			# Queued endpoints keep their existing motion. A new standalone
			# chain and released recovery use the same genuine back stow.
			if cut==0: copy_dual_slot(clips[cut],0,idle,0)
			else: copy_dual_slot(clips[cut],0,clips[cut-1],12)
			copy_dual_slot(clips[cut],9,idle,0)
			if cut==4: copy_dual_slot(clips[cut],12,idle,0)
			write_dual(CUTS[cut],clips[cut],CUTS.slice(1) if cut==0 else [],folder)
		write_dual("idle",idle,[],folder)
		write_dual("run",run,[],folder)
	FileAccess.open(RECORDS+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("DUAL_EXISTING_GAIT: accepted body pixels / two loose side swords / crossed back idle")
	quit()

func reuse_body(source: Resource,idle_key: int,running: bool) -> Resource:
	var clip := Definition.new()
	clip.weapon_texture=blade
	clip.weapon_primary_grip=Vector2(11,66)
	clip.weapon_tip=Vector2(11,0)
	clip.mirror_cutting_edge=false
	clip.allow_rest=false
	clip.offhand=Offhand.new()
	clip.offhand.texture=blade
	clip.offhand.grip=clip.weapon_primary_grip
	clip.offhand.tip=clip.weapon_tip
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,256,false,Image.FORMAT_RGBA8)
	for key in 8:
		var source_key: int = key if running else idle_key
		var origin := Vector2i(source_key%4*192,source_key/4*128)
		var body: Image = source.body_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
		# Original body, hair, palette, leg length and placement are unchanged.
		var head := hair_bounds(body,red_center_y(body)-2)
		head.size.y=maxi(head.size.y,22)
		var main: Vector2
		var off: Vector2
		var a := 35.0
		var b := 145.0
		if running:
			# Front/back boots and belt are also brown. Register on the
			# outer arm bands, including a partly occluded genuine glove.
			var hands: Array[Vector2] = []
			if view=="side": hands=glove_centers(body,head)
			else:
				hands.append(find_glove(body,Vector2(84,72),head,8))
				hands.append(find_glove(body,Vector2(109,72),head,8))
			if hands.size()!=2 or hands[0]==Vector2.ZERO or hands[1]==Vector2.ZERO or hands[0].distance_to(hands[1])<6:
				push_error("Accepted run needs two real gloves: "+view+"/"+str(key))
				failed=true
				return clip
			main=hands[0]
			off=hands[1]
			# The accepted arms travel freely. A small alternating blade tilt
			# follows those strides instead of fixing two bars to the torso.
			var sway: float = [0,3,5,2,0,-3,-5,-2][key]
			a=170.0+sway
			b=10.0-sway
		else:
			# Crossed back attachment, no fictitious hand grip. Both guards
			# sit behind the shoulders and the fingers remain empty/relaxed.
			main=Vector2(85,54)
			off=Vector2(107,54)
		clip.primary_hands.append(main)
		clip.secondary_hands.append(main-Vector2.from_angle(deg_to_rad(a))*7)
		clip.offhand.hands.append(off)
		clip.offhand.axes.append(off-Vector2.from_angle(deg_to_rad(b))*7)
		clip.offhand.behind_body.append(0 if running else 1)
		clip.offhand.visible_poses.append(1)
		clip.weapon_behind_body[key]=0 if running else 1
		clip.single_hand_poses[key]=1
		clip.stowed_poses[key]=0 if running else 1
		clip.identity_regions.append(Rect2(head))
		var target := Vector2i(key%4*192,key/4*128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),target)
		if running:
			for grip in [main,off]:
				var rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
				mask.blit_rect(body,rect,target+rect.position)
		audit.append({"view":view,"clip":"run" if running else "idle","key":key,"source":source.resource_path,"source_key":source_key,"height":body.get_used_rect().size.y,"main":var_to_str(main),"off":var_to_str(off),"main_angle":a,"off_angle":b,"body_pixel_changed":false})
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)
	return clip
