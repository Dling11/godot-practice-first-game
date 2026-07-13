class_name ExpeditionAltar
extends Area2D

signal proximity_changed(is_near: bool, prompt_text: String, prompt_icon: Texture2D)
signal selection_requested

@export var interaction_icon: Texture2D
@export var portal_glow: Node2D
@export var rune_orbit: Node2D
@export var water_glint: Node2D
var _player_inside := false


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	if rune_orbit != null:
		var orbit_tween := create_tween().set_loops()
		orbit_tween.tween_property(rune_orbit, "rotation", TAU, 7.0).from(0.0)
	if portal_glow != null:
		var glow_tween := create_tween().set_loops()
		glow_tween.tween_property(portal_glow, "scale", Vector2(1.08, 1.08), 1.2).from(Vector2.ONE).set_trans(Tween.TRANS_SINE)
		glow_tween.parallel().tween_property(portal_glow, "modulate:a", 0.58, 1.2).from(0.9)
		glow_tween.tween_property(portal_glow, "scale", Vector2.ONE, 1.4).set_trans(Tween.TRANS_SINE)
		glow_tween.parallel().tween_property(portal_glow, "modulate:a", 0.9, 1.4)
	if water_glint != null:
		var water_tween := create_tween().set_loops()
		water_tween.tween_property(water_glint, "position:x", 3.0, 0.8).from(-3.0).set_trans(Tween.TRANS_SINE)
		water_tween.tween_property(water_glint, "position:x", -3.0, 0.9).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or not event.is_action_pressed("player_interact"):
		return
	get_viewport().set_input_as_handled()
	proximity_changed.emit(false, "", null)
	selection_requested.emit()


func restore_prompt() -> void:
	if _player_inside:
		proximity_changed.emit(true, "PRESS F TO CHOOSE EXPEDITION", interaction_icon)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = true
	proximity_changed.emit(true, "PRESS F TO CHOOSE EXPEDITION", interaction_icon)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = false
	proximity_changed.emit(false, "", null)
