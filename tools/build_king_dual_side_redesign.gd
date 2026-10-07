extends "res://tools/build_king_dual_twinsteel.gd"

## Offline side-only motion study. Never writes installed Twinsteel/heavy assets.
const STUDY_SOURCE := "res://art_source/generated/characters/king/dual_side_redesign_2026_10_07/"
const STUDY_DEST := "res://assets/characters/playable/king/dual_side_redesign/"
const STUDY_NAMES := ["diagonal", "return", "rising_cross", "hop_spin", "cross_finish"]
const STEEL_PATH := "res://assets/characters/playable/king/dual_twinsteel/twinsteel.png"
const SOURCE_KEYS := [0,1,2,2,3,3,4,4,5,5,6,7,7,6,7,7]
const STUDY_MAIN := [
	[-110,-140,-115,-60,-10,50,70,70],
	[50,50,35,15,0,-30,-60,-60],
	[-90,-50,-70,-65,-15,30,50,50],
	[-60,-10,60,135,215,290,350,360],
	[-45,-65,-90,-65,-5,45,70,70]
]
const STUDY_OFF := [
	[-20,0,0,15,15,0,-20,-20],
	[-20,30,70,55,0,-60,-90,-90],
	[-90,-130,-115,25,65,85,50,50],
	[30,80,150,225,305,380,440,450],
	[-135,-115,-90,65,5,-45,-70,-70]
]
const NEAR_GUIDES := [
	[Vector2(.2,.56),Vector2(.28,.2),Vector2(.28,.48),Vector2(.3,.56),Vector2(.23,.49),Vector2(.28,.54),Vector2(.17,.48),Vector2(.28,.57)],
	[Vector2(.18,.59),Vector2(.23,.64),Vector2(.24,.57),Vector2(.32,.66),Vector2(.34,.6),Vector2(.36,.55),Vector2(.32,.65),Vector2(.22,.6)],
	[Vector2(.35,.64),Vector2(.30,.63),Vector2(.35,.62),Vector2(.17,.23),Vector2(.15,.15),Vector2(.30,.57),Vector2(.17,.65),Vector2(.25,.64)],
	[Vector2(.20,.58),Vector2(.15,.42),Vector2(.20,.22),Vector2(.28,.63),Vector2(.18,.61),Vector2(.13,.56),Vector2(.23,.58),Vector2(.20,.61)],
	[Vector2(.23,.56),Vector2(.20,.21),Vector2(.20,.13),Vector2(.21,.50),Vector2(.33,.59),Vector2(.29,.64),Vector2(.25,.62),Vector2(.20,.61)]
]
const FAR_GUIDES := [
	[Vector2(.86,.64),Vector2(.90,.63),Vector2(.90,.77),Vector2(.88,.79),Vector2(.90,.77),Vector2(.90,.60),Vector2(.94,.62),Vector2(.83,.62)],
	[Vector2(.88,.63),Vector2(.92,.37),Vector2(.92,.50),Vector2(.88,.14),Vector2(.90,.3),Vector2(.9,.12),Vector2(.9,.12),Vector2(.86,.62)],
	[Vector2(.85,.64),Vector2(.65,.65),Vector2(.90,.22),Vector2(.89,.13),Vector2(.92,.23),Vector2(.89,.59),Vector2(.88,.57),Vector2(.83,.64)],
	[Vector2(.87,.66),Vector2(.90,.42),Vector2(.87,.50),Vector2(.85,.58),Vector2(.90,.56),Vector2(.91,.5),Vector2(.87,.64),Vector2(.87,.61)],
	[Vector2(.88,.61),Vector2(.87,.18),Vector2(.88,.23),Vector2(.88,.69),Vector2(.91,.34),Vector2(.87,.66),Vector2(.85,.62),Vector2(.88,.61)]
]
var study_refs := {}

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(STUDY_DEST))
	var rows := extract_bodies(Image.load_from_file(STUDY_SOURCE+"body_source.png"),5)
	for row in rows:
		if row.size()!=8:
			push_error("Dual study needs eight complete, separated bodies per row: "+str(row.size()))
			quit(1)
			return
	var idle: Resource = load(OUTPUT+"idle.tres")
	var native: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	study_refs.side = {"image": native.body_atlas.get_image().get_region(Rect2i(0,0,192,128)),"head":Rect2i(87,41,25,24)}
	var left: Image = study_refs.side.image.duplicate()
	left.flip_x()
	study_refs.left = {"image":left,"head":Rect2i(80,41,25,24)}
	for view_name in ["up","down"]:
		var resource: Resource = load("res://assets/characters/playable/king/greatsword_readability/"+view_name+"/idle.tres")
		var reference_image: Image = resource.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var head := Rect2i(resource.identity_source_region)
		if view_name=="up": head = hair_bounds(reference_image,red_center_y(reference_image)-2)
		study_refs[view_name] = {"image":reference_image,"head":head}
	for reference in study_refs.values():
		var reference_image: Image = reference.image
		for y in reference_image.get_height():
			for x in reference_image.get_width():
				var color := reference_image.get_pixel(x,y)
				if color.a>.65 and not palette.has(Color(color.r,color.g,color.b,1)): palette.append(Color(color.r,color.g,color.b,1))
	blade = load(STEEL_PATH)
	# ONE density for the entire sheet. Crouches, turns and airborne cels never zoom.
	var density: float = 54.0/float(rows[0][0].image.get_height())
	var clips: Array[Resource] = []
	for cut in 5:
		clips.append(build_study_clip(cut,rows[cut],density))
		if failed:
			quit(1)
			return
	for cut in 5:
		copy_dual_slot(clips[cut],0,idle if cut==0 else clips[cut-1],0 if cut==0 else 15)
		copy_dual_slot(clips[cut],12,idle,0)
		if cut==4: copy_dual_slot(clips[cut],15,idle,0)
	for cut in 5: write_dual(STUDY_NAMES[cut],clips[cut],STUDY_NAMES.slice(1) if cut==0 else [],STUDY_DEST)
	build_study_effects()
	var heads := {}
	for view_name in study_refs: heads[view_name] = var_to_str(study_refs[view_name].head)
	FileAccess.open(STUDY_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"density":density,"heads":heads,"poses":audit,"scope":"LEFT/RIGHT motion study only; installed weapons untouched"},"\t")+"\n")
	print("DUAL_SIDE_BUILD: 40 new bodies, 80 registered slots, 20 new raster effects, one sheet density")
	quit(1 if failed else 0)

