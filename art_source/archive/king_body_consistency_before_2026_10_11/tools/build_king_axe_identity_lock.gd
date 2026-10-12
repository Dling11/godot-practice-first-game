extends "res://tools/build_king_axe_vertical_v2.gd"

const Identity = preload("res://tools/king_native_identity.gd")
const LOCK_SOURCE := "res://art_source/generated/characters/king/axe_identity_lock_2026_10_07/"
const LOCK_DEST := "res://assets/characters/playable/king/axe_identity_lock/"
const KEYS := [0,1,2,2,3,4,5,6,7,7,5,6,7]
const TURNS := [0,1,1,2,3,4,5,6,7,7,5,6,7]
const FACING := ["down","down","right","up","up","left","down","down"]
var identity := Identity.new()
var records: Array[Dictionary] = []
var jump_origins := {}

func _initialize() -> void:
	_setup_fresh_references()
	for view in ["up","down"]:
		var rows := identity.sheet_cells(Image.load_from_file(LOCK_SOURCE+view+"_source.png"),5,8)
		var scale := identity.density(rows[0][0].image,view)
		var idle := _carry(view,"idle")
		_carry(view,"run")
		var chains: Array[Array] = []
		for cut in 5:
			var slots: Array = []
			for key in 13:
				var source_key: int = TURNS[key] if cut==4 else KEYS[key]
				if cut==3: source_key=([0,1,2,3,4,5,6,6,7,7,5,6,7] if view=="up" else [0,1,2,3,5,5,6,6,7,7,5,6,7])[key]
				var head_view: String = FACING[source_key] if cut==4 else view
				if cut==4 and view=="up": head_view=["up","up","left","down","down","right","up","up"][source_key]
				var source_row := cut
				# The generated rear jump landing turned toward the camera.
				# Use this sheet's rear crouch, with the same density and rig.
				if view=="up" and cut==3 and key in [4,5,10]: source_row=0; source_key=5
				var source: Dictionary = rows[source_row][source_key]
				# The compressed front cel hides the red collar behind its chin.
				# Its traced neck is below the face, not beside the leather palm.
				var authored_socket := Vector2(52,49) if view=="down" and cut==3 and source_key==5 else Vector2.INF
				var placement := identity.place(source.image,scale,head_view,authored_socket)
				var body: Image = placement.body
				quantize(body)
				var guide := identity.axe_guide(source)
				if guide.is_empty(): push_error("Missing authored axe guide "+view+"/"+str(cut)+"/"+str(source_key)); quit(1); return
				var expected: Vector2 = Vector2(placement.offset)+guide.grip*scale
				var head := identity.freeze_head(body,head_view,placement.socket,[expected])
				var grip := _guide_palm(body,expected)
				var occluded := grip==Vector2.ZERO and head_view=="up" and head.has_point(Vector2i(expected))
				if occluded: grip=expected
				if grip==Vector2.ZERO:
					body.save_png(LOCK_SOURCE+"grip_failure.png")
					print("Expected ",expected," head ",head," guide ",guide," socket ",placement.socket)
					push_error("No real palm "+view+"/"+str(cut)+"/"+str(key)); quit(1); return
				remove_specks(body)
				var sole_shift := 95-body.get_used_rect().end.y
				if sole_shift!=0:
					var grounded := Image.create(192,128,false,Image.FORMAT_RGBA8)
					grounded.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,sole_shift))
					body=grounded; grip.y+=sole_shift; head.position.y+=sole_shift
				var heading: Vector2 = (guide.axis*scale).normalized()
				var rotation := heading.angle()-Vector2(-18,-10).angle()
				if cut==2 or (cut==3 and key in [4,5,6]): rotation=Vector2(0,-1 if view=="up" else 1).angle()-EDGE.angle()
				var axis := SHAFT.normalized().rotated(rotation)
				var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
				var glove := Rect2i(Vector2i(grip.round())-Vector2i(3,3),Vector2i(7,7))
				if not occluded: mask.blit_rect(body,glove,glove.position)
				var lift := -9.0 if cut==3 and key==2 else (-13.0 if cut==3 and key==3 else (-5.0 if cut==4 and key in [3,4,5,6] else 0.0))
				slots.append({"body":body,"hand":mask,"head":Rect2(head),"primary_hands":grip,"secondary_hands":grip+axis*7,"lift_pixels":lift,"weapon_behind_body":1 if head_view=="up" else 0,"single_hand_poses":0 if occluded else 1,"stowed_poses":0,"released_poses":0,"ground_clipped_poses":0,"primary_visible_poses":1,"occluded_hand_poses":1 if occluded else 0})
				records.append({"view":view,"cut":FRESH_NAMES[cut],"key":key,"source_row":source_row,"source_key":source_key,"head_view":head_view,"scale":var_to_str(scale),"head":var_to_str(head),"grip":var_to_str(grip),"guide_distance":guide.distance})
			chains.append(slots)
		for cut in 5:
			chains[cut][0]=_ready_slot(idle) if cut==0 else chains[cut-1][12].duplicate()
			chains[cut][9]=_ready_slot(idle)
			if cut==4: chains[cut][12]=_ready_slot(idle)
		for cut in 5: _write_locked(view,FRESH_NAMES[cut],chains[cut],FRESH_NAMES.slice(1) if cut==0 else [])
		var landing: Dictionary = chains[3][5]
		var rotation: float = (landing.secondary_hands-landing.primary_hands).angle()-SHAFT.angle()
		var blade: Vector2 = (landing.primary_hands+EDGE.rotated(rotation))*.5-Vector2(48,48)
		var effect_texture: Texture2D = load(FRESH_DEST+view+"/swing.png")
		var effect := effect_texture.get_image().get_region(Rect2i(192,576,192,192))
		jump_origins[view]=blade-(Vector2(effect.get_used_rect().get_center())-Vector2(96,96))*.85
	var text := FileAccess.get_file_as_string("res://data/weapons/families/iron_beard/presentation.tres")
	text=text.replace("res://gameplay/presentation/axe_vertical_v2_swing.tscn","res://gameplay/presentation/axe_identity_lock_swing.tscn")
	for view in ["up","down"]:
		text=text.replace(FRESH_DEST+view+"/chop.tres",LOCK_DEST+view+"/chop.tres")
		for lane in ["idle","run"]: text=text.replace("res://assets/characters/playable/king/axe_flow/"+view+"/"+lane+".tres",LOCK_DEST+view+"/"+lane+".tres")
	FileAccess.open(LOCK_DEST+"presentation.tres",FileAccess.WRITE).store_string(text)
	var scene := FileAccess.get_file_as_string("res://gameplay/presentation/axe_vertical_v2_swing.tscn")
	scene+="register_jump_origin = true\nupward_jump_origin = "+var_to_str(jump_origins.up)+"\ndownward_jump_origin = "+var_to_str(jump_origins.down)+"\n"
	FileAccess.open("res://gameplay/presentation/axe_identity_lock_swing.tscn",FileAccess.WRITE).store_string(scene)
	FileAccess.open(LOCK_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print("AXE_IDENTITY_LOCK frozen heads / authored grips / same accepted side and 3.19s clock")
	quit()

func _carry(view: String,lane: String) -> Resource:
	var old: Resource = load("res://assets/characters/playable/king/axe_flow/"+view+"/"+lane+".tres")
	var clip: Resource = old.duplicate(true)
	var atlas: Image = old.body_atlas.get_image().duplicate()
	var mask := Image.create(atlas.get_width(),atlas.get_height(),false,Image.FORMAT_RGBA8)
	var scale := identity.density(atlas.get_region(Rect2i(0,0,192,128)),view)
	for key in clip.pose_count:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		var body := atlas.get_region(Rect2i(origin,Vector2i(192,128)))
		var placed := identity.place(body,scale,view)
		body=placed.body
		var expected: Vector2 = Vector2(placed.offset)+old.primary_hands[key]*scale
		var primary := expected if clip.stowed_poses[key]>0 else _guide_palm(body,expected)
		assert(primary!=Vector2.ZERO,"Carry palm missing")
		var head := identity.freeze_head(body,view,placed.socket,[primary] if clip.stowed_poses[key]==0 else [])
		var axis: Vector2 = ((old.secondary_hands[key]-old.primary_hands[key])*scale).normalized()
		clip.primary_hands[key]=primary
		clip.secondary_hands[key]=primary+axis*7
		if clip.stowed_poses[key]==0:
			var glove := Rect2i(Vector2i(primary.round())-Vector2i(3,3),Vector2i(7,7))
			var hands := Image.create(192,128,false,Image.FORMAT_RGBA8)
			hands.blit_rect(body,glove,glove.position)
			mask.blit_rect(hands,Rect2i(0,0,192,128),origin)
		clip.identity_regions[key]=Rect2(head)
		atlas.fill_rect(Rect2i(origin,Vector2i(192,128)),Color.TRANSPARENT)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
	clip.identity_source_region=clip.identity_regions[0]
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)
	identity.save_clip(clip,LOCK_DEST+view+"/",lane)
	return clip

