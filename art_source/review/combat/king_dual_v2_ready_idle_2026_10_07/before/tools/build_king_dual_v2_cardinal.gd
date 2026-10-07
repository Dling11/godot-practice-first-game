extends "res://tools/build_king_dual_side_redesign.gd"

## Deterministic ingestion of new cardinal/gait/proud-idle sources.
## The approved side study and other weapon art are read-only inputs.
const V2_SOURCE := "res://art_source/generated/characters/king/dual_v2_cardinal_2026_10_07/"
const V2_DEST := "res://assets/characters/playable/king/dual_v2/"
var offhand_occluded := false

func _initialize() -> void:
	setup_references()
	blade = load(STEEL_PATH)
	var gait := extract_bodies(Image.load_from_file(V2_SOURCE+"gait_source.png"),3)
	var idle_rows := extract_bodies(Image.load_from_file(V2_SOURCE+"idle_source.png"),3)
	if not check_rows(gait,8,"gait") or not check_rows(idle_rows,8,"idle"):
		quit(1)
		return
	var gait_density: float = 54.0/gait[0][0].image.get_height()
	var idle_density: float = 54.0/idle_rows[0][0].image.get_height()
	for row in 3:
		var view_name: String = ["side","down","up"][row]
		var folder := V2_DEST+("" if view_name=="side" else view_name+"/")
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var idle := build_v2_clip(view_name,-1,idle_rows[row],idle_density)
		var run := build_v2_clip(view_name,-2,gait[row],gait_density)
		if failed:
			quit(1)
			return
		var clips: Array[Resource] = []
		if view_name=="side":
			for cut in 5: clips.append(load(STUDY_DEST+STUDY_NAMES[cut]+".tres").duplicate(true))
		else:
			var rows := extract_bodies(Image.load_from_file(V2_SOURCE+view_name+"_source.png"),5)
			if not check_rows(rows,8,view_name):
				quit(1)
				return
			var density: float = 54.0/rows[0][0].image.get_height()
			for cut in 5: clips.append(orient_spin(view_name) if cut==3 else build_v2_clip(view_name,cut,rows[cut],density))
		if failed:
			quit(1)
			return
		for cut in 5:
			copy_dual_slot(clips[cut],0,idle if cut==0 else clips[cut-1],0 if cut==0 else 15)
			copy_dual_slot(clips[cut],12,idle,0)
			if cut==4: copy_dual_slot(clips[cut],15,idle,0)
		for cut in 5: write_dual(STUDY_NAMES[cut],clips[cut],STUDY_NAMES.slice(1) if cut==0 else [],folder)
		write_dual("run",run,[],folder,OUTPUT+"twinsteel_side_rear.png" if view_name=="side" else "")
		write_dual("idle",idle,[],folder)
		for cut in 5:
			if not clips[cut].primary_visible_poses.is_empty(): append_visibility(folder+STUDY_NAMES[cut]+".tres",clips[cut])
		var file := FileAccess.open(folder+"idle.tres",FileAccess.READ_WRITE)
		file.seek_end()
		file.store_string("rest_start_pose = 1\nrest_transition_seconds = 1.10\nrest_loop_window = Vector2(5,7)\nrest_loop_seconds = 4.2\nretrieval_end_pose = 0\n")
	DirAccess.copy_absolute(ProjectSettings.globalize_path(STUDY_DEST+"slash.png"),ProjectSettings.globalize_path(V2_DEST+"slash.png"))
	for view_name in ["up","down"]: build_vertical_effects(view_name)
	FileAccess.open(V2_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("DUAL_V2_BUILD: approved side chain + new UP/DOWN cuts + cardinal full-body spin +24 fresh strides +24 proud idle bodies")
	quit(1 if failed else 0)

func setup_references() -> void:
	var native: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
	study_refs.side = {"image":native.body_atlas.get_image().get_region(Rect2i(0,0,192,128)),"head":Rect2i(87,41,25,24)}
	var left: Image = study_refs.side.image.duplicate()
	left.flip_x()
	study_refs.left = {"image":left,"head":Rect2i(80,41,25,24)}
	for view_name in ["up","down"]:
		var resource: Resource = load("res://assets/characters/playable/king/greatsword_readability/"+view_name+"/idle.tres")
		var image: Image = resource.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var head := hair_bounds(image,red_center_y(image)-2) if view_name=="up" else Rect2i(resource.identity_source_region)
		study_refs[view_name] = {"image":image,"head":head}
	for reference in study_refs.values():
		var image: Image = reference.image
		for y in image.get_height():
			for x in image.get_width():
				var color := image.get_pixel(x,y)
				if color.a>.65 and not palette.has(Color(color.r,color.g,color.b,1)): palette.append(Color(color.r,color.g,color.b,1))

func check_rows(rows: Array,count: int,label: String) -> bool:
	for row in rows:
		if row.size()<count or row.size()>count+2:
			push_error("Complete isolated source bodies required: "+label+" expected "+str(count)+" got "+str(row.size()))
			return false
	return true

func small_scalp_center(part: Image) -> float:
	var sum := 0.0
	var count := 0
	for y in range(0,roundi(part.get_height()*.3)):
		for x in part.get_width():
			var color := part.get_pixel(x,y)
			if color.a>.65 and maxf(color.r,maxf(color.g,color.b))<.4:
				sum += x
				count += 1
	return sum/count if count>0 else part.get_width()*.5

func orient_spin(view_name: String) -> Resource:
	# The approved full-body rotation traverses real front/back/side anatomy.
	# Cardinal entry/contact mapping changes; no sideways body or detached head.
	var source: Resource = load(STUDY_DEST+"hop_spin.tres")
	var clip: Resource = source.duplicate(true)
	# Duplicate the raster image itself: resource duplication may share an image
	# cache, and clearing an identical source/target slot would erase that source.
	clip.body_atlas = ImageTexture.create_from_image(source.body_atlas.get_image().duplicate())
	clip.hand_atlas = ImageTexture.create_from_image(source.hand_atlas.get_image().duplicate())
	var keys: Array = [0,8,8,9,10,1,2,4,6,8,9,9,0,9,9,0] if view_name=="up" else [0,2,2,3,4,6,8,10,1,2,3,3,0,3,3,0]
	for key in 16: copy_dual_slot(clip,key,source,keys[key])
	return clip

func append_visibility(path: String,clip: Resource) -> void:
	var file := FileAccess.open(path,FileAccess.READ_WRITE)
	file.seek_end()
	file.store_string("primary_visible_poses = "+var_to_str(clip.primary_visible_poses)+"\n")

func build_v2_clip(view_name: String,cut: int,components: Array,density: float) -> Resource:
	var clip := Definition.new()
	clip.pose_count = 16 if cut>=0 else 8
	clip.pose_order = PackedInt32Array(range(clip.pose_count))
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]: clip.set(property,clip.get(property).slice(0,0))
	clip.weapon_texture = blade
	clip.weapon_primary_grip = Vector2(8,50)
	clip.weapon_tip = Vector2(8,0)
	clip.mirror_cutting_edge = false
	clip.allow_rest = cut==-1
	clip.phase_windows = PackedVector2Array([Vector2(0,3),Vector2(4,9),Vector2(10,12)]) if cut>=0 else PackedVector2Array([Vector2(0,3),Vector2(4,5),Vector2(6,7)])
	if cut>=0: clip.queued_recovery_window = Vector2(13,15)
	clip.offhand = Offhand.new()
	clip.offhand.texture = blade
	clip.offhand.grip = clip.weapon_primary_grip
	clip.offhand.tip = clip.weapon_tip
	var atlas := Image.create(768,128*ceili(clip.pose_count/4.0),false,Image.FORMAT_RGBA8)
	var mask := Image.create(atlas.get_width(),atlas.get_height(),false,Image.FORMAT_RGBA8)
	for key in clip.pose_count:
		var motion_key: int = SOURCE_KEYS[key] if cut>=0 else key
		var source_key := roundi(motion_key/7.0*(components.size()-1))
		if cut==-1 and key>=4: source_key = 4 # Folded stance stays fixed; only baked head changes.
		var part := preserve_raster_connections(components[source_key].image,density)
		var scalp_center := small_scalp_center(part)
		# Upper-body center drives run registration; each extended boot must not drag the torso sideways.
		var center_x: float = scalp_center if cut==-2 else foot_anchor(part).x
		var offset := Vector2i(Vector2(96-center_x,94-foot_anchor(part).y).round())
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),offset)
		quantize(body)
		var original := body.duplicate()
		var head_view := view_name
		if cut==3:
			head_view = (["up","side","down","left","left","up","up","up"] if view_name=="up" else ["down","left","up","side","side","down","down","down"])[motion_key]
		if cut==-1 and key in [5,6] and view_name!="up": head_view = ("down" if view_name=="side" else "left") if key==5 else "side"
		var reference: Dictionary = study_refs[head_view]
		var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var head := attach_back_head(body,reference.image,reference.head,foreground) if head_view=="up" else attach_head(body,reference.image,reference.head,head_view,foreground)
		if cut==-1 and view_name=="up" and key in [5,6]:
			var hair := body.get_region(head)
			body.fill_rect(head,Color.TRANSPARENT)
			head.position.x += -1 if key==5 else 1
			body.blit_rect(hair,Rect2i(Vector2i.ZERO,hair.get_size()),head.position)
		remove_specks(body)
		var planted := cut==-1 and key>=3
		var hands := glove_centers(body,head)
		var both_occluded := hands.size()<2 and view_name=="up" and cut>=0
		if hands.size()<2 and not planted and not both_occluded:
			body.save_png(V2_SOURCE+"grip_failure.png")
			push_error("Missing drawn palms: "+view_name+"/"+str(cut)+"/"+str(key))
			failed = true
			return clip
		var near: Vector2 = hands[0] if hands.size()>0 else Vector2(82,70)
		var far: Vector2 = hands[1] if hands.size()>1 else Vector2(110,70)
		if both_occluded:
			near = Vector2(head.get_center().x-6,head.end.y+6)
			far = near+Vector2(12,0)
			offhand_occluded = true
		var rotation := -90.0 if view_name=="up" else (90.0 if view_name=="down" else 0.0)
		var angle: float = STUDY_MAIN[cut][motion_key]+rotation if cut>=0 else (-110.0 if view_name=="up" else (110.0 if view_name=="down" else 5.0))
		var other_angle: float = STUDY_OFF[cut][motion_key]+rotation if cut>=0 else (-70.0 if view_name=="up" else (70.0 if view_name=="down" else -12.0))
		if cut==-1:
			angle = 90.0 if key>=3 else (150.0 if key==2 else (-90.0 if key==1 else -15.0))
			other_angle = 90.0 if key>=3 else (30.0 if key==2 else (-90.0 if key==1 else -165.0))
		if planted:
			# Detached resting blades touch the floor beside King; neither hilt is assigned to his folded arms.
			near = Vector2(72,44)
			far = Vector2(120,44)
			offhand_occluded = false
		elif not both_occluded: restore_source_forearms(body,original,head,[near] if offhand_occluded else [near,far])
		clip.primary_visible_poses.append(0 if both_occluded else 1)
		clip.primary_hands.append(near)
		clip.secondary_hands.append(near-Vector2.from_angle(deg_to_rad(angle))*7)
		clip.offhand.hands.append(far)
		clip.offhand.axes.append(far-Vector2.from_angle(deg_to_rad(other_angle))*7)
		clip.weapon_behind_body.append(1 if head_view=="up" else 0)
		clip.offhand.behind_body.append(1 if head_view=="up" or (view_name=="side" and cut==-2) else 0)
		clip.offhand.visible_poses.append(0 if offhand_occluded and not planted else 1)
		clip.single_hand_poses.append(1)
		clip.stowed_poses.append(0)
		clip.released_poses.append(1 if planted else 0)
		clip.ground_clipped_poses.append(0)
		clip.lift_pixels.append(([0.0,-4.0,-10.0,-10.0,-8.0,-6.0,-4.0,0.0][motion_key] if cut==3 else ([0.0,-3.0,-10.0,0.0,0.0,0.0,0.0,0.0][motion_key] if cut==4 else 0.0)))
		clip.identity_regions.append(Rect2(head))
		clip.pose_weights.append(1.0)
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		if not planted and not both_occluded:
			for grip in [near] if offhand_occluded else [near,far]:
				var rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
				foreground.blit_rect(body,rect,rect.position)
		mask.blit_rect(foreground,Rect2i(0,0,192,128),origin)
		audit.append({"view":view_name,"cut":cut,"key":key,"source_key":source_key,"density":density,"head_view":head_view,"head":var_to_str(head),"near":var_to_str(near),"far":var_to_str(far),"far_occluded":offhand_occluded,"released":planted})
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(mask)
	return clip

