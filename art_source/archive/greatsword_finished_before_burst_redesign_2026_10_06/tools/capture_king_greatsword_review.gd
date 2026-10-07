extends SceneTree
var OUT := "res://art_source/review/characters/king/greatsword_2026_09_12/"
const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const Foe = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
var _caption: Label
var _player: Player
var _lab: Node
var _rift_review_cast := 0

func _initialize() -> void:
	if "--polish" in OS.get_cmdline_user_args():
		OUT = "res://art_source/review/characters/king/polish_2026_09_13/"
	call_deferred("_run")

func _run() -> void:
	root.get_node("RunSession").reset_run()
	_lab = Lab.instantiate()
	root.add_child(_lab)
	await process_frame
	await process_frame
	_lab.clear_simulation()
	_lab.get_node("UI/LabPanel").hide()
	_lab.get_node("UI/BossHealthHUD").hide()
	_player = _lab.player
	if "--polish" in OS.get_cmdline_user_args():
		var crater: AnimatedSprite2D = _player.get_node("AbilityPivot/RiftbreakVisual/EffectSprite")
		_player.ability_2_component.ability_started.connect(func() -> void: _rift_review_cast += 1)
		crater.frame_changed.connect(func() -> void:
			if crater.visible and crater.animation == &"impact":
				_save("riftbreak_cast_"+str(_rift_review_cast)+"_contact_"+str(crater.frame)+".png")
		)
	_player.global_position = Vector2(365,300)
	var camera: Camera2D = _lab.camera
	camera.top_level=true
	camera.limit_left=-10000
	camera.limit_right=10000
	camera.limit_top=-10000
	camera.limit_bottom=10000
	camera.global_position=Vector2(365,280)
	camera.zoom=Vector2(2,2)
	_caption=Label.new()
	_caption.position=Vector2(220,20)
	_caption.size=Vector2(520,45)
	_caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	_caption.add_theme_font_size_override("font_size",14)
	_lab.get_node("UI").add_child(_caption)
	_caption.text="KING · GREAT SWORD C\n2× animation inspection"
	await _wait(.8)
	for entry in [["player_move_down",Vector2.DOWN],["player_move_right",Vector2.RIGHT],["player_move_up",Vector2.UP],["player_move_left",Vector2.LEFT]]:
		_player.global_position=Vector2(365,300)
		Input.action_press(entry[0])
		await _wait(.8)
		Input.action_release(entry[0])
		await _wait(.18)
	_player.set_physics_process(false)
	_player.velocity=Vector2.ZERO
	_player.movement_changed.emit(Vector2.ZERO,false)
	_player.global_position=Vector2(365,300)
	var foe := Foe.instantiate()
	_lab.actors.add_child(foe)
	foe.set_physics_process(false)
	var health := foe.get_node("HealthComponent") as HealthComponent
	health.maximum_health=10000
	health.set_current_health(10000)
	for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]:
		_player.attack_component.reset_combo()
		_player._set_facing_direction(direction)
		_caption.text="OPENING CUT → RETURN CUT → FINISHING SWEEP\nWhite contact light follows the real hit shape"
		for index in 3:
			foe.global_position=_player.get_node("SwordPivot").global_position+direction*25+Vector2(0,10)
			_player.request_primary_attack()
			var captured := false
			while _player.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
				if not captured and index == 0 and _player.attack_component.phase == MeleeAttackComponent.Phase.ACTIVE:
					captured = true
					await _save("slash_"+str(direction)+".png")
				await physics_frame
		await _wait(.2)
	_player._set_facing_direction(Vector2.RIGHT)
	foe.global_position=_player.global_position+Vector2(55,0)
	_caption.text="1 · ECHOING SEVER + RESOLVE\nPrimary cut and delayed echo"
	_player.ability_1_component.request_cast(Vector2.RIGHT,25)
	await _wait(.22)
	await _save("echoing_sever.png")
	await _wait(.9)
	if "--polish" in OS.get_cmdline_user_args():
		foe.global_position=Vector2(900,900)
	_caption.text="2 · RIFTBREAK\nPlanted greatsword, grounded impact"
	_player.ability_2_component.request_cast(Vector2.RIGHT,25)
	await _wait(.2)
	await _save("riftbreak.png")
	await _wait(.65)
	_player.ability_2_component.clear_cooldown()
	_player.set_physics_process(true)
	_caption.text="3 → 2 · PURSUIT / RIFTBREAK\nCollision-safe leap opens a +15% follow-up"
	_player.ability_3_component.request_cast_at(_player.global_position+Vector2(60,0),25)
	_player.request_ability(2)
	await _wait(1.25)
	_player.set_physics_process(false)
	_player._set_facing_direction(Vector2.RIGHT)
	_caption.text="4 · WORLDSPLITTER\nFormation → first crash → final detonation"
	_player.ability_4_component.request_cast_at(_player.global_position+Vector2(50,0),25)
	await _wait(.98)
	await _save("worldsplitter.png")
	await _wait(1.2)
	_caption.text="KING · GREAT SWORD C\nNative gameplay scale"
	camera.zoom=Vector2.ONE
	await _wait(.4)
	await _save("native_gameplay.png")
	var menu := load("res://ui/character_menu.tscn").instantiate() as CharacterMenu
	menu.player=_player
	_lab.get_node("UI").add_child(menu)
	menu.open_menu()
	await _wait(.25)
	await _save("character_menu.png")
	menu._show_page(&"skills",false)
	await _wait(.25)
	await _save("skills_menu.png")
	menu.close_menu()
	menu.queue_free()
	_lab.queue_free()
	await process_frame
	await process_frame
	# Release review cursor handles before the rendering server shuts down.
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("KING_GREATSW0RD_RENDER_REVIEW_COMPLETE")
	quit()

func _wait(seconds: float) -> void:
	await create_timer(seconds,true,false,true).timeout

func _save(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name)
