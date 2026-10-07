extends "res://tools/build_king_axe_cardinal.gd"

## Fresh generated motion study. Old attack rasters are never input here.
const FRESH_SOURCE := "res://art_source/generated/characters/king/axe_vertical_redesign_2026_10_07/"
const FRESH_DEST := "res://assets/characters/playable/king/axe_vertical_v2/"
const FRESH_NAMES := ["chop","rise","thrust","slam","spin"]
const MOTION_KEYS := [0,1,2,2,3,3,4,4,5,5,6,7,7,5,6,6]
const TURN_KEYS := [0,0,1,1,2,3,4,5,6,7,7,7,7,7,7,7]
const SLAM_KEYS := [0,1,2,3,4,4,5,5,6,6,6,7,7,5,6,6]
const TURN_VIEWS := ["down","down","side","up","up","up","left","down"]
const SLOT_FIELDS := ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","primary_visible_poses","occluded_hand_poses"]
const SHAFT := Vector2(4,10)
const EDGE := Vector2(8,30)-Vector2(39,33)
var fresh_records: Array[Dictionary] = []
var references: Dictionary = {}

func _initialize() -> void:
	_setup_fresh_references()
	var down_rows := extract_bodies(Image.load_from_file(FRESH_SOURCE+"down_source.png"))
	var up_rows := extract_bodies(Image.load_from_file(FRESH_SOURCE+"up_source.png"))
	if not _check_fresh_rows(down_rows) or not _check_fresh_rows(up_rows): quit(1); return
	var rear_jump := extract_bodies(Image.load_from_file(FRESH_SOURCE+"up_jump_source.png"),2)
	if rear_jump[0].size()!=4 or rear_jump[1].size()!=4:
		push_error("Rear jump needs8 complete source cels in two rows"); quit(1); return
	up_rows[3] = rear_jump[0]+rear_jump[1]
	for view in ["down","up"]:
		_build_fresh_view(view,down_rows if view=="down" else up_rows,down_rows[4],54.0/down_rows[0][0].image.get_height())
		if failed: quit(1); return
	if "--body-only" not in OS.get_cmdline_user_args():
		for view in ["up","down"]: _build_fresh_effects(view)
	_write_fresh_profile("--body-only" not in OS.get_cmdline_user_args())
	FileAccess.open(FRESH_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(fresh_records,"\t")+"\n")
	print("AXE_VERTICAL_V2 fresh generated bodies and rear jump, real whole-body turn, native grips and camera-specific FX")
	quit(1 if failed else 0)

func _write_fresh_profile(with_effects: bool) -> void:
	var baseline := FileAccess.get_file_as_string(FRESH_SOURCE+"presentation_baseline.tres")
	for view in ["up","down"]: baseline = baseline.replace("res://assets/characters/playable/king/axe_flow/"+view+"/chop.tres",FRESH_DEST+view+"/chop.tres")
	if with_effects:
		baseline = baseline.replace("load_steps=12","load_steps=13").replace("[resource]","[ext_resource type=\"PackedScene\" path=\"res://gameplay/presentation/axe_vertical_v2_swing.tscn\" id=\"12\"]\n[resource]")
		baseline += "swing_scene = ExtResource(\"12\")\n"
	FileAccess.open(FRESH_DEST+"presentation.tres",FileAccess.WRITE).store_string(baseline)

func _check_fresh_rows(rows: Array) -> bool:
	for row in rows:
		if row.size()!=8: push_error("Fresh axe source needs8 complete cels; got"+str(row.size())); return false
	return true

func _setup_fresh_references() -> void:
	for view in ["up","down"]:
		var clip: Resource = load("res://assets/characters/playable/king/dual_v2/"+view+"/idle.tres")
		references[view] = {"image":clip.body_atlas.get_image().get_region(Rect2i(0,0,192,128)),"head":Rect2i(clip.identity_regions[0])}
	var side: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	var side_image: Image = side.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	references.side = {"image":side_image,"head":Rect2i(87,41,25,24)}
	var left: Image = side_image.duplicate()
	left.flip_x()
	references.left = {"image":left,"head":Rect2i(80,41,25,24)}
	for reference in references.values():
		var image: Image = reference.image
		for y in 128:
			for x in 192:
				var color := image.get_pixel(x,y)
				if color.a>.65 and not palette.has(Color(color.r,color.g,color.b,1)): palette.append(Color(color.r,color.g,color.b,1))

