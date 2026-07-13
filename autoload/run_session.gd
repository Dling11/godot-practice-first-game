extends Node

## In-memory run state that survives scene transitions but is never written to disk.

signal progression_state_changed(total_experience: int, coins: int)

var total_experience := 0
var coins := 0


func update_progression(experience: int, coin_total: int) -> void:
	total_experience = maxi(experience, 0)
	coins = maxi(coin_total, 0)
	progression_state_changed.emit(total_experience, coins)


func reset_run() -> void:
	total_experience = 0
	coins = 0
	progression_state_changed.emit(total_experience, coins)
