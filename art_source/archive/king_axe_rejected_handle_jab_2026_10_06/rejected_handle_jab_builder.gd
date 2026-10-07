extends "res://tools/build_king_axe_cardinal.gd"

## Offline raster registration. Reuses accepted axe cuts and leaves their
## original atlases, all carry/gait clips, and the other families untouched.
const FLOW_SOURCE := "res://art_source/generated/characters/king/axe_flow_2026_10_06/"
const FLOW_DEST := "res://assets/characters/playable/king/axe_flow/"
const FLOW_NAMES := ["chop","jab","slam","spin"]
const SLOT_PROPERTIES := ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]
var flow_records: Array[Dictionary] = []

func _initialize() -> void:
	var rows := extract_bodies(Image.load_from_file(FLOW_SOURCE+"jab_source.png"),3)
	for row in rows:
		if row.size()!=10:
			push_error("Axe jab requires ten complete bodies per direction; found "+str(row.size()))
			quit(1); return
	var density: float = 54.0/float(rows[0][0].image.get_height())
	for index in 3:
		_build_flow(["side","down","up"][index],rows[index],density)
		if failed: quit(1); return
	_build_flow_effects()
	FileAccess.open(FLOW_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"density":density,"new_source_cels":30,"runtime_cels":156,"names":FLOW_NAMES,"records":flow_records},"\t")+"\n")
	print("AXE_FLOW registered30 new jab cels; four connected cuts x13 keys x3 authored views")
	quit(1 if failed else 0)

func _build_flow(direction: String,row: Array,density: float) -> void:
	var folder := FLOW_DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var idle: Resource = load("res://assets/characters/playable/king/"+("axe_proof_v3/carry.tres" if direction=="side" else "axe_cardinal/"+direction+"/idle.tres"))
	var guard := _source_slot(idle,0)
	var reference: Image = guard.body
	var head := Rect2i(84,41,24,24) if direction=="down" else hair_bounds(reference,red_center_y(reference)-2)
	if direction=="side": head.size.y+=7
	palette.clear(); color_cache.clear()
	for y in 128:
		for x in 192:
			var color := reference.get_pixel(x,y)
			if color.a>.65 and not palette.has(Color(color.r,color.g,color.b,1)): palette.append(Color(color.r,color.g,color.b,1))
	var chains: Array[Array] = []
	var originals: Array[Resource] = []
	for name in FLOW_NAMES:
		if name=="jab":
			chains.append(_jab_slots(direction,row,density,reference,head))
			originals.append(idle)
		else:
			var path: String = "res://assets/characters/playable/king/axe_cardinal/"+direction+"/"+name+".tres"
			if direction=="side":
				path={"chop":"res://assets/characters/playable/king/axe_proof_v3/down.tres","slam":"res://assets/characters/playable/king/axe_proof/finisher.tres","spin":"res://assets/characters/playable/king/axe_proof_v3/spin.tres"}[name]
			var source: Resource = load(path)
			originals.append(source)
			chains.append(_expand_cut(source))
		if failed: return
	# Released input returns to the existing guard; queued input instead keeps
	# the cut's drawn endpoint and inherits it at the next wind-up's entry.
	for cut in chains.size():
		chains[cut][9]=guard.duplicate()
		if cut>0: chains[cut][0]=chains[cut-1][12].duplicate()
	# Draw two actual shaft-turn keys into jab preparation. The old chop
	# ends blade-forward; flipping to butt-forward in one cel looks like a
	# teleport. Keep each crisp glove fixed and turn only its rigid shaft.
	var entry_axis: Vector2 = chains[1][0].secondary_hands-chains[1][0].primary_hands
	var jab_axis: Vector2 = chains[1][3].secondary_hands-chains[1][3].primary_hands
	for key in [1,2]:
		var angle := lerp_angle(entry_axis.angle(),jab_axis.angle(),.4 if key==1 else .75)
		chains[1][key].secondary_hands=chains[1][key].primary_hands+Vector2.from_angle(angle)*7
	for cut in chains.size():
		_write_flow_clip(folder,FLOW_NAMES[cut],originals[cut],chains[cut],FLOW_NAMES.slice(1) if cut==0 else [])