func _scale_source(source: Image,density: float) -> Image:
	var size := Vector2i(maxi(1,roundi(source.get_width()*density)),maxi(1,roundi(source.get_height()*density)))
	var part: Image = source.duplicate()
	part.resize(size.x,size.y,Image.INTERPOLATE_NEAREST)
	for y in source.get_height():
		for x in source.get_width():
			var point := Vector2i(Vector2(x,y)*density).min(size-Vector2i.ONE)
			if source.get_pixel(x,y).a>.65 and part.get_pixelv(point).a<.65: part.set_pixelv(point,source.get_pixel(x,y))
	return part

func _build_fresh_view(view: String,rows: Array,spin: Array,spin_density: float) -> void:
	var density: float = 54.0/rows[0][0].image.get_height()
	var chains: Array[Array] = []
	for cut in 5:
		var slots: Array = []
		for key in 16:
			var source_key: int = MOTION_KEYS[key]
			if cut==3: source_key = SLAM_KEYS[key]
			var head_view := view
			var component: Dictionary = rows[cut][source_key]
			var scale := density
			if view=="up" and cut==3: scale=54.0/rows[3][0].image.get_height()
			if cut==4:
				source_key = (TURN_KEYS[key]+(4 if view=="up" else 0))%8
				head_view = TURN_VIEWS[source_key]
				component = spin[source_key]
				scale = spin_density
			slots.append(_fresh_slot(view,head_view,cut,key,source_key,component,scale))
			if failed: return
		chains.append(slots)
	var ready: Resource = load("res://assets/characters/playable/king/axe_flow/"+view+"/idle.tres")
	for cut in 5:
		chains[cut][0] = _ready_slot(ready) if cut==0 else chains[cut-1][15].duplicate()
		chains[cut][12] = _ready_slot(ready)
		if cut==4: chains[cut][15] = _ready_slot(ready)
	for cut in 5: _write_fresh_clip(view,FRESH_NAMES[cut],chains[cut],FRESH_NAMES.slice(1) if cut==0 else [])

func _fresh_slot(view: String,head_view: String,cut: int,key: int,source_key: int,component: Dictionary,density: float) -> Dictionary:
	var part := _scale_source(component.image,density)
	var foot := foot_anchor(part)
	var offset := Vector2i(Vector2(96-foot.x,94-foot.y).round())
	var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
	body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
	quantize(body)
	var original: Image = body.duplicate()
	var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
	var reference: Dictionary = references[head_view]
	var head: Rect2i = attach_back_head(body,reference.image,reference.head,mask) if head_view=="up" else (_attach_axe_front_head(body,reference.image,reference.head,mask) if head_view=="down" else attach_head(body,reference.image,reference.head,head_view,mask))
	if failed: return {}
	remove_specks(body)
	var sole_shift := 94-roundi(foot_anchor(body).y)
	if sole_shift!=0:
		var grounded := Image.create(192,128,false,Image.FORMAT_RGBA8)
		grounded.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,sole_shift))
		body = grounded
		var grounded_original := Image.create(192,128,false,Image.FORMAT_RGBA8)
		grounded_original.blit_rect(original,Rect2i(0,0,192,128),Vector2i(0,sole_shift))
		original = grounded_original
		var grounded_mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
		grounded_mask.blit_rect(mask,Rect2i(0,0,192,128),Vector2i(0,sole_shift))
		mask = grounded_mask
		head.position.y += sole_shift
	var guide: Vector2 = _fresh_grip_guide(view,cut,source_key)
	var expected := Vector2(offset)+guide*Vector2(part.get_size())+Vector2(0,sole_shift)
	var grip := find_glove(body,expected,head,10)
	if grip==Vector2.ZERO: grip = find_glove(body,expected,head,18)
	if grip==Vector2.ZERO:
		body.save_png(FRESH_SOURCE+"grip_failure.png")
		push_error("Fresh axe missing actual glove "+view+"/"+str(cut)+"/"+str(key)); failed=true; return {}
	var restored := _restore_fresh_forearm(body,original,head,grip)
	var edge_angle := _fresh_edge_angle(view,cut,source_key)
	var handle_axis := SHAFT.normalized().rotated(deg_to_rad(edge_angle)-EDGE.angle())
	var lift := 0.0
	if cut==3: lift = [0.0,0.0,-9.0,-13.0,0.0,0.0,0.0,0.0][source_key]
	if cut==4: lift = -5.0 if key in [3,4,5,6,7,8] else 0.0
	var glove_rect := Rect2i(Vector2i(grip.round())-Vector2i(3,3),Vector2i(7,7))
	mask.blit_rect(body,glove_rect,glove_rect.position)
	fresh_records.append({"view":view,"cut":FRESH_NAMES[cut],"key":key,"source_key":source_key,"head_view":head_view,"source_bounds":var_to_str(component.bounds),"density":density,"head":var_to_str(head),"grip":var_to_str(grip),"edge_angle":edge_angle,"lift":lift,"restored_forearm_pixels":restored})
	return {"body":body,"hand":mask,"head":Rect2(head),"primary_hands":grip,"secondary_hands":grip+handle_axis*7,"lift_pixels":lift,"weapon_behind_body":1 if head_view=="up" else 0,"single_hand_poses":1,"stowed_poses":0,"released_poses":0,"ground_clipped_poses":0,"primary_visible_poses":1,"occluded_hand_poses":0}

