extends SceneTree
const PlayerScene = preload("res://entities/player/player.tscn")
var checks := 0

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	player.global_position = Vector2(200,200)
	var mastery := player.get_node("KingMastery") as KingMasteryComponent
	var attack := player.attack_component
	var body := player.get_node("VisualRoot/Body") as AnimatedSprite2D
	var inside := _target()
	var outside := _target()
	await physics_frame
	for direction in [Vector2.RIGHT,Vector2.DOWN,Vector2.LEFT,Vector2.UP]:
		attack.reset_combo()
		mastery.clear()
		player._set_facing_direction(direction)
		var pivot: Node2D = player.get_node("SwordPivot")
		inside.global_position = pivot.global_position + direction*26
		outside.global_position = pivot.global_position + direction*43
		await physics_frame
		for step in 3:
			var before := inside.health_component.current_health
			var missed := outside.health_component.current_health
			_check(player.request_primary_attack(),"Accepted combo request")
			_check(attack.combo_step == step,"Ordered 0/1/2 combo")
			while attack.phase != MeleeAttackComponent.Phase.IDLE:
				await physics_frame
			var damage := before-inside.health_component.current_health
			var multiplier := attack.weapon.combo.damage_multipliers[step]
			_check(damage>=9.99*multiplier and damage<=12.01*multiplier,"Actual contact damage follows combo weight")
			_check(is_equal_approx(missed,outside.health_component.current_health),"No damage beyond greatsword reach")
			_check(mastery.stacks == step+1,"One Resolve per accepted swing")
	_check(body.sprite_frames.get_frame_count("heavy_cleave_up")==8,"Directional heavy frames installed")
	var skill := player.ability_2_component
	_check(player.request_ability(2),"Empowered cast accepted")
	_check(mastery.stacks==0 and is_equal_approx(skill.cast_power_multiplier,1.25),"Resolve consumed exactly once by cast")
	_check(is_equal_approx(skill.get_resolved_damage(),25*1.25),"Resolve modifies committed damage")
	var before_skill := inside.health_component.current_health
	while skill.phase != AbilityComponent.Phase.RECOVERY:
		await physics_frame
	_check(is_equal_approx(before_skill-inside.health_component.current_health,25*1.5*1.25),"Real Riftbreak hit carries Resolve through strike multiplier")
	skill.cancel_cast()
	mastery.stacks=3
	_check(not player.request_ability(2) and mastery.stacks==3,"Cooldown rejection keeps Resolve")
	mastery.clear()
	skill.clear_cooldown()
	var pursuit := player.ability_3_component
	_check(pursuit.request_cast_at(player.global_position,25),"Pursuit starts")
	while pursuit.is_casting():
		await physics_frame
	_check(player.request_ability(2) and is_equal_approx(skill.cast_power_multiplier,1.15),"Landing opens real Pursuit-Riftbreak link")
	skill.cancel_cast()
	skill.clear_cooldown()
	_check(player.request_ability(2) and is_equal_approx(skill.cast_power_multiplier,1.0),"Link cannot repeat")
	skill.cancel_cast()
	attack.reset_combo()
	inside.global_position=Vector2(900,900)
	mastery.clear()
	_check(player.request_primary_attack(),"Air swing accepted")
	while attack.phase != MeleeAttackComponent.Phase.IDLE:
		await physics_frame
	_check(mastery.stacks==0,"Air swing gives no Resolve")
	attack.set_equipment_attack_speed_bonus(.5)
	attack.reset_combo()
	player.request_primary_attack()
	_check(is_equal_approx(attack._phase_time_remaining,.19/1.5),"Equipment haste controls authoritative windup")
	attack.cancel_attack()
	_check(mastery.definition.level_multiplier(10)==1.18 and mastery.definition.level_multiplier(99)==1.18,"Skill growth is capped")
	for name in body.sprite_frames.get_animation_names():
		for index in body.sprite_frames.get_frame_count(name):
			var texture := body.sprite_frames.get_frame_texture(name,index) as AtlasTexture
			var pixels := texture.atlas.get_image().get_region(texture.region)
			var bounds := pixels.get_used_rect()
			_check(bounds.position.x>0 and bounds.position.y>0 and bounds.end.x<96 and bounds.end.y<64,"Padded complete weapon in "+name)
	print("KING_GREATSW0RD_MASTERY_PASSED=",checks)
	quit()

func _target() -> HurtboxComponent:
	var health := HealthComponent.new()
	health.maximum_health=10000
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
	checks += 1
