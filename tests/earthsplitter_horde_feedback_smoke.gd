extends SceneTree

## Real released wave contacts across different physics ticks, not emitted mocks.
const PLAYER = preload("res://entities/player/player.tscn")
const ENEMY = preload("res://entities/enemies/mireling/mireling.tscn")
var contacts := 0
var contact_frames: Dictionary = {}

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	var world := Node2D.new()
	root.add_child(world)
	var player := PLAYER.instantiate() as Player
	world.add_child(player)
	player.position = Vector2(260,300)
	player.set_physics_process(false)
	var form := EarthsplitterDefinition.Form.FAN if "--fan" in OS.get_cmdline_user_args() else (EarthsplitterDefinition.Form.CASCADE if "--cascade" in OS.get_cmdline_user_args() else EarthsplitterDefinition.Form.FOUNDATION)
	player.ability_1_component.definition = player.ability_1_component.definition.duplicate(true)
	player.ability_1_component.definition.configure_form(form)
	var feedback := CombatFeedbackPresenter.new()
	feedback.player = player
	feedback.effects_parent = world
	feedback.camera = Camera2D.new()
	player.add_child(feedback.camera)
	feedback.damage_number_scene = load("res://ui/world/damage_number.tscn")
	feedback.hit_burst_scene = load("res://gameplay/presentation/hit_burst.tscn")
	world.add_child(feedback)
	player.ability_1_component.hit_landed.connect(func(_hurtbox: HurtboxComponent, _info: DamageInfo) -> void:
		contacts += 1
		contact_frames[Engine.get_physics_frames()] = true
	)
	for index in 8:
		var enemy := ENEMY.instantiate() as Mireling
		var reward := enemy.get_node_or_null("EnemyRewardComponent")
		if reward != null:
			enemy.remove_child(reward)
			reward.free()
		enemy.position = Vector2(290+index*18,300)
		world.add_child(enemy)
		enemy.health_component.maximum_health = 1000
		enemy.health_component.current_health = 1000
		enemy.set_physics_process(false)
	await create_timer(0.8).timeout
	assert(player.ability_1_component.request_cast_at(Vector2(580,300),10.0))
	var start := Time.get_ticks_usec()
	var pauses := 0
	var paused_usec := 0
	var was_paused := false
	var previous := start
	while Time.get_ticks_usec()-start < 1800000:
		await process_frame
		var now := Time.get_ticks_usec()
		if was_paused: paused_usec += now-previous
		if paused and not was_paused: pauses += 1
		was_paused = paused
		previous = now
	print("EARTHSPLITTER_HORDE form=%d contacts=%d contact_ticks=%d global_pauses=%d paused_ms=%.2f" % [form,contacts,contact_frames.size(),pauses,paused_usec/1000.0])
	assert(contacts == [8,16,24][form],"Released wave lost or duplicated its authored target contacts")
	assert(contact_frames.size() > 1,"Fixture must span multiple physics ticks")
	if not "--baseline" in OS.get_cmdline_user_args():
		assert(pauses == 0,"Authored travelling wave must not pause the whole game per target")
		assert(CombatFeedbackPresenter.find_for_player(player) == feedback,"Feedback must resolve independently of service folder names")
	world.queue_free()
	await process_frame
	quit()
