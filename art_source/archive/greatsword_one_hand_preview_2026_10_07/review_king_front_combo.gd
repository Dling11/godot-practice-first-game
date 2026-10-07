extends SceneTree

## Isolated Greatsword presentation. No Player, equipment grant or save service.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const PREVIEW := "res://assets/characters/playable/king/greatsword_front_combo_preview/"
const SOURCE := "res://art_source/generated/characters/king/greatsword_front_combo_2026_10_06/"
const IDLE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const RUN = preload("res://assets/characters/playable/king/greatsword_readability/side/run.tres")
const WIND := [0.20,0.16,0.18,0.26]
const CONTACT := [0.10,0.10,0.20,0.10]
const RECOVERY := [0.20,0.18,0.16,0.30]
const STEPS := [8.0,7.0,0.0,10.0]
const CUT_NAMES := ["1 FRONT SLASH / 120°","2 RETURN SLASH / 120°","3 FULL SPIN","4 JUMP STRIKE"]
const FX_PIVOTS := [Vector2(18,96),Vector2(18,96),Vector2(96,96),Vector2(20,96)]
const ZOOM := 3.0
var scene: Node2D
var group: Node2D
var presenter: Node2D
var effect: Sprite2D
var clips: Array[Resource] = []
var status: Label
var facing := 1
var elapsed := 0.0
var capturing := false
var previous_cut := -2
var previous_pose := -2
var held_keys := {}
var evidence: Array[Dictionary] = []
var assertions := 0
var failures: Array[String] = []
var registration: Dictionary
var references := {}

