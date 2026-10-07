extends "res://tools/build_king_oathbound_greatsword.gd"

## Build the opt-in Greatsword V2; accepted V1 art/data and locomotion stay intact.
const FRONT_SOURCE := "res://art_source/generated/characters/king/greatsword_front_combo_2026_10_06/"
const TWO_HAND_SOURCE := "res://art_source/generated/characters/king/greatsword_two_hand_2026_10_07/"
const LANDING_SOURCE := "res://art_source/generated/characters/king/greatsword_v2_landing_2026_10_07/"
const POLISH_SOURCE := "res://art_source/generated/characters/king/greatsword_v2_polish_2026_10_07/"
const REAR_SOURCE := "res://art_source/generated/characters/king/greatsword_v2_rear_cleanup_2026_10_07/"
const FRONT_DEST := "res://assets/characters/playable/king/greatsword_front_combo_preview/"
const FRONT_NAMES := ["front","return","spin","jump"]
const FRONT_GUIDES := [
	[Vector2(.2,.62),Vector2(.24,.38),Vector2(.85,.12),Vector2(.90,.42),Vector2(.91,.45),Vector2(.91,.76),Vector2(.20,.55),Vector2(.2,.5)],
	[Vector2(.9,.8),Vector2(.79,.55),Vector2(.9,.76),Vector2(.9,.43),Vector2(.9,.14),Vector2(.9,.12),Vector2(.9,.32),Vector2(.18,.35)],
	[Vector2(.2,.4),Vector2(.9,.50),Vector2(.85,.53),Vector2(.15,.63),Vector2(.1,.5),Vector2(.14,.63),Vector2(.91,.46),Vector2(.19,.4)],
	[Vector2(.25,.33),Vector2(.18,.69),Vector2(.18,.25),Vector2(.2,.18),Vector2(.9,.59),Vector2(.91,.77),Vector2(.18,.68),Vector2(.15,.63)]
]
const TWO_HAND_GUIDES := [
	[Vector2(.56,.66),Vector2(.43,.38),Vector2(.74,.12),Vector2(.65,.13),Vector2(.79,.58),Vector2(.78,.54),Vector2(.80,.60),Vector2(.83,.58),Vector2(.84,.78),Vector2(.85,.77),Vector2(.90,.76),Vector2(.90,.75)],
	[Vector2(.82,.76),Vector2(.80,.78),Vector2(.81,.79),Vector2(.83,.72),Vector2(.88,.56),Vector2(.88,.31),Vector2(.85,.35),Vector2(.86,.24),Vector2(.23,.20),Vector2(.59,.48),Vector2(.75,.13),Vector2(.73,.54)],
	[],
	[Vector2(.72,.62),Vector2(.72,.62),Vector2(.40,.12),Vector2(.32,.11),Vector2(.54,.13),Vector2(.84,.55),Vector2(.88,.59),Vector2(.84,.75),Vector2(.78,.79),Vector2(.84,.85),Vector2(.78,.67),Vector2(.60,.55)]
]
const FRONT_ACTIVE_ANGLES := [
	[-60,-36,-12,12,36,60],
	[60,36,12,-12,-36,-60],
	[30,102,174,246,318,390],
	[-85,-50,-10,30,60,70]
]
const FRONT_LOAD_ANGLES := [
	[-145,-105,-75,-60],
	[60,70,65,60],
	[-60,-15,0,30],
	[30,-100,-100,-90]
]
var views: Array[PackedStringArray] = []
const TWO_HAND_CONTACT_GUIDES := [
	[Vector2(.32,.14),Vector2(.79,.28),Vector2(.85,.44),Vector2(.85,.43),Vector2(.85,.64),Vector2(.85,.74)],
	[Vector2(.73,.78),Vector2(.85,.40),Vector2(.83,.48),Vector2(.84,.39),Vector2(.84,.33),Vector2(.72,.14)],
	[Vector2(.31,.13),Vector2(.40,.12),Vector2(.84,.45),Vector2(.84,.48),Vector2(.81,.71),Vector2(.84,.74)]
]
const JUMP_GUIDES := [Vector2(.46,.10),Vector2(.22,.22),Vector2(.53,.12),Vector2(.75,.13),Vector2(.76,.66),Vector2(.79,.64),Vector2(.75,.60),Vector2(.74,.57)]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(FRONT_DEST))
	var rows := extract_two_hand_rows(Image.load_from_file(TWO_HAND_SOURCE+"body_source.png"))
	for row in rows:
		if row.size()!=12:
			push_error("Expected four rows of twelve two-hand bodies, found "+str(row.size()))
			quit(1)
			return
	# One natural one-hand flourish is allowed; keep the authored full-body spin.
	var spin_rows := extract_bodies(Image.load_from_file(FRONT_SOURCE+"body_source.png"),4)
	rows[2] = spin_rows[2]
	var contact_sheet := Image.load_from_file(TWO_HAND_SOURCE+"contact_source.png")
	for y in contact_sheet.get_height():
		for x in contact_sheet.get_width():
			var c := contact_sheet.get_pixel(x,y)
			if c.a<.65 or (c.r>.45 and c.b>.3 and c.g<c.r*.5): contact_sheet.set_pixel(x,y,Color.TRANSPARENT)
	var contact_rows := extract_bodies(contact_sheet,3)
	for row in contact_rows:
		if row.size()!=6:
			push_error("Expected six paired-hand contacts per row, found "+str(row.size()))
			quit(1)
			return
	var jump_sheet := clean_handle_guide(Image.load_from_file(POLISH_SOURCE+"jump_source.png"))
	var jump_rows := extract_bodies(jump_sheet,2)
	if jump_rows[0].size()!=4 or jump_rows[1].size()!=4:
		push_error("Expected eight complete jump/landing bodies")
		quit(1)
		return
	var jump_bodies: Array = jump_rows[0]+jump_rows[1]
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var carry_hand: Image = idle.hand_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var head := Rect2i(87,41,25,24)
	var density: float = float(carry.get_used_rect().size.y)/rows[0][0].image.get_height()
	var contact_density: float = float(carry.get_used_rect().size.y)/contact_rows[0][2].image.get_height()
	var spin_density: float = float(carry.get_used_rect().size.y)/spin_rows[0][0].image.get_height()
	var jump_density: float = float(carry.get_used_rect().size.y)/jump_bodies[6].image.get_height()
	var identities := {"side":{"image":carry,"head":head}}
	var left: Image = carry.duplicate()
	left.flip_x()
	identities.left = {"image":left,"head":Rect2i(80,41,25,24)}
	for direction in ["up","down"]:
		var resource: Resource = load("res://assets/characters/playable/king/greatsword_readability/"+direction+"/idle.tres")
		var image: Image = resource.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var region := Rect2i(resource.identity_source_region)
		if direction=="up": region = hair_bounds(image,red_center_y(image)-2)
		identities[direction] = {"image":image,"head":region}
	for identity in identities.values():
		var image: Image = identity.image
		for y in 128:
			for x in 192:
				var c := image.get_pixel(x,y)
				if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	var clips: Array[Resource] = []
	var bodies: Array[Image] = []
	var hands: Array[Image] = []
	for cut in 4:
		var clip := Definition.new()
		clip.pose_count = 16
		clip.pose_order = PackedInt32Array(range(16))
		clip.primary_hands.clear(); clip.secondary_hands.clear(); clip.lift_pixels.clear()
		clip.weapon_behind_body.clear(); clip.single_hand_poses.clear(); clip.stowed_poses.clear()
		clip.released_poses.clear(); clip.ground_clipped_poses.clear()
		clip.weapon_texture = STEEL
		clip.weapon_primary_grip = Vector2(15,113)
		clip.weapon_tip = Vector2(15,0)
		clip.mirror_cutting_edge = false
		clip.phase_windows = PackedVector2Array([Vector2(0,3),Vector2(4,9),Vector2(10,12)])
		clip.queued_recovery_window = Vector2(13,15)
		clip.identity_source_region = Rect2(head)
		clip.pose_weights = PackedFloat32Array([.2,.6,.8,1,1,1,1,1,1,1,.6,.8,1,.6,.8,1])
		if cut==3: clip.pose_weights = PackedFloat32Array([.8,1,1.5,.35,1.5,1,1,.8,.8,.6,.6,.8,1,.6,.8,1])
		var atlas := Image.create(768,512,false,Image.FORMAT_RGBA8)
		var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
		var clip_views := PackedStringArray()
		for key in 16:
			var source_key: int = [0,1,2,3,4,5,6,7,8,9,10,11,11,10,11,11][key]
			if cut==2: source_key = [0,0,1,1,2,3,4,5,6,7,7,7,7,7,7,7][key]
			if cut==3: source_key = [0,1,2,3,4,4,5,5,6,6,6,7,7,6,7,7][key]
			var component: Dictionary = rows[cut][source_key]
			if cut==3: component = jump_bodies[source_key]
			var contact_row: int = 2 if cut==3 else cut
			var uses_contact := cut<2 and key>=4 and key<=10
			var contact_key := key-2 if key<4 else mini(5,key-4)
			if uses_contact: component = contact_rows[contact_row][contact_key]
			# The generated fifth spin source faced right again; use a real
			# mirrored left body instead of pretending a head swap turns its torso.
			var mirrored_source := cut==2 and source_key==4
			if mirrored_source: component = rows[cut][1]
			var image: Image = component.image.duplicate()
			if mirrored_source: image.flip_x()
			var cel_density := spin_density if cut==2 else contact_density if uses_contact else density
			if cut==3: cel_density = jump_density
			image.resize(roundi(image.get_width()*cel_density),roundi(image.get_height()*cel_density),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i((foot_anchor(carry)-foot_anchor(image)).round())
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
			quantize(body)
			var view := "side"
			if cut==2: view = ["side","side","down","left","left","up","up","side"][source_key]
			var identity: Dictionary = identities[view]
			var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
			var placed := attach_back_head(body,identity.image,identity.head,foreground) if view=="up" else attach_head(body,identity.image,identity.head,view,foreground)
			if failed:
				body.save_png(TWO_HAND_SOURCE+"failed_body_%d_%d.png" % [cut,key])
				print("FAILED_BODY ",cut,"/",key," density ",density," source ",image.get_size())
				print("SCALP ",hair_bounds(body,red_center_y(body)-2)," scarf ",red_center_y(body))
				quit(1)
				return
			remove_specks(body)
			var guide: Vector2 = FRONT_GUIDES[cut][source_key] if cut==2 else TWO_HAND_GUIDES[cut][source_key]
			if uses_contact: guide = TWO_HAND_CONTACT_GUIDES[contact_row][contact_key]
			if cut==3: guide = JUMP_GUIDES[source_key]
			var expected: Vector2 = Vector2(offset)+guide*Vector2(image.get_size())
			var primary := find_glove(body,expected,placed,12)
			if primary==Vector2.ZERO:
				body.save_png(FRONT_SOURCE+"missing_glove.png")
				push_error("Missing drawn glove "+str(cut)+"/"+str(key)+" view "+view)
				quit(1)
				return
			var angle: float = FRONT_LOAD_ANGLES[cut][key] if key<4 else FRONT_ACTIVE_ANGLES[cut][mini(5,key-4)]
			if cut==3: angle = [-130,-150,-135,-60][key] if key<4 else 10.0
			var secondary := primary-Vector2.from_angle(deg_to_rad(angle))*7
			if cut!=2:
				var pair := find_two_hand_grip(body,expected,placed,angle)
				if cut==3 and key>=4: pair = find_landing_grip(body,expected,placed)
				if pair.is_empty():
					body.save_png(TWO_HAND_SOURCE+"missing_pair_%d_%d.png" % [cut,key])
					push_error("Missing two connected drawn palms "+str(cut)+"/"+str(key))
					quit(1)
					return
				primary = pair[0]
				secondary = pair[1]
			clip.primary_hands.append(primary)
			clip.secondary_hands.append(secondary)
			clip.lift_pixels.append([0,-3,-24,-12,0,0,0,0,0,0,0,0,0,0,0,0][key] if cut==3 else 0)
			clip.weapon_behind_body.append(1 if view=="up" else 0)
			clip.single_hand_poses.append(1 if cut==2 else 0); clip.stowed_poses.append(0)
			clip.released_poses.append(0); clip.ground_clipped_poses.append(0)
			clip.identity_regions.append(Rect2(placed))
			clip_views.append(view)
			var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
			atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
			mask.blit_rect(foreground,Rect2i(0,0,192,128),origin)
			var palm := Rect2i(Vector2i(primary)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,palm,origin+palm.position)
			if cut!=2:
				var rear_palm := Rect2i(Vector2i(secondary)-Vector2i(3,3),Vector2i(7,7))
				mask.blit_rect(body,rear_palm,origin+rear_palm.position)
			audit.append({"cut":cut,"key":key,"source_key":source_key,"view":view,"density":cel_density,"contact_source":uses_contact,"grip":[primary.x,primary.y],"secondary_grip":[secondary.x,secondary.y],"head":var_to_str(placed),"mirrored_source":mirrored_source})
		copy_slot(clip,atlas,mask,12,idle,carry,carry_hand,0,head)
		clip_views[12] = "side"
		clips.append(clip); bodies.append(atlas); hands.append(mask); views.append(clip_views)
	copy_slot(clips[0],bodies[0],hands[0],0,idle,carry,carry_hand,0,head)
	for cut in 3:
		copy_slot(clips[cut],bodies[cut],hands[cut],15,clips[cut+1],bodies[cut+1],hands[cut+1],0,head)
		views[cut][15] = views[cut+1][0]
	copy_slot(clips[3],bodies[3],hands[3],15,idle,carry,carry_hand,0,head)
	views[3][15] = "side"
	for cut in 4:
		for key in 16:
			var record: Dictionary = audit[cut*16+key]
			record["final_head"] = var_to_str(clips[cut].identity_regions[key])
			record["final_grip"] = var_to_str(clips[cut].primary_hands[key])
			record["final_secondary_grip"] = var_to_str(clips[cut].secondary_hands[key])
			record["two_hands"] = clips[cut].single_hand_poses[key]==0
			record["final_view"] = views[cut][key]
			record["copied_endpoint"] = key==12 or key==15 or (cut==0 and key==0)
		bodies[cut].save_png(FRONT_DEST+FRONT_NAMES[cut]+"_body.png")
		hands[cut].save_png(FRONT_DEST+FRONT_NAMES[cut]+"_hands.png")
		write_clip(FRONT_DEST,FRONT_NAMES[cut],clips[cut],FRONT_NAMES.slice(1) if cut==0 else [])
	build_front_effects()
	build_landing_effects()
	build_vertical_cels(identities,clips,bodies,hands)
	if failed:
		quit(1)
		return
	for folder: String in [FRONT_DEST,FRONT_DEST+"up/",FRONT_DEST+"down/"]:
		for name in DirAccess.get_files_at(folder):
			if name.ends_with(".png.import"):
				var path: String = folder+name
				var settings := FileAccess.get_file_as_string(path).replace("process/fix_alpha_border=true","process/fix_alpha_border=false")
				FileAccess.open(path,FileAccess.WRITE).store_string(settings)
	var reference_records := {}
	for view in identities:
		reference_records[view] = var_to_str(identities[view].head)
	FileAccess.open(TWO_HAND_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"records":audit,"final_views":views,"reference_heads":reference_records},"\t")+"\n")
	print("FRONT_COMBO_BUILD two-hand front/return/jump, one-hand spin; 64 keys")
	quit()

