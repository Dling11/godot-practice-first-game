class_name TitleBackground
extends Control

@onready var mist: TextureRect = %Mist
@onready var left_tree: TextureRect = %LeftTree
@onready var right_tree: TextureRect = %RightTree
@onready var fireflies: Control = %Fireflies


func _ready() -> void:
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	_animate_mist()
	_animate_tree(left_tree, -0.012)
	_animate_tree(right_tree, 0.012)
	for index in fireflies.get_child_count():
		_animate_firefly(fireflies.get_child(index) as ColorRect, index * 0.18)


func _animate_mist() -> void:
	var tween := create_tween().set_loops()
	tween.tween_property(mist, "modulate:a", 0.2, 3.2).from(0.08).set_trans(Tween.TRANS_SINE)
	tween.tween_property(mist, "modulate:a", 0.08, 3.2).set_trans(Tween.TRANS_SINE)


func _animate_tree(tree: TextureRect, rotation_radians: float) -> void:
	tree.pivot_offset = tree.size * Vector2(0.5, 1.0)
	var tween := create_tween().set_loops()
	tween.tween_property(tree, "rotation", rotation_radians, 2.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(tree, "rotation", -rotation_radians, 3.1).set_trans(Tween.TRANS_SINE)


func _animate_firefly(firefly: ColorRect, delay_seconds: float) -> void:
	var origin := firefly.position
	var drift := Vector2(6.0 if int(delay_seconds * 10.0) % 2 == 0 else -6.0, -8.0)
	var tween := create_tween().set_loops()
	tween.tween_interval(delay_seconds)
	tween.tween_property(firefly, "modulate:a", 1.0, 0.5).from(0.15)
	tween.parallel().tween_property(firefly, "position", origin + drift, 1.8).set_trans(Tween.TRANS_SINE)
	tween.tween_property(firefly, "modulate:a", 0.15, 0.6)
	tween.tween_property(firefly, "position", origin, 0.0)
