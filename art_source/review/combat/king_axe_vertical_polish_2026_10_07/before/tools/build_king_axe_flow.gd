extends "res://tools/build_king_axe_cardinal.gd"

## Offline raster assembly. Reuses accepted axe cuts and leaves their
## original atlases, all carry/gait clips, and the other families untouched.
const FLOW_SOURCE := "res://art_source/generated/characters/king/axe_head_thrust_2026_10_06/"
const FLOW_DEST := "res://assets/characters/playable/king/axe_flow/"
const FLOW_NAMES := ["chop","rise","thrust","slam","spin"]
const CUTTING_EDGE := Vector2(8,30)
const SLOT_PROPERTIES := ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]
var flow_records: Array[Dictionary] = []

func _initialize() -> void:
	for index in 3:
		_build_flow(["side","down","up"][index])
		if failed: quit(1); return
	_build_flow_effects()
	FileAccess.open(FLOW_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"new_body_source_cels":0,"runtime_cels":195,"names":FLOW_NAMES,"records":flow_records,"complete_raster_rows":[0,1,2,3,4],"cutting_edge":var_to_str(CUTTING_EDGE)},"\t")+"\n")
	print("AXE_HEAD_THRUST five connected cuts x13 keys x3 authored views; cutting edge leads third hit")
	quit(1 if failed else 0)

func _build_flow(direction: String) -> void:
	var folder := FLOW_DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var idle: Resource = load("res://assets/characters/playable/king/"+("axe_proof_v3/carry.tres" if direction=="side" else "axe_cardinal/"+direction+"/idle.tres"))
	var guard := _source_slot(idle,0)
	var chains: Array[Array] = []
	var originals: Array[Resource] = []
	for name in FLOW_NAMES:
		if name=="thrust":
			var push := Definition.new()
			push.mirror_cutting_edge=direction=="side"
			var metadata: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(FLOW_SOURCE+direction+"/body_registration.json"))
			var head_region: Array = metadata.identity_source_region
			push.identity_source_region=Rect2(head_region[0],head_region[1],head_region[2],head_region[3])
			originals.append(push)
			chains.append(_head_thrust_slots(direction,metadata,push.mirror_cutting_edge))
			if failed: return
			continue
		var path: String = "res://assets/characters/playable/king/axe_cardinal/"+direction+"/"+name+".tres"
		if direction=="side":
			path={"chop":"res://assets/characters/playable/king/axe_proof_v3/down.tres","rise":"res://assets/characters/playable/king/axe_proof/return.tres","slam":"res://assets/characters/playable/king/axe_proof/finisher.tres","spin":"res://assets/characters/playable/king/axe_proof_v3/spin.tres"}[name]
		var source: Resource = load(path)
		originals.append(source)
		chains.append(_expand_cut(source))
		flow_records.append({"direction":direction,"cut":name,"source":path,"native_pixels_reused":true})
		if failed: return
	# Released input returns to the existing guard; queued input instead keeps
	# the cut's drawn endpoint and inherits it at the next wind-up's entry.
	for cut in chains.size():
		chains[cut][9]=guard.duplicate()
		if cut>0: chains[cut][0]=chains[cut-1][12].duplicate()
	# Keep the real inherited opening, then turn the rigid axe through two
	# drawn wind-up keys. The cutting edge, not the crown or butt, leads.
	var opening_axis: Vector2 = chains[2][0].secondary_hands-chains[2][0].primary_hands
	var push_axis: Vector2 = chains[2][3].secondary_hands-chains[2][3].primary_hands
	for key in [1,2]:
		var angle := lerp_angle(opening_axis.angle(),push_axis.angle(),.45 if key==1 else .8)
		chains[2][key].secondary_hands=chains[2][key].primary_hands+Vector2.from_angle(angle)*7
	for cut in chains.size():
		_write_flow_clip(folder,FLOW_NAMES[cut],originals[cut],chains[cut],FLOW_NAMES.slice(1) if cut==0 else [])