func _initialize() -> void:
	facing = -1 if OS.get_cmdline_user_args().has("--left") else 1
	capturing = OS.get_cmdline_user_args().has("--capture")
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(900,560)
	root.content_scale_size = Vector2i(900,560)
	root.title = "Battle of Gods | Greatsword front / return / spin / jump"
	RenderingServer.set_default_clear_color(Color("202b30"))
	scene = Node2D.new()
	root.add_child(scene)
	_load_clips()
	var layer := CanvasLayer.new()
	scene.add_child(layer)
	_label(layer,Vector2(24,16),22).text = "GREATSWORD — FRONT → RETURN → SPIN → JUMP"
	status = _label(layer,Vector2(24,50),15)
	_label(layer,Vector2(24,523),14).text = "SPACE replay · A/D facing · ESC close | 3x review scale · existing game preserved"
	group = Node2D.new()
	group.position = Vector2(450,360)
	group.scale = Vector2(ZOOM*facing,ZOOM)
	scene.add_child(group)
	effect = Sprite2D.new()
	effect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	effect.scale = Vector2.ONE*.5
	var atlas := AtlasTexture.new()
	atlas.atlas = load(PREVIEW+"slash.png")
	atlas.region = Rect2(0,0,192,192)
	effect.texture = atlas
	group.add_child(effect)
	var attack := MeleeAttackComponent.new()
	group.add_child(attack)
	presenter = Presenter.new()
	_check(presenter.configure(clips[0],attack,false),"shared presentation setup")
	presenter.scale = Vector2.ONE*.5
	presenter.position = Vector2(0,-16)
	group.add_child(presenter)
	var floor_mark := Line2D.new()
	floor_mark.points = PackedVector2Array([Vector2(-25,0),Vector2(25,0)])
	floor_mark.width = .5
	floor_mark.default_color = Color("405158")
	group.add_child(floor_mark)
	if not capturing:
		_sample(0)
		return
	var output := "res://art_source/review/combat/king_greatsword_front_combo_2026_10_06/"+("left/" if facing<0 else "")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output+"motion_frames/"))
	for frame in ceili((.8+_combo_seconds()+.5)*60):
		elapsed = frame/60.0
		var record := _sample(elapsed)
		_check_visible_bounds(presenter.weapon_sprite)
		if effect.visible: _check_visible_bounds(effect)
		await process_frame
		await RenderingServer.frame_post_draw
		var name := "motion_frames/frame_%03d.png" % frame
		_check(root.get_texture().get_image().save_png(output+name)==OK,"frame export")
		record["file"] = name
		record["elapsed_ms"] = roundi(elapsed*1000)
		evidence.append(record)
		if record.cut>=0 and record.phase=="CONTACT" and record.pose==7:
			root.get_texture().get_image().save_png(output+"cut_%d.png" % (record.cut+1))
	FileAccess.open(output+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t")+"\n")
	_key_pressed(KEY_A)
	_sample(1.05)
	_check(group.scale.x<0,"A selects left-facing review")
	_key_pressed(KEY_D)
	_sample(1.05)
	_check(group.scale.x>0,"D selects right-facing review")
	_key_pressed(KEY_SPACE)
	_check(elapsed==0,"Space resets review")
	FileAccess.open(output+"checks.json",FileAccess.WRITE).store_string(JSON.stringify({"assertions":assertions,"failures":failures,"frames":evidence.size(),"combo_seconds":_combo_seconds(),"contact_seconds":CONTACT,"mode":"deterministic native presentation; not gameplay or performance profiling"},"\t")+"\n")
	print("FRONT_COMBO_REVIEW assertions=",assertions," failures=",failures.size()," frames=",evidence.size())
	scene.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _load_clips() -> void:
	registration = JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"registration.json"))
	for view in ["side","left","up","down"]:
		var resource: Resource = IDLE if view in ["side","left"] else load("res://assets/characters/playable/king/greatsword_readability/"+view+"/idle.tres")
		var image: Image = resource.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		if view=="left": image.flip_x()
		references[view] = image.get_region(str_to_var(registration.reference_heads[view]))
	var first: Resource = load(PREVIEW+"front.tres")
	clips.append(first)
	clips.append_array(first.follow_up_clips)
	_check(clips.size()==4,"four requested moves only")
	for cut in clips.size():
		var clip: Resource = clips[cut]
		_check(clip.has_valid_layout(),"valid cut "+str(cut))
		_check(clip.weapon_texture.resource_path=="res://assets/characters/playable/king/huge_greatsword_proof/greatsword.png" and clip.weapon_texture.get_size()==Vector2(30,140),"exact canonical Greatsword")
		for key in clip.pose_count:
			var body: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			_check(body.get_pixelv(Vector2i(clip.primary_hands[key])).a>.65,"actual drawn glove")
			_check(body.get_used_rect().position.x>0 and body.get_used_rect().end.x<192 and body.get_used_rect().position.y>0 and body.get_used_rect().end.y<128,"complete body inside atlas cell")
			_check_anatomy(body,clip,key,registration.final_views[cut][key])
		if cut<3:
			var next: Resource = clips[cut+1]
			var last: Image = clip.body_atlas.get_image().get_region(Rect2i(3*192,3*128,192,128))
			var entry: Image = next.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
			_check(last.get_data()==entry.get_data() and clip.primary_hands[15]==next.primary_hands[0] and clip.secondary_hands[15]==next.secondary_hands[0],"exact connected boundary")
		if cut in [0,1]:
			for key in range(4,10):
				var angle: float = (clip.primary_hands[key]-clip.secondary_hands[key]).angle()
				_check(absf(angle)<=deg_to_rad(60.01),"strike confined to frontal120-degree sweep")
			var span := rad_to_deg((clip.primary_hands[9]-clip.secondary_hands[9]).angle()-(clip.primary_hands[4]-clip.secondary_hands[4]).angle())
			_check(is_equal_approx(span,120.0 if cut==0 else -120.0),"front / return opposite chronological sweep")
	var spin := clips[2]
	var total := 0.0
	for key in range(5,10):
		var before: float = (spin.primary_hands[key-1]-spin.secondary_hands[key-1]).angle()
		var after: float = (spin.primary_hands[key]-spin.secondary_hands[key]).angle()
		total += fposmod(after-before,TAU)
	_check(is_equal_approx(total,TAU),"spin completes360 degrees")
	_check(clips[3].lift_pixels[3]==-24 and clips[3].lift_pixels[6]==0,"jump has takeoff and grounded landing")

