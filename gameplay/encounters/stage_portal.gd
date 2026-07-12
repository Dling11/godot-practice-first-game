class_name StagePortal
extends Area2D

signal player_entered
signal proximity_changed(is_near: bool, prompt_text: String)

@export_file("*.tscn") var target_scene_path := ""
@export var rings: Node2D
@export var ground_glow: Polygon2D
@export var interaction_text := "PRESS F TO ENTER PORTAL"

@onready var interaction_label: Label = %InteractionLabel

var _player_inside := false


func _ready() -> void:
	interaction_label.text = interaction_text
	interaction_label.hide()
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	var tween := create_tween().set_loops()
	tween.tween_property(rings, "rotation", TAU, 3.0).from(0.0)
	var pulse := create_tween().set_loops()
	pulse.tween_property(ground_glow, "scale", Vector2(1.12, 1.12), 0.8).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(ground_glow, "scale", Vector2.ONE, 0.8).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or not event.is_action_pressed("player_interact"):
		return
	get_viewport().set_input_as_handled()
	player_entered.emit()
	if target_scene_path.is_empty():
		return
	proximity_changed.emit(false, "")
	interaction_label.hide()
	_player_inside = false
	var transition_service := get_node_or_null("/root/SceneTransition")
	if transition_service == null:
		push_error("StagePortal requires the SceneTransition autoload.")
		return
	transition_service.transition_to(target_scene_path)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = true
	interaction_label.text = interaction_text
	interaction_label.show()
	proximity_changed.emit(true, interaction_text)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = false
	interaction_label.hide()
	proximity_changed.emit(false, "")
