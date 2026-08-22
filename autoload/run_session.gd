extends Node

## Current-run state that survives scene transitions. SaveService may snapshot
## this data, but RunSession does not perform file I/O.

signal progression_state_changed(total_experience: int, coins: int)
signal player_health_state_changed(current_health: float)

const SNAPSHOT_VERSION := 1

var total_experience := 0
var coins := 0
var player_current_health := -1.0


func update_progression(experience: int, coin_total: int) -> void:
	total_experience = maxi(experience, 0)
	coins = maxi(coin_total, 0)
	progression_state_changed.emit(total_experience, coins)


func can_spend_coins(amount: int) -> bool:
	return amount >= 0 and coins >= amount


func spend_coins(amount: int) -> bool:
	if amount <= 0 or not can_spend_coins(amount):
		return false
	coins -= amount
	progression_state_changed.emit(total_experience, coins)
	return true


func add_coins(amount: int) -> bool:
	if amount <= 0 or coins > 2147483647 - amount:
		return false
	coins += amount
	progression_state_changed.emit(total_experience, coins)
	return true


func has_player_health_state() -> bool:
	return player_current_health >= 0.0


func update_player_health(current_health: float) -> void:
	player_current_health = maxf(current_health, 0.0)
	player_health_state_changed.emit(player_current_health)


func reset_run() -> void:
	total_experience = 0
	coins = 0
	player_current_health = -1.0
	progression_state_changed.emit(total_experience, coins)
	player_health_state_changed.emit(player_current_health)


func create_snapshot() -> Dictionary:
	return {
		"version": SNAPSHOT_VERSION,
		"total_experience": total_experience,
		"coins": coins,
		"player_current_health": player_current_health,
	}


func can_restore_snapshot(snapshot: Dictionary) -> bool:
	if snapshot.get("version", -1) != SNAPSHOT_VERSION:
		return false
	var experience_value: Variant = snapshot.get("total_experience")
	var coin_value: Variant = snapshot.get("coins")
	var health_value: Variant = snapshot.get("player_current_health")
	return (
		(experience_value is int or experience_value is float)
		and (coin_value is int or coin_value is float)
		and (health_value is int or health_value is float)
		and is_equal_approx(float(experience_value), roundf(float(experience_value)))
		and is_equal_approx(float(coin_value), roundf(float(coin_value)))
		and float(experience_value) >= 0.0
		and float(coin_value) >= 0.0
		and float(health_value) >= -1.0
		and is_finite(float(health_value))
	)


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	total_experience = int(snapshot["total_experience"])
	coins = int(snapshot["coins"])
	var restored_health := float(snapshot["player_current_health"])
	player_current_health = restored_health
	progression_state_changed.emit(total_experience, coins)
	# Level-driven vitality observers may synchronize a recalculated current HP
	# while handling progression. The explicit saved health must win last.
	player_current_health = restored_health
	player_health_state_changed.emit(player_current_health)
	return true