func _restore_fresh_forearm(body: Image,original: Image,head: Rect2i,grip: Vector2) -> int:
	# The rectangular head erase can intersect a raised sleeve. Recover only
	# source coverage beside the native face; never draw or stretch a new arm.
	var restored := 0
	var shoulder := Vector2(head.get_center().x+signf(grip.x-head.get_center().x)*7,head.end.y+5)
	for y in range(maxi(0,mini(roundi(grip.y),roundi(shoulder.y))-6),mini(128,maxi(roundi(grip.y),roundi(shoulder.y))+7)):
		for x in range(maxi(0,mini(roundi(grip.x),roundi(shoulder.x))-6),mini(192,maxi(roundi(grip.x),roundi(shoulder.x))+7)):
			var point := Vector2(x,y)
			if point.distance_to(Geometry2D.get_closest_point_to_segment(point,grip,shoulder))>6: continue
			if y<head.position.y+head.size.y*.55 and absf(x-head.get_center().x)<head.size.x*.4: continue
			var color := original.get_pixel(x,y)
			if body.get_pixel(x,y).a<.65 and color.a>.65 and not is_crimson(color):
				body.set_pixel(x,y,color)
				restored += 1
	return restored

func _fresh_grip_guide(view: String,cut: int,key: int) -> Vector2:
	var down := [
		[Vector2(.15,.68),Vector2(.18,.13),Vector2(.2,.1),Vector2(.56,.78),Vector2(.5,.79),Vector2(.78,.80),Vector2(.34,.53),Vector2(.15,.65)],
		[Vector2(.38,.55),Vector2(.48,.55),Vector2(.92,.20),Vector2(.79,.41),Vector2(.88,.10),Vector2(.78,.29),Vector2(.31,.61),Vector2(.15,.65)],
		[Vector2(.15,.66),Vector2(.2,.50),Vector2(.3,.5),Vector2(.16,.36),Vector2(.34,.79),Vector2(.2,.59),Vector2(.12,.56),Vector2(.15,.66)],
		[Vector2(.18,.67),Vector2(.23,.14),Vector2(.18,.10),Vector2(.23,.12),Vector2(.54,.74),Vector2(.49,.80),Vector2(.25,.58),Vector2(.15,.67)],
		[Vector2(.15,.62),Vector2(.23,.56),Vector2(.70,.57),Vector2(.25,.50),Vector2(.15,.56),Vector2(.13,.58),Vector2(.29,.57),Vector2(.15,.65)]
	]
	var up := [
		[Vector2(.18,.64),Vector2(.75,.12),Vector2(.43,.10),Vector2(.26,.12),Vector2(.62,.75),Vector2(.81,.64),Vector2(.22,.50),Vector2(.20,.65)],
		[Vector2(.20,.65),Vector2(.75,.56),Vector2(.85,.40),Vector2(.22,.22),Vector2(.82,.10),Vector2(.89,.12),Vector2(.17,.63),Vector2(.20,.65)],
		[Vector2(.20,.64),Vector2(.84,.58),Vector2(.85,.41),Vector2(.87,.28),Vector2(.18,.49),Vector2(.16,.58),Vector2(.13,.57),Vector2(.20,.65)],
		[Vector2(.20,.64),Vector2(.38,.10),Vector2(.30,.10),Vector2(.53,.06),Vector2(.58,.08),Vector2(.75,.12),Vector2(.79,.24),Vector2(.20,.65)]
	]
	return down[cut][key] if view=="down" or cut==4 else up[cut][key]

