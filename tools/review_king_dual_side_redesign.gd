extends SceneTree

## Isolated LEFT/RIGHT presentation review. No Player, grants or damage authority.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const PREVIEW := "res://assets/characters/playable/king/dual_side_redesign/"
const SOURCE := "res://art_source/generated/characters/king/dual_side_redesign_2026_10_07/"
const PROOF := "res://art_source/review/combat/king_dual_side_redesign_2026_10_07/"
const IDLE = preload("res://assets/characters/playable/king/dual_twinsteel/idle.tres")
const RUN = preload("res://assets/characters/playable/king/dual_twinsteel/run.tres")
const WIND := [0.14,0.12,0.15,0.16,0.23]
const CONTACT := [0.08,0.08,0.10,0.22,0.10]
const RECOVERY := [0.16,0.14,0.15,0.15,0.22]
const NAMES := ["1 DIAGONAL CUT", "2 RETURN CUT", "3 RISING CROSS", "4 HOP SPIN", "5 CROSSING FINISHER"]
const ZOOM := 3.0
var scene: Node2D
var clips: Array[Resource] = []
var actors: Array[Dictionary] = []
var status: Label
var elapsed := 0.0
var capturing := false
var review_paused := false
var slow := false
var selected_cut := -1
var previous_cut := -2
var previous_pose := -2
var held_keys := {}
var assertions := 0
var failures: Array[String] = []
var registration: Dictionary
var head_refs := {}
var timeline: Array[Dictionary] = []

