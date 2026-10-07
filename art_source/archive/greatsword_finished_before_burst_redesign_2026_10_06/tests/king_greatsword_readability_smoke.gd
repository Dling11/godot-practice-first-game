extends "res://tests/king_oathbound_greatsword_smoke.gd"

## Actual Player phase movement plus native vertical rest / side identity.
func _run() -> void:
	root.size = Vector2i(1400,850)
	root.content_scale_size = root.size
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var inventory := root.get_node("WeaponInventory")
	inventory.reset_inventory()
	inventory.acquire_weapon(ITEM)
	inventory.acquire_weapon(AXE)
	var background := ColorRect.new()
	background.color = Color("202b30")
	background.size = root.size
	background.mouse_filter = Control.MOUSE_FILTER_IGNORE
	root.add_child(background)
	var directions := [Vector2.RIGHT,Vector2.LEFT,Vector2.UP,Vector2.DOWN]
	for index in 4:
		var actor: Player = PLAYER.instantiate()
		actor.position = [Vector2(230,300),Vector2(900,300),Vector2(230,720),Vector2(900,720)][index]
		actor.scale = Vector2.ONE*3
		actor.movement_bounds = Rect2(0,0,2000,1600)
		root.add_child(actor)
		actor.set_physics_process(false)
		actor.set_process_unhandled_input(false)
		check(actor.equip_owned_weapon(ITEM),"Cannot equip greatsword")
		actor._set_facing_direction(directions[index])
		actors.append(actor)
		var title := Label.new()
		title.text = ["RIGHT · accepted proud idle","LEFT · accepted proud idle","UP · new proud idle","DOWN · new proud idle"][index]
		title.position = [Vector2(28,28),Vector2(730,28),Vector2(28,450),Vector2(730,450)][index]
		root.add_child(title)
	_validate_new_art()
	var render := DisplayServer.get_name()!="headless"
	for actor in actors:
		var presenter: Node2D = actor.get_node("WeaponFamilyPresentation").presenter
		presenter._rest_timer.stop()
		presenter._rest()
	for tick in 38: await physics_frame
	for actor in actors:
		var family := actor.get_node("WeaponFamilyPresentation")
		var p: Node2D = family.presenter
		check(p._resting and p.pose_index==7,"Direction has no complete proud idle")
		check(p.definition==ITEM.weapon_definition.family_presentation.idle_for(actor.facing_direction),"Proud rest uses a different facing")
		check(p.hand_sprite.texture.get_image().get_used_rect().size==Vector2i.ZERO,"Crossed arms still hold a planted grip")
		var tip: Vector2 = p.weapon_rig.transform*(p.definition.weapon_tip-p.definition.weapon_primary_grip)
		var ground: Vector2 = p.get_plant_ground_position()
		check(is_equal_approx(tip.x,ground.x) and is_equal_approx(tip.y-ground.y,10),"Proud blade is off its registered shallow plant")
		check(is_instance_valid(family._plant_marker),"Direction did not get its planting contact")
		check(family.trail.get_index()<actor.get_node("VisualRoot").get_index(),"Upward FX paint after King")
		check(family.trail.z_index==(0 if actor.facing_direction==Vector2.UP else 3),"Arc depth is wrong for facing")
	if render:
		await RenderingServer.frame_post_draw
		root.get_texture().get_image().save_png(evidence_path+"proud_all_directions.png")
	# Vertical retrieval must still give actual Player the attack, without
	# moving the collision body or retaining the cosmetic ground marker.
	for actor: Player in actors.slice(2,4):
		var family := actor.get_node("WeaponFamilyPresentation")
		var before := actor.global_position
		check(actor.request_primary_attack() and family.presenter._drawing,"Vertical rest cannot retrieve into attack")
		for tick in 18: await physics_frame
		check(actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE,"Vertical draw did not start actual melee")
		check(actor.global_position.distance_to(before)<13,"Drawing planted steel moved the collision body")
		check(not is_instance_valid(family._plant_marker),"Planted marker stays after retrieval")
		actor._clear_buffered_action()
		actor.attack_component.cancel_attack()
	if render: await _verify_upward_visibility(actors[2])
	await _verify_phase_movement(actors[0])
	for actor in actors: actor.queue_free()
	await process_frame
	FileAccess.open(evidence_path+"readability_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"greatsword_walk_ratios":[.25,0,.6],"vertical_proud_idle":true,"native":render},"\t")+"\n")
	print("Greatsword readability / movement: %d checks, %d failures"%[checks,failures])
	quit(1 if failures else 0)

func _verify_upward_visibility(actor: Player) -> void:
	var family := actor.get_node("WeaponFamilyPresentation")
	var presenter: Node2D = family.presenter
	for cut in 5:
		actor.attack_component._next_combo_step = cut
		check(actor.request_primary_attack(),"Upward visibility cut refused")
		while actor.attack_component.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
		paused = true
		family.trail.hide()
		family.impacts.hide()
		await RenderingServer.frame_post_draw
		var reference := root.get_texture().get_image()
		family.trail.show()
		family.impacts.show()
		await RenderingServer.frame_post_draw
		var rendered := root.get_texture().get_image()
		var body: Image = presenter.body_sprite.texture.get_image()
		var samples := 0
		var hidden := 0
		for y in range(1,127):
			for x in range(1,191):
				# Interior pixels avoid legitimate alpha silhouette blending.
				if body.get_pixel(x,y).a<.999 or body.get_pixel(x-1,y).a<.999 or body.get_pixel(x+1,y).a<.999 or body.get_pixel(x,y-1).a<.999 or body.get_pixel(x,y+1).a<.999: continue
				var world: Vector2 = presenter.body_sprite.to_global(Vector2(x+.5-96,y+.5-64))
				var pixel := Vector2i(world.floor())
				samples += 1
				if rendered.get_pixelv(pixel).to_rgba32()!=reference.get_pixelv(pixel).to_rgba32(): hidden += 1
		check(samples>=200,"Upward body verification has too few visible samples")
		check(hidden==0,"Upward contact FX hide body pixels: "+str(hidden))
		rendered.save_png(evidence_path+"up_contact_%d.png"%cut)
		paused = false
		actor.attack_component.cancel_attack()

func _verify_phase_movement(actor: Player) -> void:
	var attack := actor.attack_component
	var family := actor.get_node("WeaponFamilyPresentation")
	family.presenter.cancel_presentation_transition()
	actor._set_facing_direction(Vector2.RIGHT)
	actor.attack_component.reset_combo()
	actor.velocity = Vector2.RIGHT*actor.movement_component.max_speed
	Input.action_press("player_move_right")
	await process_frame
	check(actor.request_primary_attack(),"Moving primary refused")
	actor._physics_process(1.0/60.0)
	check(actor.velocity.x>0 and actor.velocity.length()<=actor.movement_component.max_speed*.25+.01,"Windup coasts at full walking speed")
	while attack.phase!=MeleeAttackComponent.Phase.ACTIVE: await physics_frame
	var contact_origin := actor.global_position
	actor._physics_process(1.0/60.0)
	check(actor.velocity==Vector2.ZERO and actor.global_position.is_equal_approx(contact_origin),"Holding movement slides during contact")
	Input.action_press("player_move_down")
	actor._physics_process(1.0/60.0)
	check(actor.global_position.is_equal_approx(contact_origin) and attack.get_attack_direction()==Vector2.RIGHT,"Diagonal movement changes contact or moves the planted body")
	actor.knockback_component.apply_pressure(Vector2.LEFT,40)
	actor._physics_process(1.0/60.0)
	check(actor.velocity.x<0 and actor.global_position.x<contact_origin.x,"Planting feet incorrectly blocks incoming knockback")
	actor.knockback_component.clear()
	Input.action_release("player_move_down")
	while attack.phase!=MeleeAttackComponent.Phase.RECOVERY: await physics_frame
	actor._physics_process(.1)
	check(actor.velocity.x>0 and actor.velocity.length()<=actor.movement_component.max_speed*.6+.01,"Recovery does not restore controlled movement")
	while attack.phase!=MeleeAttackComponent.Phase.IDLE: await physics_frame
	for tick in 10: actor._physics_process(1.0/60.0)
	check(is_equal_approx(actor.velocity.length(),actor.movement_component.max_speed),"Walking stays slow after release")
	check(actor.request_evade(Vector2.LEFT),"Greatsword walk treatment blocks dodge")
	actor._physics_process(1.0/60.0)
	check(actor.velocity.x<0 and actor.velocity.length()>actor.movement_component.max_speed,"Weapon walk ratio incorrectly scales dodge")
	actor.evade_component.cancel_evade()
	actor._clear_buffered_action()
	check(actor.equip_owned_weapon(AXE),"Axe cannot be equipped after greatsword")
	actor._set_facing_direction(Vector2.RIGHT)
	actor.velocity = Vector2.RIGHT*actor.movement_component.max_speed
	check(actor.request_primary_attack(),"Axe primary refused")
	actor._physics_process(1.0/60.0)
	check(actor.velocity.length()<=actor.movement_component.max_speed*AXE.weapon_definition.get_attack_movement_ratio(MeleeAttackComponent.Phase.WIND_UP)+.01,"Weapon swap did not use the axe's own wind-up ratio")
	Input.action_release("player_move_right")
	actor.attack_component.cancel_attack()

func _validate_new_art() -> void:
	var profile := ITEM.weapon_definition.family_presentation
	check(profile.is_valid_profile(),"New facing profile is invalid")
	for direction in [Vector2.UP,Vector2.DOWN]:
		var idle: Resource = profile.idle_for(direction)
		var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		check(idle.allow_rest and idle.planting!=null,"Vertical confident idle remains disabled")
		for pose in 8:
			var image: Image = idle.body_atlas.get_image().get_region(Rect2i(pose%4*192,pose/4*128,192,128))
			var mask: Image = idle.hand_atlas.get_image().get_region(Rect2i(pose%4*192,pose/4*128,192,128))
			var low := 192
			var high := 0
			for y in range(92,96):
				for x in 192:
					if image.get_pixel(x,y).a>.65: low = mini(low,x); high = maxi(high,x)
			check(absf((low+high)*.5-96)<=.5 and image.get_used_rect().end.y==96,"Vertical idle is not centered at its boots")
			var target := Rect2i(idle.identity_regions[pose])
			check(_crown_covered(image,carry,target,Rect2i(idle.identity_source_region)),"Vertical proud crown is clipped")
			check(_head_reach(image,target).lower_pixels>=50,"Vertical proud head is detached")
			check(_identity_core_matches(image,mask,carry,target,Rect2i(idle.identity_source_region)),"Vertical proud head changes appearance")
	var running: Resource = profile.running_poses
	var carry: Image = profile.idle_poses.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	for pose in 8:
		var image: Image = running.body_atlas.get_image().get_region(Rect2i(pose%4*192,pose/4*128,192,128))
		var mask: Image = running.hand_atlas.get_image().get_region(Rect2i(pose%4*192,pose/4*128,192,128))
		var target := Rect2i(running.identity_regions[pose])
		check(_crown_covered(image,carry,target,Rect2i(running.identity_source_region)),"Side run clips the accepted hair")
		check(_identity_core_matches(image,mask,carry,target,Rect2i(running.identity_source_region),0.0),"Side gait still changes head/hair colors")
		check(_head_reach(image,target).lower_pixels>=50,"Running head detaches from torso")
