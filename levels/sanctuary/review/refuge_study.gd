extends Node

## Optional environment review on the real hub, without changing service authority.
const Ground = preload("res://levels/sanctuary/review/refuge_ground.gd")
const OrrenReview = preload("res://levels/sanctuary/review/orren_workshop_review.gd")
const ART := "res://assets/environment/sanctuary/refuge_review/"
var hub: Node
var ground: TileMapLayer
var props: Node2D
var lodge: StaticBody2D
var orren_review: Node
var review_enabled := true
var overview := false
var _button: Button
var _panel: PanelContainer

func _ready() -> void:
	ground = Ground.new()
	ground.name = "RefugeGround32"
	hub.get_node("World/Level").add_child(ground)
	props = Node2D.new()
	props.name = "RefugeStudyProps"
	props.y_sort_enabled = true
	hub.get_node("World/Actors").add_child(props)
	_build_lodge()
	orren_review = OrrenReview.new()
	add_child(orren_review)
	orren_review.configure(hub,props)
	for position in [Vector2(128,432),Vector2(344,432),Vector2(464,388),Vector2(688,388),Vector2(464,564),Vector2(672,584),Vector2(512,720),Vector2(624,720)]:
		_prop("lantern",position,Vector2(18,12))
	for position in [Vector2(384,408),Vector2(752,408),Vector2(400,584),Vector2(720,584)]:
		_prop("planter",position,Vector2(54,18))
	for position in [Vector2(408,352),Vector2(752,352)]:
		_prop("bench",position,Vector2(56,14))
	for position in [Vector2(184,192),Vector2(264,192),Vector2(344,208),Vector2(808,208),Vector2(888,192),Vector2(968,192),Vector2(152,560),Vector2(152,640),Vector2(936,696)]:
		_prop("wall",position,Vector2(72,18))
	_build_controls()
	set_review_enabled(true)

func _build_lodge() -> void:
	lodge = StaticBody2D.new()
	lodge.name = "TrainerLodgeReview"
	lodge.position = Vector2(224,390)
	lodge.collision_layer = 1
	lodge.collision_mask = 0
	props.add_child(lodge)
	var sprite := Sprite2D.new()
	sprite.texture = load(ART+"trainer_lodge.png")
	sprite.position = Vector2(0,-96)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	lodge.add_child(sprite)
	_collision(lodge,Vector2(176,52),Vector2(16,-34))
	for marker_name in ["Doorway","Approach","ReturnPoint"]:
		var marker := Marker2D.new()
		marker.name = marker_name
		marker.position = Vector2(0,0 if marker_name == "Doorway" else (36 if marker_name == "Approach" else 48))
		lodge.add_child(marker)
	lodge.set_meta("service_id",&"skillkeeper")
	lodge.set_meta("interior_status",&"planned")
	# Footprint remains fixed. Only the roof/body visibility fades behind it.
	var rear := Area2D.new()
	rear.collision_layer = 0
	rear.collision_mask = 2
	lodge.add_child(rear)
	_collision(rear,Vector2(168,112),Vector2(16,-116))
	rear.body_entered.connect(func(body: Node) -> void:
		if body is Player: sprite.modulate.a = .48)
	rear.body_exited.connect(func(body: Node) -> void:
		if body is Player: sprite.modulate.a = 1.0)

