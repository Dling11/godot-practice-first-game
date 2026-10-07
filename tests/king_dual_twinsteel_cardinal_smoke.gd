extends "res://tests/sanctuary_test_base.gd"

const PLAYER = preload("res://entities/player/player.tscn")
const WEAPON = preload("res://data/weapons/families/twinsteel_prototype/weapon.tres")
const PROFILE = preload("res://data/weapons/families/twinsteel_prototype/presentation.tres")
const AXE_PROFILE = preload("res://data/weapons/families/iron_beard/presentation.tres")
const GS_PROFILE = preload("res://data/weapons/families/royal_greatsword/presentation.tres")
const NATIVE_SIDE_RUN = preload("res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres")
const NATIVE_SIDE_FACE = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const NATIVE_FRONT = preload("res://assets/characters/playable/king/greatsword_cardinal/down/run.tres")
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const Trail = preload("res://gameplay/presentation/axe_swing_trail.gd")
const StepMotion = preload("res://gameplay/movement/melee_step_motion.gd")
const OUT := "res://art_source/review/combat/king_dual_close_hilt_2026_10_05/"
var evidence_path := OUT
const DIRECTIONS := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2.UP,Vector2.DOWN]
var actors: Array[Player] = []
var presenters: Array[Node2D] = []
var pending: Array[bool] = [false,false,false,false,false,false]
var began: Array[Array] = [[],[],[],[],[],[]]
var timeline: Array[Dictionary] = []
var captures: Array[Image] = []
var locations := [Vector2(225,205),Vector2(875,205),Vector2(225,525),Vector2(875,525),Vector2(100,755),Vector2(265,755)]

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://art_source/review/"): evidence_path=argument.trim_prefix("--output=").trim_suffix("/")+"/"
	super._initialize()

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	check(PROFILE.is_valid_profile(),"Full cardinal profile is invalid")
	var benchmark: Image = GS_PROFILE.idle_poses.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var axe_benchmark: Image = AXE_PROFILE.idle_poses.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	check(benchmark.get_used_rect().size.y==54,"Heavy-family standing calibration changed")
	check(absi(axe_benchmark.get_used_rect().size.y-54)<=3,"Dual standing size differs from the accepted axe benchmark")
	root.size=Vector2i(1100,850)
	root.content_scale_size=root.size
	var bg := ColorRect.new()
	bg.color=Color("263339")
	bg.size=Vector2(root.size)
	root.add_child(bg)
	for spec in [[Vector2(25,12),"RIGHT / accepted side"],[Vector2(585,12),"LEFT / mirrored side"],[Vector2(25,335),"UP / actual back body"],[Vector2(585,335),"DOWN / actual front body"],[Vector2(25,690),"Actual game size / up + down"],[Vector2(490,690),"Back / front gait · travel driven"]]:
		var label := Label.new()
		label.position=spec[0]
		label.text=spec[1]
		root.add_child(label)
	for index in 6:
		var actor: Player = PLAYER.instantiate()
		actor.position=locations[index]
		actor.scale=Vector2.ONE*(2.5 if index<4 else 1.0)
		actor.movement_bounds=Rect2(0,0,2000,1200)
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.set_weapon_definition(WEAPON),"Review weapon rejected")
		actor.get_node("VisualRoot/Body").hide()
		var old := actor.get_node("GreatswordEffects")
		if actor.attack_component.phase_changed.is_connected(old._on_attack_phase): actor.attack_component.phase_changed.disconnect(old._on_attack_phase)
		old.hide()
		actor.facing_direction=DIRECTIONS[index]
		var p := Presenter.new()
		p.continuation_requested=func() -> bool: return pending[index]
		p.continuation_pending=func() -> bool: return pending[index]
		check(p.configure(PROFILE.attack_for(DIRECTIONS[index]),actor.attack_component),"Directional attack rejected")
		check(p.configure_idle(PROFILE.idle_for(DIRECTIONS[index])),"Directional idle rejected")
		p.position=Vector2(0,-16)
		p.scale=Vector2.ONE*.5
		p.face_horizontal(-1 if index==1 else 1)
		actor.get_node("VisualRoot").add_child(p)
		var trail := Trail.new()
		trail.configure(actor.attack_component,PROFILE.swing_atlas)
		trail.rows=5
		trail.origins=PROFILE.swing_origins
		trail.world_origin=Vector2(0,-16)
		trail.rotate_vertical_sampling=true
		trail.edge_feather_pixels=2
		actor.add_child(trail)
		actor.move_child(trail,actor.get_node("VisualRoot").get_index())
		trail.z_index=0 if DIRECTIONS[index]==Vector2.UP else 3
		var motion := StepMotion.new()
		motion.actor=actor
		motion.attack=actor.attack_component
		motion.step_distances=PROFILE.step_distances
		actor.add_child(motion)
		actor.attack_component.attack_started.connect(func() -> void:
			began[index].append(actor.attack_component.combo_step)
			pending[index]=actor.attack_component.combo_step<4
		)
		actor.attack_component.attack_finished.connect(func() -> void:
			if pending[index]: actor.attack_component.request_attack.call_deferred(actor.facing_direction)
		)
		actors.append(actor)
		presenters.append(p)
	var runners: Array[Node2D] = []
	var dummy := MeleeAttackComponent.new()
	root.add_child(dummy)
	for index in 2:
		var p := Presenter.new()
		var run: Resource = PROFILE.run_for(Vector2.UP if index==0 else Vector2.DOWN)
		p.configure(run,dummy,false)
		p.position=Vector2(650+index*225,745)
		p.scale=Vector2.ONE*1.3
		root.add_child(p)
		p.play_locomotion(run,.36,true)
		runners.append(p)
	for facing in [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]: validate_direction(facing,presenters[0])
	presenters[0].select_clip(PROFILE.idle_poses)
	presenters[0].set_pose(0)
	var seconds := 0.0
	for cut in 5: seconds+=WEAPON.combo.windups[cut]+WEAPON.combo.contacts[cut]+WEAPON.combo.recoveries[cut]
	check(is_equal_approx(seconds,2.2),"Cardinal art changed accepted combo timing")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path+"motion_frames/"))
	var capture := DisplayServer.get_name()!="headless" and "--capture" in OS.get_cmdline_user_args()
	for frame in 105:
		if frame==8:
			for actor in actors: check(actor.attack_component.request_attack(actor.facing_direction),"Directional primary failed")
		for runner in runners: runner.advance_locomotion(3.66)
		await process_frame
		await process_frame
		if capture:
			await RenderingServer.frame_post_draw
			captures.append(root.get_texture().get_image())
		var states: Array[Dictionary] = []
		for index in 6:
			var p: Node2D = presenters[index]
			check(p.offhand_rig.visible==(p.definition.offhand.visible_poses[p.pose_index]>0),"Occluded blade visibility disagrees with art")
			check(p.weapon_sprite.texture==p.offhand_sprite.texture,"Canonical pair changed between directions")
			if p.offhand_rig.visible: check(p.weapon_rig.position.distance_to(p.offhand_rig.position)>=4,"Two visible hilts collapse onto one hand")
			states.append({"direction":var_to_str(DIRECTIONS[index]),"step":actors[index].attack_component.combo_step,"phase":actors[index].attack_component.phase,"pose":p.pose_index})
		timeline.append({"frame":frame,"file":"motion_frames/frame_%03d.png"%frame,"elapsed_ms":roundi(frame*1000.0/30.0),"actors":states})
	for index in 6:
		check(began[index]==[0,1,2,3,4],"Cardinal chain dropped or repeated a cut")
		check(presenters[index].definition==PROFILE.idle_for(DIRECTIONS[index]),"Cardinal chain resets to wrong carry")
		check(actors[index].position.distance_to(locations[index]+DIRECTIONS[index]*18)<.1,"Art changed collision-authoritative travel")
	for frame in captures.size(): check(captures[frame].save_png(evidence_path+"motion_frames/frame_%03d.png"%frame)==OK,"Native capture failed")
	FileAccess.open(evidence_path+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	FileAccess.open(evidence_path+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"frames":captures.size(),"chain_seconds":seconds,"directions":4,"campaign_integrated":false},"\t")+"\n")
	for actor in actors: actor.queue_free()
	for runner in runners: runner.queue_free()
	dummy.queue_free()
	await process_frame
	print("TWINSTEEL_CARDINAL checks=%d failures=%d"%[checks,failures])
	quit(1 if failures else 0)

