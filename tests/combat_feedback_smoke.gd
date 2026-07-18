extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const MirelingScene = preload("res://entities/enemies/mireling/mireling.tscn")
const DamageNumberScene = preload("res://ui/world/damage_number.tscn")
const HitBurstScene = preload("res://gameplay/presentation/hit_burst.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate() as Player
	var effects := Node2D.new()
	var camera := Camera2D.new()
	var feedback := CombatFeedbackPresenter.new()
	feedback.player = player
	feedback.effects_parent = effects
	feedback.camera = camera
	feedback.damage_number_scene = DamageNumberScene
	feedback.hit_burst_scene = HitBurstScene
	root.add_child(player)
	player.add_child(camera)
	root.add_child(effects)
	root.add_child(feedback)
	await process_frame

	player.health_component.apply_damage(DamageInfo.new(7.0, null, Vector2.LEFT))
	await process_frame
	if effects.get_child_count() != 2:
		_fail("Accepted player damage did not create a number and hit burst.")
		return
	for effect in effects.get_children():
		effect.queue_free()
	await process_frame

	var mireling := MirelingScene.instantiate() as Mireling
	root.add_child(mireling)
	await process_frame
	player.attack_component.hit_landed.emit(
		mireling.get_node("Hurtbox") as HurtboxComponent,
		DamageInfo.new(25.0, player, Vector2.RIGHT)
	)
	var mireling_body := mireling.get_node("Visual/Body") as AnimatedSprite2D
	if not mireling_body.material is ShaderMaterial:
		_fail("Accepted player hit did not apply the reusable enemy hit-flash material.")
		return
	if not paused:
		_fail("Accepted player hit did not start hitstop.")
		return
	await create_timer(0.12, true, false, true).timeout
	if paused:
		_fail("Hitstop did not restore gameplay after its short real-time window.")
		return
	if mireling_body.material != null:
		_fail("Enemy hit flash did not restore the original material.")
		return
	await process_frame
	if effects.get_child_count() != 2:
		_fail("Accepted player hit did not create outgoing impact feedback.")
		return
	await create_timer(0.7).timeout
	if effects.get_child_count() != 0:
		_fail("Combat feedback did not clean up its transient effects.")
		return
	print("Combat feedback smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
