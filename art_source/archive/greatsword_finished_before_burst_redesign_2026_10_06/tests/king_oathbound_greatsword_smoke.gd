extends "res://tests/sanctuary_test_base.gd"

const ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const AXE = preload("res://data/items/equipment/king_iron_beard_axe.tres")
const PLAYER = preload("res://entities/player/player.tscn")
const OUT := "res://art_source/review/combat/king_greatsword_readability_2026_10_05/"
var evidence_path := OUT
var actors: Array[Player] = []
var began: Array[Array] = [[],[],[],[],[]]
var images: Array[Image] = []
var timeline: Array[Dictionary] = []
var chain := true

func _initialize() -> void:
	for argument in OS.get_cmdline_user_args():
		if argument.begins_with("--output=res://art_source/review/"):
			evidence_path = argument.trim_prefix("--output=").trim_suffix("/")+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(evidence_path))
	super._initialize()

func _run() -> void:
	root.size = Vector2i(1200,800)
	root.content_scale_size = Vector2i(1200,800)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("WeaponInventory").reset_inventory()
	root.get_node("WeaponInventory").acquire_weapon(ITEM)
	root.get_node("WeaponInventory").acquire_weapon(AXE)
	var background := ColorRect.new()
	background.color = Color("202b30")
	background.size = Vector2(1200,800)
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(background)
	for index in 5:
		var label := Label.new()
		label.position = [Vector2(18,18),Vector2(418,18),Vector2(18,418),Vector2(418,418),Vector2(818,18)][index]
		label.text = ["OATHBOUND · right","OATHBOUND · left","OATHBOUND · up / back","OATHBOUND · down / front","AXE · unchanged benchmark"][index]
		root.add_child(label)
	var note := Label.new()
	note.position = Vector2(820,420)
	note.text = "New five-cut sequence\nInstalled King identity\nFourth / fifth both 0.54s"
	root.add_child(note)
	var positions := [Vector2(170,230),Vector2(650,230),Vector2(200,690),Vector2(595,530),Vector2(1035,240)]
	var directions := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN,Vector2.RIGHT]
	for index in 5:
		var actor: Player = PLAYER.instantiate()
		actor.position = positions[index]
		actor.movement_bounds = Rect2(0,0,4000,1000)
		actor.scale = Vector2.ONE*2.5
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.equip_owned_weapon(AXE if index==4 else ITEM),"Cannot equip comparison actor")
		actor._set_facing_direction(directions[index])
		actor.attack_component.attack_started.connect(func() -> void: began[index].append(actor.attack_component.combo_step))
		actor.attack_component.phase_changed.connect(func(phase: int,_seconds: float) -> void:
			if phase==MeleeAttackComponent.Phase.ACTIVE and index<4:
				var family := actor.get_node("WeaponFamilyPresentation")
				if actor.attack_component.combo_step==2:
					var tip_world: Vector2 = family.presenter.get_parent().to_global(family.presenter.get_contact_tip_in_parent())
					check(actor.to_local(tip_world).dot(actor.facing_direction)>0,"Slam contact points away from the enemy")
					var aligned := false
					for burst in family.impacts.get_children():
						if burst.row==1: aligned = burst.global_position.distance_to(tip_world)<.01
					check(aligned,"Slam dust does not meet the registered blade tip")
				else:
					check(family.trail.frame_sample_transforms.is_empty(),"Ordinary white arcs still use the miniature meteor mapping")
			if chain and phase==MeleeAttackComponent.Phase.ACTIVE and actor.attack_component.combo_step<4: actor.request_primary_attack()
			if phase==MeleeAttackComponent.Phase.RECOVERY and index<4:
				var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
				check(presenter._queued_recovery_active==(chain and actor.attack_component.combo_step<4),"Recovery ignores the actual buffer state")
		)
		actors.append(actor)
	_validate_authored_clips()
	var seconds := 0.0
	for cut in 5: seconds += ITEM.weapon_definition.combo.windups[cut]+ITEM.weapon_definition.combo.contacts[cut]+ITEM.weapon_definition.combo.recoveries[cut]
	check(is_equal_approx(seconds,3.0),"Oathbound chain is not3.00s")
	var combo: Resource = ITEM.weapon_definition.combo
	check(is_equal_approx(combo.windups[3]+combo.contacts[3]+combo.recoveries[3],combo.windups[4]+combo.contacts[4]+combo.recoveries[4]),"Fourth and fifth pacing differ")
	DirAccess.make_dir_recursive_absolute(evidence_path+"motion_frames/")
	var render := DisplayServer.get_name()!="headless" and OS.get_cmdline_user_args().has("--capture")
	for frame in 130:
		if frame==8:
			for actor in actors: check(actor.request_primary_attack(),"Comparison primary refused")
		await process_frame
		await process_frame
		if render:
			await RenderingServer.frame_post_draw
			images.append(root.get_texture().get_image())
		var states: Array[Dictionary] = []
		for actor in actors:
			var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
			states.append({"step":actor.attack_component.combo_step,"phase":actor.attack_component.phase,"pose":presenter.pose_index,"grip":var_to_str(presenter.weapon_rig.position),"blade_degrees":rad_to_deg(presenter.weapon_rig.rotation)})
		timeline.append({"frame":frame,"file":"motion_frames/frame_%03d.png"%frame,"elapsed_ms":roundi(frame*1000.0/30.0),"actors":states})
	for index in 5:
		check(began[index]==[0,1,2,3,4],"Buffered input dropped a cut: "+str(began[index]))
		check(actors[index].attack_component.phase==MeleeAttackComponent.Phase.IDLE,"Comparison did not complete")
		if index<4:
			check(actors[index].position.distance_to(positions[index]+directions[index]*46)<.1,"Presentation changed physical travel")
			check(actors[index].get_node("WeaponFamilyPresentation").presenter.definition==ITEM.weapon_definition.family_presentation.idle_for(directions[index]),"Released combo lost carry")
	# Released recovery chooses its separate authored path and ends on carry.
	chain = false
	for cut in 5:
		var actor: Player = actors[0]
		var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		var before: Transform2D = presenter.weapon_rig.transform
		var body: PackedByteArray = presenter.body_sprite.texture.get_image().get_data()
		actor.attack_component._next_combo_step = cut
		actor.request_primary_attack()
		check(before.is_equal_approx(presenter.weapon_rig.transform) and body==presenter.body_sprite.texture.get_image().get_data(),"Standalone input teleports into a prior chamber")
		while actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE:
			await physics_frame
		check(actor.get_node("WeaponFamilyPresentation").presenter.definition==ITEM.weapon_definition.family_presentation.idle_poses,"Standalone cut leaves a chamber/frozen rig")
	for frame in images.size(): check(images[frame].save_png(evidence_path+"motion_frames/frame_%03d.png"%frame)==OK,"Capture failed")
	FileAccess.open(evidence_path+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
	FileAccess.open(evidence_path+"validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"rendered_frames":images.size(),"greatsword_seconds":seconds,"axe_seconds":3.6,"modular_arms":false,"steel_size":[30,140]},"\t")+"\n")
	for actor in actors: actor.queue_free()
	await process_frame
	print("Oathbound greatsword: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)

func _validate_authored_clips() -> void:
	for actor in actors.slice(0,4):
		var profile: Resource = ITEM.weapon_definition.family_presentation
		var first: Resource = profile.attack_for(actor.facing_direction)
		var carry: Resource = profile.idle_for(actor.facing_direction)
		var carry_image: Image = carry.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		var clips: Array[Resource] = [first]
		clips.append_array(first.follow_up_clips)
		var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		for cut in 5:
			var clip: Resource = clips[cut]
			check(clip.has_valid_layout() and clip.pose_count==13,"Invalid authored motion branch")
			check(clip.body_atlas.resource_path.begins_with("res://assets/characters/playable/king/greatsword_oathbound/"),"Rejected attack artwork remains installed")
			check(clip.weapon_texture.get_size()==Vector2(30,140),"Steel size changed")
			presenter.select_clip(clip)
			for pose in 13:
				presenter.set_pose(pose)
				var pixels: Image = presenter.body_sprite.texture.get_image()
				var identity := Rect2i(clip.identity_regions[pose])
				var key := "%s cut %d pose %d"%[actor.facing_direction,cut,pose]
				var source_identity := Rect2i(clip.identity_source_region)
				var hands: Image = presenter.hand_sprite.texture.get_image()
				check(_identity_core_matches(pixels,hands,carry_image,identity,source_identity),"Attack changes installed face/lower hair: "+key)
				check(_crown_covered(pixels,carry_image,identity,source_identity),"Head silhouette is clipped: "+key)
				check(pixels.get_used_rect().end.y==carry_image.get_used_rect().end.y,"Grounded body bounces/crops at its boots: "+key)
				check(pixels.get_used_rect().position.y>0 and pixels.get_used_rect().end.x<192 and pixels.get_used_rect().position.x>0,"Complete body crosses a cel boundary: "+key)
				var joined := _head_reach(pixels,identity)
				check(joined.lower_pixels>=50,"Head is detached from torso: "+key)
				check(joined.seen[roundi(clip.primary_hands[pose].y)*192+roundi(clip.primary_hands[pose].x)]>0,"Drawn glove is detached from head/body: "+key)
				check(pixels.get_pixelv(Vector2i(clip.primary_hands[pose])).a>.5,"Hilt loses drawn hand: "+key)
				check(presenter.weapon_rig.position.is_equal_approx(clip.primary_hands[pose]-Vector2(96,64)),"Weapon floats off the complete pose")
				check(is_equal_approx(absf(presenter.weapon_rig.transform.determinant()),1),"Steel is stretched")
				check(presenter.hand_sprite.visible,"Drawn glove overlay hidden")
			if cut<4:
				presenter.set_pose(12)
				var pixels: PackedByteArray = presenter.body_sprite.texture.get_image().get_data()
				var basis: Transform2D = presenter.weapon_rig.transform
				presenter.select_clip(clips[cut+1])
				presenter.set_pose(0)
				check(pixels==presenter.body_sprite.texture.get_image().get_data() and basis.is_equal_approx(presenter.weapon_rig.transform),"Drawn queued handoff resets the pose")
		presenter._carry()

func _identity_core_matches(image: Image,hands: Image,carry: Image,target: Rect2i,source: Rect2i,start_fraction := .4) -> bool:
	var count := 0
	for y in range(roundi(source.size.y*start_fraction),source.size.y):
		for x in source.size.x:
			var original := carry.get_pixelv(source.position+Vector2i(x,y))
			if original.a<.999: continue
			count += 1
			var point := target.position+Vector2i(x,y)
			var actual := image.get_pixelv(point)
			if actual.to_rgba32()==original.to_rgba32(): continue
			# Only a registered foreground brown glove can occlude the head.
			if actual.r>.18 and actual.r<.8 and actual.r>actual.g*1.35 and actual.g>actual.b*1.25 and hands.get_pixelv(point).to_rgba32()==actual.to_rgba32(): continue
			return false
	return count>=25

func _crown_covered(image: Image,carry: Image,target: Rect2i,source: Rect2i) -> bool:
	for y in source.size.y:
		for x in source.size.x:
			if carry.get_pixelv(source.position+Vector2i(x,y)).a>.99 and image.get_pixelv(target.position+Vector2i(x,y)).a<.5: return false
	return true

func _head_reach(image: Image,head: Rect2i) -> Dictionary:
	var seed := Vector2i(head.get_center())
	var seen := PackedByteArray()
	seen.resize(192*128)
	if image.get_pixelv(seed).a<.5: return {"seen":seen,"lower_pixels":0}
	var todo := PackedInt32Array([seed.y*192+seed.x])
	seen[todo[0]] = 1
	var cursor := 0
	var below := 0
	while cursor<todo.size():
		var id := todo[cursor]
		cursor += 1
		if id/192>head.end.y+3: below += 1
		for dy in range(-1,2):
			for dx in range(-1,2):
				var point := Vector2i(id%192+dx,id/192+dy)
				if point.x<0 or point.x>=192 or point.y<0 or point.y>=128: continue
				var next := point.y*192+point.x
				if seen[next] or image.get_pixelv(point).a<.5: continue
				seen[next] = 1
				todo.append(next)
	return {"seen":seen,"lower_pixels":below}
