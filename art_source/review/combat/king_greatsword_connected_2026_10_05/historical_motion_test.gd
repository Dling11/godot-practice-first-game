extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const PLAYER = preload("res://entities/player/player.tscn")
const OUT := "res://art_source/review/combat/king_greatsword_connected_2026_10_05/"
var actors: Array[Player] = []
var images: Array[Image] = []
var timeline: Array[Dictionary] = []
var began: Array[Array] = [[],[],[],[]]

func _run() -> void:
	root.size = Vector2i(1000,800)
	root.content_scale_size = Vector2i(1000,800)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	var background := ColorRect.new()
	background.color = Color("202b30")
	background.size = Vector2(1000,800)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(background)
	var directions := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
	var positions := [Vector2(190,245),Vector2(800,245),Vector2(235,665),Vector2(740,630)]
	for index in 4:
		var label := Label.new()
		label.position = Vector2((index%2)*500+18,(index/2)*400+16)
		label.text = ["RIGHT · connected two-hand cuts","LEFT · mirrored grips and motion","UP · back view","DOWN · front view"][index]
		root.add_child(label)
		var actor: Player = PLAYER.instantiate()
		actor.position = positions[index]
		actor.movement_bounds = Rect2(0,0,1000,800)
		actor.scale = Vector2.ONE*2.5
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.equip_owned_weapon(ITEM),"Cannot equip native motion fixture")
		actor._set_facing_direction(directions[index])
		var rig := actor.get_node("WeaponFamilyPresentation")
		check(rig.presenter.visible,"Direction fell back to the old sword")
		actor.attack_component.attack_started.connect(func() -> void: began[index].append(actor.attack_component.combo_step))
		actor.attack_component.phase_changed.connect(func(phase: int,_seconds: float) -> void:
			if phase==MeleeAttackComponent.Phase.ACTIVE and actor.attack_component.combo_step<4: actor.request_primary_attack()
		)
		actors.append(actor)
	_validate_tracks()
	_validate_style()
	DirAccess.make_dir_recursive_absolute(OUT+"motion_frames/")
	var render := DisplayServer.get_name()!="headless" and OS.get_cmdline_user_args().has("--capture")
	for frame in 160:
		if frame==8:
			for actor in actors: check(actor.request_primary_attack(),"Primary combo refused")
		await process_frame
		await process_frame
		if render:
			await RenderingServer.frame_post_draw
			images.append(root.get_texture().get_image())
		var record := {"frame":frame,"file":"motion_frames/frame_%03d.png"%frame,"elapsed_ms":roundi(frame*1000.0/30.0),"directions":[]}
		for actor in actors:
			var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
			record.directions.append({"phase":actor.attack_component.phase,"step":actor.attack_component.combo_step,"pose":presenter.pose_index,"grip":var_to_str(presenter.weapon_rig.position),"blade_degrees":rad_to_deg(presenter.weapon_rig.rotation),"arm_reach_error":presenter.arm_rig.reach_error})
		timeline.append(record)
	for index in 4:
		check(began[index]==[0,1,2,3,4],"Real input dropped/repeated a cut: "+str(began[index]))
		check(actors[index].attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Combo did not complete")
		check(actors[index].position.distance_to(positions[index]+directions[index]*46)<.1,"Presentation changed physical step distance")
		# Fixed capture includes settlement and idle; no frozen body remains.
		var rig := actors[index].get_node("WeaponFamilyPresentation")
		check(rig.presenter.definition==ITEM.weapon_definition.family_presentation.idle_for(directions[index]),"Combo did not return to its directional carry")
	for index in images.size(): check(images[index].save_png(OUT+"motion_frames/frame_%03d.png"%index)==OK,"Native capture failed")
	FileAccess.open(OUT+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	FileAccess.open(OUT+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"rendered_frames":images.size(),"timing_seconds":4.26,"steel_size":[30,140]},"\t")+"\n")
	for actor in actors: actor.queue_free()
	await process_frame
	print("Connected greatsword: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)

func _validate_tracks() -> void:
	for actor in actors:
		var rig := actor.get_node("WeaponFamilyPresentation")
		var presenter: Node2D = rig.presenter
		var root_clip: Resource = rig.profile.attack_for(actor.facing_direction)
		var clips: Array[Resource] = [root_clip]
		clips.append_array(root_clip.follow_up_clips)
		for cut in 5:
			var clip: Resource = clips[cut]
			check(clip.has_valid_layout() and clip.pose_count==20,"Invalid two-hand track")
			check(clip.weapon_texture.get_size()==Vector2(30,140),"Sword size changed")
			presenter.select_clip(clip)
			presenter._motion_entry_valid = false
			for sample in 77:
				var value := sample*.25
				presenter._advance_pose(value)
				var basis: Transform2D = presenter.weapon_rig.transform
				check(presenter.arm_rig.wrists[1].distance_to(basis.origin)<.01,"Leading hand loses the hilt")
				if value>=5 and value<=16:
					check(presenter.arm_rig.wrists[0].distance_to(basis*(clip.weapon_support_grip-clip.weapon_primary_grip))<.01,"Support hand slides off the handle")
				check(presenter.arm_rig.reach_error<.05,"Arm cannot reach its registered grip: "+str(actor.facing_direction)+" cut="+str(cut)+" sample="+str(value)+" error="+str(presenter.arm_rig.reach_error))
				check(is_equal_approx(absf(basis.determinant()),1),"Steel stretches during animation")
			for key in range(6,11):
				var turn: float = clip.weapon_angles[key+1]-clip.weapon_angles[key]
				check(turn<0 if cut==1 else turn>=0,"Contact reverses its authored stroke")
			if cut<4:
				presenter.set_pose(19)
				var pixels: PackedByteArray = presenter.body_sprite.texture.get_image().get_data()
				var endpoint: Transform2D = presenter.weapon_rig.transform
				presenter.select_clip(clips[cut+1])
				presenter.set_pose(0)
				check(pixels==presenter.body_sprite.texture.get_image().get_data() and endpoint.is_equal_approx(presenter.weapon_rig.transform),"Recovery→next windup snaps")
		presenter._carry()
		check(presenter.weapon_rig.get_index()>presenter.body_sprite.get_index() and presenter.hand_sprite.get_index()>presenter.weapon_rig.get_index(),"Carry hilt/glove is hidden by sibling order")

func _validate_style() -> void:
	var source := "res://art_source/generated/characters/king/greatsword_connected_2026_10_05/"
	var reference := Image.load_from_file(source+"protected_body_reference.png")
	var registration: Dictionary = JSON.parse_string(FileAccess.get_file_as_string(source+"registration.json"))
	for actor in [actors[0],actors[2],actors[3]]:
		var row := 0 if actor.facing_direction==Vector2.RIGHT else (2 if actor.facing_direction==Vector2.UP else 1)
		var first: Resource = ITEM.weapon_definition.family_presentation.attack_for(actor.facing_direction)
		var clips: Array[Resource] = [first]
		clips.append_array(first.follow_up_clips)
		for clip in clips:
			var atlas: Image = clip.body_atlas.get_image()
			for key in clip.pose_count:
				var body := atlas.get_region(Rect2i(key%4*192,key/4*128,192,128))
				var head_matches := false
				var boots_match := false
				for column in 4:
					var original := reference.get_region(Rect2i(column*192,row*128,192,128))
					var head: Rect2i = str_to_var(registration.source_frames[row*4+column].protected_head)
					head_matches = head_matches or _same_opaque(original,body,head)
					boots_match = boots_match or _same_opaque(original,body,Rect2i(0,86,192,42))
				check(head_matches,"Generated motion changed King's installed head/face pixels")
				check(boots_match,"Generated motion changed the installed boot pixels/foot baseline")

func _same_opaque(original: Image, candidate: Image, region: Rect2i) -> bool:
	for y in range(region.position.y,region.end.y):
		for x in range(region.position.x,region.end.x):
			var c := original.get_pixel(x,y)
			var actual := candidate.get_pixel(x,y)
			if c.a!=actual.a or (c.a>.5 and c!=actual): return false
	return true
