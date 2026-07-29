class_name StageRewardChest
extends Area2D

signal reward_claimed(result: Dictionary)
signal proximity_changed(is_near: bool, prompt_text: String, prompt_icon: Texture2D)

@export var loot_table: LootTableDefinition
@export var chest_sprite: Sprite2D
@export var closed_texture: Texture2D
@export var open_texture: Texture2D
@export var glow: Polygon2D
@export var interaction_text := "PRESS F TO CLAIM REWARD"

var _player_inside := false
var _claimed := false


func configure(table: LootTableDefinition) -> void:
	loot_table = table


func _ready() -> void:
	if (
		loot_table == null
		or not loot_table.has_valid_layout()
		or chest_sprite == null
		or closed_texture == null
		or open_texture == null
		or glow == null
	):
		push_error("StageRewardChest requires a valid loot table and chest presentation.")
		queue_free()
		return
	chest_sprite.texture = closed_texture
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	scale = Vector2(0.72, 0.72)
	var arrival := create_tween()
	arrival.tween_property(self, "scale", Vector2.ONE, 0.28).set_trans(
		Tween.TRANS_BACK
	).set_ease(Tween.EASE_OUT)
	var pulse := create_tween().set_loops()
	pulse.tween_property(glow, "modulate:a", 0.42, 0.7).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(glow, "modulate:a", 0.16, 0.7).set_trans(Tween.TRANS_SINE)


func _unhandled_input(event: InputEvent) -> void:
	if (
		_claimed
		or not _player_inside
		or not event.is_action_pressed("player_interact")
	):
		return
	get_viewport().set_input_as_handled()
	_claim_reward()


func claim_for_testing() -> Dictionary:
	return _claim_reward()


func _claim_reward() -> Dictionary:
	if _claimed:
		return {"success": false}
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service == null:
		return {"success": false}
	var result: Dictionary = loot_service.claim_stage_reward(loot_table)
	if not bool(result.get("success", false)):
		return result
	_claimed = true
	monitoring = false
	_player_inside = false
	proximity_changed.emit(false, "", null)
	chest_sprite.texture = open_texture
	glow.modulate.a = 0.55
	reward_claimed.emit(result)
	var depart := create_tween()
	depart.tween_interval(1.0)
	depart.tween_property(self, "modulate:a", 0.0, 0.3)
	depart.tween_callback(queue_free)
	return result


func _on_body_entered(body: Node2D) -> void:
	if _claimed or not body is Player:
		return
	_player_inside = true
	proximity_changed.emit(true, interaction_text, closed_texture)


func _on_body_exited(body: Node2D) -> void:
	if _claimed or not body is Player:
		return
	_player_inside = false
	proximity_changed.emit(false, "", null)
