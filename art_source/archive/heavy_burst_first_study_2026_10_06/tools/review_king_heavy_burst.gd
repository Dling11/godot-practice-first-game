extends SceneTree

## Deterministic presentation study: no Player, save, inventory or damage mutation.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const PREVIEW := "res://assets/characters/playable/king/heavy_burst_preview/"
const IDLE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const RUN = preload("res://assets/characters/playable/king/greatsword_readability/side/run.tres")
const WIND := [0.14,0.12,0.19,0.12,0.12]
const CONTACT := 4.0/60.0
const RECOVERY := [0.16,0.16,0.22,0.16,0.18]
const STEPS := [10.0,9.0,14.0,10.0,10.0]
const CUT_NAMES := ["1 DESCENDING CUT","2 RISING RETURN","3 HOP SLAM","4 DIAGONAL CUT","5 RETURN STROKE"]
const FX_TIPS := [
	[Vector2(106,110),Vector2(118,112),Vector2(117,86),Vector2(116,106)],
	[Vector2(111,48),Vector2(112,17),Vector2(116,10),Vector2(116,40)],
	[Vector2(104,116),Vector2(117,117),Vector2(100,116),Vector2(118,116)]
]
const ZOOM := 2.4
var scene: Node2D
var presenters: Array[Node2D] = []
var groups: Array[Node2D] = []
var effects: Array[Sprite2D] = []
var clips: Array[Resource] = []
var carry: Resource
var title: Label
var status: Label
var scythe := false
var elapsed := 0.0
var capturing := false
var previous_cut := -2
var previous_pose := -2
var evidence: Array[Dictionary] = []
var held_keys := {}
var assertions := 0
var failures: Array[String] = []

