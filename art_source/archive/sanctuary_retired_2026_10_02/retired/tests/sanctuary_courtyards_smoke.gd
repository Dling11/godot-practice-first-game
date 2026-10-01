extends "res://tests/sanctuary_refuge_review_smoke.gd"

const CAPTURES := "res://art_source/review/environment/sanctuary_courtyards_2026_10_01/"

func _run() -> void:
	root.size = Vector2i(960,540)
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	var study := Study.new()
	study.hub = hub
	hub.add_child(study)
	var player: Player = hub.get_node("World/Actors/Player")
	await physics_frame
	await physics_frame
	var space := player.get_world_2d().direct_space_state
	check(study.dressing.buildings.size() == 2,"Both angled artisan buildings must mount")
	check(_blocked(space,Vector2(232,620)) and _blocked(space,Vector2(904,640)),"Artisan buildings lack collision")
	check(_blocked(space,Vector2(298,632)) and _blocked(space,Vector2(840,648)),"Outdoor forge/crucible benches lack collision")
	check(not _blocked(space,Vector2(262,676)) and not _blocked(space,Vector2(884,696)),"Reserved house approaches are blocked")
	var reachable := _reachable(space,Vector2i(36,43))
	for point in [study.eira_review.APPROACH,Vector2(366,658),Vector2(784,686),Vector2(262,676),Vector2(884,696)]:
		check(reachable.has(Vector2i(point/16)),"Town approach is unreachable: "+str(point))
	check(not study.ground.path_cells.has(Vector2i(344/32,410/32)),"Eira lectern is still on the road")
	for y in range(400,465,8):
		check(not _blocked(space,Vector2(224,y)),"Lodge doorway route obstructed")
	study.visit_eira()
	await create_timer(.2).timeout
	await capture("eira_teaching_nook.png")
	var interact := InputEventAction.new()
	interact.action = &"player_interact"
	interact.pressed = true
	for recipe in [["nema",study.nema_review,study.visit_nema,hub.rootforge_menu],["umi",study.umi_review,study.visit_umi,hub.umi_exchange_menu]]:
		var adapter: Node = recipe[1]
		var npc: DialogueNpc = adapter.npc
		var body_shape: Shape2D = npc.get_node("Body/Collision").shape
		var trigger_shape: Shape2D = npc.get_node("Trigger").shape
		_check_artisan(adapter)
		recipe[2].call()
		await create_timer(.25).timeout
		check(npc._player_inside,"Visit button failed to reach "+recipe[0])
		check(not adapter.sprite.is_playing(),"Artisan did not acknowledge approach")
		await capture(recipe[0]+"_native.png")
		root.push_input(interact)
		await process_frame
		check(hub.dialogue_panel.visible and hub.dialogue_panel.portrait.texture == npc.dialogue_portrait,"F failed to open matching artisan dialogue")
		check(not adapter.sprite.is_playing(),"Artisan keeps working during dialogue")
		await capture(recipe[0]+"_dialogue.png")
		hub.dialogue_panel.close_dialogue(false)
		await create_timer(1.3).timeout
		check(adapter.sprite.is_playing(),"Canceled dialogue does not resume artisan")
		var seen := {}
		for sample in 48:
			seen[adapter.sprite.frame] = true
			await create_timer(.08).timeout
		check(seen.size() == 8,"Artisan does not play all working poses")
		root.push_input(interact)
		await process_frame
		hub.dialogue_panel.close_dialogue(true)
		check(recipe[3].visible,"Completed dialogue lost existing service")
		await capture(recipe[0]+"_service.png")
		recipe[3].close_menu()
		check(not paused,"Service close left town paused")
		study.set_review_enabled(false)
		check(adapter.sprite.sprite_frames == adapter._old.frames and npc.dialogue_portrait == adapter._old.portrait,"Old comparison fails to restore artisan")
		check(not npc.get_node("WorkIdle").is_stopped(),"Old work timer not restored")
		study.set_review_enabled(true)
		check(npc.get_node("WorkIdle").is_stopped(),"Old timer competes with new working poses")
		check(body_shape == npc.get_node("Body/Collision").shape and trigger_shape == npc.get_node("Trigger").shape,"Artisan swap replaces interaction resources")
		body_shape = null
		trigger_shape = null
	study.visit_courier()
	await create_timer(.2).timeout
	check(study.courier.dialogue._player_inside and study.courier.talk_label.visible,"Rowan approach fails to expose F talk")
	root.push_input(interact)
	await process_frame
	check(hub.dialogue_panel.visible and hub.dialogue_panel.speaker_label.text.begins_with("ROWAN"),"F fails to talk with new civilian")
	check(not study.courier.talk_label.visible,"Rowan talk prompt remains over an active dialogue")
	await capture("rowan_dialogue.png")
	hub.dialogue_panel.close_dialogue(true)
	check(not paused and not hub.rootforge_menu.visible and not hub.umi_exchange_menu.visible,"Courier dialogue opened an unrelated service")
	study.visit_eira()
	study.courier.position = player.position+Vector2(10,0)
	study.courier._stop_remaining = 0
	await create_timer(.2).timeout
	check(not study.courier.dialogue.can_interact(),"Courier steals F while a fixed service is in range")
	root.push_input(interact)
	await process_frame
	check(hub.dialogue_panel.visible and hub.dialogue_panel.portrait.texture == study.eira_review.PORTRAIT,"Overlapping courier prevents Eira interaction")
	hub.dialogue_panel.close_dialogue(false)
	player.position = Vector2(576,688)
	var courier: Node = study.courier
	await create_timer(.2).timeout
	var distance_before: float = courier.total_distance
	var phase_before: float = courier._stride_distance
	await create_timer(.35).timeout
	var distance: float = courier.total_distance-distance_before
	check(distance > 5 and is_equal_approx(courier._stride_distance,fposmod(phase_before+distance,courier.STRIDE_DISTANCE)),"Foot cadence is disconnected from actual distance")
	check(not courier.sprite.is_playing() and str(courier.sprite.animation).begins_with("walk_"),"Automatic playback competes with distance-driven walk")
	player.position = courier.position+Vector2(10,0)
	await create_timer(.2).timeout
	var stopped_phase: float = courier._stride_distance
	await create_timer(.2).timeout
	check(courier.velocity == Vector2.ZERO and courier._stride_distance == stopped_phase,"Courier steps or slides while yielding")
	check(str(courier.sprite.animation).begins_with("idle_"),"Courier holds a mid-stride pose at rest")
	# Put a real world obstacle on a short clear lane and verify actual physics contact.
	player.position = Vector2(576,688)
	courier.route = PackedVector2Array([Vector2(600,552),Vector2(680,552)])
	courier.stop_indices.clear()
	courier.set_enabled(true)
	courier._stop_remaining = 0
	var obstacle := StaticBody2D.new()
	obstacle.position = Vector2(632,552)
	var blocker := CollisionShape2D.new()
	var rectangle := RectangleShape2D.new()
	rectangle.size = Vector2(12,32)
	blocker.shape = rectangle
	obstacle.add_child(blocker)
	hub.get_node("World/Actors").add_child(obstacle)
	await create_timer(1).timeout
	check(courier.position.x < 622 and str(courier.sprite.animation).begins_with("idle_"),"Collision lets courier glide through an obstacle or keep stepping")
	var blocked_phase: float = courier._stride_distance
	await create_timer(.2).timeout
	check(courier._stride_distance == blocked_phase,"Blocked feet keep advancing")
	obstacle.queue_free()
	await physics_frame
	player.position = Vector2(232,548)
	await create_timer(.2).timeout
	check(study.dressing.buildings[0].get_node("Art").modulate.a < 1,"New workshop roof hides King without reveal")
	player.position = Vector2(104,156)
	await create_timer(.2).timeout
	for tree in study.dressing.trees:
		check(tree.get_node("Art").material is ShaderMaterial,"Tree is missing bounded foliage wind")
	check(study.dressing.trees[0].get_node("Art").modulate.a < 1,"Canopy reveal regressed with wind")
	study.set_overview(true)
	study.birds.set_enabled(true)
	await create_timer(3).timeout
	check(study.birds.birds[0].visible and study.birds.birds[0].is_playing(),"Swallow pass has no animated flight")
	var bird_at: Vector2 = study.birds.birds[0].position
	await create_timer(.5).timeout
	check(study.birds.birds[0].position.distance_to(bird_at)>10,"Swallow is frozen in the sky")
	await capture("town_overview.png")
	study.set_review_enabled(false)
	check(not study.birds.birds[0].visible and study.birds._timer.is_stopped(),"Comparison leaves bird activity running")
	check(not courier.dialogue.can_process(),"Hidden courier can still interact")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Study enables persistent saves")
	interact = null
	hub.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("SANCTUARY_COURTYARDS: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _check_artisan(adapter: Node) -> void:
	check(adapter.frames.get_frame_count(&"artisan_work") == 8,"Artisan working sheet incomplete")
	check(adapter.npc.dialogue_portrait.get_size() == Vector2(96,96),"Artisan portrait size invalid")
	var hashes := {}
	for index in 8:
		var atlas: AtlasTexture = adapter.frames.get_frame_texture(&"artisan_work",index)
		var pose := atlas.atlas.get_image().get_region(Rect2i(atlas.region))
		var bounds := pose.get_used_rect()
		check(bounds.end.y == 80 and bounds.position.x > 4 and bounds.end.x < 92 and bounds.size.y >= 58 and bounds.size.y <= 68,"Artisan feet/scale/clipping invalid")
		hashes[pose.get_data().hex_encode().sha256_text()] = true
	check(hashes.size() == 8,"Artisan work drawings duplicate")

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(CAPTURES)
	check(root.get_texture().get_image().save_png(CAPTURES+file) == OK,"Capture failed")