func _fresh_edge_angle(view: String,cut: int,key: int) -> float:
	var forward := -90.0 if view=="up" else 90.0
	if cut==2: return forward
	if cut==4: return [90.0,45.0,0.0,-45.0,-90.0,-135.0,-180.0,-270.0][key]
	var angles := [[-65.0,-120.0,-150.0,-35.0,0.0,35.0,60.0,40.0],[35.0,40.0,15.0,-10.0,-50.0,-75.0,-95.0,-80.0],[],[-70.0,-100.0,-140.0,-120.0,0.0,15.0,25.0,40.0]]
	return forward+angles[cut][key]

func _ready_slot(clip: Resource) -> Dictionary:
	var slot := {"body":clip.body_atlas.get_image().get_region(Rect2i(0,0,192,128)),"hand":clip.hand_atlas.get_image().get_region(Rect2i(0,0,192,128)),"head":clip.identity_regions[0]}
	for property in SLOT_FIELDS:
		var array = clip.get(property)
		slot[property] = array[0] if array.size()>0 else (1 if property=="primary_visible_poses" else 0)
	return slot

func _write_fresh_clip(view: String,label: String,slots: Array,followups: Array) -> void:
	var folder := FRESH_DEST+view+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var clip := Definition.new()
	clip.weapon_texture=AXE; clip.weapon_primary_grip=Vector2(39,33); clip.weapon_handle_axis=SHAFT
	clip.pose_count=16; clip.pose_order=PackedInt32Array(range(16)); clip.allow_rest=false
	clip.phase_windows=PackedVector2Array([Vector2(0,3),Vector2(4,9),Vector2(10,12)])
	clip.queued_recovery_window=Vector2(13,15)
	clip.pose_weights=PackedFloat32Array([.25,.7,1,1,1,1,1,1,1,1,1,1,1,.7,1,1])
	clip.mirror_cutting_edge=false
	var body := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
	for property in SLOT_FIELDS:
		var array = clip.get(property)
		array.resize(16)
		for key in 16: array[key]=slots[key][property]
		clip.set(property,array)
	for key in 16:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		body.blit_rect(slots[key].body,Rect2i(0,0,192,128),origin)
		mask.blit_rect(slots[key].hand,Rect2i(0,0,192,128),origin)
		clip.identity_regions.append(slots[key].head)
	clip.identity_source_region=clip.identity_regions[0]
	clip.body_atlas=ImageTexture.create_from_image(body); clip.hand_atlas=ImageTexture.create_from_image(mask)
	if not clip.has_valid_layout(): push_error("Fresh axe clip invalid "+view+" "+label); failed=true; return
	body.save_png(folder+label+"_body.png"); mask.save_png(folder+label+"_hands.png")
	var text := "[gd_resource type=\"Resource\" load_steps="+str(5+followups.size())+" format=3]\n"
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",AXE.resource_path]
	for index in paths.size(): text+="[ext_resource type=\""+("Script" if index==0 else "Texture2D")+"\" path=\""+paths[index]+"\" id=\""+str(index+1)+"\"]\n"
	for index in followups.size(): text+="[ext_resource type=\"Resource\" path=\""+folder+followups[index]+".tres\" id=\""+str(index+5)+"\"]\n"
	text+="[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in SLOT_FIELDS+["pose_count","pose_order","weapon_primary_grip","weapon_handle_axis","mirror_cutting_edge","phase_windows","queued_recovery_window","pose_weights","identity_regions","identity_source_region","allow_rest"]: text+=property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		text+="follow_up_clips = Array[Resource](["
		for index in followups.size(): text+=("," if index else "")+"ExtResource(\""+str(index+5)+"\")"
		text+="])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(text)
	for suffix in ["_body.png.import","_hands.png.import"]: _fresh_import(folder+label+suffix)

func _fresh_import(path: String) -> void:
	if FileAccess.file_exists(path):
		var settings := FileAccess.get_file_as_string(path).replace("process/fix_alpha_border=true","process/fix_alpha_border=false")
		FileAccess.open(path,FileAccess.WRITE).store_string(settings)

func _build_fresh_effects(view: String) -> void:
	var sheet := Image.load_from_file(FRESH_SOURCE+view+"_effects_source.png")
	if sheet==null: push_error("Missing fresh axe effect sheet "+view); failed=true; return
	for y in sheet.get_height():
		for x in sheet.get_width():
			var c := sheet.get_pixel(x,y)
			var gray := (c.r+c.g+c.b)/3
			sheet.set_pixel(x,y,Color(gray,gray,gray,c.a) if c.a>.65 else Color.TRANSPARENT)
	var row_cuts := PackedInt32Array([0])
	for boundary in range(1,5): row_cuts.append(_fresh_effect_gutter(sheet,false,roundi(boundary*sheet.get_height()/5.0),Rect2i(Vector2i.ZERO,sheet.get_size())))
	row_cuts.append(sheet.get_height())
	var atlas := Image.create(768,960,false,Image.FORMAT_RGBA8)
	for row in 5:
		var frames: Array[Image] = []
		var common := Rect2i()
		var band := Rect2i(0,row_cuts[row],sheet.get_width(),row_cuts[row+1]-row_cuts[row])
		var column_cuts := PackedInt32Array([0])
		for boundary in range(1,4): column_cuts.append(_fresh_effect_gutter(sheet,true,roundi(boundary*sheet.get_width()/4.0),band))
		column_cuts.append(sheet.get_width())
		for frame in 4:
			var rectangle := Rect2i(column_cuts[frame],band.position.y,column_cuts[frame+1]-column_cuts[frame],band.size.y)
			var cel := Image.create(512,band.size.y,false,Image.FORMAT_RGBA8)
			# Unequal real gutters own each complete drawing; keep the authored
			# column anchor on one common canvas before shared-density fitting.
			var anchor := roundi((frame+.5)*sheet.get_width()/4.0)
			cel.blit_rect(sheet,rectangle,Vector2i(256+rectangle.position.x-anchor,0))
			frames.append(cel)
			common=cel.get_used_rect() if frame==0 else common.merge(cel.get_used_rect())
		var maximum := Vector2(164,70) if row!=4 else Vector2(164,86)
		var ratio := minf(maximum.x/common.size.x,maximum.y/common.size.y)
		var target := Vector2i(Vector2(common.size)*ratio)
		for frame in 4:
			var cel := frames[frame].get_region(common)
			cel.resize(target.x,target.y,Image.INTERPOLATE_NEAREST)
			var center_y := 96 if row==4 else (62 if view=="up" else 128)
			atlas.blit_rect(cel,Rect2i(Vector2i.ZERO,target),Vector2i(frame*192+96-target.x/2,row*192+center_y-target.y/2))
		fresh_records.append({"view":view,"effect_row":row,"source_union":var_to_str(common),"row_cuts":var_to_str(row_cuts),"column_cuts":var_to_str(column_cuts),"size":var_to_str(target),"new_generated_frames":4,"camera_plane":true})
	atlas.save_png(FRESH_DEST+view+"/swing.png")
	_fresh_import(FRESH_DEST+view+"/swing.png.import")

func _fresh_effect_gutter(sheet: Image,vertical: bool,nominal: int,band: Rect2i) -> int:
	var best := nominal
	var best_score := INF
	var radius := 85 if vertical else 42
	for candidate in range(nominal-radius,nominal+radius+1):
		var occupied := 0
		for across in range(candidate-1,candidate+2):
			for along in range(band.position.y,band.end.y) if vertical else range(band.position.x,band.end.x):
				if sheet.get_pixel(across,along).a>.65 if vertical else sheet.get_pixel(along,across).a>.65: occupied+=1
		var score := occupied*1000.0+absi(candidate-nominal)
		if score<best_score: best_score=score; best=candidate
	return best
