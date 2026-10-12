extends "res://tools/build_king_dual_v2_cardinal.gd"

## Offline reuse of approved complete bodies. No generated anatomy or resizing.
const Native = preload("res://tools/king_native_identity.gd")
const DownRegistration = preload("res://tools/king_down_body_registration.gd")
const DualGaitGrips = preload("res://tools/king_dual_gait_grips.gd")
const LIB := "res://assets/characters/playable/king/body_library/v1/"
const SHARED := "res://assets/characters/playable/king/shared_bodies/"
const ARCHIVE := "res://art_source/archive/king_body_consistency_before_2026_10_11/"
const REVIEW := "res://art_source/review/combat/king_body_consistency_2026_10_11/"
const GREAT := "res://data/weapons/families/royal_greatsword_v2/presentation.tres"
const AXE_PROFILE := "res://data/weapons/families/iron_beard/presentation.tres"
const DUAL_PROFILE := "res://data/weapons/families/twinsteel_v2/presentation.tres"
const CAMERAS := {"side":Vector2.RIGHT,"up":Vector2.UP,"down":Vector2.DOWN}
const AXE_CUT_NAMES := ["chop","rise","thrust","slam","spin"]
var native := Native.new()
var library_records: Dictionary = {}

func _initialize() -> void:
	_freeze_library()
	if failed: quit(1); return
	if "--freeze-only" in OS.get_cmdline_user_args(): print("KING_BODY_LIBRARY frozen complete approved poses"); quit(); return
	var axe := load(ARCHIVE+AXE_PROFILE.trim_prefix("res://")).duplicate(true)
	var dual := load(ARCHIVE+DUAL_PROFILE.trim_prefix("res://")).duplicate(true)
	for view in CAMERAS:
		var idle := _axe_idle(view)
		var gait := _gait(view,false)
		_assign(axe,view,"idle_poses",idle)
		_assign(axe,view,"running_poses",gait)
		var original: Resource = load(ARCHIVE+AXE_PROFILE.trim_prefix("res://")).attack_for(CAMERAS[view])
		var attacks: Array = [original]+Array(original.follow_up_clips)
		var ready_source: Resource = idle
		for index in attacks.size():
			var clip: Resource = attacks[index].duplicate(true)
			clip.follow_up_clips.clear()
			if view=="down": DownRegistration.apply(clip,"axe",index)
			# DOWN moves complete cels around the stance pivot, never body parts.
			# Other directions retain their approved contact/queue body pixels.
			if view=="down" and index>0: _copy_ready(clip,0,attacks[index-1],12)
			if index==0: _copy_ready(clip,0,ready_source)
			_copy_ready(clip,int(clip.phase_windows[2].y),ready_source)
			if index==4: _copy_ready(clip,clip.pose_count-1,ready_source)
			if view=="down": clip.identity_source_region=clip.identity_regions[0]
			native.save_clip(clip,SHARED+"axe/"+view+"/",AXE_CUT_NAMES[index],AXE_CUT_NAMES.slice(1) if index==0 else [])
			clip.take_over_path(SHARED+"axe/"+view+"/"+AXE_CUT_NAMES[index]+".tres")
			attacks[index]=clip
		attacks[0].follow_up_clips.assign(attacks.slice(1))
		_assign(axe,view,"attack_poses",attacks[0])
		_assign(dual,view,"running_poses",_gait(view,true))
	_polish_dual_down(dual)
	_save_profile(axe,AXE_PROFILE)
	_save_profile(dual,DUAL_PROFILE)
	_build_sword_frames()
	print("KING_SHARED_BODIES approved complete poses; all families share exact eight-frame gait; no body scaling")
	quit(1 if failed else 0)