func build_vertical_effects(view_name: String) -> void:
	var source := Image.load_from_file(V2_SOURCE+"fx_"+view_name+"_source.png")
	var bands := effect_source_bands(source)
	if bands.size()!=4:
		push_error("Expected four complete vertical effect rows: "+view_name+str(bands))
		failed = true
		return
	var atlas := Image.create(768,960,false,Image.FORMAT_RGBA8)
	var side: Image = load(STUDY_DEST+"slash.png").get_image()
	for row in 4:
		var cells := complete_study_effect_cells(source,bands[row].x,bands[row].y)
		var span := Vector2i.ZERO
		for cell in cells: span = span.max(cell.get_size())
		var density := 144.0/maxi(span.x,span.y)
		var dest_row := row if row<3 else 4
		for key in 4:
			var cell: Image = cells[key]
			cell.resize(roundi(cell.get_width()*density),roundi(cell.get_height()*density),Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i(key*192+(192-cell.get_width())/2,dest_row*192+(192-cell.get_height())/2))
	# The authored spin ellipse stays in the floor's camera plane for every facing.
	atlas.blit_rect(side,Rect2i(0,3*192,768,192),Vector2i(0,3*192))
	atlas.save_png(V2_DEST+"slash_"+view_name+".png")

func glove_centers(body: Image,head: Rect2i) -> Array[Vector2]:
	# Connected brown glove regions above the belt/boots. Split an authored
	# touching pair at its two sides; never manufacture or paint a hand.
	offhand_occluded = false
	var visited := {}
	var parts: Array[Dictionary] = []
	for y in range(20,83):
		for x in range(60,135):
			var seed := Vector2i(x,y)
			if visited.has(seed) or not glove_pixel(body,seed,head): continue
			var todo: Array[Vector2i] = [seed]
			visited[seed] = true
			var low := seed
			var high := seed
			var cursor := 0
			while cursor<todo.size():
				var point := todo[cursor]
				cursor += 1
				low = low.min(point)
				high = high.max(point)
				for dy in range(-1,2):
					for dx in range(-1,2):
						var next := point+Vector2i(dx,dy)
						if next.x<60 or next.x>=135 or next.y<20 or next.y>=83 or visited.has(next) or not glove_pixel(body,next,head): continue
						visited[next] = true
						todo.append(next)
			# The leather belt is brown too. Its thin horizontal strip cannot
			# serve as a hilt, and the boot tops are below the glove band.
			if todo.size()>=5 and high.y-low.y>=2 and high.x-low.x>=2:
				var center := Vector2(low+high)*.5
				var nearest := todo[0]
				for point in todo:
					if Vector2(point).distance_squared_to(center)<Vector2(nearest).distance_squared_to(center): nearest=point
				parts.append({"point":Vector2(nearest),"pixels":todo,"size":todo.size(),"bounds":Rect2i(low,high-low+Vector2i.ONE)})
	parts.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.size>b.size)
	var result: Array[Vector2] = []
	if parts.size()>=2:
		result = [parts[0].point,parts[1].point]
	elif parts.size()==1 and parts[0].bounds.size.x>=10:
		var pixels: Array = parts[0].pixels
		pixels.sort_custom(func(a: Vector2i,b: Vector2i) -> bool: return a.x<b.x)
		result = [Vector2(pixels[pixels.size()/5]),Vector2(pixels[pixels.size()*4/5])]
	elif parts.size()==1:
		# Whole-body turning/raised-arm art can hide the far hand. Hide that
		# blade too, rather than attaching a visible blade to a belt or boot.
		offhand_occluded = true
		result = [parts[0].point,parts[0].point+Vector2(-10 if parts[0].point.x>96 else 10,0)]
	if not offhand_occluded: result.sort_custom(func(a: Vector2,b: Vector2) -> bool: return a.x<b.x)
	return result

func glove_pixel(body: Image,point: Vector2i,head: Rect2i) -> bool:
	if head.has_point(point) and point.y>=head.position.y+head.size.y*.4 and absf(point.x-head.get_center().x)<head.size.x*.3: return false
	var c := body.get_pixelv(point)
	return c.a>.65 and c.r>.18 and c.r<.79 and c.r>c.g*1.35 and c.g>c.b*1.25
