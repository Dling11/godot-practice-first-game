extends "res://tools/launch_enemy_arrival_art_review.gd"

var checks := 0
var failures := 0

func _run() -> void:
	await super._run()
	root.size = Vector2i(960,540)
	await process_frame
	await process_frame
	_check(root.get_node("SaveService").get_profile_path() == "user://enemy_arrival_art_review.json", "Art review uses the normal profile")
	_check(root.get_node("SaveService").is_autosave_suppressed_for_debug(), "Art review permits autosaving")
	for key: String in ART_NAMES:
		var image := Image.load_from_file(ProjectSettings.globalize_path("res://assets/vfx/enemy_arrival_review/"+key+".png"))
		var binary := true
		for y in image.get_height():
			for x in image.get_width():
				var alpha := image.get_pixel(x,y).a
				if alpha != 0.0 and alpha != 1.0: binary = false
		_check(binary and image.get_size() == Vector2i(384,64), "Raster preview is not a binary-alpha six-cell sheet")
		await click(key.to_upper())
		var encounter: EncounterController = stage.encounter_controller
		_check(encounter._arrivals.size() == 1 and encounter._active_enemies == 1, "Art switch did not replay one reserved arrival")
		if encounter._arrivals.is_empty():
			print("ART_CLICK_DEBUG art=",_art_key," rebuilding=",_rebuilding," active=",encounter._active_enemies," queued=",encounter._pending_enemies.size()," king=",stage.player.global_position)
			quit(1)
			return
		var pending: Node = encounter._arrivals.keys()[0]
		var effect: SummonEffect = encounter._arrivals[pending].effect
		var point: Vector2 = effect.global_position
		_check(effect.art_key == key and effect.sprite.animation == &"warning", "Wrong raster family or initial phase")
		_check(effect.sprite.position == Vector2(0,-20) and effect.scale == Vector2.ONE, "Floor origin or density changed")
		_check(effect.sprite.sprite_frames.get_frame_count(&"warning") == 2 and effect.sprite.sprite_frames.get_frame_count(&"release") == 4, "Short drawings were replaced with a frozen sprite")
		var phase: int = effect.sprite.frame
		paused = true
		await create_timer(.25,true).timeout
		_check(effect.sprite.frame == phase and encounter._arrivals.size() == 1, "Modal pause advances art or actor arrival")
		paused = false
		await create_timer(.2,false).timeout
		_check(effect.sprite.frame == 1 and effect.global_position == point, "Warning does not advance at a planted position")
		await create_timer(.16,false).timeout
		_check(effect.released and effect.sprite.animation == &"release", "Actual materialization does not release raster animation")
		_check(encounter._arrivals.is_empty() and encounter._active_enemies == 1, "Art changed authoritative arrival count")
		_check(pending.get_node_or_null("EnemyRewardComponent") == null, "Review actor can grant rewards")
		_check(pending.get_node("Visual/Body").scale == Vector2.ONE, "Enemy is flattened during arrival")
		await create_timer(.6,false).timeout
		_check(not is_instance_valid(effect), "Finished raster effect persists")
	await click("Three: roots + caster") # Disabled until reset: must not mix.
	_check(stage.encounter_controller._active_enemies == 1, "Disabled batch button mixes encounters")
	await click("Reset review")
	await click("Three: roots + caster")
	await create_timer(.4,false).timeout
	_check(stage.encounter_controller._active_enemies == 3, "Three-enemy comparison lost its count")
	await click("Ground: grass")
	_check(_dark_ground and stage.encounter_controller._active_enemies == 3, "Ground toggle did not replay the selected batch")
	await create_timer(.4,false).timeout
	await click("Reset review")
	await click("Eight-live crowd")
	await create_timer(.4,false).timeout
	_check(stage.encounter_controller._active_enemies == 8, "Crowd comparison changed the live cap")
	_check(stage.encounter_controller._pending_enemies.is_empty(), "Crowd review silently queued extra actors")
	await click("Replay same batch")
	_check(stage.encounter_controller._active_enemies == 8, "Replay lost the selected batch")
	await key(KEY_TAB)
	_check(stage.character_menu.visible and not toolbar.visible, "Bag overlaps review controls")
	await key(KEY_ESCAPE)
	_check(not stage.character_menu.visible and toolbar.visible, "Closing bag does not restore controls")
	for button: Button in toolbar.find_children("*","Button",true,false):
		_check(Rect2(Vector2.ZERO,Vector2(960,540)).encloses(button.get_global_rect()), "Review button outside native viewport: "+button.text)
	stage.queue_free()
	await process_frame
	print("ENEMY_ARRIVAL_ART_REVIEW checks=%d failures=%d" % [checks,failures])
	quit(1 if failures else 0)

func click(label: String) -> void:
	for button: Button in toolbar.find_children("*","Button",true,false):
		if button.text == label:
			var point: Vector2 = button.get_global_rect().get_center()
			for pressed in [true,false]:
				var event := InputEventMouseButton.new()
				event.position = point
				event.button_index = MOUSE_BUTTON_LEFT
				event.pressed = pressed
				Input.parse_input_event(event)
				await process_frame
			await process_frame
			while _rebuilding:
				await process_frame
			return
	_check(false,"Missing comparison button: "+label)

func key(code: Key) -> void:
	for pressed in [true,false]:
		var event := InputEventKey.new()
		event.physical_keycode = code
		event.keycode = code
		event.pressed = pressed
		Input.parse_input_event(event)
		await process_frame

func _check(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)