func clean_handle_guide(sheet: Image) -> Image:
	for y in sheet.get_height():
		for x in sheet.get_width():
			var c := sheet.get_pixel(x,y)
			if c.a<.65 or (c.r>.45 and c.b>.3 and c.g<c.r*.5): sheet.set_pixel(x,y,Color.TRANSPARENT)
	return sheet

func find_landing_grip(body: Image,expected: Vector2,head: Rect2i) -> Array[Vector2]:
	var best: Array[Vector2] = []
	var score := INF
	for y in range(maxi(0,roundi(expected.y)-15),mini(95,roundi(expected.y)+16)):
		for x in range(maxi(0,roundi(expected.x)-15),mini(192,roundi(expected.x)+16)):
			var first := Vector2(x,y)
			# The actual113-texel blade ends on the same sole plane as King.
			var angle := asin(clampf((95.0-y)/113.0,-1,1))
			var second := first-Vector2.from_angle(angle)*7
			if not glove_pixel(body,first,head) or not glove_pixel(body,second,head): continue
			var candidate := ((first+second)*.5).distance_squared_to(expected)
			if candidate<score:
				score = candidate
				best = [first,second]
	return best

func build_vertical_cels(identities: Dictionary,side_clips: Array[Resource],side_bodies: Array[Image],side_hands: Array[Image]) -> void:
	# New whole-body up/down front, return and jump cels. A spin actually turns
	# through all views, so reuse its authored rotating body with a phase shift.
	var rear_rows := extract_bodies(clean_handle_guide(Image.load_from_file(REAR_SOURCE+"up_rear_source.png")),3)
	var occlusion_records: Array[Dictionary] = []
	if rear_rows[2].size()!=8:
		push_error("Rear correction must retain eight complete bottom-row bodies")
		failed = true
		return
	for direction in ["up","down"]:
		var folder: String = FRONT_DEST+direction+"/"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var sheet := clean_handle_guide(Image.load_from_file(POLISH_SOURCE+direction+"_body_source.png"))
		var rows := extract_bodies(sheet,3)
		for row in rows:
			if row.size()!=8:
				push_error("Expected eight new "+direction+" bodies per row; found "+str(row.size()))
				quit(1)
				return
		var idle: Resource = load("res://assets/characters/playable/king/greatsword_readability/"+direction+"/idle.tres")
		var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var carry_hand: Image = idle.hand_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var identity: Dictionary = identities[direction]
		var density: float = 54.0/rows[0][0].image.get_height()
		print("VERTICAL ",direction," baseline ",carry.get_used_rect()," density ",density)
		var clips: Array[Resource] = []
		var bodies: Array[Image] = []
		var hands: Array[Image] = []
		for cut in 4:
			var clip: Resource = side_clips[cut].duplicate()
			if direction=="up" and cut==3:
				clip.occluded_hand_poses = PackedByteArray()
				clip.occluded_hand_poses.resize(16)
			# Packed arrays are reference values. Reordering spin keys must not
			# mutate the source anchors while later keys are still being copied.
			for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","pose_order","pose_weights","identity_regions"]:
				clip.set(property,side_clips[cut].get(property).duplicate())
			var no_followups: Array[Resource] = []
			clip.follow_up_clips = no_followups
			clip.identity_source_region = Rect2(identity.head)
			var atlas := Image.create(768,512,false,Image.FORMAT_RGBA8)
			var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
			for key in 16:
				if cut==2:
					var spin_key: int = key
					if key in range(4,10): spin_key = 4+posmod(key-4+(4 if direction=="up" else 1),6)
					copy_slot(clip,atlas,mask,key,side_clips[2],side_bodies[2],side_hands[2],spin_key,Rect2i(side_clips[2].identity_source_region))
					clip.lift_pixels[key] = 0
					continue
				var row_index := 2 if cut==3 else cut
				var source_key: int = [0,1,2,3,3,4,4,5,5,6,6,7,7,6,7,7][key]
				if cut==3: source_key = [0,1,2,3,4,4,5,5,6,6,6,7,7,6,7,7][key]
				if cut==3 and direction=="down": source_key = [0,1,2,4,5,5,6,6,7,7,7,7,7,6,7,7][key]
				var source: Image = rows[row_index][source_key].image.duplicate()
				source.resize(roundi(source.get_width()*density),roundi(source.get_height()*density),Image.INTERPOLATE_NEAREST)
				var offset := Vector2i((foot_anchor(carry)-foot_anchor(source)).round())
				var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
				body.blit_rect(source,Rect2i(Vector2i.ZERO,source.get_size()),offset)
				quantize(body)
				var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
				var original: Image = body.duplicate()
				var head := attach_back_head(body,identity.image,identity.head,foreground) if direction=="up" else attach_head(body,identity.image,identity.head,"down",foreground)
				if direction=="up":
					for y in range(head.position.y,head.end.y):
						for x in range(head.position.x,head.end.x):
							if glove_pixel(original,Vector2(x,y),Rect2i()):
								body.set_pixel(x,y,original.get_pixel(x,y))
								foreground.set_pixel(x,y,original.get_pixel(x,y))
				if failed:
					body.save_png(POLISH_SOURCE+"failed_"+direction+"_%d_%d.png"%[cut,key])
					quit(1)
					return
				remove_specks(body)
				var degrees: float = FRONT_LOAD_ANGLES[cut][key] if key<4 else FRONT_ACTIVE_ANGLES[cut][mini(5,key-4)]
				var facing_angle := -90.0 if direction=="up" else 90.0
				if cut==3: degrees = [-150,-150,-135,-60][key] if key<4 else 15.0
				degrees += facing_angle
				var exclusion := Rect2i() if direction=="up" else head
				var expected := vertical_glove_center(body,exclusion)
				var pair := find_two_hand_grip(body,expected,exclusion,degrees,6.0)
				# Loading grips follow the projected glove anatomy; contact still
				# uses the exact declared sweep. Never invent an invisible offhand.
				if pair.is_empty() and key<4:
					for delta in [15.0,-15.0,30.0,-30.0,45.0,-45.0,60.0,-60.0,90.0,-90.0]:
						pair = find_two_hand_grip(body,expected,exclusion,degrees+delta,6.0)
						if not pair.is_empty(): break
				if pair.is_empty():
					body.save_png(POLISH_SOURCE+"missing_"+direction+"_%d_%d.png"%[cut,key])
					push_error("No connected two-hand grip "+direction+" "+str(cut)+"/"+str(key))
					failed = true
					quit(1)
					return
				clip.primary_hands[key] = pair[0]
				clip.secondary_hands[key] = pair[1]
				clip.identity_regions[key] = Rect2(head)
				clip.single_hand_poses[key] = 0
				clip.weapon_behind_body[key] = 1 if direction=="up" else 0
				clip.lift_pixels[key] = [0,-3,-24,-12,0,0,0,0,0,0,0,0,0,0,0,0][key] if cut==3 else 0
				var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
				mask.blit_rect(foreground,Rect2i(0,0,192,128),origin)
				for palm: Vector2 in pair:
					var rect := Rect2i(Vector2i(palm.round())-Vector2i(3,3),Vector2i(7,7))
					mask.blit_rect(body,rect,origin+rect.position)
				if direction=="up" and cut==3 and source_key>=4:
					# Keep both real source-palm anchors on the rigid hilt. A complete
					# authored rear torso covers those front arms, rather than painting
					# crossed gloves on King's back or inventing detached runtime arms.
					var rear: Image = rear_rows[2][source_key].image.duplicate()
					rear.resize(roundi(rear.get_width()*density),roundi(rear.get_height()*density),Image.INTERPOLATE_NEAREST)
					var rear_offset := Vector2i((foot_anchor(carry)-foot_anchor(rear)).round())
					body = Image.create(192,128,false,Image.FORMAT_RGBA8)
					body.blit_rect(rear,Rect2i(Vector2i.ZERO,rear.get_size()),rear_offset)
					quantize(body)
					var rear_foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
					head = attach_back_head(body,identity.image,identity.head,rear_foreground)
					remove_specks(body)
					# Project the paired front grips behind the new rear torso as one
					# rigid group. The original palms remain in the provenance mask.
					var projected := Vector2(roundf(head.get_center().x),head.end.y+6)
					var shift := Vector2i((projected-pair[0]).round())
					var source_mask := mask.get_region(Rect2i(origin,Vector2i(192,128)))
					var hidden_mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
					hidden_mask.blit_rect(source_mask,Rect2i(0,0,192,128),shift)
					mask.fill_rect(Rect2i(origin,Vector2i(192,128)),Color.TRANSPARENT)
					mask.blit_rect(hidden_mask,Rect2i(0,0,192,128),origin)
					clip.primary_hands[key] = pair[0]+Vector2(shift)
					clip.secondary_hands[key] = pair[1]+Vector2(shift)
					occlusion_records.append({"key":key,"source_key":source_key,"source_primary":var_to_str(pair[0]),"source_secondary":var_to_str(pair[1]),"projection_shift":var_to_str(shift),"primary":var_to_str(clip.primary_hands[key]),"secondary":var_to_str(clip.secondary_hands[key]),"source":"up_rear_source.png bottom row"})
					clip.identity_regions[key] = Rect2(head)
					clip.occluded_hand_poses[key] = 1
				atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
			copy_slot(clip,atlas,mask,12,idle,carry,carry_hand,0,identity.head)
			clips.append(clip)
			bodies.append(atlas)
			hands.append(mask)
		copy_slot(clips[0],bodies[0],hands[0],0,idle,carry,carry_hand,0,identity.head)
		for cut in 3:
			copy_slot(clips[cut],bodies[cut],hands[cut],15,clips[cut+1],bodies[cut+1],hands[cut+1],0,Rect2i(clips[cut+1].identity_source_region))
		copy_slot(clips[3],bodies[3],hands[3],15,idle,carry,carry_hand,0,identity.head)
		for cut in 4:
			bodies[cut].save_png(folder+FRONT_NAMES[cut]+"_body.png")
			hands[cut].save_png(folder+FRONT_NAMES[cut]+"_hands.png")
			write_clip(folder,FRONT_NAMES[cut],clips[cut],FRONT_NAMES.slice(1) if cut==0 else [])
	FileAccess.open(REAR_SOURCE+"occlusion_registration.json",FileAccess.WRITE).store_string(JSON.stringify(occlusion_records,"\t")+"\n")

