class_name TitleBackground
extends Control

@onready var seal: AnimatedSprite2D = %Seal
@onready var glimmers: Control = %Glimmers

func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	seal.play(&"active")
	resized.connect(_place_seal)
	_place_seal()
	for index in glimmers.get_child_count():
		var glimmer := glimmers.get_child(index) as ColorRect
		var origin := glimmer.position
		var drift := Vector2(3 if index % 2 == 0 else -3, -5)
		var tween := create_tween().set_loops()
		tween.tween_interval(index * 0.24)
		tween.tween_property(glimmer, "modulate:a", 0.55, 1.8).from(0.08).set_trans(Tween.TRANS_SINE)
		tween.parallel().tween_property(glimmer, "position", origin+drift, 3.0).set_trans(Tween.TRANS_SINE)
		tween.tween_property(glimmer, "modulate:a", 0.08, 2.0)
		tween.tween_property(glimmer, "position", origin, 0.0)

func _place_seal() -> void:
	seal.position = Vector2(size.x * 0.5, 193)