func _write_locked(view: String,label: String,slots: Array,followups: Array) -> void:
	var clip := Definition.new()
	clip.weapon_texture=AXE; clip.weapon_primary_grip=Vector2(39,33); clip.weapon_handle_axis=SHAFT
	clip.pose_count=13; clip.pose_order=PackedInt32Array(range(13)); clip.allow_rest=false
	clip.phase_windows=PackedVector2Array([Vector2(0,3),Vector2(4,6),Vector2(7,9)])
	clip.queued_recovery_window=Vector2(10,12)
	clip.pose_weights=PackedFloat32Array([.25,.7,1,1,1,1,1,1,1,1,.7,1,1])
	clip.mirror_cutting_edge=false
	var body := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
	for property in SLOT_FIELDS:
		var array = clip.get(property)
		array.resize(13)
		for key in 13: array[key]=slots[key][property]
		clip.set(property,array)
	for key in 13:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		body.blit_rect(slots[key].body,Rect2i(0,0,192,128),origin)
		mask.blit_rect(slots[key].hand,Rect2i(0,0,192,128),origin)
		clip.identity_regions.append(slots[key].head)
	clip.identity_source_region=clip.identity_regions[0]
	clip.body_atlas=ImageTexture.create_from_image(body); clip.hand_atlas=ImageTexture.create_from_image(mask)
	assert(clip.has_valid_layout(),"Locked axe clip invalid")
	identity.save_clip(clip,LOCK_DEST+view+"/",label,followups)

func _guide_palm(body: Image,expected: Vector2) -> Vector2:
	var best := INF
	var found := Vector2.ZERO
	for y in range(roundi(expected.y)-4,roundi(expected.y)+5):
		for x in range(roundi(expected.x)-4,roundi(expected.x)+5):
			if not Rect2i(0,0,192,128).has_point(Vector2i(x,y)): continue
			var c := body.get_pixel(x,y)
			if c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25:
				var distance := Vector2(x,y).distance_squared_to(expected)
				if distance<best: best=distance; found=Vector2(x,y)
	return found