func build_study_clip(cut: int,row: Array,density: float) -> Resource:
	var clip := Definition.new()
	clip.pose_count = 16
	clip.pose_order = PackedInt32Array(range(16))
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		clip.set(property,clip.get(property).slice(0,0))
	clip.weapon_texture = blade
	clip.weapon_primary_grip = Vector2(8,50)
	clip.weapon_tip = Vector2(8,0)
	clip.mirror_cutting_edge = false
	clip.allow_rest = false
	clip.phase_windows = PackedVector2Array([Vector2(0,3),Vector2(4,9),Vector2(10,12)])
	clip.queued_recovery_window = Vector2(13,15)
	clip.pose_weights = PackedFloat32Array([.5,1,1,.5,1,1,1,1,1,1,1,1,1,1,1,1])
	clip.offhand = Offhand.new()
	clip.offhand.texture = blade
	clip.offhand.grip = clip.weapon_primary_grip
	clip.offhand.tip = clip.weapon_tip
	var atlas := Image.create(768,512,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
	for key in 16:
		var source_key: int = SOURCE_KEYS[key]
		var component: Dictionary = row[source_key]
		var part := preserve_raster_connections(component.image,density)
		var offset := Vector2i((Vector2(96,94)-foot_anchor(part)).round())
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
		quantize(body)
		var source_body := body.duplicate()
		var view_name: String = ["side","down","down","left","up","up","side","side"][source_key] if cut==3 else "side"
		var reference: Dictionary = study_refs[view_name]
		var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var head := attach_back_head(body,reference.image,reference.head,foreground) if view_name=="up" else attach_head(body,reference.image,reference.head,view_name,foreground)
		remove_specks(body)
		var near_expected: Vector2 = Vector2(offset)+NEAR_GUIDES[cut][source_key]*Vector2(part.get_size())
		var far_expected: Vector2 = Vector2(offset)+FAR_GUIDES[cut][source_key]*Vector2(part.get_size())
		var near := find_glove(body,near_expected,head,6)
		var far := find_glove(body,far_expected,head,6)
		# This authored back-left turn hides the far forearm behind the torso.
		# Its blade must disappear too; never attach a visible hilt to the scarf.
		var far_occluded := cut==3 and source_key==4
		if far_occluded: far = near+Vector2(7,-1)
		if near==Vector2.ZERO or (not far_occluded and (far==Vector2.ZERO or near.distance_to(far)<4)):
			body.save_png(STUDY_SOURCE+"registration_failure.png")
			print("EXPECTED_GRIPS ",near_expected," / ",far_expected," head ",head)
			push_error("Missing separate attached palms "+STUDY_NAMES[cut]+"/"+str(key)+" "+str(near)+" "+str(far))
			failed = true
			return clip
		var restored := restore_source_forearms(body,source_body,head,[near] if far_occluded else [near,far])
		# Shaft axes are orientation metadata, never a fabricated second fist.
		clip.primary_hands.append(near)
		clip.secondary_hands.append(near-Vector2.from_angle(deg_to_rad(STUDY_MAIN[cut][source_key]))*7)
		clip.offhand.hands.append(far)
		clip.offhand.axes.append(far-Vector2.from_angle(deg_to_rad(STUDY_OFF[cut][source_key]))*7)
		clip.weapon_behind_body.append(1 if view_name=="up" else 0)
		clip.offhand.behind_body.append(1 if view_name=="up" or cut in [0,1] else 0)
		clip.offhand.visible_poses.append(0 if far_occluded else 1)
		clip.single_hand_poses.append(1)
		clip.stowed_poses.append(0)
		clip.released_poses.append(0)
		clip.ground_clipped_poses.append(0)
		var lift := 0.0
		if cut==3: lift = [0.0,-4.0,-10.0,-10.0,-8.0,-6.0,-4.0,0.0][source_key]
		if cut==4: lift = [0.0,-3.0,-10.0,0.0,0.0,0.0,0.0,0.0][source_key]
		clip.lift_pixels.append(lift)
		clip.identity_regions.append(Rect2(head))
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		for grip in ([near] if far_occluded else [near,far]):
			var rectangle := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
			foreground.blit_rect(body,rectangle,rectangle.position)
		mask.blit_rect(foreground,Rect2i(0,0,192,128),origin)
		audit.append({"cut":cut,"key":key,"source_key":source_key,"bounds":var_to_str(component.bounds),"near":var_to_str(near),"far":var_to_str(far),"far_occluded":far_occluded,"view":view_name,"density":density,"head":var_to_str(head),"restored_forearm_pixels":restored})
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(mask)
	return clip

func restore_source_forearms(body: Image,source_body: Image,head: Rect2i,grips: Array) -> int:
	# Head replacement's rectangular erase may remove neutral sleeve/outline
	# pixels beside a raised glove. Recover ONLY the original drawn forearm,
	# outside the central native face, without touching any retained head pixel.
	var restored := 0
	for grip: Vector2 in grips:
		var shoulder := Vector2(head.get_center().x+signf(grip.x-head.get_center().x)*7,head.end.y+5)
		for y in range(maxi(0,mini(roundi(grip.y),roundi(shoulder.y))-6),mini(128,maxi(roundi(grip.y),roundi(shoulder.y))+7)):
			for x in range(maxi(0,mini(roundi(grip.x),roundi(shoulder.x))-6),mini(192,maxi(roundi(grip.x),roundi(shoulder.x))+7)):
				var point := Vector2(x,y)
				if point.distance_to(Geometry2D.get_closest_point_to_segment(point,grip,shoulder))>6: continue
				if y<head.position.y+head.size.y*.55 and absf(x-head.get_center().x)<head.size.x*.4: continue
				var color := source_body.get_pixel(x,y)
				if body.get_pixel(x,y).a<.65 and color.a>.65 and not is_crimson(color):
					body.set_pixel(x,y,color)
					restored += 1
	return restored

func preserve_raster_connections(source: Image,density: float) -> Image:
	# Native nearest sampling can discard a thin source forearm between pixels.
	# Keep source coverage for that pixel, using an existing source color only;
	# no blur, synthesized arm, detached runtime layer or per-pose resizing.
	var size := Vector2i(roundi(source.get_width()*density),roundi(source.get_height()*density))
	var result := source.duplicate()
	result.resize(size.x,size.y,Image.INTERPOLATE_NEAREST)
	for y in size.y:
		for x in size.x:
			if result.get_pixel(x,y).a>.65: continue
			var center := Vector2((x+.5)/density,(y+.5)/density)
			var closest := INF
			var color := Color.TRANSPARENT
			for sy in range(maxi(0,floori(y/density)),mini(source.get_height(),ceili((y+1)/density))):
				for sx in range(maxi(0,floori(x/density)),mini(source.get_width(),ceili((x+1)/density))):
					var pixel := source.get_pixel(sx,sy)
					var distance := center.distance_squared_to(Vector2(sx+.5,sy+.5))
					if pixel.a>.65 and distance<closest:
						closest = distance
						color = pixel
			if closest<INF: result.set_pixel(x,y,color)
	return result

func build_study_effects() -> void:
	var source := Image.load_from_file(STUDY_SOURCE+"slash_source.png")
	var atlas := Image.create(768,960,false,Image.FORMAT_RGBA8)
	# Generated rows have different heights. Nominal fifths cut the crescents
	# and pull parts of a neighbor into the next frame. Use real clear gutters.
	var bands := effect_source_bands(source)
	if bands.size()!=5:
		push_error("Expected five complete FX bands, found "+str(bands))
		failed = true
		return
	print("DUAL_FX_BANDS ",bands)
	var source_margins: Array[Dictionary] = []
	for row in 5:
		var cells := complete_study_effect_cells(source,int(bands[row].x),int(bands[row].y))
		var span := Vector2i.ZERO
		for key in 4:
			var cell: Image = cells[key]
			var used := cell.get_used_rect()
			if used.position.x<2 or used.end.x>cell.get_width()-2:
				push_error("FX source crosses its column gutter: "+str(row)+"/"+str(key))
				failed = true
			source_margins.append({"row":row,"key":key,"bounds":var_to_str(used),"cell_size":var_to_str(cell.get_size())})
			span = span.max(cell.get_size())
		# Common fit preserves authored growth/fade. Complete 24px output gutters.
		var density := 144.0/maxi(span.x,span.y)
		for key in 4:
			var cell: Image = cells[key]
			cell.resize(roundi(cell.get_width()*density),roundi(cell.get_height()*density),Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i(key*192+(192-cell.get_width())/2,row*192+(192-cell.get_height())/2))
	atlas.save_png(STUDY_DEST+"slash.png")
	FileAccess.open(STUDY_SOURCE+"fx_registration.json",FileAccess.WRITE).store_string(JSON.stringify({"bands":var_to_str(bands),"source_size":var_to_str(source.get_size()),"source_margins":source_margins,"output_cell":[192,192],"maximum_fit":144,"one_density_per_row":true},"\t")+"\n")

func complete_study_effect_cells(source: Image,top: int,bottom: int) -> Array[Image]:
	var band := source.get_region(Rect2i(0,top,source.get_width(),bottom-top))
	for y in band.get_height():
		for x in band.get_width():
			var color := band.get_pixel(x,y)
			if color.a<.65 or color.b-color.r>.25 or color.g-color.r>.25: color = Color.TRANSPARENT
			elif color.r>.82 and color.g>.82: color = Color(.98,.99,1,1)
			elif color.r>.5: color = Color(.67,.71,.75,1)
			else: color = Color(.18,.22,.26,1)
			band.set_pixel(x,y,color)
	var columns := PackedInt32Array()
	for index in 5: columns.append(band.get_width()*index/4)
	var cells: Array[Image] = []
	for key in 4: cells.append(Image.create(columns[key+1]-columns[key]+160,band.get_height()+64,false,Image.FORMAT_RGBA8))
	var width := band.get_width()
	var seen := PackedByteArray()
	seen.resize(width*band.get_height())
	for seed in seen.size():
		if seen[seed] or band.get_pixel(seed%width,seed/width).a<.65: continue
		var pixels := PackedInt32Array([seed])
		seen[seed] = 1
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
					if next.x<0 or next.y<0 or next.x>=width or next.y>=band.get_height(): continue
					var index := next.y*width+next.x
					if seen[index] or band.get_pixelv(next).a<.65: continue
					seen[index] = 1
					pixels.append(index)
		if pixels.size()<5: continue # Isolated generated noise, not a ribbon/chip.
		var center := (low+high)/2
		var owner := 0
		while owner<3 and center>=columns[owner+1]: owner += 1
		var left := columns[owner]-80
		if low<left or high>=left+cells[owner].get_width():
			print("FX_OVERLAP top=",top," bounds=",low,"..",high," owner=",owner," pixels=",pixels.size())
			band.save_png(STUDY_SOURCE+"fx_failed_band.png")
			push_error("Complete dual ribbon exceeds its padded source ownership")
			failed = true
			continue
		for id in pixels:
			cells[owner].set_pixel(id%width-left,id/width+32,band.get_pixel(id%width,id/width))
	return cells

func effect_source_bands(source: Image) -> Array[Vector2i]:
	var result: Array[Vector2i] = []
	var start := -1
	var last := -1
	for y in source.get_height():
		var opaque := 0
		for x in source.get_width():
			var color := source.get_pixel(x,y)
			if color.a>.65 and color.b-color.r<=.25 and color.g-color.r<=.25: opaque += 1
		if opaque>=4:
			if start<0: start = y
			last = y
		elif start>=0 and y-last>=6:
			result.append(Vector2i(maxi(0,start-2),mini(source.get_height(),last+3)))
			start = -1
	if start>=0: result.append(Vector2i(maxi(0,start-2),source.get_height()))
	return result
