extends Node2D

const PREVIEW_ANIMATIONS := [&"walk_down", &"walk_left", &"walk_right", &"walk_up", &"attack_down", &"attack_left", &"attack_right", &"attack_up"]

@onready var body: AnimatedSprite2D = $Body
@onready var current_animation_label: Label = $CurrentAnimation

var _animation_index := 0


func _ready() -> void:
	_show_current_animation()


func _on_cycle_timer_timeout() -> void:
	_animation_index = (_animation_index + 1) % PREVIEW_ANIMATIONS.size()
	_show_current_animation()


func _show_current_animation() -> void:
	var animation_name: StringName = PREVIEW_ANIMATIONS[_animation_index]
	body.play(animation_name)
	current_animation_label.text = String(animation_name).to_upper()
