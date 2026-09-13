extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const GroundAttack = preload("res://gameplay/abilities/king/oath/king_oath_ground_attack.gd")
var checks := 0
var actor: Player

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_responsive_smoke.json")
	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	actor = PlayerScene.instantiate()
	root.add_child(actor)
	actor.set_physics_process(false)
	actor.global_position=Vector2(200,200)
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	_check(actor.skill_loadout.has_complete_layout(),"Ten-slot layout")
	_check(library.current_ids().size()==10,"Ten serialized slots")
	for slot in range(5,11):
		_check(actor.get_ability_component_for_slot(slot)==null,"Expansion grants no skills")
		_check(InputMap.has_action("player_skill_%d" % slot),"Expanded input exists")
	_check(actor.skill_loadout.get_slot(10).get_key_label()=="0","Tenth slot uses zero")
	_check(KingSkillCatalog.valid_slots(library.current_ids()),"Empty slots validate")
	_check(KingSkillCatalog.valid_slots(KingOathDefinition.FAMILIES),"Four-slot saves still validate")
	var duplicate := library.current_ids()
	duplicate[9]=duplicate[0]
	_check(not KingSkillCatalog.valid_slots(duplicate),"Duplicate equipped skill rejected")
	for family in 4:
		for rank in 4:
			var tuning := KingOathDefinition.new()
			tuning.technique=family
			tuning=tuning.at_rank(rank)
			var seconds := tuning.wind_up_seconds+tuning.active_seconds+tuning.recovery_seconds
			_check(seconds <= [.50,.45,.35,.65][family],"Higher forms retain short control lock")
			_check(tuning.beat_times.size()==[2,1,0,1][family],"No upgrade adds compulsory hits")
	var ground: KingOathComponent = actor.get_node("OathAbility2")
	var heavy: KingOathComponent = actor.get_node("OathAbility4")
	var cross: KingOathComponent = actor.get_node("OathAbility1")
	var step: KingOathComponent = actor.get_node("OathAbility3")
	_check(ground.supports_ground_targeting() and not step.supports_ground_targeting(),"Targeted ground; immediate mobility")
	var core := _target(Vector2(290,200))
	var rim := _target(Vector2(336,200))
	var outside := _target(Vector2(400,200))
	await physics_frame
	# Cast cancellation before release cannot create a lingering attack.
	ground.request_cast_at(core.global_position,25)
	ground.cancel_cast()
	await _wait(.65)
	_check(core.health_component.current_health==1000,"Cancelled wind-up deals no damage")
	_check(ground.cooldown_remaining>0,"Cancel retains cooldown")
	ground.clear_cooldown()
	ground.request_cast_at(core.global_position,25)
	while ground.is_casting():
		await physics_frame
	_check(core.health_component.current_health==1000,"Control returns before delayed ground impact")
	_check(cross.request_cast(Vector2.LEFT,25),"New skill begins while ground attack remains live")
	# Moving the caster and replacing the definition must not redirect old damage.
	actor.global_position=Vector2(600,200)
	ground.definition=(ground.definition as KingOathDefinition).at_rank(3)
	await _wait(.30)
	_check(is_equal_approx(1000-core.health_component.current_health,60.0),"Released core preserves cast damage and world position")
	_check(is_equal_approx(1000-rim.health_component.current_health,33.0),"Rim gets one weaker tier, never core plus rim")
	_check(outside.health_component.current_health==1000,"No damage beyond preview")
	cross.cancel_cast()
	actor.global_position=Vector2(200,200)
	core.global_position=Vector2(240,200)
	rim.global_position=Vector2(305,200)
	core.health_component.set_current_health(1000)
	rim.health_component.set_current_health(1000)
	await physics_frame
	heavy.request_cast(Vector2.RIGHT,25)
	await _wait(.75)
	_check(is_equal_approx(1000-core.health_component.current_health,100.0),"Last Oath precision damage")
	_check(is_equal_approx(1000-rim.health_component.current_health,32.0),"Last Oath crowd rim damage")
	var riposte: KingRiposteComponent = actor.get_node("KingRiposte")
	var hostile := Node2D.new()
	root.add_child(hostile)
	step.request_cast(Vector2.RIGHT,25)
	while not step._travel_invulnerable:
		await physics_frame
	actor.health_component.apply_damage(DamageInfo.new(10,hostile,Vector2.LEFT))
	_check(not riposte._window.is_stopped(),"Real evaded hit earns riposte")
	while step.is_casting():
		await physics_frame
	_check(not actor.health_component.is_invulnerable,"Protection ends with travel")
	actor.attack_component.request_attack(Vector2.RIGHT)
	_check(actor.attack_component.committed_damage_multiplier==1.5,"Riposte empowers one accepted basic attack")
	_check(actor.attack_component.get_animation_key()=="return_cut","Riposte has matching physical cut")
	_check(riposte._window.is_stopped(),"Riposte consumed once")
	actor.attack_component.cancel_attack()
	actor.attack_component.request_attack(Vector2.RIGHT)
	_check(actor.attack_component.committed_damage_multiplier==1.0,"Following attack returns to normal damage")
	actor.attack_component.cancel_attack()
	step.clear_cooldown()
	step.request_cast(Vector2.RIGHT,25)
	while not step._travel_invulnerable:
		await physics_frame
	actor.health_component.is_damage_immune=true
	actor.health_component.apply_damage(DamageInfo.new(10,hostile,Vector2.LEFT))
	_check(riposte._window.is_stopped(),"Debug immunity never earns riposte")
	actor.health_component.is_damage_immune=false
	var verdict := DamageInfo.new(1,hostile,Vector2.LEFT)
	verdict.ignores_invulnerability=true
	actor.health_component.apply_damage(verdict)
	_check(riposte._window.is_stopped(),"Dodge-piercing damage never earns riposte")
	step.cancel_cast()
	# A cancelled step does not create an earned completion link.
	var mastery: KingMasteryComponent=actor.get_node("KingMastery")
	mastery.clear()
	step.clear_cooldown()
	mastery.stacks=3
	step.request_cast(Vector2.RIGHT,25)
	_check(mastery.stacks==3,"Non-damaging mobility preserves Resolve")
	step.cancel_cast()
	_check(mastery._link.is_stopped(),"Cancelled step grants no completion link")
	# The shared buffer must not steal a requested dash during cancellation.
	cross.clear_cooldown()
	mastery.clear()
	cross.request_cast(Vector2.RIGHT,25)
	actor.request_ability(1) # Queue a different ready legacy ability.
	_check(actor.request_evade(Vector2.LEFT),"Dash cancels a cancellable core cast")
	_check(actor.evade_component.is_dashing() and not actor.is_any_ability_casting(),"Cancel cannot launch a stale buffered ability before Dash")
	await _wait(.65)
	# Normal movement resumes while Griefwake's released attack is still pending.
	ground.clear_cooldown()
	ground.request_cast_at(Vector2(400,200),25)
	while ground.is_casting():
		await physics_frame
	actor.set_physics_process(true)
	var before_move := actor.global_position
	Input.action_press("player_move_down")
	await _wait(.10)
	Input.action_release("player_move_down")
	_check(actor.global_position.y>before_move.y,"Ordinary movement works immediately after release recovery")
	actor.set_physics_process(false)
	await _wait(.3)
	# Bounded slow refresh does not alter the actor's authored base speed.
	var movement := EnemyMovementComponent.new()
	root.add_child(movement)
	movement.apply_slow(.25,.1)
	_check(is_equal_approx(movement.calculate_velocity(Vector2.ZERO,Vector2.RIGHT,100,10000,1).x,75),"Slow lowers ordinary movement")
	await _wait(.15)
	_check(is_equal_approx(movement.calculate_velocity(Vector2.ZERO,Vector2.RIGHT,100,10000,1).x,100),"Slow expires back to authored speed")
	movement.queue_free()
	# Restoring an older loadout expands it, preserving choices without rewards.
	var old := ["crosscut_advance","riftbreak","starfall_step","king_skill_4"]
	root.get_node("RunSession").king_skill_slots=old
	var restored := PlayerScene.instantiate() as Player
	root.add_child(restored)
	_check(restored.get_node("KingSkillLibrary").current_ids()==KingSkillCatalog.expanded_slots(old),"Four-slot save migrates without rearrangement")
	var ten := restored.get_node("KingSkillLibrary").current_ids() as Array
	ten[9]=ten[0]
	ten[0]=""
	root.get_node("RunSession").king_skill_slots=ten
	var snapshot: Dictionary=root.get_node("RunSession").create_snapshot()
	_check(root.get_node("RunSession").can_restore_snapshot(snapshot),"Ten-slot save round-trip accepts empty positions")
	var saves := root.get_node("SaveService")
	_check(saves.save_profile(),"Ten-slot profile writes to isolated storage")
	root.get_node("RunSession").king_skill_slots=[]
	_check(saves.load_profile()!= "" and root.get_node("RunSession").king_skill_slots==ten,"Ten-slot disk load preserves positions and empty slots")
	restored.get_node("KingSkillLibrary")._apply_slots(ten)
	Input.action_press("player_skill_10")
	await physics_frame
	await physics_frame
	Input.action_release("player_skill_10")
	_check(restored.get_node("OathAbility1").is_casting(),"Zero input activates tenth equipped ability")
	restored.queue_free()
	await process_frame
	library._apply_slots(["echoing_sever","riftbreak","starfall_step","king_skill_4"])
	actor._set_facing_direction(Vector2.RIGHT)
	step.clear_cooldown()
	cross.clear_cooldown()
	cross.request_cast(Vector2.RIGHT,25)
	Input.action_press("player_move_left")
	actor.request_ability(3)
	Input.action_release("player_move_left")
	while cross.is_casting():
		await physics_frame
	await physics_frame
	_check(step.is_casting() and step.get_cast_direction().x<-.9,"Buffered Breakstep preserves requested movement direction")
	step.cancel_cast()
	# Defeat removes detached authority before it can strike.
	ground.clear_cooldown()
	ground.request_cast_at(core.global_position,25)
	while ground.phase!=AbilityComponent.Phase.RECOVERY:
		await physics_frame
	actor.defeated.emit()
	await process_frame
	for child in ground.get_children():
		_check(not child is GroundAttack,"Defeat clears released ground attacks")
	actor.queue_free()
	core.queue_free()
	rim.queue_free()
	outside.queue_free()
	hostile.queue_free()
	await process_frame
	print("KING_RESPONSIVE_PASSED=",checks)
	quit()

func _target(point: Vector2) -> HurtboxComponent:
	var health := HealthComponent.new()
	health.maximum_health=1000
	root.add_child(health)
	var hurt := HurtboxComponent.new()
	hurt.health_component=health
	hurt.collision_layer=16
	hurt.collision_mask=8
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius=2
	shape.shape=circle
	hurt.add_child(shape)
	root.add_child(hurt)
	hurt.global_position=point
	return hurt

func _wait(seconds: float) -> void:
	await create_timer(seconds).timeout

func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
		assert(condition,message)
	checks+=1
