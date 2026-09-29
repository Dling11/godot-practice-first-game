extends Node

## Optional presentation adapter; the original DialogueNpc retains interaction authority.
const IDLE = preload("res://assets/characters/npcs/armskeeper/renewal/idle_work_v2.png")
const Nameplate = preload("res://entities/npcs/presentation/npc_nameplate.gd")
const PORTRAIT = preload("res://assets/characters/npcs/armskeeper/renewal/portrait.png")
const BUILDING = preload("res://assets/environment/sanctuary/refuge_review/orren_workshop.png")
const ORREN_POSITION := Vector2(992,438)
var workshop: StaticBody2D
var npc: DialogueNpc
var sprite: AnimatedSprite2D
var frames: SpriteFrames
var nameplate: Node2D
var _old: Dictionary
var _original_workshop: Node2D
var _enabled := false
var _talking := false

func configure(hub: Node, props: Node2D) -> void:
	npc = hub.get_node("World/Actors/WeaponMerchant")
	sprite = npc.get_node("Sprite")
	var breath: Timer = npc.get_node("IdleBreath")
	breath.reset_presentation()
	_old = {"position":npc.position,"frames":sprite.sprite_frames,"animation":sprite.animation,
		"scale":sprite.scale,"sprite_position":sprite.position,"portrait":npc.dialogue_portrait,
		"aura":npc.get_node("LanternAura").visible}
	_original_workshop = hub.get_node("World/Actors/ArmskeeperWorkshop")
	nameplate = Nameplate.new()
	nameplate.name = "ReviewNameplate"
	nameplate.npc_name = "Orren"
	nameplate.role_name = "Armskeeper"
	nameplate.position = Vector2(0,-62)
	npc.add_child(nameplate)
	npc.proximity_changed.connect(func(near: bool, _prompt: String, _icon: Texture2D) -> void:
		nameplate.set_near(near))
	frames = SpriteFrames.new()
	frames.remove_animation(&"default")
	frames.add_animation(&"idle_down")
	frames.set_animation_speed(&"idle_down",5.0)
	for index in 8:
		var frame := AtlasTexture.new()
		frame.atlas = IDLE
		frame.region = Rect2(Vector2(index%4,index/4)*96,Vector2(96,96))
		frames.add_frame(&"idle_down",frame,2.0 if index == 0 or index == 7 else 1.0)
	npc.dialogue_requested.connect(func(_speaker: String, _lines: Array[String], _portrait: Texture2D) -> void:
		if _enabled:
			_talking = true
			sprite.pause()
			sprite.frame = 0)
	hub.dialogue_panel.dialogue_closed.connect(func(_completed: bool) -> void:
		if _talking:
			_talking = false
			if _enabled: sprite.play(&"idle_down"))
	_build_workshop(props)

func set_enabled(value: bool) -> void:
	_enabled = value
	nameplate.visible = value
	_original_workshop.visible = not value
	_original_workshop.process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
	var breath: Timer = npc.get_node("IdleBreath")
	breath.stop()
	breath.reset_presentation()
	npc.position = ORREN_POSITION if value else _old.position
	npc.dialogue_portrait = PORTRAIT if value else _old.portrait
	npc.get_node("LanternAura").visible = false if value else _old.aura
	sprite.sprite_frames = frames if value else _old.frames
	sprite.position = Vector2(0,-16) if value else _old.sprite_position
	sprite.scale = Vector2(.5,.5) if value else _old.scale
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.play(&"idle_down" if value else _old.animation)
	if not value: breath.start()
	elif _talking:
		sprite.pause()
		sprite.frame = 0

func _build_workshop(props: Node2D) -> void:
	workshop = StaticBody2D.new()
	workshop.name = "OrrenWorkshopReview"
	workshop.position = Vector2(928,390)
	workshop.collision_layer = 1
	workshop.collision_mask = 0
	props.add_child(workshop)
	var art := Sprite2D.new()
	art.name = "Art"
	art.texture = BUILDING
	art.position = Vector2(0,-96)
	art.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	workshop.add_child(art)
	_collision(workshop,Vector2(142,42),Vector2(-5,-25))
	_collision(workshop,Vector2(82,34),Vector2(103,-21))
	for marker_name in ["Doorway","Approach","ReturnPoint"]:
		var marker := Marker2D.new()
		marker.name = marker_name
		marker.position.y = 0 if marker_name == "Doorway" else (36 if marker_name == "Approach" else 48)
		workshop.add_child(marker)
	workshop.set_meta("service_id",&"armskeeper")
	workshop.set_meta("interior_status",&"planned")
	var rear := Area2D.new()
	rear.collision_layer = 0
	rear.collision_mask = 2
	workshop.add_child(rear)
	_collision(rear,Vector2(222,120),Vector2(28,-106))
	rear.body_entered.connect(func(body: Node) -> void:
		if body is Player: art.modulate.a = .48)
	rear.body_exited.connect(func(body: Node) -> void:
		if body is Player: art.modulate.a = 1.0)
	var embers := CPUParticles2D.new()
	embers.name = "ForgeEmbers"
	embers.position = Vector2(80,-37)
	embers.amount = 5
	embers.lifetime = 1.4
	embers.direction = Vector2.UP
	embers.spread = 18
	embers.gravity = Vector2(0,-3)
	embers.initial_velocity_min = 4
	embers.initial_velocity_max = 7
	embers.color = Color(1,.44,.14,.7)
	embers.scale_amount_min = .7
	embers.scale_amount_max = 1.0
	var gradient := Gradient.new()
	gradient.set_color(0,Color(1,.65,.25,0))
	gradient.set_color(1,Color(1,.2,.06,0))
	gradient.add_point(.2,Color(1,.45,.12,.75))
	embers.color_ramp = gradient
	workshop.add_child(embers)

func _collision(parent: CollisionObject2D, size: Vector2, offset: Vector2) -> void:
	var collider := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collider.shape = shape
	collider.position = offset
	parent.add_child(collider)