func _prop(kind: String, position: Vector2, footprint: Vector2) -> void:
	var body := StaticBody2D.new()
	body.name = kind.capitalize()+str(props.get_child_count())
	body.position = position
	body.collision_layer = 1
	body.collision_mask = 0
	props.add_child(body)
	var sprite := Sprite2D.new()
	sprite.texture = load(ART+kind+".png")
	sprite.position = Vector2(0,-32)
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	body.add_child(sprite)
	_collision(body,footprint,Vector2(0,-footprint.y/2))
	if kind == "lantern":
		var glow := Sprite2D.new()
		var gradient := Gradient.new()
		gradient.set_color(0,Color(1.0,.67,.25,.24))
		gradient.set_color(1,Color(1.0,.67,.25,0.0))
		var texture := GradientTexture2D.new()
		texture.gradient = gradient
		texture.width = 28
		texture.height = 28
		texture.fill = GradientTexture2D.FILL_RADIAL
		texture.fill_from = Vector2(.5,.5)
		texture.fill_to = Vector2(1,.5)
		glow.texture = texture
		glow.position = Vector2(0,-46)
		body.add_child(glow)
		var tween := glow.create_tween().set_loops()
		tween.tween_property(glow,"modulate:a",.45,1.3)
		tween.tween_property(glow,"modulate:a",1.0,1.7)

func _collision(parent: CollisionObject2D, size: Vector2, offset: Vector2) -> void:
	var collision := CollisionShape2D.new()
	var shape := RectangleShape2D.new()
	shape.size = size
	collision.shape = shape
	collision.position = offset
	parent.add_child(collision)

func _build_controls() -> void:
	var layer := CanvasLayer.new()
	layer.layer = 15
	add_child(layer)
	_panel = PanelContainer.new()
	_panel.position = Vector2(220,8)
	layer.add_child(_panel)
	var column := VBoxContainer.new()
	_panel.add_child(column)
	var title := Label.new()
	title.text = "SANCTUARY STUDY · ORREN + WORKSHOP"
	title.add_theme_font_size_override("font_size",12)
	column.add_child(title)
	var caption := Label.new()
	caption.text = "New Orren portrait + working idle. Other NPCs / interiors follow."
	caption.add_theme_font_size_override("font_size",11)
	column.add_child(caption)
	var row := HBoxContainer.new()
	column.add_child(row)
	_button = _action(row,"Compare old environment",func() -> void: set_review_enabled(not review_enabled))
	_action(row,"Visit Orren",visit_orren)
	_action(row,"Visit lodge",func() -> void:
		set_overview(false)
		hub.get_node("World/Actors/Player").global_position = Vector2(224,434)
		hub.get_node("World/Actors/Player/Camera2D").reset_smoothing())
	_action(row,"Overview / walk",func() -> void: set_overview(not overview))

func _action(row: HBoxContainer, title: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = title
	button.add_theme_font_size_override("font_size",12)
	button.pressed.connect(action)
	row.add_child(button)
	return button

func set_review_enabled(value: bool) -> void:
	review_enabled = value
	ground.visible = value
	props.visible = value
	props.process_mode = Node.PROCESS_MODE_INHERIT if value else Node.PROCESS_MODE_DISABLED
	orren_review.set_enabled(value)
	hub.get_node("World/Level/Ground").visible = not value
	var original := hub.get_node("World/Actors/SkillkeeperLodge")
	original.visible = not value
	original.process_mode = Node.PROCESS_MODE_DISABLED if value else Node.PROCESS_MODE_INHERIT
	_button.text = "Compare old environment" if value else "Return to new study"

func visit_orren() -> void:
	set_overview(false)
	hub.get_node("World/Actors/Player").global_position = Vector2(984,474) if review_enabled else Vector2(916,616)
	hub.get_node("World/Actors/Player/Camera2D").reset_smoothing()

func set_overview(value: bool) -> void:
	overview = value
	var camera := hub.get_node("World/Actors/Player/Camera2D") as Camera2D
	camera.position_smoothing_enabled = false
	camera.set_as_top_level(value)
	camera.position = Vector2(576,384) if value else Vector2(0,-8)
	camera.zoom = Vector2(.68,.68) if value else Vector2.ONE
	camera.limit_left = -10000 if value else 0
	camera.limit_top = -10000 if value else 0
	camera.limit_right = 10000 if value else 1152
	camera.limit_bottom = 10000 if value else 768
	camera.reset_smoothing()