func _head_thrust_slots(direction: String,metadata: Dictionary,mirrored_edge: bool) -> Array:
	var body := Image.load_from_file(FLOW_SOURCE+direction+"/push_body.png")
	var hands := Image.load_from_file(FLOW_SOURCE+direction+"/push_hands.png")
	var forward := Vector2.RIGHT if direction=="side" else (Vector2.UP if direction=="up" else Vector2.DOWN)
	var shaft := Vector2(4,10).normalized()
	var edge := CUTTING_EDGE-Vector2(39,33)
	if mirrored_edge: edge=shaft*2*shaft.dot(edge)-edge
	var angle := forward.angle()-edge.angle()
	var handle_axis := shaft.rotated(angle)
	var result: Array = []
	for key in 13:
		var rectangle := Rect2i(key%4*192,key/4*128,192,128)
		var grip_data: Array = metadata.primary_hands[key]
		var grip := Vector2(grip_data[0],grip_data[1])
		var head := Rect2()
		if metadata.identity_regions.size()==13:
			var head_data: Array = metadata.identity_regions[key]
			head=Rect2(head_data[0],head_data[1],head_data[2],head_data[3])
		var slot := {"body":body.get_region(rectangle),"hand":hands.get_region(rectangle),"head":head,"primary_hands":grip,"secondary_hands":grip+handle_axis*7,"lift_pixels":0.0,"weapon_behind_body":1 if direction=="up" else 0,"single_hand_poses":1,"stowed_poses":0,"released_poses":0,"ground_clipped_poses":0}
		result.append(slot)
	flow_records.append({"direction":direction,"cut":"thrust","source":FLOW_SOURCE+direction+"/push_body.png","native_body_pixels_reused":true,"cutting_edge_forward":true,"shaft_axis":var_to_str(handle_axis),"single_hand_axis_is_orientation_only":true})
	return result

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
	# angle-only interpolation drops reflection and changes cutting direction.
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
	var swing := Image.create(512,640,false,Image.FORMAT_RGBA8)
	for pair in [[2,0],[1,1],[3,3],[4,4]]: swing.blit_rect(old,Rect2i(0,pair[0]*128,512,128),Vector2i(0,pair[1]*128))
	var thrust := Image.load_from_file(FLOW_SOURCE+"thrust_source.png")
	if thrust==null: push_error("Missing generated axe-head thrust raster"); failed=true; return
	# Ignore nearly transparent generation noise before detecting real gutters.
	# The generated third tip crosses the nominal equal-column boundary.
	var columns := PackedInt32Array()
	columns.resize(thrust.get_width())
	for y in thrust.get_height():
		for x in thrust.get_width():
			var pixel := thrust.get_pixel(x,y)
			if pixel.a<16.0/255.0: thrust.set_pixel(x,y,Color(0,0,0,0))
			else:
				pixel.a=1
				thrust.set_pixel(x,y,pixel)
				columns[x]+=1
	var cuts := PackedInt32Array([0])
	for boundary in range(1,4):
		var nominal := boundary*thrust.get_width()/4
		var found := -1
		for distance in 128:
			for candidate in [nominal+distance,nominal-distance]:
				if candidate<6 or candidate+6>=columns.size(): continue
				var empty := true
				for offset in range(-5,6):
					if columns[candidate+offset]>0: empty=false; break
				if empty: found=candidate; break
			if found>=0: break
		if found<0: push_error("Thrust source has no safe frame gutter"); failed=true; return
		cuts.append(found)
	cuts.append(thrust.get_width())
	var common := Rect2i()
	var frames: Array[Image] = []
	var tips: Array[Dictionary] = []
	for key in 4:
		var source_rectangle := Rect2i(cuts[key],0,cuts[key+1]-cuts[key],thrust.get_height())
		var cel := thrust.get_region(source_rectangle)
		var ink := cel.get_used_rect()
		var tip_x := ink.end.x-1
		var tip_y := 0.0
		var tip_pixels := 0
		for y in cel.get_height():
			for x in range(tip_x-1,tip_x+1):
				if cel.get_pixel(x,y).a>.5: tip_y+=y; tip_pixels+=1
		if tip_pixels==0: push_error("Missing white thrust tip"); failed=true; return
		tip_y/=tip_pixels
		var offset := Vector2i(720-tip_x,512-roundi(tip_y))
		var registered := Image.create(1024,1024,false,Image.FORMAT_RGBA8)
		registered.blit_rect(cel,Rect2i(Vector2i.ZERO,cel.get_size()),offset)
		frames.append(registered)
		common=registered.get_used_rect() if key==0 else common.merge(registered.get_used_rect())
		tips.append({"key":key,"source_rectangle":var_to_str(source_rectangle),"tip":var_to_str(Vector2(tip_x,tip_y)),"registered_tip":[720,512]})
	# One union crop and scale across all four cels keeps origin and density
	# stable while preserving every painted chip and transparent outer margin.
	var ratio := minf(104.0/common.size.x,96.0/common.size.y)
	var target := Vector2i(maxi(1,roundi(common.size.x*ratio)),maxi(1,roundi(common.size.y*ratio)))
	for key in 4:
		var cel := frames[key].get_region(common)
		cel.resize(target.x,target.y,Image.INTERPOLATE_NEAREST)
		swing.blit_rect(cel,Rect2i(Vector2i.ZERO,target),Vector2i(key*128+12,256+64-target.y/2))
	flow_records.append({"cut":"thrust_fx","source_union":var_to_str(common),"common_size":var_to_str(target),"cell":[128,128],"shared_registration":true,"new_raster_cels":4,"safe_gutters":var_to_str(cuts),"tip_registration":tips})
	if swing.save_png(FLOW_DEST+"swing.png")!=OK: failed=true