func validate_direction(facing: Vector2,p: Node2D) -> void:
	var root_clip: Resource = PROFILE.attack_for(facing)
	var clips: Array[Resource] = [root_clip]
	clips.append_array(root_clip.follow_up_clips)
	clips.append(PROFILE.idle_for(facing))
	clips.append(PROFILE.run_for(facing))
	for clip in clips:
		check(clip.has_valid_layout(),"Invalid cardinal pose layout")
		check(clip.weapon_texture.get_size()==Vector2(16,62) and clip.offhand.texture.get_size()==Vector2(16,62),"Compact canonical blades grow between states")
		var expected_grip := Vector2(8,44) if facing==Vector2.RIGHT and clip==PROFILE.run_for(facing) else Vector2(8,50)
		check(clip.weapon_primary_grip==expected_grip and clip.offhand.grip==expected_grip,"Compact blade grip leaves its registered carrying/attack handle")
		for key in clip.pose_count:
			p.select_clip(clip)
			p.set_pose(key)
			var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
			var body: Image = clip.body_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
			check(p.weapon_rig.position.is_equal_approx(clip.primary_hands[key]-Vector2(96,64)),"Main hilt detached")
			check(p.offhand_rig.position.is_equal_approx(clip.offhand.hands[key]-Vector2(96,64)),"Far hilt detached")
			if clip.stowed_poses[key]==0:
				for grip in [clip.primary_hands[key]] if not p.offhand_rig.visible else [clip.primary_hands[key],clip.offhand.hands[key]]:
					var c := body.get_pixelv(Vector2i(grip))
					if facing==Vector2.RIGHT and clip==PROFILE.run_for(facing) and grip==clip.offhand.hands[key]:
						# This arm is physically behind the vest, not a second
						# foreground fist. Its grip must be occluded by the body.
						check(c.a>.65 and clip.offhand.behind_body[key]==1 and clip.offhand.texture.get_image().get_region(Rect2i(0,43,16,19)).is_invisible(),"Rear grip exposes a floating fist or handle through the vest")
					else:
						check(c.a>.65 and c.r>c.g*1.35 and c.g>c.b*1.25,"Visible hilt is not on a drawn glove")
			else:
				var back_depth := 0 if facing==Vector2.UP else 1
				check(clip.weapon_behind_body[key]==back_depth and clip.offhand.behind_body[key]==back_depth,"Back stow uses screen depth instead of King's facing")
			check(body.get_used_rect().position.y>0 and body.get_used_rect().end.y<128,"Body is cropped at canvas edge")
			check(connected_body(body),"Head/torso/boots are disconnected: "+clip.resource_path+"/"+str(key))
			var identity: Rect2 = clip.identity_regions[key]
			if facing==Vector2.DOWN and clip==root_clip and key in [1,2,3,4,5,6,7,8,10,11,12]:
				# Fists can stagger independently. Compare the crown to the
				# registered body/sole axis, not the moving hand midpoint.
				check(absf(identity.get_center().x-96)<=3,"Front thrust head shifts sideways off its registered body axis")
			if facing==Vector2.RIGHT and clip==root_clip.follow_up_clips[0] and key in [4,5,6,7,8,10,11,12]:
				check(glove_reaches_boots(body,Vector2i(clip.offhand.hands[key])),"Raised crosscut glove has no continuous sleeve/torso connection: "+str(key))
			if facing==Vector2.RIGHT and clip==PROFILE.run_for(facing):
				var native: Image = NATIVE_SIDE_RUN.body_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
				var reference: Image = NATIVE_SIDE_FACE.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
				var bob := roundi(clip.primary_hands[key].y-clip.primary_hands[0].y)
				var first: Image = clip.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
				check(absi(bob)<=1 and body.get_region(Rect2i(60,32+bob,75,44)).get_data()==first.get_region(Rect2i(60,32,75,44)).get_data(),"Hip carry arms and hilts do not share one coherent upper-body bob")
				check(same_visible_pixels(body.get_region(Rect2i(91,41+bob,25,24)),reference.get_region(Rect2i(87,41,25,24))),"Side walk changes the accepted standing face or neck")
				check(identity==Rect2(91,41+bob,25,24),"Side head registration separates from its scarf socket")
				var rear: Image = clip.offhand.texture.get_image()
				var full: Image = clip.weapon_texture.get_image()
				check(same_visible_pixels(rear.get_region(Rect2i(0,0,16,43)),full.get_region(Rect2i(0,0,16,43))) and rear.get_region(Rect2i(0,43,16,19)).is_invisible(),"Far side sword exposes a handle or changes its canonical blade")
				check(p.weapon_rig.get_index()>p.body_sprite.get_index() and p.offhand_rig.get_index()<p.body_sprite.get_index() and p.hand_sprite.get_index()>p.weapon_rig.get_index(),"Lower-hand sword or foreground fingers use the wrong physical depth")
				check(p.to_local(p.weapon_sprite.to_global(Vector2(8,41))).distance_to(p.weapon_rig.position)<=3.1,"Near sword guard sits too far from its actual fist")
				check(clip.primary_hands[key]==Vector2(87,74+bob) and clip.offhand.hands[key]==Vector2(91,69+bob),"Side sword grip leaves the sketch's lower hand or tucked rear arm")
				var intact: Image = NATIVE_SIDE_RUN.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
				check(same_visible_pixels(body.get_region(Rect2i(96,65+bob,6,6)),intact.get_region(Rect2i(96,65,6,6))),"Side forearm extraction cuts or moves the original central chest")
				check(preserves_opaque_pixels(body.get_region(Rect2i(84,71+bob,6,6)),intact.get_region(Rect2i(81,70,6,6))),"Lower closed palm is cropped or rotated away from its source anatomy")
				var fingers: Image = clip.hand_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
				check(fingers.get_pixelv(Vector2i(clip.primary_hands[key]))==body.get_pixelv(Vector2i(clip.primary_hands[key])) and fingers.get_region(Rect2i(96,65+bob,6,6)).is_invisible(),"Foreground mask misses the actual palm or covers the chest with false armor")
				check(not fingers.get_region(Rect2i(77,77,20,5)).is_invisible(),"The forearm is sliced at the walking pelvis seam")
				check(same_pixels_outside_mask(body,native,fingers,Rect2i(0,77,192,51)),"Steady carry changes the accepted leg cycle outside its real foreground arm")
				check(clip.offhand.hands[key]-clip.primary_hands[key]==clip.offhand.hands[0]-clip.primary_hands[0] and (clip.secondary_hands[key]-clip.primary_hands[key]).is_equal_approx(clip.secondary_hands[0]-clip.primary_hands[0]) and (clip.offhand.axes[key]-clip.offhand.hands[key]).is_equal_approx(clip.offhand.axes[0]-clip.offhand.hands[0]),"Running hands and blades do not share the steady carry pose")
			else:
				check(identity.size.x>=23 and identity.size.x<=25 and identity.size.y>=22 and identity.size.y<=24,"Head scale grows between states: "+clip.resource_path+"/"+str(key))
			check(body.get_used_rect().size.y<=60,"Body exceeds the heavy-family size envelope: "+clip.resource_path+"/"+str(key))
			if clip!=PROFILE.idle_for(facing) and clip!=PROFILE.run_for(facing):
				check(body.get_used_rect().end.y-1==94,"Grounded attack sole drifts before explicit hop lift")
			if clip==PROFILE.idle_for(facing) or clip==PROFILE.run_for(facing):
				var running: bool = clip==PROFILE.run_for(facing)
				if running:
					var aim := Vector2.RIGHT if facing==Vector2.RIGHT else facing
					check(p._weapon_basis_for(key).basis_xform(clip.weapon_tip-clip.weapon_primary_grip).normalized().dot(aim)>.7 and clip.offhand.basis_for(key,clip.cell_size).basis_xform(clip.offhand.tip-clip.offhand.grip).normalized().dot(aim)>.7,"Both running swords must point forward")
					if facing in [Vector2.UP,Vector2.DOWN]:
						var main_basis: Transform2D = p._weapon_basis_for(key)
						var off_basis: Transform2D = clip.offhand.basis_for(key,clip.cell_size)
						var main_end: Vector2 = main_basis*(clip.weapon_tip-clip.weapon_primary_grip)
						var off_end: Vector2 = off_basis*(clip.offhand.tip-clip.offhand.grip)
						var main_tilt := main_end.x-main_basis.origin.x
						var off_tilt := off_end.x-off_basis.origin.x
						check(main_tilt<0 and main_tilt>-3 and off_tilt>0 and off_tilt<3 and Geometry2D.segment_intersects_segment(main_basis.origin,main_end,off_basis.origin,off_end)==null,"Cardinal swords must have a tiny outward tilt without crossing")
						var bob := roundi(clip.primary_hands[key].y-clip.primary_hands[0].y)
						var first: Image = clip.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
						check(same_visible_pixels(body.get_region(Rect2i(60,32+bob,75,44)),first.get_region(Rect2i(60,32,75,44))) and clip.primary_hands[key].x==clip.primary_hands[0].x and clip.offhand.hands[key].x==clip.offhand.hands[0].x,"Cardinal upper body and grips sway sideways across the run")
						if facing==Vector2.DOWN:
							var native_first: Image = NATIVE_FRONT.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
							var native_stride: Image = NATIVE_FRONT.body_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
							var shift := 94-(native_first.get_used_rect().end.y-1)
							# Compare the entire head/neck/chest/gloves above the
							# fixed pelvis seam, even on the positive bob keys.
							check(same_visible_pixels(body.get_region(Rect2i(60,32+shift+bob,75,42)),native_first.get_region(Rect2i(60,32,75,42))),"Front walk grafts a displaced head onto a different torso")
							check(identity==Rect2(84,40+shift+bob,24,24),"Front walk head metadata drifts from the actual native upper body")
							check(same_visible_pixels(body.get_region(Rect2i(0,77,192,51)),native_stride.get_region(Rect2i(0,77-shift,192,51))),"Front walk replaces the complete native stride below its hip seam")
						elif facing==Vector2.UP:
							for pelvis_y in [78,79]:
								var low := 192
								var high := -1
								for pelvis_x in range(70,125):
									if body.get_pixel(pelvis_x,pelvis_y).a>.65: low=mini(low,pelvis_x); high=maxi(high,pelvis_x)
								check(high>=low and absf((low+high)*.5-96.0)<=.5,"Upward walking pelvis drifts sideways from the fixed torso")
							var ankle := body.get_region(Rect2i(70,89,55,7)).get_used_rect()
							check(ankle.has_area() and ankle.position.x+70>=88 and ankle.end.x+70<=106,"Upward boots step outside the aligned leg lanes")
				else:
					if facing==Vector2.DOWN:
						var native: Image = NATIVE_FRONT.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
						var shift := 94-(native.get_used_rect().end.y-1)
						check(body.get_region(Rect2i(60,32+shift,75,44)).get_data()==native.get_region(Rect2i(60,32,75,44)).get_data(),"Front idle changes the accepted head/neck/torso")
						check(body.get_used_rect().end.y-1==94,"Front idle does not share the grounded attack sole")
						var left_foot := body.get_region(Rect2i(60,86,36,20)).get_used_rect()
						var right_foot := body.get_region(Rect2i(96,86,36,20)).get_used_rect()
						check(left_foot.has_area() and right_foot.has_area() and left_foot.end.y==9 and right_foot.end.y==9,"Front idle leaves one foot behind the other instead of planting both")
						check(body.get_region(Rect2i(96,89,1,6)).is_invisible(),"Planted feet merge into one central boot")
					else:
						check(body.get_used_rect().size.y==54,"Side/back idle size changed")
					var hand_image: Image = clip.hand_atlas.get_image().get_region(Rect2i(origin,Vector2i(192,128)))
					check(hand_image.is_invisible(),"Back stow leaves a false holding-hand overlay")
				var main_tip: Vector2 = p._weapon_basis_for(key)*(clip.weapon_tip-clip.weapon_primary_grip)
				var off_tip: Vector2 = clip.offhand.basis_for(key,clip.cell_size)*(clip.offhand.tip-clip.offhand.grip)
				if not running: check(main_tip.y<=31 and off_tip.y<=31,"Stowed pair falls below registered soles")
		if clip.interpolate_blade_angles:
			p.set_pose(4)
			var main: Transform2D = p.weapon_rig.transform
			var off: Transform2D = p.offhand_rig.transform
			p._advance_pose(4.5)
			check(p.weapon_rig.position==main.origin and p.offhand_rig.position==off.origin,"Interpolated steel slides away from gloves")
			check(p.hand_sprite.transform==Transform2D.IDENTITY,"Angle interpolation rotates the glove overlay")
			var expected := lerp_angle(main.get_rotation(),p._weapon_basis_for(5).get_rotation(),.5)
			check(absf(angle_difference(p.weapon_rig.rotation,expected))<.0001,"Rigid steel does not interpolate between cels: "+clip.resource_path)
	for cut in 4:
		var a: Resource = clips[cut]
		var b: Resource = clips[cut+1]
		check(a.body_atlas.get_image().get_region(Rect2i(0,384,192,128)).get_data()==b.body_atlas.get_image().get_region(Rect2i(0,0,192,128)).get_data(),"Queued whole body snaps at next opening")
		check(a.primary_hands[12]==b.primary_hands[0] and a.offhand.hands[12]==b.offhand.hands[0],"Queued hilt positions reset")
		check(a.offhand.visible_poses[12]==b.offhand.visible_poses[0],"Queued far-hand occlusion pops")
	var spin: Resource = clips[3]
	check(Array(spin.lift_pixels).min()==-12 and spin.lift_pixels[0]==0 and spin.lift_pixels[8]==0 and spin.lift_pixels[12]==0,"Spin must hop then land without a scale tween")
	var first: Resource = clips[0]
	var thrust_aim := Vector2.RIGHT if facing==Vector2.RIGHT else facing
	p.select_clip(first)
	for key in [4,5,6]:
		check(p._weapon_basis_for(key).basis_xform(first.weapon_tip-first.weapon_primary_grip).normalized().dot(thrust_aim)>.95 and first.offhand.basis_for(key,first.cell_size).basis_xform(first.offhand.tip-first.offhand.grip).normalized().dot(thrust_aim)>.95,"Opening pair does not thrust forward")

