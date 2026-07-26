extends Node

## In-memory run state that survives scene transitions but is never written to disk.

signal progression_state_changed(total_experience: int, coins: int)
signal player_health_state_changed(current_health: float)

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
