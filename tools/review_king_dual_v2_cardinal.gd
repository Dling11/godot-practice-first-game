extends SceneTree

## Native four-direction motion capture, sampled from the installed family data.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
var PROFILE: Resource = preload("res://data/weapons/families/twinsteel_v2/presentation.tres")
const COMBO = preload("res://data/weapons/families/twinsteel_v2/combo.tres")
var output := "res://art_source/review/combat/king_dual_v2_cardinal_2026_10_07/"
const DIRECTIONS := [Vector2.LEFT,Vector2.RIGHT,Vector2.UP,Vector2.DOWN]
var scene: Node2D
var actors: Array[Dictionary] = []
var label: Label
var assertions := 0
var failures := 0
var timeline: Array = []
var checked_fx := {}

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output="): output = argument.trim_prefix("--output=").trim_suffix("/")+"/"
		if argument.begins_with("--profile=res://"): PROFILE=load(argument.trim_prefix("--profile="))
	_run.call_deferred()

func check(ok: bool,message: String) -> void:
	assertions += 1
	if not ok:
		failures += 1
		push_error(message)

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(1000,960)
	root.content_scale_size = root.size
	root.title = "Battle of Gods — Twinsteel V2 / four-direction motion"
	RenderingServer.set_default_clear_color(Color("202b30"))
	scene = Node2D.new()
	root.add_child(scene)
	check(PROFILE.is_valid_profile(),"Installed cardinal profile invalid")
	label = make_label(Vector2(20,16),"TWINSTEEL V2 · FOUR DIRECTIONS · NATIVE GAME ASSETS")
	for index in 4:
		var direction: Vector2 = DIRECTIONS[index]
		var group := Node2D.new()
		group.position = Vector2(250 if index%2==0 else 750,330 if index<2 else 745)
		group.scale = Vector2.ONE*2.6
		scene.add_child(group)
		var attack := MeleeAttackComponent.new()
		group.add_child(attack)
		var rig := Presenter.new()
		rig.configure(PROFILE.attack_for(direction),attack,false)
		rig.position = Vector2(0,-16)
		rig.scale = Vector2.ONE*.5
		group.add_child(rig)
		rig.face_horizontal(-1 if direction==Vector2.LEFT else 1)
		var fx := Sprite2D.new()
		var region := AtlasTexture.new()
		region.atlas = PROFILE.swing_atlas if index<2 else load("res://assets/characters/playable/king/dual_v2/slash_"+("up" if index==2 else "down")+".png")
		region.filter_clip = true
		fx.texture = region
		fx.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		group.add_child(fx)
		if direction==Vector2.UP: group.move_child(fx,0)
		actors.append({"group":group,"rig":rig,"fx":fx,"direction":direction})
		make_label(Vector2(group.position.x-65,430 if index<2 else 925),["LEFT","RIGHT","UP / BACK","DOWN / FRONT"][index])
		var base: Resource = PROFILE.attack_for(direction)
		for clip in [base]+Array(base.follow_up_clips)+[PROFILE.idle_for(direction),PROFILE.run_for(direction)]:
			check(clip.has_valid_layout(),"Invalid body/steel registration")
			for key in clip.pose_count:
				var image: Image = clip.body_atlas.get_image().get_region(Rect2i(key%4*192,key/4*128,192,128))
				var bounds: Rect2i = image.get_used_rect()
				check(bounds.position.x>15 and bounds.position.y>5 and bounds.end.x<177 and bounds.end.y<120,"Body/head cell clipped: "+clip.resource_path+" key "+str(key)+" "+str(bounds))
	if OS.get_cmdline_user_args().has("--verify-only"):
		print("DUAL_V2_LAYOUT checks=",assertions," failures=",failures)
		scene.queue_free()
		actors.clear()
		await process_frame
		quit(1 if failures else 0)
		return
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(output+"motion_frames/"))
	for frame in 300:
		var time := frame/30.0
		var sample := sample_motion(time)
		await process_frame
		await RenderingServer.frame_post_draw
		var path := "motion_frames/frame_%03d.png"%frame
		check(root.get_texture().get_image().save_png(output+path)==OK,"Native frame export failed")
		timeline.append({"time":time,"state":sample,"file":path})
		if frame in [15,30,40,60,80,105,155,200,240,280]: root.get_texture().get_image().save_png(output+"sample_%03d.png"%frame)
	FileAccess.open(output+"motion_checks.json",FileAccess.WRITE).store_string(JSON.stringify({"assertions":assertions,"failures":failures,"frames":timeline.size(),"scope":"Native installed cardinal/gait/idle art; combat verified separately"},"\t")+"\n")
	FileAccess.open(output+"timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	print("DUAL_V2_NATIVE checks=",assertions," failures=",failures," frames=",timeline.size())
	scene.queue_free()
	await process_frame
	await process_frame
	actors.clear()
	quit(1 if failures else 0)

func sample_motion(time: float) -> String:
	var phase := "WALK"
	for actor in actors:
		var direction: Vector2 = actor.direction
		var rig: Node2D = actor.rig
		var fx: Sprite2D = actor.fx
		var clip: Resource = PROFILE.run_for(direction)
		var pose := int(time/.08)%8
		var cut := -1
		var effect_frame := -1
		if time>=.8 and time<1.1:
			phase = "READY"
			clip = PROFILE.idle_for(direction)
			pose = 0
		elif time>=1.1 and time<3.3:
			var local := time-1.1
			var base: Resource = PROFILE.attack_for(direction)
			for index in 5:
				var duration: float = COMBO.windups[index]+COMBO.contacts[index]+COMBO.recoveries[index]
				if local<duration or index==4:
					cut = index
					clip = base if index==0 else base.follow_up_clips[index-1]
					var window: Vector2 = clip.phase_windows[0]
					var progress := local/COMBO.windups[index]
					phase = "LOAD"
					if local>=COMBO.windups[index]+COMBO.contacts[index]:
						phase = "RECOVER"
						window = clip.queued_recovery_window
						progress = (local-COMBO.windups[index]-COMBO.contacts[index])/COMBO.recoveries[index]
					elif local>=COMBO.windups[index]:
						phase = "CUT %d"%(index+1)
						window = clip.phase_windows[1]
						progress = (local-COMBO.windups[index])/COMBO.contacts[index]
						effect_frame = mini(3,int(progress*4))
					pose = weighted_key(clip,window,progress)
					break
				local -= duration
		elif time>=3.3:
			clip = PROFILE.idle_for(direction)
			phase = "PLANT BLADES · FOLD ARMS · HEAD GLANCES"
			var local := time-3.3
			var end_pose: int = clip.rest_transition_end_pose if clip.rest_transition_end_pose>=0 else clip.pose_count-1
			var exposure: float = clip.rest_loop_seconds/(clip.rest_loop_window.y-clip.rest_loop_window.x+1)
			if local<clip.rest_transition_seconds:
				pose = clip.rest_start_pose+int(local/clip.rest_transition_seconds*(end_pose+1-clip.rest_start_pose))
			elif local<clip.rest_transition_seconds+exposure:
				pose = end_pose
				phase = "FOLDED ARMS · CALM CENTER HOLD"
			else:
				pose = int(clip.rest_loop_window.x)+int(fmod(local-clip.rest_transition_seconds-exposure,clip.rest_loop_seconds)/exposure)
		if rig.definition!=clip: rig.select_clip(clip)
		rig.set_pose(pose)
		fx.visible = effect_frame>=0
		if fx.visible:
			(fx.texture as AtlasTexture).region = Rect2(effect_frame*192,cut*192,192,192)
			var lift: float = clip.lift_pixels[pose]*.5
			if cut==3: fx.transform = Transform2D(0,Vector2.ONE*1.18,0,Vector2(0,-32+lift))
			elif absf(direction.x)>0: fx.transform = Transform2D(0,Vector2(-.95 if direction.x<0 else .95,.95),0,Vector2(22*direction.x,-31+lift))
			else: fx.transform = Transform2D(0,Vector2(.95,.65),0,Vector2(0,-16+lift)+direction*25)*Transform2D(direction.angle(),Vector2.ZERO)
			var signature := str(direction)+"/"+str(cut)+"/"+str(effect_frame)
			if not checked_fx.has(signature):
				checked_fx[signature] = true
				var bounds := Rect2(fx.texture.get_image().get_used_rect())
				bounds.position -= Vector2(96,96)
				for point in [bounds.position,Vector2(bounds.end.x,bounds.position.y),bounds.end,Vector2(bounds.position.x,bounds.end.y)]:
					var screen: Vector2 = fx.global_transform*point
					check(screen.x>0 and screen.y>50 and screen.x<root.size.x and screen.y<root.size.y-20,"Rendered slash clipped at gallery edge")
	label.text = "TWINSTEEL V2 · "+phase
	return phase

func weighted_key(clip: Resource,window: Vector2,progress: float) -> int:
	var total := 0.0
	for key in range(int(window.x),int(window.y)+1): total += clip.pose_weights[key]
	var remaining := clampf(progress,0,1)*total
	for key in range(int(window.x),int(window.y)+1):
		if remaining<clip.pose_weights[key] or key==int(window.y): return key
		remaining -= clip.pose_weights[key]
	return int(window.y)

func make_label(point: Vector2,title: String) -> Label:
	var text := Label.new()
	text.position = point
	text.text = title
	text.add_theme_font_size_override("font_size",17)
	text.add_theme_color_override("font_color",Color("d8e1df"))
	scene.add_child(text)
	return text