func _initialize() -> void:
	scythe = OS.get_cmdline_user_args().has("--scythe")
	capturing = OS.get_cmdline_user_args().has("--capture")
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1000,520)
	root.content_scale_size = Vector2i(1000,520)
	root.title = "Battle of Gods | Heavy burst motion study"
	RenderingServer.set_default_clear_color(Color("202b30"))
	scene = Node2D.new()
	root.add_child(scene)
	_load_clips()
	var layer := CanvasLayer.new()
	scene.add_child(layer)
	title = _label(layer,Vector2(20,14),20)
	title.text = ("SCYTHE — silhouette / motion study" if scythe else "GREATSWORD — heavy burst study")
	status = _label(layer,Vector2(20,46),14)
	_label(layer,Vector2(20,486),13).text = "SPACE replay   TAB weapon study   ESC close | Enlarged 2.4x • current gameplay unchanged"
	for side in 2:
		_label(layer,Vector2(165+side*550,82),13).text = "RIGHT" if side==0 else "LEFT"
		var group := Node2D.new()
		group.position = Vector2(240 if side==0 else 760,310)
		group.scale = Vector2(ZOOM*(1 if side==0 else -1),ZOOM)
		scene.add_child(group)
		groups.append(group)
		var fx := Sprite2D.new()
		var fx_atlas := AtlasTexture.new()
		fx_atlas.atlas = load(PREVIEW+"slash.png")
		fx_atlas.region = Rect2(0,0,128,128)
		fx.texture = fx_atlas
		fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		fx.scale = Vector2.ONE*.5
		fx.position = Vector2(30,-28)
		group.add_child(fx)
		effects.append(fx)
		var attack := MeleeAttackComponent.new()
		group.add_child(attack)
		var body := Presenter.new()
		_check(body.configure(clips[0],attack,false),"valid shared presenter setup")
		body.scale = Vector2.ONE*.5
		body.position = Vector2(0,-16)
		group.add_child(body)
		presenters.append(body)
		var floor_mark := Line2D.new()
		floor_mark.points = PackedVector2Array([Vector2(-28,0),Vector2(28,0)])
		floor_mark.width = .5
		floor_mark.default_color = Color("405158")
		group.add_child(floor_mark)
	if not capturing:
		_sample(0)
		return
	var output := "res://art_source/review/combat/king_"+("scythe" if scythe else "greatsword")+"_heavy_burst_2026_10_06/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output+"motion_frames/"))
	var total := 0.8+_combo_seconds()+.5
	for frame in ceili(total*60):
		elapsed = frame/60.0
		var record := _sample(elapsed)
		for body in presenters: _check_visible_bounds(body.weapon_sprite)
		for effect in effects:
			if effect.visible: _check_visible_bounds(effect)
		await process_frame
		await RenderingServer.frame_post_draw
		var name := "motion_frames/frame_%03d.png" % frame
		_check(root.get_texture().get_image().save_png(output+name)==OK,"frame export")
		record["file"] = name
		record["elapsed_ms"] = roundi(elapsed*1000)
		evidence.append(record)
		if record.cut>=0 and record.phase=="CONTACT" and record.pose==4:
			root.get_texture().get_image().save_png(output+"cut_%d.png" % (record.cut+1))
	FileAccess.open(output+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(evidence,"\t")+"\n")
	# Review controls switch only isolated art; validate both directions.
	var old_mode := scythe
	_key_pressed(KEY_TAB)
	_check(scythe!=old_mode,"Tab switches preview")
	_sample(1.1)
	_check(presenters[0].definition.weapon_texture==clips[0].weapon_texture,"Tab presenter uses selected weapon")
	_key_pressed(KEY_TAB)
	_check(scythe==old_mode,"Tab returns to original study")
	_key_pressed(KEY_SPACE)
	_check(elapsed==0,"Space replay resets clock")
	FileAccess.open(output+"checks.json",FileAccess.WRITE).store_string(JSON.stringify({"assertions":assertions,"failures":failures,"frames":evidence.size(),"combo_seconds":_combo_seconds(),"contact_seconds":CONTACT,"mode":"presentation only; fixed60fps native render; not performance profiling"},"\t")+"\n")
	print("HEAVY_BURST_REVIEW ","scythe" if scythe else "greatsword"," assertions=",assertions," failures=",failures.size()," frames=",evidence.size())
	scene.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _load_clips() -> void:
	clips.clear()
	var first: Resource = load(PREVIEW+("scythe/" if scythe else "")+"sweep.tres")
	clips.append(first)
	clips.append_array(first.follow_up_clips)
	carry = IDLE.duplicate()
	if scythe:
		carry.weapon_texture = first.weapon_texture
		carry.weapon_primary_grip = first.weapon_primary_grip
		carry.weapon_tip = first.weapon_tip
		carry.planting = null
	for cut in clips.size():
		var clip: Resource = clips[cut]
		_check(clip.has_valid_layout(),"complete registered clip "+str(cut))
		for key in clip.pose_count:
			var body: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			_check(body.get_pixelv(Vector2i(clip.primary_hands[key])).a>.65,"visible grip "+str(cut)+"/"+str(key))
			_check(body.get_used_rect().position.x>0 and body.get_used_rect().end.x<192 and body.get_used_rect().position.y>0 and body.get_used_rect().end.y<128,"body crop safety")
			_check_anatomy(body,clip,key)
		if cut<4:
			var next: Resource = clips[cut+1]
			var last: Image = clip.body_atlas.get_image().get_region(Rect2i(3*192,2*128,192,128))
			var entry: Image = next.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
			_check(last.get_data()==entry.get_data() and clip.primary_hands[11]==next.primary_hands[0] and clip.secondary_hands[11]==next.secondary_hands[0],"connected combo boundary "+str(cut))
		if not scythe: _check(clip.weapon_texture.resource_path=="res://assets/characters/playable/king/huge_greatsword_proof/greatsword.png" and clip.weapon_texture.get_size()==Vector2(30,140),"canonical steel")

