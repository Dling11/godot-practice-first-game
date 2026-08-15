extends SceneTree

const BossScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")
const DialogueScene = preload("res://ui/dialogue/dialogue_panel.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var boss := BossScene.instantiate() as Stage5Boss
	root.add_child(boss)
	await process_frame
	var audio := boss.get_node("BossAudio")
	for player_name in [
		"Step", "Lunge", "Slap", "JumpLaunch", "JumpAir", "JumpImpact",
		"RootPrison", "Hurt", "Phase", "Defeat",
	]:
		var player := audio.get_node_or_null(player_name) as AudioStreamPlayer
		if player == null or player.stream == null or player.bus != &"SFX":
			_fail("Varkuun audio player %s lost its real stream or SFX routing." % player_name)
			return
	var health := boss.get_node("HealthComponent") as HealthComponent
	health.apply_damage(DamageInfo.new(health.maximum_health * 0.71, null, Vector2.ZERO))
	await process_frame
	if not bool(audio.get("_phase_played")):
		_fail("Varkuun's 30-percent phase cue remained coupled to movement instead of accepted damage.")
		return

	var dialogue := DialogueScene.instantiate() as DialoguePanel
	root.add_child(dialogue)
	dialogue.show_dialogue("VARKUUN", ["FIRST", "SECOND", "THIRD"])
	await process_frame
	await process_frame
	var body := dialogue.get_node("Panel/Margin/Root/Text/BodyLabel") as Label
	if body.text != "FIRST":
		_fail("Dialogue did not begin on its first line.")
		return
	var press := InputEventKey.new()
	press.keycode = KEY_SPACE
	press.pressed = true
	Input.parse_input_event(press)
	await process_frame
	var release := InputEventKey.new()
	release.keycode = KEY_SPACE
	release.pressed = false
	Input.parse_input_event(release)
	await process_frame
	if body.text != "SECOND":
		_fail("One Space press did not advance dialogue by exactly one line (now %s)." % body.text)
		return

	print("Varkuun real-audio routing and single-advance dialogue input passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
