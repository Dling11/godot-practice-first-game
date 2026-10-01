extends "res://tests/sanctuary_refuge_review_smoke.gd"

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	await process_frame
	var player: Player = hub.get_node("World/Actors/Player")
	root.get_node("DebugAdminState").set_enabled(false)
	check(hub.get_node_or_null("SanctuaryStudy") == null,"Normal Continue silently promotes the study")
	var admin_key := InputEventAction.new()
	admin_key.action = &"debug_toggle_admin"
	admin_key.pressed = true
	root.push_input(admin_key)
	await process_frame
	check(hub.admin_panel.visible,"F10 admin route does not expose review entry")
	await capture("life_admin_entry.png")
	var review_button: Button = hub.get_node("UI/AdminPanel/Margin/Stack/OpenSanctuaryStudy")
	var entry_click := InputEventMouseButton.new()
	entry_click.button_index = MOUSE_BUTTON_LEFT
	entry_click.position = review_button.get_global_rect().get_center()
	entry_click.pressed = true
	root.push_input(entry_click)
	entry_click = entry_click.duplicate()
	entry_click.pressed = false
	root.push_input(entry_click)
	await process_frame
	var study: Node = hub.get_node_or_null("SanctuaryStudy")
	check(study != null,"Clicking admin review button failed to mount Sanctuary study")
	if study == null:
		quit(1)
		return
	check(not hub.admin_panel.visible,"Admin panel obscures town after entering review")
	player.position = Vector2(576,688)
	await physics_frame
	await physics_frame
	var space := player.get_world_2d().direct_space_state
	for snapshot in study.dressing.replacements:
		check(not snapshot.node.visible and snapshot.node.process_mode == Node.PROCESS_MODE_DISABLED,"Legacy cart/tree still visible or active")
	check(not _blocked(space,Vector2(832,550)),"Hidden red cart still blocks its former footprint")
	check(study.dressing.trees.size() == 6 and study.dressing.stations.size() == 3,"Tree/workstation set incomplete")
	check(_blocked(space,Vector2(280,218)) and not _blocked(space,Vector2(456,224)),"North garden boundary or deliberate portal approach is wrong")
	check(_blocked(space,Vector2(1038,424)) and _blocked(space,Vector2(248,412)),"New workstations have no physical footprint")
	_check_courier_frames(study.courier)
	for index in study.courier.route.size():
		var start: Vector2 = study.courier.route[index]
		var end: Vector2 = study.courier.route[(index+1)%study.courier.route.size()]
		var clear := true
		var samples := ceili(start.distance_to(end)/8.0)
		for sample in range(samples+1):
			if _blocked(space,start.lerp(end,float(sample)/maxi(samples,1))): clear = false
		check(clear,"Courier authored route crosses a physical prop: segment "+str(index))
	var map_key := InputEventKey.new()
	map_key.physical_keycode = KEY_M
	map_key.pressed = true
	root.push_input(map_key)
	await process_frame
	check(study.town_map.panel.visible,"M failed to open town map")
	check(study.town_map.panel.get_global_rect().end.y < 440,"Town map covers the action tray")
	await capture("life_town_map.png")
	var eira_button: Button
	for child in study.town_map.panel.get_child(0).get_children():
		if child is Button and child.text.begins_with("Eira"): eira_button = child
	check(eira_button != null,"Map has no Eira destination")
	if eira_button != null:
		var click := InputEventMouseButton.new()
		click.button_index = MOUSE_BUTTON_LEFT
		click.position = eira_button.get_global_rect().get_center()
		click.pressed = true
		root.push_input(click)
		click = click.duplicate()
		click.pressed = false
		root.push_input(click)
		await process_frame
	check(study.town_map.selected_id == "eira" and study.beacons[1].selected,"Clicking map destination failed to select Eira beacon")
	check(not study.town_map.panel.visible and study.town_map.guidance.visible,"Destination selection failed to close map and show guidance")
	await capture("life_tracking.png")
	study.visit_eira()
	await create_timer(.25).timeout
	check(study.beacons[1].speech.visible and study.beacons[1].near,"Eira did not greet the approaching player")
	check(not study.eira_review.sprite.is_playing(),"Eira did not look up from reading")
	await capture("life_eira_greeting.png")
	await create_timer(1.3).timeout
	check(study.eira_review.sprite.is_playing(),"Eira did not resume reading after greeting")
	study.town_map.toggle()
	var interact := InputEventAction.new()
	interact.action = &"player_interact"
	interact.pressed = true
	root.push_input(interact)
	await process_frame
	check(hub.dialogue_panel.visible and not study.town_map.panel.visible and not study.town_map.guidance.visible,"Town map overlays NPC dialogue")
	check(not study.beacons[1].speech.visible,"Ambient speech overlaps real dialogue")
	hub.dialogue_panel.close_dialogue(false)
	study.beacons[0]._last_greeting_ms = -30000
	study.visit_orren()
	await create_timer(.25).timeout
	check(study.beacons[0].speech.visible and not study.orren_review.sprite.is_playing(),"Orren did not acknowledge approach")
	await capture("life_orren_greeting.png")
	player.position = Vector2(438,684)
	await create_timer(.25).timeout
	check(study.noticeboard.player_inside,"Noticeboard front approach is unavailable")
	root.push_input(interact)
	await process_frame
	check(study.town_map.panel.visible,"F at noticeboard did not open map")
	await capture("life_noticeboard.png")
	study.town_map.panel.hide()
	player.position = Vector2(104,156)
	await create_timer(.15).timeout
	check(study.dressing.trees[0].get_node("Art").modulate.a < 1.0,"New tree canopy hides King without fading")
	await capture("life_canopy_fade.png")
	player.position = Vector2(576,688)
	study.courier.set_enabled(true)
	var route_start: Vector2 = study.courier.position
	Engine.time_scale = 8
	await create_timer(65).timeout
	Engine.time_scale = 1
	check(study.courier.arrivals >= study.courier.route.size(),"Courier failed to complete a full service route")
	check(study.courier.total_distance > 1200 and study.courier.position.distance_to(route_start) > 5,"Courier failed to travel with actual movement")
	player.position = study.courier.position + Vector2(10,0)
	await create_timer(.2).timeout
	check(study.courier.yielding_to_player and study.courier.velocity == Vector2.ZERO,"Courier fails to yield near King")
	check(str(study.courier.sprite.animation).begins_with("idle_"),"Courier freezes mid-stride instead of standing when yielding")
	var stopped_at: Vector2 = study.courier.position
	await create_timer(.3).timeout
	check(study.courier.position == stopped_at,"Courier slides through King while yielding")
	await capture("life_courier.png")
	player.position = Vector2(576,688)
	await create_timer(.3).timeout
	check(not study.courier.yielding_to_player,"Courier fails to resume after player leaves")
	study.set_review_enabled(false)
	await physics_frame
	await physics_frame
	for snapshot in study.dressing.replacements:
		check(snapshot.node.visible == snapshot.visible and snapshot.node.process_mode == snapshot.process_mode,"Comparison fails to restore original cart/tree")
	check(_blocked(space,Vector2(832,550)),"Original cart collision not restored")
	check(not study.courier.visible and not study.courier.is_physics_processing(),"Courier stays active during old comparison")
	check(not study.town_map.enabled and study.town_map.selected_id.is_empty(),"Old comparison retains new town guidance")
	for beacon in study.beacons: check(not beacon.visible and not beacon.speech.visible,"Old comparison retains NPC markers")
	study.set_review_enabled(true)
	await physics_frame
	await physics_frame
	check(not _blocked(space,Vector2(832,550)) and study.courier.visible,"New town fails to return after comparison")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Town review may save campaign state")
	var child_count := hub.get_child_count()
	root.get_node("DebugAdminState").set_enabled(true)
	hub._open_sanctuary_study()
	check(hub.get_node("SanctuaryStudy") == study and hub.get_child_count() == child_count,"Repeated admin entry duplicates the study")
	study.set_overview(true)
	await capture("life_overview.png")
	admin_key = null
	entry_click = null
	hub.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("SANCTUARY_LIFE_REVIEW: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _check_courier_frames(courier: Node) -> void:
	var image: Image = courier.SHEET.get_image()
	check(image.get_size() == Vector2i(384,384),"Courier runtime sheet is not an exact4x4 grid")
	var hashes := {}
	for index in 16:
		var frame := image.get_region(Rect2i(Vector2i(index%4,index/4)*96,Vector2i(96,96)))
		var bounds := frame.get_used_rect()
		check(bounds.end.y == 80 and bounds.size.y >= 50 and bounds.size.y <= 60 and bounds.position.x > 4 and bounds.end.x < 92,"Courier frame clips or loses body/foot registration")
		hashes[frame.get_data().hex_encode().sha256_text()] = true
	check(hashes.size() == 16,"Courier has duplicate runtime drawings")