func _sample(time: float) -> Dictionary:
	var cut := -1
	var pose := 0
	var phase := "CARRY"
	var fx_key := -1
	var travel := 0.0
	var clip: Resource = IDLE
	if time>=.2 and time<.55:
		clip = RUN
		pose = int((time-.2)/.35*8)%8
		phase = "ACCEPTED SIDE WALK"
	elif time>=.8:
		var local := time-.8
		for index in 4:
			var duration: float = WIND[index]+CONTACT[index]+RECOVERY[index]
			if local<duration:
				cut = index
				clip = clips[cut]
				if local<WIND[index]:
					phase = "LOAD"
					pose = mini(3,int(local/WIND[index]*4))
				else:
					var active: float = local-WIND[index]
					travel += STEPS[index]*smoothstep(0,CONTACT[index],active)
					if active<CONTACT[index]:
						phase = "CONTACT"
						pose = mini(9,4+int(active/CONTACT[index]*6))
					else:
						phase = "FOLLOW THROUGH"
						pose = 13+mini(2,int((active-CONTACT[index])/RECOVERY[index]*3))
					if cut==2: fx_key = mini(3,int(active/.07)) if active<.28 else -1
					else: fx_key = 0 if active<.017 else 1 if active<.067 else 2 if active<.117 else 3 if active<.167 else -1
				break
			local -= duration
			travel += STEPS[index]
	if presenter.definition!=clip: presenter.select_clip(clip)
	if cut!=previous_cut or pose!=previous_pose: presenter.set_pose(pose)
	group.scale.x = ZOOM*facing
	group.position.x = 450+travel*ZOOM*facing
	effect.visible = fx_key>=0
	if fx_key>=0:
		var atlas: AtlasTexture = effect.texture
		atlas.region = Rect2(fx_key*192,cut*192,192,192)
		# Shared crop/scale keeps the broad front ribbon anchored at its hilt;
		# the spin instead turns around King's planted body pivot.
		var pivot: Vector2 = presenter.position+presenter.weapon_rig.position*.5
		if cut==2: pivot = Vector2(0,-12)
		effect.position = pivot-(FX_PIVOTS[cut]-Vector2(96,96))*.5
	previous_cut = cut
	previous_pose = pose
	status.text = ((CUT_NAMES[cut]+" · ") if cut>=0 else "")+phase+" · "+("RIGHT" if facing>0 else "LEFT")
	return {"cut":cut,"pose":pose,"phase":phase,"fx_key":fx_key,"travel":travel,"facing":facing}

func _process(delta: float) -> bool:
	if not capturing and scene!=null:
		for key in [KEY_ESCAPE,KEY_SPACE,KEY_A,KEY_D]:
			var pressed := Input.is_physical_key_pressed(key)
			if pressed and not held_keys.get(key,false): _key_pressed(key)
			held_keys[key] = pressed
		elapsed = fmod(elapsed+delta,.8+_combo_seconds()+.75)
		_sample(elapsed)
	return false

func _key_pressed(key: int) -> void:
	if key==KEY_ESCAPE: quit()
	elif key==KEY_SPACE: elapsed=0; previous_cut=-2; previous_pose=-2
	elif key in [KEY_A,KEY_D]:
		facing = -1 if key==KEY_A else 1
		elapsed=0; previous_cut=-2; previous_pose=-2

func _combo_seconds() -> float:
	var result := 0.0
	for index in 4: result += WIND[index]+CONTACT[index]+RECOVERY[index]
	return result

func _label(parent: Node,point: Vector2,font_size: int) -> Label:
	var label := Label.new()
	label.position = point
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",Color("d8e1df"))
	parent.add_child(label)
	return label

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		push_error(message)

func _check_visible_bounds(sprite: Sprite2D) -> void:
	var bounds := Rect2(sprite.texture.get_image().get_used_rect())
	if sprite.centered: bounds.position -= sprite.texture.get_size()*.5
	for point in [bounds.position,Vector2(bounds.end.x,bounds.position.y),bounds.end,Vector2(bounds.position.x,bounds.end.y)]:
		var screen: Vector2 = sprite.global_transform*point
		_check(screen.x>=0 and screen.y>=0 and screen.x<=900 and screen.y<=560,"no blade / effect crop at "+str(elapsed)+" / "+str(screen))

func _check_anatomy(body: Image,clip: Resource,key: int,view: String) -> void:
	var seed := Vector2i(clip.primary_hands[key])
	var visited := PackedByteArray()
	visited.resize(192*128)
	var todo := PackedInt32Array([seed.y*192+seed.x])
	visited[todo[0]] = 1
	var cursor := 0
	while cursor<todo.size():
		var id := todo[cursor]
		cursor += 1
		for dy in range(-1,2):
			for dx in range(-1,2):
				var point := Vector2i(id%192+dx,id/192+dy)
				if point.x<0 or point.x>=192 or point.y<0 or point.y>=128: continue
				var next := point.y*192+point.x
				if visited[next] or body.get_pixelv(point).a<.65: continue
				visited[next] = 1
				todo.append(next)
	var reference: Image = references[view]
	var head: Rect2 = clip.identity_regions[key]
	var matched := 0
	var expected := 0
	var connected := 0
	for y in reference.get_height():
		for x in reference.get_width():
			var pixel := reference.get_pixel(x,y)
			if pixel.a<.65: continue
			var point := Vector2i(head.position)+Vector2i(x,y)
			expected += 1
			if body.get_pixelv(point)==pixel: matched += 1
			if visited[point.y*192+point.x]: connected += 1
	_check(float(matched)/expected>=.85,"native head retained "+view+" pose "+str(key))
	_check(float(connected)/expected>=.85,"connected glove/body/head "+view+" pose "+str(key))
