extends SceneTree

const HUB = preload("res://levels/sanctuary/sanctuary.tscn")
const Study = preload("res://levels/sanctuary/review/refuge_study.gd")
const OUT := "res://art_source/review/environment/sanctuary_life_2026_10_01/"
var failures := 0
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	var hub: Node = HUB.instantiate()
	root.add_child(hub)
	current_scene = hub
	await process_frame
	await process_frame
	var player: Player = hub.get_node("World/Actors/Player")
	var original_ground := hub.get_node("World/Level/Ground") as TileMapLayer
	var original_texture: Texture2D = hub.get_node("World/Actors/SkillkeeperLodge/Sprite").texture
	var portraits: Array[Texture2D] = []
	var orren: DialogueNpc = hub.get_node("World/Actors/WeaponMerchant")
	var old_frames: SpriteFrames = orren.get_node("Sprite").sprite_frames
	var old_position := orren.position
	var old_collision: Shape2D = orren.get_node("Body/Collision").shape
	var eira: DialogueNpc = hub.get_node("World/Actors/Skillkeeper")
	var eira_old_frames: SpriteFrames = eira.get_node("Sprite").sprite_frames
	var eira_old_position := eira.position
	var eira_body: Shape2D = eira.get_node("Body/Collision").shape
	var eira_trigger: Shape2D = eira.get_node("Trigger").shape
	for name in ["Skillkeeper","WeaponMerchant","Rootweaver","Umi"]:
		portraits.append(hub.get_node("World/Actors/"+name).dialogue_portrait)
	var study := Study.new()
	study.hub = hub
	hub.add_child(study)
	await physics_frame
	await physics_frame
	check(original_ground.tile_set.tile_size == Vector2i(64,64),"Production tileset changed")
	check(study.ground.tile_set.tile_size == Vector2i(32,32) and study.ground.get_used_cells().size() == 864,"Review ground does not cover the same world at 32px")
	check(not original_ground.visible and study.ground.visible,"Review ground not selected")
	check(root.get_node("SaveService").is_autosave_suppressed_for_debug(),"Review may write campaign saves")
	check(study.lodge.get_node("Doorway").global_position == Vector2(224,390),"Doorway no longer agrees with the authored approach")
	check(study.lodge.get_meta("interior_status") == &"planned", "Unimplemented interior presented as available")
	var space := player.get_world_2d().direct_space_state
	check(_blocked(space,Vector2(320,370)),"New lodge footprint not solid")
	check(not _blocked(space,Vector2(224,434)),"Lodge approach blocked")
	check(_blocked(space,Vector2(1040,370)),"Workshop forge footprint not solid")
	check(not _blocked(space,Vector2(928,426)),"Workshop doorway approach blocked")
	check(study.orren_review.workshop.get_meta("interior_status") == &"planned","Workshop falsely offers an interior")
	check(orren.get_node("Body/Collision").shape == old_collision,"NPC body authority replaced")
	check(orren.get_node("IdleBreath").is_stopped(),"Old whole-body bob still active")
	check(study.orren_review.nameplate.visible and study.orren_review.nameplate.npc_name == "Orren" and study.orren_review.nameplate.role_name == "Armskeeper","NPC name/role missing")
	_check_orren_art(study.orren_review)
	_check_eira_art(study.eira_review)
	check(eira.get_node("Body/Collision").shape == eira_body and eira.get_node("Trigger").shape == eira_trigger,"Eira interaction/body authority replaced")
	check(eira.get_node("IdleBreath").is_stopped() and not eira.idle_aura.visible,"Eira's old body wobble or floating aura is active")
	check(study.eira_review.nameplate.visible and study.eira_review.nameplate.npc_name == "Eira" and study.eira_review.nameplate.role_name == "Skillkeeper","Eira identity label missing")
	var reachable := _reachable(space,Vector2i(36,42))
	for destination in [Vector2(224,434),Vector2(344,474),Vector2(360,548),Vector2(376,630),Vector2(808,670),Vector2(984,474),Vector2(928,426),Vector2(576,328)]:
		check(reachable.has(Vector2i(destination/16)),"An existing service/door/gate route is blocked: "+str(destination))
	study.visit_orren()
	await create_timer(.3).timeout
	await capture("orren_native.png")
	check(orren._player_inside,"New courtyard position cannot reach Orren with F")
	var interaction := InputEventAction.new()
	interaction.action = &"player_interact"
	interaction.pressed = true
	root.push_input(interaction)
	await process_frame
	check(hub.dialogue_panel.visible,"F interaction did not open Orren dialogue")
	check(not study.orren_review.sprite.is_playing(),"Orren keeps inspecting his blade during dialogue")
	await capture("orren_dialogue.png")
	hub.dialogue_panel.close_dialogue(true)
	check(study.orren_review.sprite.is_playing(),"Orren failed to resume work after dialogue")
	check(not hub.character_menu.visible and not hub.rootforge_menu.visible and not hub.umi_exchange_menu.visible,"Orren unexpectedly opened a service menu")
	var observed := {}
	for tick in 24:
		await create_timer(.1).timeout
		observed[study.orren_review.sprite.frame] = true
	check(observed.size() == 8,"Working idle does not play all eight poses")
	check(study.orren_review.sprite.position == Vector2(0,-16) and orren.position == Vector2(992,438),"Idle translates the body or collision")
	study.set_overview(true)
	var camera: Camera2D = player.get_node("Camera2D")
	camera.position = Vector2(928,424)
	camera.zoom = Vector2(2,2)
	camera.reset_smoothing()
	await capture("orren_detail_2x.png")
	study.visit_eira()
	await create_timer(.3).timeout
	await capture("eira_native.png")
	check(eira._player_inside and not orren._player_inside,"Visit Eira does not reach her exclusive F interaction")
	root.push_input(interaction)
	await process_frame
	check(hub.dialogue_panel.visible and not study.eira_review.sprite.is_playing() and study.eira_review.sprite.frame == 0,"Eira does not face the player during real F dialogue")
	await capture("eira_dialogue.png")
	hub.dialogue_panel.close_dialogue(false)
	check(not hub.character_menu.visible and study.eira_review.sprite.is_playing(),"Canceling Eira dialogue opens skills or fails to resume reading")
	root.push_input(interaction)
	await process_frame
	hub.dialogue_panel.close_dialogue(true)
	check(hub.character_menu.visible,"Completing Eira dialogue does not retain skill training service")
	await capture("eira_skills.png")
	hub.character_menu.close_menu()
	check(not paused,"Eira skill menu left the hub paused")
	var eira_observed := {}
	for tick in 30:
		await create_timer(.1).timeout
		eira_observed[study.eira_review.sprite.frame] = true
	check(eira_observed.size() == 8,"Eira reading idle fails to play all eight poses after service")
	check(study.eira_review.sprite.position == Vector2(0,-16) and eira.position == Vector2(344,438),"Eira reading moves body/interaction roots")
	study.set_overview(true)
	camera.position = Vector2(256,424)
	camera.zoom = Vector2(2,2)
	camera.reset_smoothing()
	await capture("eira_detail_2x.png")
	study.set_overview(false)
	player.position = Vector2(928,280)
	for tick in 10:
		await physics_frame
		if study.orren_review.workshop.get_node("Art").modulate.a < 1.0: break
	check(study.orren_review.workshop.get_node("Art").modulate.a < 1.0,"Workshop roof does not reveal King")
	await capture("orren_roof_fade.png")
	player.position = Vector2(576,580)
	study.set_overview(false)
	await capture("study_native.png")
	study.set_overview(true)
	await capture("study_overview.png")
	study.set_overview(false)
	player.position = Vector2(224,434)
	await capture("study_lodge.png")
	player.position = Vector2(224,270)
	for tick in 10:
		await physics_frame
		if study.lodge.get_child(0).modulate.a < 1.0: break
	check(study.lodge.get_child(0).modulate.a < 1.0,"Lodge roof hides King without fading")
	await capture("study_behind_lodge.png")
	player.position = Vector2(576,580)
	study.set_review_enabled(false)
	await physics_frame
	await physics_frame
	check(not _blocked(space,Vector2(320,370)),"Review collision remained after switching to old environment")
	check(original_ground.visible and not study.ground.visible,"Compare did not restore original ground")
	check(hub.get_node("World/Actors/SkillkeeperLodge/Sprite").texture == original_texture,"Original building asset overwritten")
	check(orren.dialogue_portrait == portraits[1] and orren.get_node("Sprite").sprite_frames == old_frames,"Comparison did not restore Orren art")
	check(orren.position == old_position and not orren.get_node("IdleBreath").is_stopped(),"Comparison did not restore original NPC placement/idle")
	check(not study.orren_review.nameplate.visible,"New nameplate remains in original comparison")
	check(eira.position == eira_old_position and eira.get_node("Sprite").sprite_frames == eira_old_frames and eira.dialogue_portrait == portraits[0],"Comparison did not restore Eira position/frames/portrait")
	check(not study.eira_review.nameplate.visible and not eira.get_node("IdleBreath").is_stopped() and eira.idle_aura.visible,"Comparison did not restore Eira idle/aura or hide nameplate")
	check(not _blocked(space,Vector2(1040,370)),"Review workshop collision remains in original mode")
	await capture("study_compare_old.png")
	study.set_review_enabled(true)
	check(eira.get_node("Sprite").sprite_frames == study.eira_review.frames and eira.dialogue_portrait == study.eira_review.PORTRAIT and eira.position == Vector2(344,438),"Re-enabling study failed to restore Eira candidate")
	var index := 0
	for name in ["Skillkeeper","WeaponMerchant","Rootweaver","Umi"]:
		var npc: DialogueNpc = hub.get_node("World/Actors/"+name)
		var expected_portrait: Texture2D = portraits[index]
		if name == "WeaponMerchant": expected_portrait = study.orren_review.PORTRAIT
		if name == "Skillkeeper": expected_portrait = study.eira_review.PORTRAIT
		if name == "Rootweaver": expected_portrait = study.nema_review._portrait
		if name == "Umi": expected_portrait = study.umi_review._portrait
		check(npc.dialogue_portrait == expected_portrait,"Wrong portrait bound to NPC")
		npc.dialogue_requested.emit(npc.speaker_name,npc.dialogue_lines,npc.dialogue_portrait)
		check(hub.dialogue_panel.visible,"NPC lost dialogue: "+name)
		hub.dialogue_panel.close_dialogue(true)
		if name != "WeaponMerchant":
			var menu: Node = hub.character_menu if name == "Skillkeeper" else (hub.rootforge_menu if name == "Rootweaver" else hub.umi_exchange_menu)
			check(menu.visible,"NPC service menu did not open: "+name)
			if name == "Skillkeeper": await capture("study_eira_service.png")
			menu.close_menu()
		index += 1
	check(not paused,"Service menu left the review paused")
	eira_body = null
	eira_trigger = null
	hub.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("SANCTUARY_REFUGE_REVIEW: ",checks," checks, ",failures," failures")
	quit(1 if failures else 0)