func copy_slot(clip: Resource,body: Image,hand: Image,key: int,source: Resource,source_body: Image,source_hand: Image,pose: int,head: Rect2i) -> void:
	super.copy_slot(clip,body,hand,key,source,source_body,source_hand,pose,head)
	if not clip.occluded_hand_poses.is_empty():
		clip.occluded_hand_poses[key] = 1 if source.hands_are_occluded(pose) else 0

func write_clip(folder: String,label: String,clip: Resource,followups: Array) -> void:
	super.write_clip(folder,label,clip,followups)
	if not clip.occluded_hand_poses.is_empty():
		var path := folder+label+".tres"
		var text := FileAccess.get_file_as_string(path)
		FileAccess.open(path,FileAccess.WRITE).store_string(text+"occluded_hand_poses = "+var_to_str(clip.occluded_hand_poses)+"\n")

func build_landing_effects() -> void:
	var source := Image.load_from_file(LANDING_SOURCE+"impact_source.png")
	var slash := Image.new()
	slash.load_png_from_buffer(FileAccess.get_file_as_bytes(FRONT_DEST+"slash.png"))
	var landing := Image.create(768,192,false,Image.FORMAT_RGBA8)
	for row in 2:
		for key in 4:
			var cell := source.get_region(Rect2i(key*source.get_width()/4,row*source.get_height()/2,source.get_width()/4,source.get_height()/2))
			cell.resize(192,192,Image.INTERPOLATE_NEAREST)
			for y in 192:
				for x in 192:
					var c := cell.get_pixel(x,y)
					if c.a<.65 or c.b-c.r>.20 or c.g-c.r>.20: c = Color.TRANSPARENT
					elif c.r>.82 and c.g>.82: c = Color(.98,.99,1,c.a)
					elif c.r>.5: c = Color(.67,.71,.75,c.a)
					else: c = Color(.18,.22,.26,c.a)
					cell.set_pixel(x,y,c)
			if row==1: landing.blit_rect(cell,Rect2i(0,0,192,192),Vector2i(key*192,0))
	slash.save_png(FRONT_DEST+"slash.png")
	landing.save_png(FRONT_DEST+"landing.png")

