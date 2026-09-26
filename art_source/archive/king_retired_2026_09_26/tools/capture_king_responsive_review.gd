extends SceneTree

const OUT := "res://art_source/review/characters/king/responsive_2026_09_13/"
const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const Foe = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
var lab: Node
var actor: Player
var caption: Label
var foes: Array[Node2D] = []

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	call_deferred("_run")

func _run() -> void:
	root.get_node("RunSession").reset_run()
	lab=Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	lab.clear_simulation()
	lab.get_node("UI/LabPanel").hide()
	lab.get_node("UI/BossHealthHUD").hide()
	actor=lab.player
	actor.global_position=Vector2(365,300)
	var camera: Camera2D=lab.camera
	camera.top_level=true
	camera.limit_left=-10000
	camera.limit_top=-10000
	camera.limit_right=10000
	camera.limit_bottom=10000
	camera.global_position=Vector2(400,280)
	camera.zoom=Vector2(1.3,1.3)
	caption=Label.new()
	caption.position=Vector2(230,28)
	caption.size=Vector2(500,42)
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",13)
	lab.get_node("UI").add_child(caption)
	var library: KingSkillLibrary=actor.get_node("KingSkillLibrary")
	library.equip_oath_preview()
	library.open_collection()
	library._collection._selected="griefwake"
	library._collection._refresh()
	await _wait(.2)
	await _save("collection.png")
	library._collection._close()
	await process_frame
	var menu := load("res://ui/character_menu.tscn").instantiate() as CharacterMenu
	menu.player=actor
	lab.get_node("UI").add_child(menu)
	menu.open_skillkeeper_menu()
	await _wait(.2)
	await _save("skills_menu.png")
	menu.close_menu()
	if "--ui-only" in OS.get_cmdline_user_args():
		await _finish()
		return
	for index in 8:
		var foe := Foe.instantiate() as Node2D
		lab.actors.add_child(foe)
		foe.set_physics_process(false)
		var health: HealthComponent=foe.get_node("HealthComponent")
		health.maximum_health=100000
		health.set_current_health(100000)
		foes.append(foe)
	for rank in [0,3]:
		library.set_preview_rank(rank)
		for slot in 4:
			actor.global_position=Vector2(320,300)
			actor.velocity=Vector2.ZERO
			actor._set_facing_direction(Vector2.RIGHT)
			for i in foes.size():
				foes[i].global_position=Vector2(385,300)+Vector2.from_angle(i*TAU/8)*45
			var ability: KingOathComponent=actor.get_ability_component_for_slot(slot+1)
			ability.clear_cooldown()
			caption.text=ability.definition.display_name.to_upper()+" · "+KingOathDefinition.RANK_NAMES[rank]+"\n"+["Two cuts. Short pressure window.","Aim, release, move while the ground erupts.","Evasive travel. No forced landing attack.","One precise impact. Wider, weaker crowd wave."][slot]
			if slot==1:
				actor.set_physics_process(false)
				actor.request_ability(2)
				actor.ground_point_targeting.update_aim(Vector2(400,300),Vector2.ZERO)
				await _wait(.45)
				await _save("targeted_griefwake.png")
				actor.ground_point_targeting.confirm_targeting()
				actor.set_physics_process(true)
			else:
				ability.request_cast(Vector2.RIGHT,38)
			await _wait([.14,.50,.14,.31][slot])
			await _save("rank_%d_skill_%d.png" % [rank,slot+1])
			while ability.is_casting():
				await physics_frame
			await _wait(.8)
	caption.text="RELEASED GRIEFWAKE + CROSSCUT\nKing can act while his aimed eruption finishes."
	actor.global_position=Vector2(320,300)
	var ground: KingOathComponent=actor.get_node("OathAbility2")
	ground.clear_cooldown()
	ground.request_cast_at(Vector2(400,300),38)
	while ground.is_casting():
		await physics_frame
	var cross: KingOathComponent=actor.get_node("OathAbility1")
	cross.clear_cooldown()
	cross.request_cast(Vector2.RIGHT,38)
	await _wait(1.2)
	await _finish()

func _finish() -> void:
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("KING_RESPONSIVE_REVIEW_COMPLETE")
	quit()

func _wait(seconds: float) -> void:
	await create_timer(seconds,true,false,true).timeout

func _save(file_name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+file_name)
