extends SceneTree
const OUT := "res://art_source/review/characters/king/unwritten_oath_2026_09_13/"
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
	camera.global_position=Vector2(365,280)
	camera.zoom=Vector2(1.45,1.45)
	caption=Label.new()
	caption.position=Vector2(200,20)
	caption.size=Vector2(560,52)
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",15)
	lab.get_node("UI").add_child(caption)
	var library := actor.get_node("KingSkillLibrary") as KingSkillLibrary
	library.open_collection()
	await _wait(.2)
	await _save("collection.png")
	library._collection._close()
	await process_frame
	if "--ui-only" in OS.get_cmdline_user_args():
		var menu := load("res://ui/character_menu.tscn").instantiate() as CharacterMenu
		menu.player=actor
		lab.get_node("UI").add_child(menu)
		menu.open_skillkeeper_menu()
		await _wait(.2)
		await _save("skills_menu.png")
		menu.close_menu()
		lab.queue_free()
		await process_frame
		await process_frame
		Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
		Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
		print("KING_OATH_UI_REVIEW_COMPLETE")
		quit()
		return
	library.set_preview_rank(3)
	library.equip_oath_preview()
	library.open_collection()
	library._collection._selected="oathstorm"
	library._collection._refresh()
	await _wait(.2)
	await _save("unbound_collection.png")
	library._collection._close()
	await process_frame
	for index in 8:
		var foe := Foe.instantiate() as Node2D
		lab.actors.add_child(foe)
		foe.set_physics_process(false)
		var health: HealthComponent=foe.get_node("HealthComponent")
		health.maximum_health=100000
		health.set_current_health(100000)
		foes.append(foe)
	for rank in [0,1,3]:
		library.set_preview_rank(rank)
		for slot in 4:
			actor.global_position=Vector2(285,300) if slot==2 else Vector2(365,300)
			actor.velocity=Vector2.ZERO
			actor._set_facing_direction(Vector2.RIGHT)
			for i in foes.size():
				foes[i].global_position=Vector2(365,300)+Vector2.from_angle(i*TAU/8)*100
			var ability := actor.get_ability_component_for_slot(slot+1) as KingOathComponent
			ability.clear_cooldown()
			caption.text=ability.definition.display_name.to_upper()+"\n"+KingOathDefinition.RANK_NAMES[rank]+" form"+(" · future milestone preview" if rank>1 else "")
			if slot==2:
				ability.request_cast_at(Vector2(435,300),38)
			else:
				ability.request_cast(Vector2.RIGHT,38)
			await _wait(ability.definition.wind_up_seconds+.27)
			await _save("rank_"+str(rank)+"_skill_"+str(slot+1)+".png")
			while ability.is_casting():
				await physics_frame
			await _wait(.5)
	caption.text="STARFALL → GRIEFWAKE\nTravel, land, and turn the opening into a rupture."
	actor.global_position=Vector2(285,300)
	var step := actor.get_node("OathAbility3") as KingOathComponent
	step.clear_cooldown()
	step.request_cast_at(Vector2(425,300),38)
	while step.is_casting():
		await physics_frame
	var ground := actor.get_node("OathAbility2") as KingOathComponent
	ground.clear_cooldown()
	ground.request_cast(Vector2.LEFT,38)
	await _wait(1.8)
	lab.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("KING_OATH_RENDER_REVIEW_COMPLETE")
	quit()

func _wait(seconds: float) -> void:
	await create_timer(seconds,true,false,true).timeout

func _save(name: String) -> void:
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+name)
