extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const Burst = preload("res://entities/player/presentation/king_contact_burst.gd")

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("RunSession").reset_run()
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	await physics_frame
	var body: AnimatedSprite2D = player.get_node("VisualRoot/Body")
	var visual: RiftbreakVisual = player.get_node("AbilityPivot/RiftbreakVisual")
	var effects: Node2D = player.get_node("GreatswordEffects")
	var ability := player.ability_2_component
	player.global_position = Vector2(200,200)
	assert(ability.request_cast(Vector2.RIGHT,25))
	# Movement during preparation must not leave contact at the stale windup point.
	player.global_position += Vector2(18,9)
	while ability.phase != AbilityComponent.Phase.ACTIVE:
		await physics_frame
	var origin := ability.hitbox.global_position
	assert(visual.effect_sprite.global_position.distance_to(origin)<.1,"Actual hitbox anchors the ground contact")
	for child in effects.get_children():
		assert(not child is Burst,"No duplicate Riftbreak crater observer")
	player.global_position += Vector2(50,30)
	var seen := {}
	var saw_residual := false
	while visual.visible:
		assert(visual.effect_sprite.global_position.distance_to(origin)<.1,"Crater cannot follow King or jump between rows")
		if visual.effect_sprite.animation == &"impact":
			seen[visual.effect_sprite.frame] = true
		if visual.effect_sprite.animation == &"residual":
			saw_residual = true
		await physics_frame
	assert(seen.size()==7,"Complete impact sequence survives ability recovery")
	assert(saw_residual,"Contact must settle into the residual before fading")
	ability.clear_cooldown()
	assert(ability.request_cast(Vector2.DOWN,25))
	ability.cancel_cast()
	assert(not visual.visible,"Canceled preparation cannot leave a crater")
	for method in ["play_dash","play_hit_recovery","play_interaction","play_defeat"]:
		body.speed_scale=1.35
		match method:
			"play_dash": body.call(method,Vector2.RIGHT)
			"play_hit_recovery": body.call(method,.2)
			_: body.call(method)
		assert(is_equal_approx(body.speed_scale,1),"Movement haste must not alter reaction playback")
		body.resume_locomotion()
	for direction in ["down","left","right","up"]:
		var sweep := body.sprite_frames.get_frame_texture("heavy_cleave_"+direction,4) as AtlasTexture
		var slam := body.sprite_frames.get_frame_texture("riftbreak_"+direction,4) as AtlasTexture
		assert(sweep.atlas!=slam.atlas,"Basic finisher must not borrow the ground-slam sheet")
	var hud := load("res://ui/combat_hud.tscn").instantiate() as CombatHUD
	root.add_child(hud)
	hud.bind_player(player)
	var mastery := player.get_node("KingMastery") as KingMasteryComponent
	var label: Label = hud.get_node("ResolveLabel")
	assert(label.text.contains("LAND BASIC HITS") and not label.text.contains("NEXT SKILL +25%"),"Unfilled Resolve cannot advertise an active bonus")
	mastery.stacks=3
	mastery.resolve_changed.emit(3,3)
	mastery.link_changed.emit(true)
	assert(label.text.contains("RESOLVE READY") and label.text.contains("+25%") and label.text.contains("RUPTURE +15%"),"Landing link must not hide ready Resolve")
	assert(label.mouse_filter!=Control.MOUSE_FILTER_IGNORE and label.tooltip_text.contains("8 seconds"),"Resolve explanation is reachable on hover")
	hud.queue_free()
	player.queue_free()
	await process_frame
	print("KING_PRESENTATION_POLISH_PASSED")
	quit()
