extends SceneTree

## Review-only capture of installed skills. No runtime resources or saves change.
const OUT := "res://art_source/review/characters/king/skill_choices_2026_09_13/"
const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
const Foe = preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")
var lab: Node
var actor: Player
var caption: Label
var detail: Label
var foes: Array[Node2D] = []
var segments: Array[Dictionary] = []

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
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	actor=lab.player
	actor.global_position=Vector2(340,300)
	var camera: Camera2D=lab.camera
	camera.top_level=true
	camera.limit_left=-10000
	camera.limit_top=-10000
	camera.limit_right=10000
	camera.limit_bottom=10000
	camera.global_position=Vector2(400,280)
	camera.zoom=Vector2(2.0,2.0)
	var layer := CanvasLayer.new()
	root.add_child(layer)
	var title_back := ColorRect.new()
	title_back.color=Color(.025,.04,.06,.94)
	title_back.position=Vector2(0,0)
	title_back.size=Vector2(960,62)
	layer.add_child(title_back)
	caption=Label.new()
	caption.position=Vector2(16,8)
	caption.size=Vector2(928,24)
	caption.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size",18)
	layer.add_child(caption)
	detail=Label.new()
	detail.position=Vector2(16,36)
	detail.size=Vector2(928,18)
	detail.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
	detail.add_theme_font_size_override("font_size",12)
	detail.modulate=Color(.65,.8,.86)
	layer.add_child(detail)
	var library: KingSkillLibrary=actor.get_node("KingSkillLibrary")
	library.set_preview_rank(0)
	for index in 4:
		var foe := Foe.instantiate() as Node2D
		lab.actors.add_child(foe)
		foe.set_physics_process(false)
		var health: HealthComponent=foe.get_node("HealthComponent")
		health.maximum_health=100000
		health.set_current_health(100000)
		foes.append(foe)
	var abilities := library.entries()
	for index in abilities.size():
		if "--body-only" in OS.get_cmdline_user_args():
			break
		var ability: AbilityComponent=abilities[index]
		camera.zoom=Vector2(1.3,1.3) if index==3 else Vector2(2.0,2.0)
		camera.global_position=Vector2(400,245) if index==3 else Vector2(400,280)
		_reset_positions(index)
		actor.get_node("KingMastery").clear()
		ability.clear_cooldown()
		var id := String(ability.definition.ability_id)
		caption.text=ability.definition.display_name.to_upper()
		detail.text="Original installed skill" if index<4 else "Latest installed version · Mortal form"
		var start_frame := Engine.get_process_frames()
		await _wait(.45)
		var target := Vector2(400,300)
		if ability.supports_ground_targeting():
			ability.request_cast_at(target,38)
		else:
			ability.request_cast(Vector2.RIGHT,38)
		while ability.is_casting():
			await physics_frame
		await _wait(1.0)
		segments.append({"id":id,"name":ability.definition.display_name,"start":start_frame/60.0,"end":Engine.get_process_frames()/60.0,"group":"Original" if index<4 else "Latest"})
		await _wait(.3)
	# Separate body-reference loops allow the owner to judge King's pixel detail.
	for foe in foes:
		foe.queue_free()
	await process_frame
	actor.global_position=Vector2(370,300)
	actor.velocity=Vector2.ZERO
	actor._set_facing_direction(Vector2.RIGHT)
	caption.text="KING · THREE-CUT BASIC ATTACK"
	detail.text="Current body and sword animation · unchanged"
	var combo_start := Engine.get_process_frames()
	await _wait(.4)
	actor.attack_component.reset_combo()
	for index in 3:
		actor.attack_component.request_attack(Vector2.RIGHT)
		while actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE:
			await physics_frame
	await _wait(.8)
	segments.append({"id":"basic_combo","name":"Basic attack combo","start":combo_start/60.0,"end":Engine.get_process_frames()/60.0,"group":"Body reference"})
	caption.text="KING · WALKING"
	detail.text="Current pixel detail and proportions · unchanged"
	actor.global_position=Vector2(360,300)
	var walk_start := Engine.get_process_frames()
	await _wait(.35)
	for action in ["player_move_right","player_move_down","player_move_left","player_move_up"]:
		Input.action_press(action)
		await _wait(.50)
		Input.action_release(action)
	await _wait(.5)
	segments.append({"id":"walking","name":"Walking reference","start":walk_start/60.0,"end":Engine.get_process_frames()/60.0,"group":"Body reference"})
	var output := FileAccess.open(OUT+("body_segments.json" if "--body-only" in OS.get_cmdline_user_args() else "segments.json"),FileAccess.WRITE)
	output.store_string(JSON.stringify(segments,"\t"))
	lab.queue_free()
	layer.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null,Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null,Input.CURSOR_POINTING_HAND)
	print("KING_SKILL_CHOICES_CAPTURE_COMPLETE")
	quit()

func _reset_positions(index: int) -> void:
	actor.global_position=Vector2(340,300)
	actor.velocity=Vector2.ZERO
	actor._set_facing_direction(Vector2.RIGHT)
	for i in foes.size():
		var point := Vector2(410,300)+Vector2.from_angle(i*TAU/4.0)*26
		if index==1:
			point=actor.global_position+Vector2.from_angle(i*TAU/4.0)*34
		elif index==6:
			point.y+=65 # Keep the movement-only preview visible beside the targets.
		foes[i].global_position=point
		foes[i].velocity=Vector2.ZERO

func _wait(seconds: float) -> void:
	await create_timer(seconds,true,false,true).timeout