func vertical_glove_center(body: Image,head: Rect2i) -> Vector2:
	# Boot colors also pass the glove palette; limit the search to drawn arms.
	var sum := Vector2.ZERO
	var count := 0
	for y in range(10,mini(86,head.end.y+18) if head.size!=Vector2i.ZERO else 80):
		for x in range(60,137):
			if glove_pixel(body,Vector2(x,y),head):
				sum += Vector2(x,y)
				count += 1
	return sum/maxi(count,1)

func largest_component(image: Image) -> Image:
	var width := image.get_width()
	var height := image.get_height()
	var seen := PackedByteArray()
	seen.resize(width*height)
	var largest := PackedInt32Array()
	for seed in width*height:
		if seen[seed] or image.get_pixel(seed%width,seed/width).a<.65: continue
		seen[seed] = 1
		var todo := PackedInt32Array([seed])
		var cursor := 0
		while cursor<todo.size():
			var id := todo[cursor]
			cursor += 1
			for dy in range(-1,2):
				for dx in range(-1,2):
					var p := Vector2i(id%width+dx,id/width+dy)
					if p.x<0 or p.y<0 or p.x>=width or p.y>=height: continue
					var next := p.y*width+p.x
					if seen[next] or image.get_pixelv(p).a<.65: continue
					seen[next] = 1
					todo.append(next)
		if todo.size()>largest.size(): largest = todo
	var clean := Image.create(width,height,false,Image.FORMAT_RGBA8)
	for id in largest: clean.set_pixel(id%width,id/width,image.get_pixel(id%width,id/width))
	return clean

func extract_two_hand_rows(sheet: Image) -> Array[Array]:
	# Tiny alpha filaments connect adjacent boots in this generated source.
	# Its regular12-column layout is explicit; isolate those cels before
	# component extraction instead of accidentally joining two Kings.
	var result: Array[Array] = []
	if sheet.get_size()!=Vector2i(1448,1086):
		push_error("Two-hand body source changed; its explicit gutters need recalibration")
		quit(1)
		return result
	var row_edges := [0,340,616,835,sheet.get_height()]
	for row in 4:
		var bodies: Array = []
		if row==1:
			# Return-load boots overlap the nominal twelve-column grid. A narrow
			# low-alpha/outline seam follows the actual gaps between whole bodies.
			result.append(extract_return_row(sheet.get_region(Rect2i(0,row_edges[1],sheet.get_width(),row_edges[2]-row_edges[1]))))
			continue
		for column in 12:
			var left := roundi(column*sheet.get_width()/12.0)
			var right := roundi((column+1)*sheet.get_width()/12.0)
			var top: int = row_edges[row]
			var bottom: int = row_edges[row+1]
			var cell := sheet.get_region(Rect2i(left,top,right-left,bottom-top))
			# Source filtering must happen before get_used_rect: low-alpha dust
			# would otherwise inflate the shared scale and discard the scarf.
			for y in cell.get_height():
				for x in cell.get_width():
					if cell.get_pixel(x,y).a<.65: cell.set_pixel(x,y,Color.TRANSPARENT)
			cell = largest_component(cell)
			var occupied := cell.get_used_rect()
			bodies.append({"image":cell.get_region(occupied),"bounds":Rect2i(Vector2i(left,top)+occupied.position,occupied.size)})
		result.append(bodies)
	return result

func extract_return_row(row: Image) -> Array:
	var centers := [0,143,269,391,515,639,755,864,964,1073,1198,1307,1448]
	var seams: Array[PackedInt32Array] = []
	for center in centers:
		if center==0 or center==row.get_width():
			var edge := PackedInt32Array()
			edge.resize(row.get_height())
			edge.fill(center)
			seams.append(edge)
		else: seams.append(source_seam(row,center,28))
	var bodies: Array = []
	for column in 12:
		var left := seams[column]
		var right := seams[column+1]
		var low: int = Array(left).min()
		var high: int = Array(right).max()
		var cell := Image.create(high-low,row.get_height(),false,Image.FORMAT_RGBA8)
		for y in row.get_height():
			for x in range(left[y]+(1 if column>0 else 0),right[y]):
				var c := row.get_pixel(x,y)
				if c.a>=.65: cell.set_pixel(x-low,y,c)
		cell = largest_component(cell)
		var bounds := cell.get_used_rect()
		bodies.append({"image":cell.get_region(bounds),"bounds":Rect2i(Vector2i(low,340)+bounds.position,bounds.size)})
	return bodies

func source_seam(image: Image,center: int,radius: int) -> PackedInt32Array:
	var width := radius*2+1
	var previous := PackedFloat64Array()
	previous.resize(width)
	var parents := PackedInt32Array()
	parents.resize(width*image.get_height())
	for y in image.get_height():
		var current := PackedFloat64Array()
		current.resize(width)
		for column in width:
			var best := column
			if y>0:
				for other in range(maxi(0,column-1),mini(width,column+2)):
					if previous[other]+absf(other-column)*.1<previous[best]+absf(best-column)*.1: best = other
			var c := image.get_pixel(center-radius+column,y)
			var ink := 0.0 if c.a<.65 else 1.0+20.0*maxf(c.r,maxf(c.g,c.b))
			current[column] = ink+absf(column-radius)*.003+(previous[best]+absf(best-column)*.1 if y>0 else 0.0)
			parents[y*width+column] = best
		previous = current
	var end := 0
	for column in width:
		if previous[column]<previous[end]: end = column
	var path := PackedInt32Array()
	path.resize(image.get_height())
	for y in range(image.get_height()-1,-1,-1):
		path[y] = center-radius+end
		end = parents[y*width+end]
	return path

