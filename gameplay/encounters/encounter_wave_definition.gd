class_name EncounterWaveDefinition
extends Resource

@export var title := "Wave"
@export_range(0, 20, 1) var mireling_count := 0
@export_range(0, 20, 1) var thrall_count := 0
@export_range(0.1, 5.0, 0.1, "suffix:s") var spawn_interval := 0.8
