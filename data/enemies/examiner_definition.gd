class_name ExaminerDefinition
extends EnemyDefinition

## Stage XX boss mechanics, tuned first in the rewardless Combat Lab.

@export var thrust_step_distance := 38.0
@export var pursuit_distance := 260.0
@export var pursuit_overshoot := 96.0
@export var pursuit_warning_seconds := 0.48
@export var pursuit_travel_seconds := 0.26
@export var pursuit_recovery_seconds := 0.78
@export var trial_damage_required := 240.0
@export var trial_duration_seconds := 7.0
@export var trial_cut_damage := 46.0
@export var verdict_damage := 800.0
@export var sanctuary_escape_seconds := 2.8

@export_range(1.0, 9999.0, 1.0) var sweep_damage := 30.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var combo_gap_seconds := 0.18
@export_range(0.1, 3.0, 0.01, "suffix:s") var sweep_wind_up_seconds := 0.46
@export_range(0.1, 3.0, 0.01, "suffix:s") var sweep_seconds := 0.34
@export_range(0.1, 3.0, 0.01, "suffix:s") var combo_recovery_seconds := 0.58

@export_range(1.0, 9999.0, 1.0) var judgment_charge_damage := 34.0
@export_range(0.05, 2.0, 0.01, "suffix:s") var judgment_charge_wind_up_seconds := 0.72
@export_range(0.05, 2.0, 0.01, "suffix:s") var judgment_charge_travel_seconds := 0.24
@export_range(0.05, 2.0, 0.01, "suffix:s") var judgment_charge_impact_seconds := 0.12
@export_range(0.05, 2.0, 0.01, "suffix:s") var judgment_charge_recovery_seconds := 0.48
@export_range(48.0, 420.0, 1.0, "suffix:px") var judgment_charge_distance := 188.0
@export_range(0.5, 20.0, 0.1, "suffix:s") var judgment_charge_cooldown_seconds := 5.4

@export_range(1.0, 9999.0, 1.0) var ground_judgment_damage := 42.0
@export_range(0.1, 3.0, 0.01, "suffix:s") var ground_judgment_wind_up_seconds := 0.82
@export_range(0.05, 1.0, 0.01, "suffix:s") var ground_judgment_active_seconds := 0.14
@export_range(0.1, 3.0, 0.01, "suffix:s") var ground_judgment_recovery_seconds := 0.68
@export_range(0.5, 20.0, 0.1, "suffix:s") var ground_judgment_cooldown_seconds := 7.6

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