func same_visible_pixels(a: Image,b: Image) -> bool:
	# Import's alpha-border repair can change RGB in fully transparent texels
	# next to different legs. Compare actual anatomy, including alpha edges.
	if a.get_size()!=b.get_size(): return false
	for y in a.get_height():
		for x in a.get_width():
			var first := a.get_pixel(x,y)
			var second := b.get_pixel(x,y)
			if first.a==0 and second.a==0: continue
			if first!=second: return false
	return true

func preserves_opaque_pixels(actual: Image,source: Image) -> bool:
	for y in source.get_height():
		for x in source.get_width():
			if source.get_pixel(x,y).a>.65 and actual.get_pixel(x,y)!=source.get_pixel(x,y): return false
	return true

func same_pixels_outside_mask(actual: Image,source: Image,mask: Image,region: Rect2i) -> bool:
	for y in range(region.position.y,region.end.y):
		for x in range(region.position.x,region.end.x):
			if mask.get_pixel(x,y).a>.65: continue
			var a := actual.get_pixel(x,y)
			var b := source.get_pixel(x,y)
			if (a.a>0 or b.a>0) and a!=b: return false
	return true

func glove_reaches_boots(body: Image,glove: Vector2i) -> bool:
	var seen := {}
	var todo: Array[Vector2i] = [glove]
	seen[glove]=true
	var cursor := 0
	while cursor<todo.size():
		var point := todo[cursor]
		cursor+=1
		if point.y>=90: return true
		for dy in range(-1,2):
			for dx in range(-1,2):
				var next := point+Vector2i(dx,dy)
				if next.x<0 or next.x>=192 or next.y<0 or next.y>=128 or seen.has(next) or body.get_pixelv(next).a<.65: continue
				seen[next]=true
				todo.append(next)
	return false

func connected_body(body: Image) -> bool:
	var seen := {}
	var largest := 0
	var total := 0
	for y in 128:
		for x in 192:
			var seed := Vector2i(x,y)
			if body.get_pixelv(seed).a<.65: continue
			total+=1
			if seen.has(seed): continue
			var todo: Array[Vector2i] = [seed]
			seen[seed]=true
			var cursor := 0
			while cursor<todo.size():
				var point := todo[cursor]
				cursor+=1
				for dy in range(-1,2):
					for dx in range(-1,2):
						var next := point+Vector2i(dx,dy)
						if next.x<0 or next.x>=192 or next.y<0 or next.y>=128 or seen.has(next) or body.get_pixelv(next).a<.65: continue
						seen[next]=true
						todo.append(next)
			largest=maxi(largest,todo.size())
	return largest>=total*.94