func _initialize() -> void:
	capturing = OS.get_cmdline_user_args().has("--capture")
	_run.call_deferred()

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(1000,560)
	root.content_scale_size = root.size
	root.title = "Battle of Gods — Twinsteel V2 / LEFT + RIGHT combo study"
	RenderingServer.set_default_clear_color(Color("202b30"))
	scene = Node2D.new()
	root.add_child(scene)
	_load_and_check()
	if not failures.is_empty():
		_save_checks()
		quit(1)
		return
	var layer := CanvasLayer.new()
	scene.add_child(layer)
	_label(layer,Vector2(24,16),22).text = "TWINSTEEL V2 — NEW FIVE-CUT SIDE STUDY"
	status = _label(layer,Vector2(24,52),15)
	_label(layer,Vector2(24,493),14).text = "SPACE full combo · 1–5 inspect a cut · P pause · H half speed · ESC close"
	_label(layer,Vector2(24,520),13).text = "3x review zoom · accepted carry / run / 16×62 steel · new attacks and raster slashes · side preview only"
	for index in 2:
		var actor := Node2D.new()
		actor.position = Vector2(255 if index==0 else 745,355)
		actor.scale = Vector2(-ZOOM if index==0 else ZOOM,ZOOM)
		scene.add_child(actor)
		var effect := Sprite2D.new()
		effect.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		var atlas := AtlasTexture.new()
		atlas.atlas = load(PREVIEW+"slash.png")
		atlas.region = Rect2(0,0,192,192)
		atlas.filter_clip = true
		effect.texture = atlas
		actor.add_child(effect)
		var attack := MeleeAttackComponent.new()
		actor.add_child(attack)
		var presenter := Presenter.new()
		_check(presenter.configure(clips[0],attack,false),"shared dual presenter setup")
		presenter.scale = Vector2.ONE*.5
		presenter.position = Vector2(0,-16)
		actor.add_child(presenter)
		actors.append({"group":actor,"presenter":presenter,"effect":effect})
		_label(layer,Vector2(205 if index==0 else 685,455),18).text = "LEFT" if index==0 else "RIGHT"
		var floor_mark := Line2D.new()
		floor_mark.points = PackedVector2Array([Vector2(-24,0),Vector2(24,0)])
		floor_mark.width = .5
		floor_mark.default_color = Color("405158")
		actor.add_child(floor_mark)
	_sample(0)
	if not capturing:
		_save_checks()
		print("DUAL_SIDE_REVIEW_READY checks=",assertions," failures=",failures.size())
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(PROOF+"motion_frames/"))
	for frame in ceili((.75+_combo_seconds()+.55)*60):
		elapsed = frame/60.0
		var sample := _sample(elapsed)
		await process_frame
		await RenderingServer.frame_post_draw
		var file := "motion_frames/frame_%03d.png" % frame
		_check(root.get_texture().get_image().save_png(PROOF+file)==OK,"native frame export")
		sample["file"] = file
		sample["elapsed_ms"] = roundi(elapsed*1000)
		timeline.append(sample)
		if sample.cut>=0 and sample.phase=="CONTACT" and sample.fx==1:
			root.get_texture().get_image().save_png(PROOF+"cut_%d.png" % (sample.cut+1))
	FileAccess.open(PROOF+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	_key(KEY_P)
	_check(review_paused,"P pauses review")
	_key(KEY_P)
	_key(KEY_H)
	_check(slow,"H selects half speed")
	_key(KEY_H)
	_key(KEY_2)
	_check(selected_cut==1,"number key selects individual cut")
	_sample(.9)
	_key(KEY_SPACE)
	_check(selected_cut==-1 and elapsed==0,"Space restores full chain")
	_save_checks()
	print("DUAL_SIDE_REVIEW checks=",assertions," failures=",failures.size()," frames=",timeline.size())
	scene.queue_free()
	await process_frame
	quit(0 if failures.is_empty() else 1)

func _load_and_check() -> void:
	registration = JSON.parse_string(FileAccess.get_file_as_string(SOURCE+"registration.json"))
	for view_name in ["side","left","up","down"]:
		var resource: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres" if view_name in ["side","left"] else "res://assets/characters/playable/king/greatsword_readability/"+view_name+"/idle.tres")
		var body: Image = resource.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		if view_name=="left": body.flip_x()
		head_refs[view_name] = body.get_region(str_to_var(registration.heads[view_name]))
	var first: Resource = load(PREVIEW+"diagonal.tres")
	clips.append(first)
	clips.append_array(first.follow_up_clips)
	_check(clips.size()==5,"five new cuts")
	for cut in clips.size():
		var clip: Resource = clips[cut]
		_check(clip.has_valid_layout(),"valid complete-body dual clip")
		_check(clip.weapon_texture.get_size()==Vector2(16,62) and clip.offhand.texture==clip.weapon_texture,"canonical same-size dual steel")
		for key in clip.pose_count:
			var body: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
			var bounds := body.get_used_rect()
			_check(bounds.position.x>0 and bounds.position.y>0 and bounds.end.x<192 and bounds.end.y<128,"whole body has cell margin")
			_check(body.get_pixelv(Vector2i(clip.primary_hands[key])).a>.65,"near blade belongs to drawn palm")
			if clip.offhand.visible_poses[key]: _check(body.get_pixelv(Vector2i(clip.offhand.hands[key])).a>.65,"visible far blade belongs to drawn palm")
			_check_anatomy(body,clip,key,registration.poses[cut*16+key].view)
			_check(clip.lift_pixels[key]>=-10 and clip.lift_pixels[key]<=0,"small authored hop; no body scale tween")
		if cut<4:
			var next: Resource = clips[cut+1]
			_check(_cel(clip,15).get_data()==_cel(next,0).get_data() and clip.primary_hands[15]==next.primary_hands[0] and clip.offhand.hands[15]==next.offhand.hands[0],"complete connected queue boundary")
		_check(_cel(clip,12).get_data()==_cel(IDLE,0).get_data(),"release settles to approved idle")
	_check(clips[0].primary_hands[4]!=clips[0].primary_hands[9] or clips[0].secondary_hands[4]!=clips[0].secondary_hands[9],"opening is a sweep rather than linear thrust")
	var slash: Texture2D = load(PREVIEW+"slash.png")
	for row in 5:
		for key in 4:
			var cel := slash.get_image().get_region(Rect2i(key*192,row*192,192,192))
			var bounds := cel.get_used_rect()
			_check(bounds.position.x>=20 and bounds.position.y>=20 and bounds.end.x<=172 and bounds.end.y<=172,"complete padded raster effect")
			var bright := 0
			for y in bounds.size.y:
				for x in bounds.size.x:
					var color := cel.get_pixelv(bounds.position+Vector2i(x,y))
					if color.a>.65 and color.r>.9 and color.g>.9: bright += 1
			_check(bright>30,"each contact/fade has visible white core")

func _check_anatomy(body: Image,clip: Resource,key: int,view_name: String) -> void:
	var seed := Vector2i(clip.primary_hands[key])
	var seen := PackedByteArray()
	seen.resize(192*128)
	var todo := PackedInt32Array([seed.y*192+seed.x])
	seen[todo[0]] = 1
	var cursor := 0
	while cursor<todo.size():
		var id := todo[cursor]
		cursor += 1
		for dy in range(-1,2):
			for dx in range(-1,2):
				var point := Vector2i(id%192+dx,id/192+dy)
				if point.x<0 or point.y<0 or point.x>=192 or point.y>=128: continue
				var index := point.y*192+point.x
				if seen[index] or body.get_pixelv(point).a<.65: continue
				seen[index] = 1
				todo.append(index)
	if clip.offhand.visible_poses[key]:
		var far := Vector2i(clip.offhand.hands[key])
		_check(seen[far.y*192+far.x]>0,"both visible fists connect through whole torso "+cut_key(clip,key))
		if not seen[far.y*192+far.x]: body.save_png(SOURCE+"anatomy_failure_"+cut_key(clip,key).replace("/","_")+".png")
	var reference: Image = head_refs[view_name]
	var region: Rect2 = clip.identity_regions[key]
	var expected := 0
	var matched := 0
	var connected := 0
	for y in reference.get_height():
		for x in reference.get_width():
			var pixel := reference.get_pixel(x,y)
			if pixel.a<.65: continue
			var point := Vector2i(region.position)+Vector2i(x,y)
			expected += 1
			if body.get_pixelv(point)==pixel: matched += 1
			if seen[point.y*192+point.x]: connected += 1
	_check(float(matched)/maxi(expected,1)>=.80,"native face/hair identity retained "+str(cut_key(clip,key)))
	_check(float(connected)/maxi(expected,1)>=.85,"head connected to neck and arms "+cut_key(clip,key))

func cut_key(clip: Resource,key: int) -> String:
	return str(clips.find(clip))+"/"+str(key)

func _sample(time: float) -> Dictionary:
	var cut := -1
	var pose := 0
	var phase := "ACCEPTED IDLE"
	var fx := -1
	var clip: Resource = IDLE
	if selected_cut<0 and time>=.2 and time<.55:
		clip = RUN
		pose = int((time-.2)/.35*8)%8
		phase = "ACCEPTED RUN"
	elif time>=.75:
		var local := time-.75
		var indices: Array = range(5) if selected_cut<0 else [selected_cut]
		for index: int in indices:
			var duration: float = WIND[index]+CONTACT[index]+RECOVERY[index]
			if local<duration:
				cut = index
				clip = clips[cut]
				if local<WIND[index]:
					phase = "LOAD"
					pose = _weighted_key(clip,Vector2(0,3),local/WIND[index])
				elif local<WIND[index]+CONTACT[index]:
					phase = "CONTACT"
					var active: float = (local-WIND[index])/CONTACT[index]
					pose = _weighted_key(clip,Vector2(4,9),active)
					fx = mini(3,int(active*4))
				else:
					phase = "FOLLOW THROUGH"
					pose = _weighted_key(clip,Vector2(13,15) if selected_cut<0 else Vector2(10,12),(local-WIND[index]-CONTACT[index])/RECOVERY[index])
				break
			local -= duration
	for actor in actors:
		var presenter: Node2D = actor.presenter
		var effect: Sprite2D = actor.effect
		if presenter.definition!=clip: presenter.select_clip(clip)
		if cut!=previous_cut or pose!=previous_pose: presenter.set_pose(pose)
		effect.visible = fx>=0
		if fx>=0:
			(effect.texture as AtlasTexture).region = Rect2(fx*192,cut*192,192,192)
			effect.scale = Vector2.ONE*(1.18 if cut==3 else .95)
			effect.position = Vector2(0,-16) if cut==3 else Vector2(22,-15)
			# Hop orbit follows the same authored lift; floor never moves.
			effect.position.y += clip.lift_pixels[pose]*.5
		if capturing:
			_check_bounds(presenter.body_sprite)
			_check_bounds(presenter.weapon_sprite)
			if presenter.offhand_sprite.visible: _check_bounds(presenter.offhand_sprite)
			if effect.visible: _check_bounds(effect)
	previous_cut = cut
	previous_pose = pose
	status.text = (NAMES[cut]+" · " if cut>=0 else "")+phase+" · "+("HALF SPEED" if slow else "NORMAL SPEED")
	return {"cut":cut,"pose":pose,"phase":phase,"fx":fx}

func _weighted_key(clip: Resource,window: Vector2,progress: float) -> int:
	var total := 0.0
	for key in range(int(window.x),int(window.y)+1): total += clip.pose_weights[key]
	var remaining := clampf(progress,0,1)*total
	for key in range(int(window.x),int(window.y)+1):
		if remaining<clip.pose_weights[key] or key==int(window.y): return key
		remaining -= clip.pose_weights[key]
	return int(window.y)

func _process(delta: float) -> bool:
	if not capturing and not actors.is_empty():
		for key in [KEY_ESCAPE,KEY_SPACE,KEY_P,KEY_H,KEY_1,KEY_2,KEY_3,KEY_4,KEY_5]:
			var pressed := Input.is_physical_key_pressed(key)
			if pressed and not held_keys.get(key,false): _key(key)
			held_keys[key] = pressed
		if not review_paused:
			var duration: float = .75+(_combo_seconds() if selected_cut<0 else WIND[selected_cut]+CONTACT[selected_cut]+RECOVERY[selected_cut])+.55
			elapsed = fmod(elapsed+delta*(.5 if slow else 1.0),duration)
			_sample(elapsed)
	return false

func _key(key: int) -> void:
	if key==KEY_ESCAPE: quit()
	elif key==KEY_P: review_paused = not review_paused
	elif key==KEY_H: slow = not slow
	elif key==KEY_SPACE or key in [KEY_1,KEY_2,KEY_3,KEY_4,KEY_5]:
		selected_cut = -1 if key==KEY_SPACE else key-KEY_1
		elapsed = 0
		previous_cut = -2
		previous_pose = -2
		review_paused = false

func _combo_seconds() -> float:
	var duration := 0.0
	for cut in 5: duration += WIND[cut]+CONTACT[cut]+RECOVERY[cut]
	return duration

func _cel(clip: Resource,key: int) -> Image:
	return clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))

