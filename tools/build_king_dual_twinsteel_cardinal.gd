extends "res://tools/build_king_dual_twinsteel.gd"

## Offline front/back additions. Never rebuilds the accepted side or blade.
const CARDINAL_SOURCE := "res://art_source/generated/characters/king/dual_twinsteel_cardinal_2026_10_05/"
var view := ""
var reference_head := Rect2i()
var offhand_occluded := false

func _initialize() -> void:
	blade = load(OUTPUT+"twinsteel.png")
	var gait := extract_bodies(Image.load_from_file(CARDINAL_SOURCE+"gait_source.png"),4)
	for row in gait:
		if row.size()!=8:
			push_error("Cardinal gait needs eight complete bodies per row: "+str(row.size()))
			quit(1)
			return
	for direction in ["down","up"]:
		view = direction
		var folder := OUTPUT+view+"/"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
		var original: Resource = load("res://assets/characters/playable/king/greatsword_readability/"+view+"/idle.tres")
		identity = original.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		reference_head = hair_bounds(identity,red_center_y(identity)-2) if view=="up" else Rect2i(original.identity_source_region)
		palette.clear()
		color_cache.clear()
		for y in 128:
			for x in 192:
				var c := identity.get_pixel(x,y)
				if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
		var rows := extract_bodies(Image.load_from_file(CARDINAL_SOURCE+view+"_source.png"))
		for row in rows:
			if row.size()!=10:
				push_error("Cardinal attack needs ten complete bodies: "+view+" "+str(row.size()))
				quit(1)
				return
		var gait_row := 0 if view=="down" else 2
		var height: float = identity.get_used_rect().size.y
		var density: float = height/float(rows[0][0].image.get_height())
		var gait_density: float = height/float(gait[gait_row][0].image.get_height())
		var idle := build_cardinal_clip("idle",gait[gait_row],-1,gait_density)
		var run := build_cardinal_clip("run",gait[gait_row+1],-2,gait_density)
		var clips: Array[Resource] = []
		for cut in 5: clips.append(build_cardinal_clip(CUTS[cut],rows[cut],cut,density))
		if failed:
			quit(1)
			return
		for cut in 5:
			copy_dual_slot(clips[cut],0,idle if cut==0 else clips[cut-1],0 if cut==0 else 12)
			copy_dual_slot(clips[cut],9,idle,0)
			if cut==4: copy_dual_slot(clips[cut],12,idle,0)
			write_dual(CUTS[cut],clips[cut],CUTS.slice(1) if cut==0 else [],folder)
		write_dual("idle",idle,[],folder)
		write_dual("run",run,[],folder)
	FileAccess.open(CARDINAL_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("TWINSTEEL_CARDINAL_BUILD 100 attack +32 carry/run cels / 162 registered slots")
	quit()

func build_cardinal_clip(label: String,components: Array,cut: int,density: float) -> Resource:
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
		var offset := Vector2i((Vector2(96,94)-foot_anchor(image)).round())
		var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
		body.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
		quantize(body)
		var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
		var head := hair_bounds(body,red_center_y(body)-2)
		var drawn: Image = body.duplicate()
		var gloves := glove_centers(body,head)
		# Complete turning cels keep their matching face/torso. Other keys use
		# installed identity aligned to the drawn neck; back reference is hair only.
		if cut!=3:
			head = attach_back_head(body,identity,reference_head,foreground) if view=="up" else attach_head(body,identity,reference_head,view,foreground)
			# A raised glove can occlude the wider installed head. Restore only
			# its original brown anatomy at the registered fist, never old face art.
			for grip in gloves.slice(0,1) if offhand_occluded else gloves:
				for y in range(int(grip.y)-3,int(grip.y)+4):
					for x in range(int(grip.x)-3,int(grip.x)+4):
						var c := drawn.get_pixel(x,y)
						if c.a>.65 and c.r>.18 and c.r<.79 and c.r>c.g*1.35 and c.g>c.b*1.25: body.set_pixel(x,y,c)
		remove_specks(body)
		if gloves.size()<2:
			push_error("Two actual cardinal gloves missing: "+view+"/"+label+"/"+str(key)+" "+str(gloves))
			failed = true
			return clip
		var main: Vector2 = gloves[0]
		var off: Vector2 = gloves[1]
		var rotation := -90.0 if view=="up" else 90.0
		var main_angle: float = MAIN_ANGLES[cut][source_key]+rotation if cut>=0 else 175.0
		var off_angle: float = OFF_ANGLES[cut][source_key]+rotation if cut>=0 else 5.0
		clip.primary_hands.append(main)
		clip.secondary_hands.append(main-Vector2.from_angle(deg_to_rad(main_angle))*7)
		clip.offhand.hands.append(off)
		clip.offhand.axes.append(off-Vector2.from_angle(deg_to_rad(off_angle))*7)
		clip.offhand.behind_body.append(1 if view=="up" and cut>=0 and source_key in [3,4,5,6] else 0)
		clip.offhand.visible_poses.append(0 if offhand_occluded else 1)
		clip.pose_order.append(key)
		clip.lift_pixels.append([0.0,0.0,-4.0,-8.0,-6.0,0.0][key] if cut==4 and key<6 else 0.0)
		clip.weapon_behind_body.append(1 if view=="up" and cut>=0 and source_key in [3,4,5,6] else 0)
		clip.single_hand_poses.append(1)
		clip.stowed_poses.append(0)
		clip.released_poses.append(0)
		clip.ground_clipped_poses.append(0)
		clip.identity_regions.append(Rect2(head))
		clip.pose_weights.append(1.0)
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
		for grip in [main] if offhand_occluded else [main,off]:
			var rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,rect,origin+rect.position)
		audit.append({"view":view,"clip":label,"key":key,"source_key":source_key,"source_bounds":var_to_str(component.bounds),"density":density,"main_grip":var_to_str(main),"offhand_grip":var_to_str(off),"offhand_occluded":offhand_occluded,"head":var_to_str(head),"sole":var_to_str(foot_anchor(body))})
	clip.body_atlas = ImageTexture.create_from_image(atlas)
	clip.hand_atlas = ImageTexture.create_from_image(mask)
	return clip

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