func _freeze_library() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(LIB))
	var great: Resource = load(GREAT)
	for view in CAMERAS:
		for lane in ["ready","run"]:
			var clip: Resource = great.idle_for(CAMERAS[view]) if lane=="ready" else great.run_for(CAMERAS[view])
			var destination: String = LIB+view+"_"+lane+".tres"
			if not FileAccess.file_exists(destination):
				var frozen: Resource = clip.duplicate(true)
				native.save_clip(frozen,LIB,view+"_"+lane)
			var image: Image = clip.body_atlas.get_image()
			library_records[view+"_"+lane]={"source":clip.resource_path,"sha256":FileAccess.get_sha256(LIB+view+"_"+lane+"_body.png"),"first_body":str(image.get_region(Rect2i(0,0,192,128)).get_used_rect())}
	# The approved relaxed dual stance is a second complete pose, not a
	# regenerated torso. It shares the established scale/palette.
	for view in CAMERAS:
		var relaxed: Resource = load(ARCHIVE+DUAL_PROFILE.trim_prefix("res://")).idle_for(CAMERAS[view])
		if not FileAccess.file_exists(LIB+view+"_relaxed.tres"): native.save_clip(relaxed,LIB,view+"_relaxed")
		library_records[view+"_relaxed"]={"source":relaxed.resource_path,"sha256":FileAccess.get_sha256(LIB+view+"_relaxed_body.png")}
	var side_ready := LIB+"side_axe_ready_body.png"
	if not FileAccess.file_exists(side_ready):
		var source := load(LIB+"side_relaxed.tres") as Resource
		if source!=null:
			var sheet: Image = source.body_atlas.get_image().duplicate()
			for key in range(1,4):
				sheet.fill_rect(Rect2i(key*192,0,192,128),Color.TRANSPARENT)
				sheet.blit_rect(source.body_atlas.get_image(),Rect2i(0,0,192,128),Vector2i(key*192,0))
			sheet.save_png(side_ready)
	library_records["side_axe_ready"]={"source":LIB+"side_relaxed.tres; complete neutral cel repeated during ready phase","sha256":FileAccess.get_sha256(side_ready)}
	var contract := LIB+"contract.json"
	if not FileAccess.file_exists(contract):
		FileAccess.open(contract,FileAccess.WRITE).store_string(JSON.stringify({"version":1,"cell":[192,128],"scale":.5,"policy":"Reuse complete body PNGs. Weapon size and hand attachments never resize King. New motion requires a new reviewed pose; height alone is insufficient.","poses":library_records},"\t")+"\n")
	else:
		var frozen: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(contract))
		for id in frozen.poses:
			if not library_records.has(id) or library_records[id].sha256!=frozen.poses[id].sha256:
				push_error("Frozen King body modified: "+id+". Restore it or review a new library version."); failed=true

func _source(view: String,lane: String) -> Resource:
	# Provenance resources are immutable. They may carry a canonical weapon;
	# only their body, native head and source palm data define the library.
	return load(LIB+view+"_"+lane+".tres")

func _axe_idle(view: String) -> Resource:
	var old: Resource = load(ARCHIVE+AXE_PROFILE.trim_prefix("res://")).idle_for(CAMERAS[view])
	var clip: Resource = old.duplicate(true)
	var master := _source(view,"ready" if view=="up" else "relaxed")
	var atlas: Image = master.body_atlas.get_image().duplicate()
	if view=="side": atlas=load(LIB+"side_axe_ready_body.png").get_image()
	if view=="down":
		# Ready is a neutral complete body; drawing/planting cels are not idle.
		for key in range(1,4):
			atlas.fill_rect(Rect2i(key*192,0,192,128),Color.TRANSPARENT)
			atlas.blit_rect(master.body_atlas.get_image(),Rect2i(0,0,192,128),Vector2i(key*192,0))
	var masks := Image.create(atlas.get_width(),atlas.get_height(),false,Image.FORMAT_RGBA8)
	clip.identity_regions.clear()
	for key in 8:
		var body := atlas.get_region(Rect2i(key%4*192,key/4*128,192,128))
		var source_key: int = 0 if view!="up" and key<4 else key
		var head: Rect2 = master.identity_regions[source_key] if not master.identity_regions.is_empty() else Rect2(85,40,27,27)
		var grip: Vector2 = master.primary_hands[source_key]
		if key<4:
			grip=_real_palm(body,grip)
		else:
			# A back mount belongs to the shoulder, never the folded palm.
			grip=Vector2(head.get_center().x+5,head.end.y+2)
			clip.stowed_poses[key]=1
			clip.weapon_behind_body[key]=0 if view=="up" else 1
		clip.primary_hands[key]=grip
		var axis: Vector2 = (old.secondary_hands[key]-old.primary_hands[key]).normalized()
		if view=="down" and key<4:
			# Relaxed palm holds the axe outside the waist. The old central
			# two-hand angle crossed the face when moved onto a neutral body.
			axis=clip.weapon_handle_axis.normalized().rotated(deg_to_rad(-45))
			clip.weapon_behind_body[key]=1
		clip.secondary_hands[key]=grip+axis*7
		clip.identity_regions.append(head)
		if key<4:
			var box := Rect2i(Vector2i(grip.round())-Vector2i(3,3),Vector2i(7,7))
			var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
			masks.blit_rect(body,box,origin+box.position)
	clip.body_atlas=ImageTexture.create_from_image(atlas) if view=="down" else (load(LIB+"side_axe_ready_body.png") if view=="side" else master.body_atlas)
	clip.hand_atlas=ImageTexture.create_from_image(masks)
	clip.identity_source_region=clip.identity_regions[0]
	if view=="down":
		native.save_clip(clip,SHARED+"axe/down/","idle")
		clip.take_over_path(SHARED+"axe/down/idle.tres")
	else: _write_shared(clip,SHARED+"axe/"+view+"/","idle",LIB+view+("_axe_ready_body.png" if view=="side" else "_ready_body.png"))
	return clip

