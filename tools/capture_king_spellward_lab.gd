extends SceneTree

const OUT := "res://art_source/review/characters/king/spellward_lab_2026_09_14/"
const Lab = preload("res://levels/combat_lab/combat_lab.tscn")
var lab: Node
var actor: Player
var review: Node
var caption: Label
var segments: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	lab = Lab.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	actor = lab.player
	review = lab.get_node("KingSpellwardReview")
	review.open_review()
	await process_frame
	actor.global_position = Vector2(340, 330)
	for foe: Node2D in lab._active_enemies:
		if is_instance_valid(foe):
			foe.global_position = actor.global_position + Vector2(28, 0)
			foe.set_physics_process(false)
			var health: HealthComponent = foe.get_node("HealthComponent")
			health.maximum_health = 100000
			health.set_current_health(100000)
	var start := Engine.get_process_frames()
	await _wait(.5)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT + "playable_lab.png")
	await _combo(Vector2.RIGHT)
	_record("playable_lab", start)
	lab.clear_simulation()
	await process_frame
	for child in lab.get_node("UI").get_children():
		if child is CanvasItem:
			child.hide()
	lab.camera.zoom = Vector2(2, 2)
	lab.camera.global_position = Vector2(400, 300)
	var overlay := CanvasLayer.new()
	root.add_child(overlay)
	caption = Label.new()
	caption.position = Vector2(20, 16)
	caption.size = Vector2(920, 30)
	caption.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	caption.add_theme_font_size_override("font_size", 18)
	overlay.add_child(caption)
	actor.global_position = Vector2(370, 320)
	caption.text = "KING C · STABLE IDLE / FOUR-DIRECTION WALK"
	start = Engine.get_process_frames()
	for direction in [Vector2.DOWN, Vector2.RIGHT, Vector2.UP, Vector2.LEFT]:
		actor._set_facing_direction(direction)
		await _wait(.35)
	for action in ["player_move_right", "player_move_down", "player_move_left", "player_move_up"]:
		Input.action_press(action)
		await _wait(.6)
		Input.action_release(action)
	await _wait(.4)
	_record("locomotion", start)
	actor.global_position = Vector2(370, 320)
	caption.text = "THREE DISTINCT CUTS · WHITE CONTACT TRAILS"
	start = Engine.get_process_frames()
	for direction in [Vector2.RIGHT, Vector2.DOWN, Vector2.LEFT, Vector2.UP]:
		await _combo(direction)
		await _wait(.22)
	_record("combo", start)
	caption.text = "REACTIONS · STUN DURATION FOLLOWS COMBAT AUTHORITY"
	start = Engine.get_process_frames()
	actor._set_facing_direction(Vector2.RIGHT)
	review.sample_hit(.11)
	await _wait(.45)
	review.sample_hit(.8)
	await _wait(1.05)
	actor.request_evade(Vector2.RIGHT)
	await _wait(.6)
	_record("reactions", start)
	actor.global_position = Vector2(370, 320)
	caption.text = "EQUIPMENT CAPS · +35% MOVE / +50% ATTACK SPEED"
	review.cycle_speed()
	review.cycle_speed()
	start = Engine.get_process_frames()
	Input.action_press("player_move_right")
	await _wait(.45)
	Input.action_release("player_move_right")
	await _wait(.2)
	await _combo(Vector2.RIGHT)
	review.cycle_speed()
	_record("speed_caps", start)
	caption.text = "DEFEAT · CORRECT FACING / GROUNDED FINISH"
	start = Engine.get_process_frames()
	actor.health_component.is_damage_immune = false
	actor.health_component.set_invulnerable(false)
	actor.health_component.apply_damage(DamageInfo.new(100000, lab, Vector2.LEFT))
	await _wait(1.1)
	_record("defeat", start)
	FileAccess.open(OUT + "segments.json", FileAccess.WRITE).store_string(JSON.stringify(segments, "\t"))
	lab.queue_free()
	overlay.queue_free()
	await process_frame
	await process_frame
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	print("SPELLWARD_LAB_CAPTURE_COMPLETE")
	quit()

func _combo(direction: Vector2) -> void:
	actor._set_facing_direction(direction)
	actor.attack_component.reset_combo()
	for index in 3:
		actor.attack_component.request_attack(direction)
		while actor.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
			await physics_frame

func _record(id: String, start: int) -> void:
	segments.append({"id": id, "start": start / 60.0, "end": Engine.get_process_frames() / 60.0})

func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout
