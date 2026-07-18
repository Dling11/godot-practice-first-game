class_name EncounterWaveDefinition
extends Resource

@export var title := "Wave"
@export_range(0, 20, 1) var mireling_count := 0
@export_range(0, 20, 1) var rootling_count := 0
@export_range(0, 20, 1) var thrall_count := 0
@export_range(0, 20, 1) var bramble_spitter_count := 0
@export_range(0.1, 5.0, 0.1, "suffix:s") var spawn_interval := 0.8
@export_range(0.25, 5.0, 0.05, "suffix:s") var reinforcement_delay := 0.8


func total_enemy_count() -> int:
	return mireling_count + rootling_count + thrall_count + bramble_spitter_count