func _check_orren_art(review: Node) -> void:
	var atlas: Image = review.IDLE.get_image()
	var hashes := {}
	check(review.frames.get_frame_count(&"idle_down") == 8,"Incorrect idle frame count")
	var hard_alpha := true
	for y in atlas.get_height():
		for x in atlas.get_width():
			var alpha := atlas.get_pixel(x,y).a
			if alpha != 0.0 and alpha != 1.0: hard_alpha = false
	check(hard_alpha,"Orren has soft alpha")
	for index in 8:
		var frame := atlas.get_region(Rect2i(Vector2i(index%4,index/4)*96,Vector2i(96,96)))
		var bounds := frame.get_used_rect()
		check(bounds.end.y == 80 and bounds.size.y >= 58 and bounds.size.y <= 62,"Body scale or planted-foot registration drift")
		check(bounds.position.x > 4 and bounds.end.x < 92,"Orren blade or hands clipped")
		hashes[frame.get_data().hex_encode().sha256_text()] = true
	check(hashes.size() == 8,"Generated poses are duplicated")

func _check_eira_art(review: Node) -> void:
	var atlas: Image = review.IDLE.get_image()
	check(atlas.get_size() == Vector2i(384,192) and review.frames.get_frame_count(&"idle_down") == 8,"Eira grid or frame contract incorrect")
	var hard_alpha := true
	for texture: Texture2D in [review.IDLE,review.PORTRAIT]:
		var image := texture.get_image()
		for y in image.get_height():
			for x in image.get_width():
				var alpha := image.get_pixel(x,y).a
				if alpha != 0.0 and alpha != 1.0: hard_alpha = false
	check(hard_alpha,"Eira body or portrait has soft alpha")
	check(review.PORTRAIT.get_size() == Vector2(96,96),"Eira portrait is not native 96px")
	var hashes := {}
	for index in 8:
		var frame := atlas.get_region(Rect2i(Vector2i(index%4,index/4)*96,Vector2i(96,96)))
		var bounds := frame.get_used_rect()
		check(bounds.end.y == 80 and bounds.size.y >= 58 and bounds.size.y <= 62 and bounds.position.x > 4 and bounds.end.x < 92,"Eira frame registration/scale/clipping mismatch")
		hashes[frame.get_data().hex_encode().sha256_text()] = true
	check(hashes.size() == 8,"Eira repeats drawings instead of authored idle poses")

