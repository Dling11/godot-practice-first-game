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
		experience_value is int
		and coin_value is int
		and (health_value is int or health_value is float)
		and int(experience_value) >= 0
		and int(coin_value) >= 0
		and float(health_value) >= -1.0
		and is_finite(float(health_value))
	)


func restore_snapshot(snapshot: Dictionary) -> bool:
	if not can_restore_snapshot(snapshot):
		return false
	total_experience = int(snapshot["total_experience"])
	coins = int(snapshot["coins"])
	player_current_health = float(snapshot["player_current_health"])
	progression_state_changed.emit(total_experience, coins)
	player_health_state_changed.emit(player_current_health)
	return true
