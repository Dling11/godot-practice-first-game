extends "res://tools/build_king_oathbound_greatsword.gd"

## Offline raster ingestion only. Shared helpers protect native anatomy/palette.
## Never invokes the Greatsword builder or writes into any other family.
const AXE_SOURCE := "res://art_source/generated/characters/king/axe_cardinal_2026_10_06/"
const AXE_DEST := "res://assets/characters/playable/king/axe_cardinal/"
const AXE = preload("res://assets/characters/playable/king/axe_proof/iron_beard.png")
const CUTS := ["sweep","rise","chop","slam","spin"]
const FRONT_GUIDES := [
	[Vector2(.70,.59),Vector2(.30,.58),Vector2(.85,.48),Vector2(.12,.48),Vector2(.80,.58),Vector2(.78,.60),Vector2(.65,.70),Vector2(.87,.63)],
	[Vector2(.25,.80),Vector2(.30,.68),Vector2(.70,.29),Vector2(.63,.07),Vector2(.65,.11),Vector2(.30,.33),Vector2(.25,.58),Vector2(.86,.60)],
	[Vector2(.57,.09),Vector2(.60,.14),Vector2(.60,.68),Vector2(.58,.73),Vector2(.58,.72),Vector2(.58,.72),Vector2(.58,.72),Vector2(.86,.60)],
	[Vector2(.58,.69),Vector2(.62,.48),Vector2(.58,.08),Vector2(.59,.74),Vector2(.60,.75),Vector2(.80,.75),Vector2(.20,.57),Vector2(.86,.60)],
	[Vector2(.15,.49),Vector2(.15,.24),Vector2(.10,.54),Vector2(.65,.53),Vector2(.25,.60),Vector2(.83,.47),Vector2(.80,.71),Vector2(.86,.60)],
]
const BACK_GUIDES := [
	[Vector2(.26,.48),Vector2(.90,.44),Vector2(.91,.42),Vector2(.10,.24),Vector2(.80,.39),Vector2(.86,.43),Vector2(.86,.43),Vector2(.85,.65)],
	[Vector2(.20,.65),Vector2(.30,.60),Vector2(.73,.33),Vector2(.65,.07),Vector2(.75,.06),Vector2(.86,.31),Vector2(.87,.42),Vector2(.85,.65)],
	[Vector2(.63,.08),Vector2(.48,.08),Vector2(.79,.34),Vector2(.91,.44),Vector2(.85,.44),Vector2(.90,.57),Vector2(.89,.57),Vector2(.85,.65)],
	[Vector2(.18,.55),Vector2(.34,.09),Vector2(.67,.08),Vector2(.65,.07),Vector2(.51,.12),Vector2(.87,.58),Vector2(.86,.58),Vector2(.85,.65)],
	[Vector2(.90,.43),Vector2(.25,.69),Vector2(.20,.74),Vector2(.13,.44),Vector2(.20,.50),Vector2(.18,.24),Vector2(.20,.59),Vector2(.85,.65)],
]
## Angles describe the outward blade sweep, rotated for the actual facing.
const CUT_ANGLES := [
	[-60,-85,-65,-25,25,65,45,25],
	[65,65,45,15,-25,-65,-35,25],
	[-90,-80,-35,0,20,40,40,25],
	[25,-35,-80,-65,-20,15,30,25],
	[-100,-140,-100,-25,60,145,230,25],
]
var axe_audit: Array[Dictionary] = []

func _initialize() -> void:
	var front_rows := extract_bodies(Image.load_from_file(AXE_SOURCE+"down_body_source.png"))
	if not _check_rows(front_rows,"down"): quit(1); return
	# A single source density, from the standing cel, for both complete sheets.
	var density: float = 54.0/float(front_rows[0][7].image.get_height())
	for facing in ["down","up"]:
		build_axe_direction(facing,density)
		if failed: quit(1); return
	FileAccess.open(AXE_SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"density":density,"sole_y":94,"body_cells":[192,128],"source_cels":80,"records":axe_audit},"\t")+"\n")
	print("AXE_CARDINAL registered80 source attack cels +32 idle/run keys; native gaits; density=",density)
	quit()

func _check_rows(rows: Array,direction: String) -> bool:
	for row in rows.size():
		if rows[row].size()!=8:
			push_error("Axe "+direction+" row"+str(row)+" requires8 complete bodies; found "+str(rows[row].size()))
			failed = true
	return not failed

