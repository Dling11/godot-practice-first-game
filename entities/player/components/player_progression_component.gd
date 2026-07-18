class_name PlayerProgressionComponent
extends Node

## Player-local progression authority synchronized with the in-memory RunSession service.

signal progression_changed(level: int, total_experience: int, next_level_experience: int)
signal coins_changed(total_coins: int)
signal leveled_up(new_level: int)

@export var definition: ProgressionDefinition

var level := 1
var total_experience := 0
var coins := 0


func _ready() -> void:
	if definition == null or definition.total_experience_by_level.size() < definition.maximum_level:
		push_error("PlayerProgressionComponent requires thresholds through its maximum level.")
		set_process(false)
		return
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		total_experience = run_session.total_experience
		coins = run_session.coins
	_recalculate_level()
	_emit_progression_changed()
	coins_changed.emit(coins)


func grant_rewards(experience: int, coin_amount: int) -> void:
	if experience > 0:
		total_experience += experience
		while level < definition.maximum_level and total_experience >= _next_level_threshold():
			level += 1
			leveled_up.emit(level)
		_emit_progression_changed()
	if coin_amount > 0:
		coins += coin_amount
		coins_changed.emit(coins)
	_sync_run_session()


func spend_coins(amount: int) -> bool:
	if amount <= 0 or coins < amount:
		return false
	coins -= amount
	coins_changed.emit(coins)
	_sync_run_session()
	return true


func experience_into_current_level() -> int:
	return total_experience - definition.total_experience_by_level[level - 1]


func experience_required_for_current_level() -> int:
	if level >= definition.maximum_level:
		return 0
	return _next_level_threshold() - definition.total_experience_by_level[level - 1]


func _next_level_threshold() -> int:
	return definition.total_experience_by_level[level]


func _emit_progression_changed() -> void:
	var next_level_experience := _next_level_threshold() if level < definition.maximum_level else total_experience
	progression_changed.emit(level, total_experience, next_level_experience)


func _recalculate_level() -> void:
	level = definition.get_level_for_total_experience(total_experience)


func _sync_run_session() -> void:
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		run_session.update_progression(total_experience, coins)