func attach_head(body: Image,carry: Image,reference: Rect2i,direction: String,foreground: Image,raised_hands := true) -> Rect2i:
	if red_center_y(body)>0:
		return super.attach_head(body,carry,reference,direction,foreground,raised_hands)
	# Crossed forearms can legitimately cover the entire scarf in the load.
	# Register to the drawn crown in that case, preserving those forearms.
	var scalp := hair_bounds(body,body.get_used_rect().position.y+34)
	if scalp.size.x<12 or scalp.size.y<8:
		failed = true
		push_error("Missing crown in scarf-occluded two-hand pose")
		return reference
	var destination := Vector2i(roundi(scalp.get_center().x-reference.size.x*.5),scalp.position.y)
	var drawn: Image = body.duplicate()
	for y in range(scalp.position.y,scalp.end.y+8):
		for x in range(scalp.position.x,scalp.end.x):
			var c := body.get_pixel(x,y)
			if c.a>.65 and (hair_pixel(c) or (c.r>.65 and c.r>c.b*1.15)):
				body.set_pixel(x,y,Color.TRANSPARENT)
	body.blend_rect(carry,reference,destination)
	for y in range(scalp.position.y,scalp.end.y+8):
		for x in range(scalp.position.x,scalp.end.x):
			var c := drawn.get_pixel(x,y)
			if c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25:
				body.set_pixel(x,y,c)
				foreground.set_pixel(x,y,c)
	return Rect2i(destination,reference.size)

func glove_pixel(body: Image,point: Vector2,head: Rect2i) -> bool:
	var pixel := Vector2i(point.round())
	if pixel.x<0 or pixel.x>=192 or pixel.y<0 or pixel.y>=95: return false
	if head.has_point(pixel) and pixel.y>=head.position.y+head.size.y*.4: return false
	var c := body.get_pixelv(pixel)
	return c.a>.65 and c.r>=.18 and c.r<=.79 and c.r>=c.g*1.35 and c.g>=c.b*1.25