func build_axe_direction(direction: String,density: float) -> void:
	var rows := extract_bodies(Image.load_from_file(AXE_SOURCE+direction+"_body_source.png"))
	if not _check_rows(rows,direction): return
	var folder := AXE_DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var native: Resource = load("res://assets/characters/playable/king/dual_twinsteel/"+direction+"/idle.tres")
	var reference: Image = native.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var head := Rect2i(84,41,24,24) if direction=="down" else hair_bounds(reference,red_center_y(reference)-2)
	palette.clear()
	color_cache.clear()
	for y in 128:
		for x in 192:
			var c := reference.get_pixel(x,y)
			if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	var clips: Array[Resource] = []
	var body_sets: Array[Array] = []
	var hand_sets: Array[Array] = []
	for cut in 5:
		var clip := _new_axe_clip()
		clip.phase_windows = PackedVector2Array([Vector2(0,1),Vector2(2,5),Vector2(6,7)])
		clip.identity_source_region = Rect2(head)
		var bodies: Array[Image] = []
		var hands: Array[Image] = []
		for key in 8:
			var source: Image = rows[cut][key].image
			var scaled := source.duplicate()
			scaled.resize(maxi(1,roundi(source.get_width()*density)),maxi(1,roundi(source.get_height()*density)),Image.INTERPOLATE_NEAREST)
			var sole := foot_anchor(scaled)
			var offset := Vector2i(roundi(96-sole.x),roundi(94-sole.y))
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(scaled,Rect2i(Vector2i.ZERO,scaled.get_size()),offset)
			quantize(body)
			var mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
			var placed := attach_back_head(body,reference,head,mask) if direction=="up" else _attach_axe_front_head(body,reference,head,mask)
			if failed: return
			remove_specks(body)
			# Removing a stray source speck can change the last boot scanline.
			# Ground the completed silhouette, including head/mask, afterward.
			var sole_shift := 94-roundi(foot_anchor(body).y)
			if sole_shift!=0:
				var grounded := Image.create(192,128,false,Image.FORMAT_RGBA8)
				grounded.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,sole_shift))
				body=grounded
				var grounded_mask := Image.create(192,128,false,Image.FORMAT_RGBA8)
				grounded_mask.blit_rect(mask,Rect2i(0,0,192,128),Vector2i(0,sole_shift))
				mask=grounded_mask
				placed.position.y+=sole_shift
				offset.y+=sole_shift
			var guide: Vector2 = (BACK_GUIDES if direction=="up" else FRONT_GUIDES)[cut][key]
			var expected := Vector2(offset)+guide*Vector2(scaled.get_size())
			var grip := find_glove(body,expected,placed,12)
			if grip==Vector2.ZERO: grip = find_glove(body,expected,placed,20)
			if grip==Vector2.ZERO:
				push_error("Missing connected axe glove "+direction+" "+str(cut)+"/"+str(key)); failed=true; return
			var angle: float = float(CUT_ANGLES[cut][key])+(-90.0 if direction=="up" else 90.0)
			# Above-head fists lift the axe head above the crown in both views.
			# A screen-facing rotation here would lay the haft across his scalp.
			if (cut==2 and key<2) or (cut==3 and key>=1 and key<=3): angle=-90.0
			# The airborne hop is explicit; sole registration introduces no lift.
			clip.lift_pixels[key] = [0.0,-5.0,-11.0,-7.0,0.0,0.0,0.0,0.0][key] if cut==3 else 0.0
			_register_axe_pose(clip,key,grip,angle,direction=="up")
			clip.identity_regions.append(Rect2(placed))
			var glove_rect := Rect2i(Vector2i(grip)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,glove_rect,glove_rect.position)
			bodies.append(body)
			hands.append(mask)
			axe_audit.append({"direction":direction,"cut":cut,"key":key,"source_bounds":var_to_str(rows[cut][key].bounds),"body_bounds":var_to_str(body.get_used_rect()),"head":var_to_str(placed),"grip":var_to_str(grip),"guide":var_to_str(expected),"sole":var_to_str(foot_anchor(body))})
		clips.append(clip)
		body_sets.append(bodies)
		hand_sets.append(hands)
	# Holding guard is the actual opening fist/body, not a different costume.
	var idle := _new_axe_clip()
	idle.identity_source_region = Rect2(head)
	var idle_bodies: Array[Image] = []
	var idle_hands: Array[Image] = []
	for key in 8:
		if key<4:
			idle_bodies.append(body_sets[0][0])
			idle_hands.append(hand_sets[0][0])
			_register_axe_pose(idle,key,clips[0].primary_hands[0],115 if direction=="down" else -65,direction=="up")
			idle.identity_regions.append(clips[0].identity_regions[0])
		elif key<6:
			idle_bodies.append(body_sets[2][0])
			idle_hands.append(hand_sets[2][0])
			_register_axe_pose(idle,key,clips[2].primary_hands[0],225,direction=="down")
			idle.identity_regions.append(clips[2].identity_regions[0])
		else:
			idle_bodies.append(reference)
			idle_hands.append(Image.create(192,128,false,Image.FORMAT_RGBA8))
			_register_axe_pose(idle,key,Vector2(101,69),-120,direction=="down")
			idle.stowed_poses[key]=1
			idle.identity_regions.append(Rect2(head))
	# Each released cut returns to exactly the same held guard.
	for cut in 5:
		body_sets[cut][7] = idle_bodies[0]
		hand_sets[cut][7] = idle_hands[0]
		clips[cut].primary_hands[7] = idle.primary_hands[0]
		clips[cut].secondary_hands[7] = idle.secondary_hands[0]
		clips[cut].identity_regions[7] = idle.identity_regions[0]
		_write_axe_clip(folder,CUTS[cut],clips[cut],body_sets[cut],hand_sets[cut],CUTS.slice(1) if cut==0 else [])
	_write_axe_clip(folder,"idle",idle,idle_bodies,idle_hands,[])
	# Reuse the complete accepted native gait. Travel, not time, advances it.
	var gait: Resource = load("res://assets/characters/playable/king/dual_twinsteel/"+direction+"/run.tres")
	var running := _new_axe_clip()
	var run_bodies: Array[Image] = []
	var run_hands: Array[Image] = []
	for key in 8:
		run_bodies.append(gait.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128)))
		run_hands.append(Image.create(192,128,false,Image.FORMAT_RGBA8))
		var bob: int = [0,1,0,-1,0,1,0,-1][key]
		_register_axe_pose(running,key,Vector2(101,69+bob),-120,direction=="down")
		running.stowed_poses[key]=1
	_write_axe_clip(folder,"run",running,run_bodies,run_hands,[])

