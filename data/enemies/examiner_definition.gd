class_name ExaminerDefinition
extends EnemyDefinition

## Debug-first tuning for the Examiner's restrained Stage VII challenge kit.

@export_range(1.0, 9999.0, 1.0) var sweep_damage := 30.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var combo_gap_seconds := 0.18
@export_range(0.1, 3.0, 0.01, "suffix:s") var sweep_seconds := 0.34
@export_range(0.1, 3.0, 0.01, "suffix:s") var combo_recovery_seconds := 0.58

@export_range(1.0, 9999.0, 1.0) var zero_interval_damage := 24.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var zero_interval_wind_up_seconds := 0.24
@export_range(0.05, 2.0, 0.01, "suffix:s") var zero_interval_travel_seconds := 0.22
@export_range(0.05, 2.0, 0.01, "suffix:s") var zero_interval_recovery_seconds := 0.34
@export_range(48.0, 420.0, 1.0, "suffix:px") var zero_interval_distance := 176.0
@export_range(0.5, 20.0, 0.1, "suffix:s") var zero_interval_cooldown_seconds := 4.2

@export_range(1.0, 9999.0, 1.0) var refutation_damage := 18.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var refutation_wind_up_seconds := 0.28
@export_range(0.05, 2.0, 0.01, "suffix:s") var refutation_active_seconds := 0.42
@export_range(0.05, 2.0, 0.01, "suffix:s") var refutation_recovery_seconds := 0.30
@export_range(0.5, 20.0, 0.1, "suffix:s") var refutation_cooldown_seconds := 6.4

@export_range(1.0, 9999.0, 1.0) var axiom_damage := 38.0
@export_range(8.0, 96.0, 1.0, "suffix:px") var axiom_lane_width := 28.0
@export_range(0.1, 3.0, 0.01, "suffix:s") var axiom_telegraph_seconds := 0.92
@export_range(0.5, 30.0, 0.1, "suffix:s") var axiom_cooldown_seconds := 11.5
@export_range(0.0, 10.0, 0.1, "suffix:s") var initial_axiom_delay := 4.2