func find_two_hand_grip(body: Image,expected: Vector2,head: Rect2i,angle: float,spacing := 7.0) -> Array[Vector2]:
	# Both anchors must be real brown glove texels on the full cel. One rigid
	# hilt spans them; there is no detached runtime offhand or virtual grip.
	var axis := Vector2.from_angle(deg_to_rad(angle))
	var best: Array[Vector2] = []
	var score := INF
	for y in range(maxi(0,roundi(expected.y)-15),mini(95,roundi(expected.y)+16)):
		for x in range(maxi(0,roundi(expected.x)-15),mini(192,roundi(expected.x)+16)):
			var first := Vector2(x,y)
			var second := first-axis*spacing
			if not glove_pixel(body,first,head) or not glove_pixel(body,second,head): continue
			var support := 0
			for dy in range(-1,2):
				for dx in range(-1,2):
					if glove_pixel(body,first+Vector2(dx,dy),head): support += 1
					if glove_pixel(body,second+Vector2(dx,dy),head): support += 1
			var candidate := ((first+second)*.5).distance_squared_to(expected)+(18-support)*5
			if candidate<score:
				score = candidate
				best = [first,second]
	return best

func build_front_effects() -> void:
	var source := Image.load_from_file(POLISH_SOURCE+"slash_source.png")
	var atlas := Image.create(768,768,false,Image.FORMAT_RGBA8)
	# Generated gutters are calibrated once, then each whole row uses ONE fit.
	# Independent per-frame fits would pump the radius between contact keys.
	var row_edges := [0,332,650,901,source.get_height()]
	var columns := [[0,313,635,973,source.get_width()],[0,310,635,973,source.get_width()],[0,300,630,966,source.get_width()],[0,313,635,973,source.get_width()]]
	for row in 4:
		var cells: Array[Image] = []
		var largest := Vector2i.ZERO
		for key in 4:
			var cell := source.get_region(Rect2i(columns[row][key],row_edges[row],columns[row][key+1]-columns[row][key],row_edges[row+1]-row_edges[row]))
			for y in cell.get_height():
				for x in cell.get_width():
					var c := cell.get_pixel(x,y)
					# Drop generated cyan glow/noise; keep the silver-white ribbon.
					if c.a<.65 or (c.b-c.r>.25) or (c.g-c.r>.25): c = Color.TRANSPARENT
					elif c.r>.82 and c.g>.82: c = Color(.98,.99,1,c.a)
					elif c.r>.5: c = Color(.67,.71,.75,c.a)
					else: c = Color(.18,.22,.26,c.a)
					cell.set_pixel(x,y,c)
			cells.append(cell)
			largest = largest.max(cell.get_size())
		var density := 144.0/maxi(largest.x,largest.y)
		if row==3:
			# The second cleave extends across a straight gutter. Assign its entire
			# connected ribbon to its own cel; retain separately authored sparks.
			# Expanded source canvases keep the existing common density/origins.
			cells = complete_effect_cells(source,row_edges[row],row_edges[row+1],columns[row])
		for key in 4:
			var cell: Image = cells[key]
			cell.resize(roundi(cell.get_width()*density),roundi(cell.get_height()*density),Image.INTERPOLATE_NEAREST)
			var offset := Vector2i((192-cell.get_width())/2,(192-cell.get_height())/2)
			atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i(key*192,row*192)+offset)
	atlas.save_png(FRONT_DEST+"slash.png")

func complete_effect_cells(source: Image,top: int,bottom: int,columns: Array) -> Array[Image]:
	var band := source.get_region(Rect2i(0,top,source.get_width(),bottom-top))
	for y in band.get_height():
		for x in band.get_width():
			var c := band.get_pixel(x,y)
			if c.a<.65 or c.b-c.r>.25 or c.g-c.r>.25: c = Color.TRANSPARENT
			elif c.r>.82 and c.g>.82: c = Color(.98,.99,1,c.a)
			elif c.r>.5: c = Color(.67,.71,.75,c.a)
			else: c = Color(.18,.22,.26,c.a)
			band.set_pixel(x,y,c)
	var cells: Array[Image] = []
	for key in 4: cells.append(Image.create(columns[key+1]-columns[key]+64,band.get_height(),false,Image.FORMAT_RGBA8))
	var seen := PackedByteArray()
	seen.resize(band.get_width()*band.get_height())
	var width := band.get_width()
	for seed in seen.size():
		if seen[seed] or band.get_pixel(seed%width,seed/width).a<.65: continue
		seen[seed] = 1
		var pixels := PackedInt32Array([seed])
		var low := seed%width
		var high := low
		var cursor := 0
		while cursor<pixels.size():
			var id := pixels[cursor]
			cursor += 1
			var point := Vector2i(id%width,id/width)
			low = mini(low,point.x)
			high = maxi(high,point.x)
			for dy in range(-1,2):
				for dx in range(-1,2):
					var next := point+Vector2i(dx,dy)
					if next.x<0 or next.x>=width or next.y<0 or next.y>=band.get_height(): continue
					var index := next.y*width+next.x
					if seen[index] or band.get_pixelv(next).a<.65: continue
					seen[index] = 1
					pixels.append(index)
		if pixels.size()<5: continue # Generated isolated noise, not authored chips.
		var center := (low+high)/2
		var owner := 0
		while owner<3 and center>=columns[owner+1]: owner += 1
		var local_left: int = columns[owner]-32
		if low<local_left or high>=local_left+cells[owner].get_width():
			push_error("Complete cleave exceeds padded source canvas; recalibrate gutters")
			failed = true
			continue
		for id in pixels:
			cells[owner].set_pixel(id%width-local_left,id/width,band.get_pixel(id%width,id/width))
	return cells