func _new_axe_clip() -> Resource:
	var clip := Definition.new()
	clip.weapon_texture=AXE
	clip.weapon_primary_grip=Vector2(39,33)
	clip.weapon_handle_axis=Vector2(4,10)
	clip.mirror_cutting_edge=false
	clip.single_hand_poses=PackedByteArray([1,1,1,1,1,1,1,1])
	return clip

func _attach_axe_front_head(body: Image,reference: Image,head: Rect2i,foreground: Image) -> Rect2i:
	# Scarf tails are asymmetric. Keep the native face on the drawn crown axis;
	# matching the reference's leftmost red pixel displaced it toward one arm.
	var original: Image = body.duplicate()
	var scalp := hair_bounds(body,red_center_y(body)-2)
	var socket := nearest_crimson(body,Vector2(scalp.get_center().x,scalp.end.y+2),Rect2i(scalp.position.x-3,scalp.end.y-2,scalp.size.x+6,12))
	var native_socket := nearest_crimson(reference,Vector2(head.get_center().x,head.end.y-1),head)
	if socket==Vector2i(-1,-1) or native_socket==Vector2i(-1,-1):
		push_error("Missing axe front neck landmark"); failed=true; return head
	# A leaning source face can extend below the nearest scarf pixel. Align
	# the complete chin as well, otherwise the old mouth survives below it.
	var drawn_chin := _face_bottom(body,Rect2i(scalp.position.x+roundi(scalp.size.x*.25),scalp.end.y-6,roundi(scalp.size.x*.5),18),Vector2(scalp.get_center().x,scalp.end.y+2))
	var native_chin := _face_bottom(reference,head,Vector2(head.get_center().x,head.end.y-5))
	var shift_y := socket.y-native_socket.y if drawn_chin<0 or native_chin<0 else drawn_chin-native_chin
	var destination := Vector2i(roundi(scalp.get_center().x-head.size.x*.5),head.position.y+shift_y)
	var erase := Rect2i(scalp.position,Vector2i(scalp.size.x,maxi(scalp.size.y,maxi(socket.y,drawn_chin+1)-scalp.position.y)))
	for y in range(erase.position.y,erase.end.y):
		for x in range(erase.position.x,erase.end.x):
			var color := body.get_pixel(x,y)
			if is_crimson(color): continue
			var fist := color.r>.18 and color.r<.8 and color.r>color.g*1.35 and color.g>color.b*1.25
			if y>=scalp.end.y-2 and (color.b>color.r+.005 or (fist and absf(x-scalp.get_center().x)>scalp.size.x*.35)): continue
			body.set_pixel(x,y,Color.TRANSPARENT)
	body.blend_rect(reference,head,destination)
	# Genuine raised fists, unlike old face pixels, can overlap the crown.
	for y in range(scalp.position.y,roundi(scalp.position.y+scalp.size.y*.4)):
		for x in range(scalp.position.x,scalp.end.x):
			var c := original.get_pixel(x,y)
			if c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25:
				body.set_pixel(x,y,c)
				foreground.set_pixel(x,y,c)
	return Rect2i(destination,head.size)