func _polish_dual_down(profile: Resource) -> void:
	var original: Resource = load(ARCHIVE+DUAL_PROFILE.trim_prefix("res://")).attack_for(Vector2.DOWN)
	var sources: Array = [original]+Array(original.follow_up_clips)
	var clips: Array[Resource] = []
	for step in 5:
		var clip: Resource = sources[step].duplicate(true)
		clip.follow_up_clips.clear()
		DownRegistration.apply(clip,"dual",step)
		_copy_ready(clip,0,profile.downward_idle_poses if step==0 else clips[step-1],0 if step==0 else 12)
		_copy_ready(clip,9,profile.downward_idle_poses,0)
		if step==4: _copy_ready(clip,12,profile.downward_idle_poses,0)
		clip.identity_source_region=clip.identity_regions[0]
		native.save_clip(clip,SHARED+"dual/down/",STUDY_NAMES[step],STUDY_NAMES.slice(1) if step==0 else [])
		clip.take_over_path(SHARED+"dual/down/"+STUDY_NAMES[step]+".tres")
		clips.append(clip)
	clips[0].follow_up_clips.assign(clips.slice(1))
	profile.downward_attack_poses=clips[0]

func _gait(view: String,dual: bool) -> Resource:
	var profile_path := DUAL_PROFILE if dual else AXE_PROFILE
	var old: Resource = load(ARCHIVE+profile_path.trim_prefix("res://")).run_for(CAMERAS[view])
	var clip: Resource = old.duplicate(true)
	var master := _source(view,"run")
	var bodies: Image = master.body_atlas.get_image()
	var masks := Image.create(bodies.get_width(),bodies.get_height(),false,Image.FORMAT_RGBA8)
	clip.identity_regions=master.identity_regions.duplicate()
	for key in 8:
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		var body := bodies.get_region(Rect2i(origin,Vector2i(192,128)))
		var grip: Vector2
		if dual:
			var palms := DualGaitGrips.palms(view,key)
			for palm in palms:
				var color := body.get_pixelv(Vector2i(palm))
				assert(color.a>.65 and color.r>.18 and color.r<.8 and color.r>color.g*1.35 and color.g>color.b*1.25,"Reviewed gait palm no longer matches frozen body: "+view+"/"+str(key))
			grip=palms[0]
			var far: Vector2 = palms[1]
			var main_angle := 10.0 if view=="side" else (110.0 if view=="down" else -110.0)
			var far_angle := -6.0 if view=="side" else (70.0 if view=="down" else -70.0)
			clip.secondary_hands[key]=grip-Vector2.from_angle(deg_to_rad(main_angle))*7
			clip.offhand.hands[key]=far; clip.offhand.axes[key]=far-Vector2.from_angle(deg_to_rad(far_angle))*7
			clip.offhand.behind_body[key]=1 if view=="side" or view=="up" else 0
			clip.offhand.visible_poses[key]=1
			clip.weapon_behind_body[key]=1 if view=="up" else 0
			var box := DualGaitGrips.glove_box(far)
			masks.blit_rect(body,box,origin+box.position)
		else:
			# A stowed axe follows the shoulder, never the moving empty palm.
			var head: Rect2 = master.identity_regions[key]
			grip=Vector2(head.get_center().x+5,head.end.y+2) if clip.stowed_poses[key]>0 else master.primary_hands[key]
			var axis: Vector2 = (old.secondary_hands[key]-old.primary_hands[key]).normalized()
			clip.secondary_hands[key]=grip+axis*7
		clip.primary_hands[key]=grip
		if dual or clip.stowed_poses[key]==0:
			var box := DualGaitGrips.glove_box(grip) if dual else Rect2i(Vector2i(grip.round())-Vector2i(3,3),Vector2i(7,7))
			masks.blit_rect(body,box,origin+box.position)
	clip.body_atlas=master.body_atlas; clip.hand_atlas=ImageTexture.create_from_image(masks)
	clip.identity_source_region=clip.identity_regions[0]
	# Keep the prior gait resources as immutable rollback/proof dependencies.
	var folder := SHARED+("dual_gait_v2/" if dual else "axe/")+view+"/"
	_write_shared(clip,folder,"run",LIB+view+"_run_body.png")
	return clip