func _blocked(space: PhysicsDirectSpaceState2D, point: Vector2) -> bool:
	var shape := CircleShape2D.new()
	shape.radius = 8.0
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = shape
	query.transform = Transform2D(0,point)
	query.collision_mask = 1
	query.collide_with_areas = false
	return not space.intersect_shape(query,1).is_empty()

func _reachable(space: PhysicsDirectSpaceState2D, start: Vector2i) -> Dictionary:
	var visited := {start:true}
	var blocked := {}
	var queue: Array[Vector2i] = [start]
	var cursor := 0
	while cursor < queue.size():
		var cell := queue[cursor]
		cursor += 1
		for offset in [Vector2i.LEFT,Vector2i.RIGHT,Vector2i.UP,Vector2i.DOWN]:
			var next: Vector2i = cell+offset
			if next.x < 0 or next.y < 0 or next.x >= 72 or next.y >= 48 or visited.has(next) or blocked.has(next): continue
			if _blocked(space,Vector2(next*16)+Vector2(8,8)):
				blocked[next] = true
			else:
				visited[next] = true
				queue.append(next)
	return visited

func capture(file: String) -> void:
	if DisplayServer.get_name() == "headless": return
	await process_frame
	await RenderingServer.frame_post_draw
	DirAccess.make_dir_recursive_absolute(OUT)
	check(root.get_texture().get_image().save_png(OUT+file) == OK,"Capture failed")

func check(ok: bool, message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