func _face_bottom(image: Image,region: Rect2i,expected: Vector2) -> int:
	var seed := Vector2i(-1,-1)
	var distance := INF
	for y in range(maxi(0,region.position.y),mini(image.get_height(),region.end.y)):
		for x in range(maxi(0,region.position.x),mini(image.get_width(),region.end.x)):
			if not _face_shade(image.get_pixel(x,y)): continue
			var delta := Vector2(x,y).distance_squared_to(expected)
			if delta<distance: seed=Vector2i(x,y); distance=delta
	if seed==Vector2i(-1,-1): return -1
	# Brown glove highlights can share skin colors. Follow only the actual
	# face component under the crown, separated from gloves by scarf/cuffs.
	var queue: Array[Vector2i] = [seed]
	var visited := {seed:true}
	var cursor := 0
	var bottom := seed.y
	while cursor<queue.size():
		var p := queue[cursor]
		cursor+=1
		bottom=maxi(bottom,p.y)
		for dy in range(-1,2):
			for dx in range(-1,2):
				var next := p+Vector2i(dx,dy)
				if visited.has(next) or not region.has_point(next) or not _face_shade(image.get_pixelv(next)): continue
				visited[next]=true
				queue.append(next)
	return bottom

func _face_shade(c: Color) -> bool:
	return c.a>.65 and c.r>.78 and c.g>.40 and c.b>.25 and c.b/c.g>.58 and c.r>c.g*1.15

func _register_axe_pose(clip: Resource,key: int,grip: Vector2,heading: float,behind: bool) -> void:
	clip.primary_hands.append(grip)
	clip.secondary_hands.append(grip-Vector2.from_angle(deg_to_rad(heading))*7)
	clip.weapon_behind_body[key]=1 if behind else 0

func _write_axe_clip(folder: String,label: String,clip: Resource,bodies: Array,hands: Array,followups: Array) -> void:
	var atlas := Image.create(768,256,false,Image.FORMAT_RGBA8)
	var mask := Image.create(768,256,false,Image.FORMAT_RGBA8)
	for key in 8:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		atlas.blit_rect(bodies[key],Rect2i(0,0,192,128),origin)
		mask.blit_rect(hands[key],Rect2i(0,0,192,128),origin)
	if atlas.save_png(folder+label+"_body.png")!=OK or mask.save_png(folder+label+"_hands.png")!=OK: failed=true; return
	clip.body_atlas=ImageTexture.create_from_image(atlas)
	clip.hand_atlas=ImageTexture.create_from_image(mask)
	if not clip.has_valid_layout(): push_error("Invalid axe clip "+folder+label); failed=true; return
	var output := "[gd_resource type=\"Resource\" load_steps="+str(5+followups.size())+" format=3]\n"
	for i in 4:
		var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",AXE.resource_path]
		output+="[ext_resource type=\""+("Script" if i==0 else "Texture2D")+"\" path=\""+paths[i]+"\" id=\""+str(i+1)+"\"]\n"
	for i in followups.size(): output+="[ext_resource type=\"Resource\" path=\""+folder+followups[i]+".tres\" id=\""+str(i+5)+"\"]\n"
	output+="[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in ["pose_count","pose_order","primary_hands","secondary_hands","weapon_primary_grip","weapon_handle_axis","mirror_cutting_edge","phase_windows","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","lift_pixels","identity_regions","identity_source_region","allow_rest"]:
		output+=property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		output+="follow_up_clips = Array[Resource](["
		for i in followups.size(): output+=("," if i>0 else "")+"ExtResource(\""+str(i+5)+"\")"
		output+="])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(output)
