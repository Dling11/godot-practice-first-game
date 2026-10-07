extends "res://tools/build_king_oathbound_greatsword.gd"

## Offline Twinsteel ingestion. Reuses complete-body extraction/registration,
## never the greatsword builder's output paths or single-blade motion data.
const Offhand = preload("res://data/weapons/offhand_pose_definition.gd")
const RAW := "res://art_source/generated/characters/king/dual_twinsteel_2026_10_05/"
const OUTPUT := "res://assets/characters/playable/king/dual_twinsteel/"
const CUTS := ["descending","rising","scissors","spin","cross_finish"]
const MAIN_ANGLES := [
	[-130,-150,-120,-80,-40,0,45,75,110,125],
	[125,100,65,35,10,-15,-40,-65,-95,-125],
	[-130,-145,-110,-65,-30,0,35,75,100,125],
	[125,85,35,-15,-65,-115,-165,-215,-260,-235],
	[125,100,60,-70,-55,-15,25,65,95,125]
]
const OFF_ANGLES := [
	[55,70,90,100,115,125,130,100,75,55],
	[55,85,120,155,125,75,15,-40,-90,-125],
	[55,100,145,190,145,90,35,-10,-55,-90],
	[-90,-135,-185,-235,-285,-335,-385,-435,-475,-485],
	[-125,-105,-75,-110,-125,-165,-205,-245,-285,-305]
]
const MAIN_GUIDES := [
	[Vector2(.15,.44),Vector2(.14,.23),Vector2(.22,.14),Vector2(.82,.64),Vector2(.20,.29),Vector2(.83,.60),Vector2(.22,.59),Vector2(.27,.59),Vector2(.17,.57),Vector2(.18,.40)],
	[Vector2(.18,.40),Vector2(.19,.60),Vector2(.21,.62),Vector2(.53,.76),Vector2(.29,.77),Vector2(.22,.70),Vector2(.25,.76),Vector2(.21,.70),Vector2(.27,.70),Vector2(.18,.40)],
	[Vector2(.18,.40),Vector2(.27,.50),Vector2(.38,.48),Vector2(.12,.40),Vector2(.14,.52),Vector2(.16,.16),Vector2(.42,.48),Vector2(.11,.46),Vector2(.13,.56),Vector2(.18,.40)],
	[Vector2(.18,.40),Vector2(.29,.58),Vector2(.23,.57),Vector2(.34,.57),Vector2(.28,.57),Vector2(.27,.59),Vector2(.25,.57),Vector2(.56,.59),Vector2(.28,.54),Vector2(.18,.40)],
	[Vector2(.24,.62),Vector2(.12,.52),Vector2(.35,.55),Vector2(.28,.59),Vector2(.24,.25),Vector2(.38,.47),Vector2(.17,.33),Vector2(.10,.57),Vector2(.14,.64),Vector2(.18,.40)]
]
const OFF_GUIDES := [
	[Vector2(.87,.56),Vector2(.89,.59),Vector2(.90,.56),Vector2(.27,.57),Vector2(.88,.68),Vector2(.31,.59),Vector2(.90,.63),Vector2(.92,.64),Vector2(.90,.72),Vector2(.89,.55)],
	[Vector2(.86,.57),Vector2(.92,.47),Vector2(.76,.24),Vector2(.17,.48),Vector2(.81,.13),Vector2(.83,.23),Vector2(.82,.12),Vector2(.83,.11),Vector2(.85,.23),Vector2(.89,.55)],
	[Vector2(.88,.57),Vector2(.67,.55),Vector2(.72,.50),Vector2(.61,.68),Vector2(.91,.34),Vector2(.89,.57),Vector2(.83,.30),Vector2(.93,.47),Vector2(.88,.63),Vector2(.89,.55)],
	[Vector2(.87,.57),Vector2(.77,.61),Vector2(.84,.58),Vector2(.63,.55),Vector2(.53,.53),Vector2(.71,.59),Vector2(.77,.57),Vector2(.28,.54),Vector2(.53,.51),Vector2(.89,.55)],
	[Vector2(.89,.54),Vector2(.84,.52),Vector2(.83,.40),Vector2(.77,.12),Vector2(.80,.27),Vector2(.60,.49),Vector2(.90,.36),Vector2(.94,.62),Vector2(.84,.42),Vector2(.89,.55)]
]
var blade: Texture2D
var identity: Image
var fixed_density := 1.0

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUTPUT))
	build_blade()
	var installed: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	identity = installed.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	for y in 128:
		for x in 192:
			var c := identity.get_pixel(x,y)
			if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	var rows := extract_bodies(Image.load_from_file(RAW+"body_source.png"))
	for row in rows:
		if row.size()!=10:
			push_error("Twinsteel source needs ten complete bodies per row; found "+str(row.size()))
			quit(1)
			return
	fixed_density = float(identity.get_used_rect().size.y)/float(rows[0][0].image.get_height())
	var run_rows := extract_bodies(Image.load_from_file(RAW+"run_source.png"),2)
	if run_rows[0].size()!=8 or run_rows[1].size()!=8:
		push_error("Twinsteel carry/run source is not eight plus eight complete bodies")
		quit(1)
		return
	var run_density: float = float(identity.get_used_rect().size.y)/float(run_rows[0][0].image.get_height())
	var idle := build_clip("idle",run_rows[0],-1,run_density)
	var run := build_clip("run",run_rows[1],-2,run_density)
	if failed:
		quit(1)
		return
	var clips: Array[Resource] = []
	for cut in 5: clips.append(build_clip(CUTS[cut],rows[cut],cut,fixed_density))
	if failed:
		quit(1)
		return
	for cut in 5:
		copy_dual_slot(clips[cut],0,idle if cut==0 else clips[cut-1],0 if cut==0 else 12)
		copy_dual_slot(clips[cut],9,idle,0)
		if cut==4: copy_dual_slot(clips[cut],12,idle,0)
		write_dual(CUTS[cut],clips[cut],CUTS.slice(1) if cut==0 else [])
	write_dual("idle",idle)
	write_dual("run",run)
	FileAccess.open(RAW+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("TWINSTEEL_BUILD: 50 attack +16 carry/run source cels; 65+16 registered slots, two independent grips")
	quit()

func build_blade() -> void:
	var source := Image.load_from_file(RAW+"blade_source.png")
	source.convert(Image.FORMAT_RGBA8)
	# Generated alpha fringe is discarded at the same ingestion threshold as
	# the approved body pipeline. No background is painted or synthesized.
	for y in source.get_height():
		for x in source.get_width():
			var c := source.get_pixel(x,y)
			if c.a<.65: source.set_pixel(x,y,Color.TRANSPARENT)
	var used := source.get_used_rect()
	var cropped := source.get_region(used)
	cropped.resize(22,82,Image.INTERPOLATE_NEAREST)
	cropped.save_png(OUTPUT+"twinsteel.png")
	blade = ImageTexture.create_from_image(cropped)
	blade.resource_path = OUTPUT+"twinsteel.png"
	audit.append({"blade_source_bounds":var_to_str(used),"blade_size":[22,82],"grip":[11,66],"tip":[11,0]})

func build_clip(label: String,components: Array,cut: int,density: float) -> Resource:
	var clip := Definition.new()
	clip.pose_count = 13 if cut>=0 else 8
	clip.pose_order.clear()
	clip.primary_hands.clear()
	clip.secondary_hands.clear()
	clip.weapon_primary_grip = Vector2(11,66)
	clip.weapon_tip = Vector2(11,0)
	clip.weapon_texture = blade
	clip.mirror_cutting_edge = false
	clip.allow_rest = false
	clip.phase_windows = PackedVector2Array([Vector2(0,3),Vector2(4,6),Vector2(7,9)]) if cut>=0 else PackedVector2Array([Vector2(0,3),Vector2(4,5),Vector2(6,7)])
	if cut>=0: clip.queued_recovery_window = Vector2(10,12)
	for property in ["lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]: clip.set(property,clip.get(property).slice(0,0))
	clip.offhand = Offhand.new()
	clip.offhand.texture = blade
	clip.offhand.grip = clip.weapon_primary_grip
	clip.offhand.tip = clip.weapon_tip
	var atlas := Image.create(768,128*ceili(clip.pose_count/4.0),false,Image.FORMAT_RGBA8)
	var mask := Image.create(atlas.get_width(),atlas.get_height(),false,Image.FORMAT_RGBA8)
	for key in clip.pose_count:
		var source_key := key if key<10 else mini(key-3,8)
		var component: Dictionary = components[source_key]
		var image: Image = component.image.duplicate()
		image.resize(maxi(1,roundi(image.get_width()*density)),maxi(1,roundi(image.get_height()*density)),Image.INTERPOLATE_NEAREST)
		var sole := foot_anchor(image)
		var offset := Vector2i(roundi(96-sole.x),roundi(94-sole.y))
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
		quantize(body)
		var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
		# Side strokes/gait retain the installed head; spin keeps its complete
		# generated turn cels, quantized to the exact installed King palette.
		var head := hair_bounds(body,red_center_y(body)-2)
		if cut!=3:
			head = attach_head(body,identity,Rect2i(87,41,25,24),"side",foreground,false)
		remove_specks(body)
		var guide_main: Vector2 = MAIN_GUIDES[cut][source_key] if cut>=0 else (Vector2(.13,.64) if cut==-1 else Vector2(.18,.56))
		var guide_off: Vector2 = OFF_GUIDES[cut][source_key] if cut>=0 else (Vector2(.88,.64) if cut==-1 else Vector2(.89,.68))
		var main := find_glove(body,Vector2(offset)+guide_main*Vector2(image.get_size()),head,18)
		var off := find_glove(body,Vector2(offset)+guide_off*Vector2(image.get_size()),head,18)
		if main==Vector2.ZERO or off==Vector2.ZERO or main.distance_to(off)<4:
			push_error("Two distinct drawn Twinsteel gloves missing: "+label+"/"+str(key)+" "+str(main)+" "+str(off))
			failed = true
			return clip
		# Relaxed carry/travel tips spread outside the stance and clear the
		# sole plane. Steep crossed blades previously extended into the floor.
		var main_angle: float = MAIN_ANGLES[cut][source_key] if cut>=0 else 166.0
		var off_angle: float = OFF_ANGLES[cut][source_key] if cut>=0 else 14.0
		clip.primary_hands.append(main)
		clip.secondary_hands.append(main-Vector2.from_angle(deg_to_rad(main_angle))*7)
		clip.offhand.hands.append(off)
		clip.offhand.axes.append(off-Vector2.from_angle(deg_to_rad(off_angle))*7)
		clip.offhand.behind_body.append(1 if cut==3 and source_key>=4 and source_key<=7 else 0)
		clip.offhand.visible_poses.append(1)
		clip.pose_order.append(key)
		clip.lift_pixels.append([0.0,0.0,-4.0,-8.0,-6.0,0.0][key] if cut==4 and key<6 else 0.0)
		clip.weapon_behind_body.append(1 if cut==3 and source_key>=3 and source_key<=6 else 0)
		clip.single_hand_poses.append(1)
		clip.stowed_poses.append(0)
		clip.released_poses.append(0)
		clip.ground_clipped_poses.append(0)
		clip.identity_regions.append(Rect2(head))
		clip.pose_weights.append(1.0)
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		for grip in [main,off]:
			var rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,rect,origin+rect.position)
		audit.append({"clip":label,"key":key,"source_key":source_key,"source_bounds":var_to_str(component.bounds),"density":density,"main_grip":var_to_str(main),"offhand_grip":var_to_str(off),"sole":var_to_str(foot_anchor(body)),"identity": "whole generated turn cel / installed palette" if cut==3 else "installed head on generated neck"})
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(mask)
	return clip

func copy_dual_slot(target: Resource,index: int,source: Resource,source_index: int) -> void:
	var body: Image = target.body_atlas.get_image()
	var hand: Image = target.hand_atlas.get_image()
	copy_slot(target,body,hand,index,source,source.body_atlas.get_image(),source.hand_atlas.get_image(),source_index,Rect2i(source.identity_regions[source_index]))
	for property in ["hands","axes","behind_body","visible_poses"]:
		var values = target.offhand.get(property)
		values[index] = source.offhand.get(property)[source_index]
		target.offhand.set(property,values)
	target.body_atlas = ImageTexture.create_from_image(body)
	target.hand_atlas = ImageTexture.create_from_image(hand)

func write_dual(label: String,clip: Resource,followups: Array = [],destination: String = OUTPUT,offhand_texture_path: String = "") -> void:
	assert(clip.has_valid_layout())
	clip.body_atlas.get_image().save_png(destination+label+"_body.png")
	clip.hand_atlas.get_image().save_png(destination+label+"_hands.png")
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",destination+label+"_body.png",destination+label+"_hands.png",OUTPUT+"twinsteel.png","res://data/weapons/offhand_pose_definition.gd"]
	var out := "[gd_resource type=\"Resource\" load_steps="+str(7+followups.size()+(0 if offhand_texture_path.is_empty() else 1))+" format=3]\n"
	for i in paths.size(): out += "[ext_resource type=\""+("Script" if i==0 or i==4 else "Texture2D")+"\" path=\""+paths[i]+"\" id=\""+str(i+1)+"\"]\n"
	if not offhand_texture_path.is_empty(): out += "[ext_resource type=\"Texture2D\" path=\""+offhand_texture_path+"\" id=\"blade_off\"]\n"
	for i in followups.size(): out += "[ext_resource type=\"Resource\" path=\""+destination+followups[i]+".tres\" id=\""+str(i+6)+"\"]\n"
	out += "[sub_resource type=\"Resource\" id=\"offhand\"]\nscript = ExtResource(\"5\")\ntexture = ExtResource(\""+("4" if offhand_texture_path.is_empty() else "blade_off")+"\")\n"
	for property in ["grip","tip","handle_axis","hands","axes","behind_body","visible_poses"]: out += property+" = "+var_to_str(clip.offhand.get(property))+"\n"
	out += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\noffhand = SubResource(\"offhand\")\n"
	for property in ["pose_count","pose_order","primary_hands","secondary_hands","weapon_primary_grip","weapon_tip","mirror_cutting_edge","phase_windows","queued_recovery_window","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","lift_pixels","pose_weights","identity_regions","allow_rest","interpolate_blade_angles"]: out += property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		out += "follow_up_clips = Array[Resource](["
		for i in followups.size(): out += ("," if i>0 else "")+"ExtResource(\""+str(i+6)+"\")"
		out += "])\n"
	FileAccess.open(destination+label+".tres",FileAccess.WRITE).store_string(out)