func _check_bounds(sprite: Sprite2D) -> void:
	var bounds := Rect2(sprite.texture.get_image().get_used_rect())
	if sprite.centered: bounds.position -= sprite.texture.get_size()*.5
	for point in [bounds.position,Vector2(bounds.end.x,bounds.position.y),bounds.end,Vector2(bounds.position.x,bounds.end.y)]:
		var screen: Vector2 = sprite.global_transform*point
		_check(screen.x>=0 and screen.y>=0 and screen.x<=1000 and screen.y<=490,"no rendered body / weapon / slash crop")

func _label(parent: Node,point: Vector2,size: int) -> Label:
	var label := Label.new()
	label.position = point
	label.add_theme_font_size_override("font_size",size)
	label.add_theme_color_override("font_color",Color("d8e1df"))
	parent.add_child(label)
	return label

func _check(condition: bool,message: String) -> void:
	assertions += 1
	if not condition:
		failures.append(message)
		push_error(message)

func _save_checks() -> void:
	# Interactive opening must never replace the completed capture evidence.
	var filename := "checks.json" if capturing else "owner_checks.json"
	FileAccess.open(PROOF+filename,FileAccess.WRITE).store_string(JSON.stringify({"assertions":assertions,"failures":failures,"frames":timeline.size(),"combo_seconds":_combo_seconds(),"wind":WIND,"contact":CONTACT,"recovery":RECOVERY,"scope":"Native LEFT/RIGHT presentation only; not installed gameplay, enemy balance or performance profiling"},"\t")+"\n")