func _write_shared(clip: Resource,folder: String,label: String,body_path: String) -> void:
	native.save_clip(clip,folder,label)
	var path := folder+label+".tres"
	var text := FileAccess.get_file_as_string(path).replace(folder+label+"_body.png",body_path)
	var output := FileAccess.open(path,FileAccess.WRITE)
	assert(output!=null,"Cannot write shared pose resource: "+path+" error="+str(FileAccess.get_open_error()))
	output.store_string(text)
	clip.take_over_path(path)
	# The body is shared by reference; remove only this newly-written duplicate.
	DirAccess.remove_absolute(ProjectSettings.globalize_path(folder+label+"_body.png"))

func _real_palm(body: Image,expected: Vector2) -> Vector2:
	var found := Vector2.ZERO
	var best := INF
	for y in range(maxi(0,roundi(expected.y)-6),mini(128,roundi(expected.y)+7)):
		for x in range(maxi(0,roundi(expected.x)-6),mini(192,roundi(expected.x)+7)):
			var c := body.get_pixel(x,y)
			if c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25:
				var distance := Vector2(x,y).distance_squared_to(expected)
				if distance<best: best=distance; found=Vector2(x,y)
	assert(found!=Vector2.ZERO,"Canonical body is missing the authored palm")
	return found

func _assign(profile: Resource,view: String,suffix: String,clip: Resource) -> void:
	profile.set(("upward_" if view=="up" else ("downward_" if view=="down" else ""))+suffix,clip)

func _copy_ready(clip: Resource,key: int,ready: Resource,source_key := 0) -> void:
	var bodies: Image = clip.body_atlas.get_image().duplicate()
	var hands: Image = clip.hand_atlas.get_image().duplicate()
	var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
	var rectangle := Rect2i(origin,Vector2i(192,128))
	bodies.fill_rect(rectangle,Color.TRANSPARENT); hands.fill_rect(rectangle,Color.TRANSPARENT)
	var source_box := Rect2i(source_key%4*192,source_key/4*128,192,128)
	bodies.blit_rect(ready.body_atlas.get_image(),source_box,origin)
	hands.blit_rect(ready.hand_atlas.get_image(),source_box,origin)
	clip.body_atlas=ImageTexture.create_from_image(bodies)
	clip.hand_atlas=ImageTexture.create_from_image(hands)
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		var values = clip.get(property).duplicate()
		values[key]=ready.get(property)[source_key]; clip.set(property,values)
	if not clip.occluded_hand_poses.is_empty(): clip.occluded_hand_poses[key]=1 if ready.hands_are_occluded(source_key) else 0
	if not clip.identity_regions.is_empty(): clip.identity_regions[key]=ready.identity_regions[source_key]
	if clip.offhand!=null:
		for property in ["hands","axes","behind_body","visible_poses"]:
			var values = clip.offhand.get(property).duplicate()
			values[key]=ready.offhand.get(property)[source_key]; clip.offhand.set(property,values)

func _save_profile(profile: Resource,path: String) -> void:
	assert(profile.is_valid_profile(),"Shared body profile invalid")
	var original: Resource = load(ARCHIVE+path.trim_prefix("res://"))
	var text := FileAccess.get_file_as_string(ARCHIVE+path.trim_prefix("res://"))
	for view in CAMERAS:
		for suffix in ["attack_poses","idle_poses","running_poses"]:
			var field: String = ("upward_" if view=="up" else ("downward_" if view=="down" else ""))+suffix
			text=text.replace(original.get(field).resource_path,profile.get(field).resource_path)
	# Rebuilds must not rewrite unchanged selectors under the editor watcher.
	if FileAccess.get_file_as_string(path)==text: return
	var temporary := path+".tmp"
	var file := FileAccess.open(temporary,FileAccess.WRITE)
	if file==null:
		push_error("Cannot write shared family selection: "+path+" error="+str(FileAccess.get_open_error()))
		failed=true
		return
	file.store_string(text)
	file.close()
	var result := DirAccess.rename_absolute(ProjectSettings.globalize_path(temporary),ProjectSettings.globalize_path(path))
	if result!=OK:
		push_error("Cannot replace shared family selection: "+path+" error="+str(result))
		failed=true