func _source_slot(source: Resource,key: int) -> Dictionary:
	var rectangle := Rect2i(key%4*192,key/4*128,192,128)
	var slot := {"body":source.body_atlas.get_image().get_region(rectangle),"hand":source.hand_atlas.get_image().get_region(rectangle),"head":Rect2()}
	for property in SLOT_PROPERTIES: slot[property]=source.get(property)[key]
	if not source.identity_regions.is_empty(): slot.head=source.identity_regions[key]
	return slot

func _expand_cut(source: Resource) -> Array:
	var result: Array = []
	for phase in 3:
		var window: Vector2 = source.phase_windows[phase]
		var count := 4 if phase==0 else 3
		for index in count:
			var key := roundi(lerpf(window.x,window.y,float(index)/float(count-1)))
			result.append(_source_slot(source,key))
	# Recovery retains the actual contact/recoil drawing, avoiding a guard
	# flash between strikes. Timing remains in SwordComboDefinition.
	result.append(_source_slot(source,int(source.phase_windows[1].y)))
	result.append(_source_slot(source,int(source.phase_windows[2].x)))
	result.append(_source_slot(source,int(source.phase_windows[2].x)))
	return result

func _jab_slots(direction: String,row: Array,density: float,reference: Image,head: Rect2i) -> Array:
	var result: Array = []
	var forward := Vector2.RIGHT if direction=="side" else (Vector2.UP if direction=="up" else Vector2.DOWN)
	for key in 10:
		var source: Image = row[key].image
		var scaled: Image = source.duplicate()
		scaled.resize(maxi(1,roundi(source.get_width()*density)),maxi(1,roundi(source.get_height()*density)),Image.INTERPOLATE_NEAREST)
		var sole := foot_anchor(scaled)
		var offset := Vector2i(roundi(96-sole.x),roundi(94-sole.y))
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(scaled,Rect2i(Vector2i.ZERO,scaled.get_size()),offset)
		quantize(body)
		var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var placed := attach_back_head(body,reference,head,mask) if direction=="up" else _attach_axe_front_head(body,reference,head,mask)
		if failed: return []
		remove_specks(body)
		var shift := 94-roundi(foot_anchor(body).y)
		if shift!=0:
			var grounded := Image.create(192,128,false,Image.FORMAT_RGBA8)
			grounded.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,shift)); body=grounded
			var grounded_mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
			grounded_mask.blit_rect(mask,Rect2i(0,0,192,128),Vector2i(0,shift)); mask=grounded_mask
			placed.position.y+=shift; offset.y+=shift
		var contact := key>=4 and key<=6
		var guide := Vector2(.82,.54) if direction=="up" else Vector2(.63,.58)
		if direction=="side": guide=Vector2(.88,.44) if contact else Vector2(.57,.65)
		elif direction=="up" and contact: guide=Vector2(.89,.38)
		var expected := Vector2(offset)+guide*Vector2(scaled.get_size())
		var grip := find_glove(body,expected,placed,16)
		if grip==Vector2.ZERO: push_error("Missing jab glove "+direction+str(key)); failed=true; return []
		# The metal butt, rather than the blade's crown, leads this grounded jab.
		var glove_rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
		mask.blit_rect(body,glove_rect,glove_rect.position)
		result.append({"body":body,"hand":mask,"head":Rect2(placed),"primary_hands":grip,"secondary_hands":grip+forward*7,"lift_pixels":0.0,"weapon_behind_body":1 if direction=="up" else 0,"single_hand_poses":1,"stowed_poses":0,"released_poses":0,"ground_clipped_poses":0})
		flow_records.append({"direction":direction,"key":key,"head":var_to_str(placed),"grip":var_to_str(grip),"body_bounds":var_to_str(body.get_used_rect()),"sole":var_to_str(foot_anchor(body))})
	for key in [7,8,8]: result.append(result[key].duplicate())
	return result

