extends SceneTree
const PlayerScene = preload("res://entities/player/player.tscn")
var checks := 0
var contacts: Array[int] = []
var actor: Player

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("RunSession").reset_run()
	var story := root.get_node("StoryState")
	story.reset_story()
	actor=PlayerScene.instantiate()
	root.add_child(actor)
	actor.set_physics_process(false)
	actor.global_position=Vector2(200,200)
	var library := actor.get_node("KingSkillLibrary") as KingSkillLibrary
	_check(library.entries().size()==8,"Eight component authorities")
	_check(library.is_learned("crosscut_advance") and library.is_learned("starfall_step"),"Initial mobility and crosscut learned")
	_check(not library.is_learned("griefwake") and not library.is_learned("oathstorm"),"Story unlocks remain gated")
	_check(not library.set_preview_rank(3) and not library.equip("crosscut_advance",1),"No production preview or field swapping")
	story.remember_story(&"forgotten_grove_completed")
	_check(library.is_learned("griefwake"),"Stage II unlock")
	story.remember_story(&"forest_stage_5_cleared")
	_check(library.is_learned("oathstorm") and library.get_rank()==1,"Stage V unlock and rank")
	_check(KingSkillCatalog.valid_slots(KingOathDefinition.FAMILIES),"Stable four-slot save")
	_check(KingSkillCatalog.valid_slots([]),"Legacy save migration")
	_check(not KingSkillCatalog.valid_slots(["oathstorm","oathstorm","riftbreak","starfall_step"]),"Duplicate save rejected")
	_check(not KingSkillCatalog.valid_slots(["missing","griefwake","starfall_step","oathstorm"]),"Unknown save rejected")
	var session := root.get_node("RunSession")
	session.king_skill_slots=KingOathDefinition.FAMILIES.duplicate()
	var snapshot: Dictionary = session.create_snapshot()
	_check(session.can_restore_snapshot(snapshot),"New snapshot validates")
	session.king_skill_slots=[]
	_check(session.restore_snapshot(snapshot) and session.king_skill_slots==KingOathDefinition.FAMILIES,"Snapshot round trip")
	var target := _target()
	var outside := _target()
	var mastery: KingMasteryComponent = actor.get_node("KingMastery")
	for ability in library.entries():
		if not ability is KingOathComponent:
			continue
		ability.strike_started.connect(func(index: int,_count: int,_duration: float) -> void: contacts.append(index))
		for rank in 4:
			actor.global_position=Vector2(200,200)
			mastery.clear()
			ability.definition=(ability.definition as KingOathDefinition).at_rank(rank)
			ability.clear_cooldown()
			var tuning := ability.definition as KingOathDefinition
			var immutable := tuning.strike_damage_multipliers.duplicate()
			contacts.clear()
			target.global_position=actor.global_position+Vector2(28,0)
			outside.global_position=actor.global_position+Vector2(900,0)
			var before := target.health_component.current_health
			var missed := outside.health_component.current_health
			await physics_frame
			_check(ability.request_cast_at(target.global_position,25) if tuning.technique==1 else ability.request_cast(Vector2.RIGHT,25),"Cast rank "+str(rank))
			_check(actor.get_active_ability_component()==ability,"Generic active authority")
			var elapsed := 0.0
			while ability.is_casting() and elapsed<4:
				await physics_frame
				elapsed+=1.0/60
			_check(not ability.is_casting(),"Complete timeline")
			await create_timer(.25).timeout # Released ground authority outlives control.
			_check(contacts.size()==tuning.beat_times.size(),"Every authored contact fires")
			_check(target.health_component.current_health<before if tuning.technique!=2 else target.health_component.current_health==before,"Damage skills hit; evasive step has no automatic explosion")
			_check(outside.health_component.current_health==missed,"No damage outside AOE")
			_check(tuning.strike_damage_multipliers==immutable,"Shared tuning immutable")
			_check(not actor.health_component.is_invulnerable,"Travel protection clears")
			_check(not ability.hitbox._enabled,"Hitbox closes")
		ability.clear_cooldown()
		mastery.stacks=3
		ability.request_cast(Vector2.RIGHT,25)
		_check(mastery.stacks==3 if (ability.definition as KingOathDefinition).technique==2 else mastery.stacks==0 and ability.cast_power_multiplier==1.25,"Damage consumes Resolve once; mobility retains it")
		ability.cancel_cast()
		_check(not ability.hitbox._enabled and not actor.health_component.is_invulnerable,"Cancel cleans combat")
		_check(not ability.request_cast(Vector2.RIGHT,25),"Cancellation retains cooldown")
	# Travel remains wall-controlled through Player.move_and_slide.
	var step := actor.get_node("OathAbility3") as KingOathComponent
	step.definition=(step.definition as KingOathDefinition).at_rank(0)
	step.clear_cooldown()
	var wall := StaticBody2D.new()
	wall.collision_layer=1
	var shape := CollisionShape2D.new()
	var box := RectangleShape2D.new()
	box.size=Vector2(12,300)
	shape.shape=box
	wall.add_child(shape)
	root.add_child(wall)
	wall.position=Vector2(260,200)
	actor.global_position=Vector2(200,200)
	actor.set_physics_process(true)
	await physics_frame
	step.request_cast_at(Vector2(380,200),25)
	while step.is_casting():
		await physics_frame
	_check(actor.global_position.x<254,"Mobility cannot cross solid wall")
	_check(step.contact_origin.distance_to(actor.global_position)<1,"Landing contact uses reachable position")
	_check(not mastery._link.is_stopped(),"First landing opens combo link")
	var rupture := actor.get_node("OathAbility2") as KingOathComponent
	rupture.clear_cooldown()
	rupture.request_cast(Vector2.RIGHT,25)
	_check(is_equal_approx(rupture.cast_power_multiplier,1.15),"Starfall into Griefwake link")
	rupture.cancel_cast()
	actor.set_physics_process(false)
	library.open_collection()
	await process_frame
	_check(is_instance_valid(library._collection),"Collection opens")
	library._collection._close()
	await process_frame
	_check(not paused,"Collection restores pause state")
	print("KING_OATH_PASSED=",checks)
	quit()

func _target() -> HurtboxComponent:
	var health := HealthComponent.new()
	health.maximum_health=100000
	root.add_child(health)
	var hurt := HurtboxComponent.new()
	hurt.health_component=health
	hurt.collision_layer=16
	hurt.collision_mask=8
	var collision := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius=2
	collision.shape=circle
	hurt.add_child(collision)
	root.add_child(hurt)
	return hurt

func _check(condition: bool, message: String) -> void:
	if not condition:
		push_error(message)
		quit(1)
		assert(condition,message)
	checks+=1