func _sample(time: float) -> Dictionary:
	var cut := -1
	var pose := 0
	var phase := "CARRY"
	var fx_key := -1
	var travel := 0.0
	var clip: Resource = carry
	if time>=.25 and time<.65 and not scythe:
		clip = RUN
		pose = int((time-.25)/.4*8)%8
		phase = "APPROVED WALK"
	elif time>=.8:
		var local := time-.8
		for index in 5:
			var duration: float = WIND[index]+CONTACT+RECOVERY[index]
			if local<duration:
				cut = index
				clip = clips[cut]
				if local<WIND[index]:
					phase = "LOAD"
					pose = 0 if local<WIND[index]*.125 else (1 if local<WIND[index]*.5 else 2)
				else:
					var active: float = local-WIND[index]
					travel += STEPS[index]*smoothstep(0,CONTACT+.06,active)
					if active<CONTACT:
						phase = "CONTACT"
						pose = mini(5,3+int(active/CONTACT*3))
					else:
						phase = "FOLLOW THROUGH"
						var progress: float = (active-CONTACT)/RECOVERY[index]
						pose = 9+mini(2,int(progress*3))
					fx_key = mini(3,int(active/.03)) if active<.12 else -1
				break
			local -= duration
			travel += STEPS[index]
	for side in 2:
		var presenter: Node2D = presenters[side]
		if presenter.definition!=clip: presenter.select_clip(clip)
		if cut!=previous_cut or pose!=previous_pose: presenter.set_pose(pose)
		groups[side].position.x = (240+travel*ZOOM) if side==0 else (760-travel*ZOOM)
		var fx: Sprite2D = effects[side]
		fx.visible = fx_key>=0
		if fx_key>=0:
			var atlas: AtlasTexture = fx.texture
			var row := 2 if cut==2 else 1 if cut==1 or cut==4 else 0
			atlas.region = Rect2(fx_key*128,row*128,128,128)
			fx.texture = atlas
			# Register the painted leading point to the actual rigid blade tip.
			# A generic static origin made slash art float above the entire swing.
			var tip: Vector2 = presenter.position+presenter.weapon_rig.transform*(clip.weapon_tip-clip.weapon_primary_grip)*.5
			fx.position = tip-(FX_TIPS[row][fx_key]-Vector2(64,64))*.5
	previous_cut = cut
	previous_pose = pose
	status.text = ((CUT_NAMES[cut]+" / ") if cut>=0 else "")+phase+" | 67ms strike window • full-body poses • huge raster slash"
	return {"cut":cut,"pose":pose,"phase":phase,"fx_key":fx_key,"travel":travel}

func _process(delta: float) -> bool:
	if not capturing and scene!=null:
		for key in [KEY_ESCAPE,KEY_SPACE,KEY_TAB]:
			var pressed := Input.is_physical_key_pressed(key)
			if pressed and not held_keys.get(key,false): _key_pressed(key)
			held_keys[key] = pressed
		elapsed = fmod(elapsed+delta,.8+_combo_seconds()+.75)
		_sample(elapsed)
	return false

func _key_pressed(key: int) -> void:
	if key==KEY_ESCAPE: quit()
	elif key==KEY_SPACE: elapsed=0; previous_cut=-2; previous_pose=-2
	elif key==KEY_TAB:
		scythe = not scythe
		_load_clips()
		title.text = "SCYTHE — silhouette / motion study" if scythe else "GREATSWORD — heavy burst study"
		elapsed=0; previous_cut=-2; previous_pose=-2

func _combo_seconds() -> float:
	var result := 0.0
	for index in 5: result += WIND[index]+CONTACT+RECOVERY[index]
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
		_check(screen.x>=0 and screen.y>=0 and screen.x<=1000 and screen.y<=520,"visible art crop safety t="+str(elapsed)+" point="+str(screen))

func _check_anatomy(body: Image,clip: Resource,key: int) -> void:
	# A visible hilt alone cannot prove that an arm or head is connected.
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
	var reference: Image = IDLE.body_atlas.get_image().get_region(Rect2i(87,41,25,24))
	var head: Rect2 = clip.identity_regions[key]
	var matched := 0
	var expected := 0
	var connected_head := 0
	for y in 24:
		for x in 25:
			var pixel := reference.get_pixel(x,y)
			if pixel.a<.65: continue
			var point := Vector2i(head.position)+Vector2i(x,y)
			expected += 1
			if body.get_pixelv(point)==pixel: matched += 1
			if visited[point.y*192+point.x]: connected_head += 1
	_check(float(matched)/expected>=.88,"retained native head pixels; raised gloves may occlude crown")
	_check(float(connected_head)/expected>=.9,"head connected to drawn weapon glove through body")