func _write_flow_clip(folder: String,label: String,source: Resource,slots: Array,followups: Array) -> void:
	var body := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var clip := Definition.new()
	clip.weapon_texture=AXE; clip.weapon_primary_grip=Vector2(39,33); clip.weapon_handle_axis=Vector2(4,10)
	clip.pose_count=13; clip.pose_order=PackedInt32Array(range(13))
	clip.phase_windows=PackedVector2Array([Vector2(0,3),Vector2(4,6),Vector2(7,9)])
	clip.queued_recovery_window=Vector2(10,12)
	clip.pose_weights=PackedFloat32Array([.15,.6,.8,1,1,1,1,.7,.8,1,.65,.85,1])
	clip.mirror_cutting_edge=source.mirror_cutting_edge
	# Side axe steel reflects about the shaft. Keep its full rigid basis;
	# angle-only interpolation drops that reflection and turns the jab up.
	clip.interpolate_blade_angles=false
	for property in SLOT_PROPERTIES:
		var packed = clip.get(property)
		packed.resize(13)
		for key in 13: packed[key]=slots[key][property]
		clip.set(property,packed)
	var all_heads := true
	for key in 13:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		body.blit_rect(slots[key].body,Rect2i(0,0,192,128),origin)
		mask.blit_rect(slots[key].hand,Rect2i(0,0,192,128),origin)
		if slots[key].head.size==Vector2.ZERO: all_heads=false
	if all_heads:
		for slot in slots: clip.identity_regions.append(slot.head)
		clip.identity_source_region=source.identity_source_region
	clip.body_atlas=ImageTexture.create_from_image(body); clip.hand_atlas=ImageTexture.create_from_image(mask)
	if not clip.has_valid_layout(): push_error("Invalid flow clip "+folder+label); failed=true; return
	if body.save_png(folder+label+"_body.png")!=OK or mask.save_png(folder+label+"_hands.png")!=OK: failed=true; return
	var text := "[gd_resource type=\"Resource\" load_steps="+str(5+followups.size())+" format=3]\n"
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",AXE.resource_path]
	for index in paths.size(): text+="[ext_resource type=\""+("Script" if index==0 else "Texture2D")+"\" path=\""+paths[index]+"\" id=\""+str(index+1)+"\"]\n"
	for index in followups.size(): text+="[ext_resource type=\"Resource\" path=\""+folder+followups[index]+".tres\" id=\""+str(index+5)+"\"]\n"
	text+="[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in SLOT_PROPERTIES+["pose_count","pose_order","weapon_primary_grip","weapon_handle_axis","mirror_cutting_edge","phase_windows","queued_recovery_window","pose_weights","interpolate_blade_angles","identity_regions","identity_source_region"]: text+=property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		text+="follow_up_clips = Array[Resource](["
		for index in followups.size(): text+=("," if index else "")+"ExtResource(\""+str(index+5)+"\")"
		text+="])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(text)

func _build_flow_effects() -> void:
	var old: Image = load("res://assets/characters/playable/king/axe_proof_v3/swing.png").get_image()
	var swing := Image.create(512,512,false,Image.FORMAT_RGBA8)
	for pair in [[2,0],[3,2],[4,3]]: swing.blit_rect(old,Rect2i(0,pair[0]*128,512,128),Vector2i(0,pair[1]*128))
	var thrust: Image = load("res://assets/characters/playable/king/dual_twinsteel/swing.png").get_image()
	var cell := thrust.get_width()/4
	for key in 4:
		var source := thrust.get_region(Rect2i(key*cell,0,cell,cell))
		var bounds := source.get_used_rect()
		var pulse := source.get_region(bounds)
		pulse.resize(54,9,Image.INTERPOLATE_NEAREST)
		swing.blit_rect(pulse,Rect2i(0,0,54,9),Vector2i(key*128+62,128+60))
	if swing.save_png(FLOW_DEST+"swing.png")!=OK: failed=true