func _build_sword_frames() -> void:
	var original_path := "res://assets/characters/playable/king/spellward/spellward_frames.tres"
	var original_frames: SpriteFrames = load(original_path)
	var text := FileAccess.get_file_as_string(original_path)
	# This is a distinct resource; never duplicate the legacy frames UID.
	var uid := RegEx.new(); uid.compile(' uid="[^"]+"')
	text=uid.sub(text,"",false)
	var external := ""
	var subresources := ""
	var added := 0
	var steel: Image = load("res://assets/ui/inventory/king_sword_64.png").get_image()
	var grip := Vector2(10,53)
	var handle_axis := Vector2(-1,1)
	var steel_scale := .55
	for view in CAMERAS:
		for lane in ["idle","walk"]:
			var master := _source(view,"ready" if lane=="idle" else "run")
			var count := 2 if lane=="idle" else 8
			var atlas := Image.create(192*count,128,false,Image.FORMAT_RGBA8)
			for key in count:
				# Greatsword ready key1 starts its planted-rest action. A normal
				# sword's two-frame stand must not loop that reach motion.
				var body_key: int = 0 if lane=="idle" else key
				var body: Image = master.body_atlas.get_image().get_region(Rect2i(body_key%4*192,body_key/4*128,192,128))
				var angle: float = (master.secondary_hands[body_key]-master.primary_hands[body_key]).angle()-handle_axis.angle()
				var basis := Transform2D(angle,master.primary_hands[body_key])
				var composed := Image.create(192,128,false,Image.FORMAT_RGBA8)
				for y in 128:
					for x in 192:
						var pixel := Vector2i((grip+basis.affine_inverse()*Vector2(x,y)/steel_scale).round())
						if Rect2i(0,0,64,64).has_point(pixel) and steel.get_pixelv(pixel).a>.5: composed.set_pixel(x,y,steel.get_pixelv(pixel))
				composed.blend_rect(body,Rect2i(0,0,192,128),Vector2i.ZERO)
				atlas.blit_rect(composed,Rect2i(0,0,192,128),Vector2i(key*192,0))
			var path: String = SHARED+"sword/"+view+"_"+lane+".png"
			DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(SHARED+"sword/"))
			atlas.save_png(path)
			var left_path: String = SHARED+"sword/left_"+lane+".png"
			if view=="side":
				var left := Image.create(atlas.get_width(),128,false,Image.FORMAT_RGBA8)
				for key in count:
					var mirrored := atlas.get_region(Rect2i(key*192,0,192,128))
					mirrored.flip_x()
					left.blit_rect(mirrored,Rect2i(0,0,192,128),Vector2i(key*192,0))
				left.save_png(left_path)
			var directions: Array = ["right","left"] if view=="side" else [view]
			for direction in directions:
				var animation := StringName(lane+"_"+direction)
				var id: String = "KingBody_"+str(animation)
				external+='[ext_resource type="Texture2D" path="%s" id="%s"]\n'%[left_path if direction=="left" else path,id]
				added+=1
				var block := '{\n"frames": ['
				for key in count:
					var cel_id: String = id+"_"+str(key)
					subresources+='[sub_resource type="AtlasTexture" id="%s"]\natlas = ExtResource("%s")\nregion = Rect2(%d,0,192,128)\nfilter_clip = true\n\n'%[cel_id,id,key*192]
					block+=(', ' if key else '')+'{\n"duration": 1.0,\n"texture": SubResource("%s")\n}'%cel_id
					added+=1
				var speed: float = original_frames.get_animation_speed("walk_right") if lane=="walk" else original_frames.get_animation_speed(animation)
				block+='],\n"loop": 1,\n"name": &"%s",\n"speed": %s\n}'%[animation,str(speed)]
				var regex := RegEx.new()
				regex.compile('\\{\\n"frames": \\[[^\\]]*\\],\\n"loop": [01],\\n"name": &"'+str(animation)+'",\\n"speed": [^\\n]+\\n\\}')
				assert(regex.search(text)!=null,"Missing original locomotion animation")
				text=regex.sub(text,block,false)
	var first_sub := text.find("[sub_resource")
	text=text.insert(first_sub,external+"\n")
	text=text.replace("[resource]",subresources+"[resource]")
	var header := RegEx.new(); header.compile("load_steps=(\\d+)")
	var match := header.search(text)
	if match!=null: text=header.sub(text,"load_steps="+str(int(match.get_string(1))+added),false)
	FileAccess.open(SHARED+"sword/frames.tres",FileAccess.WRITE).store_string(text)
