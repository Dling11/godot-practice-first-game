class_name AbilityDefinition
extends Resource

## Immutable tuning shared by ability runtime instances.

enum ActivationMode { IMMEDIATE_DIRECTIONAL, GROUND_TARGETED, SELF_AREA }
enum PresentationStyle { SWEEP, THRUST }

@export var ability_id: StringName
@export var display_name := "Ability"
@export var hud_name := "ABILITY"
@export_multiline var description := ""
@export var icon: Texture2D
@export var activation_mode := ActivationMode.IMMEDIATE_DIRECTIONAL
@export var presentation_style := PresentationStyle.SWEEP
@export var hitbox_shape: Shape2D
@export_range(0.0, 9999.0, 1.0) var damage := 0.0
@export_range(0.0, 10.0, 0.05) var weapon_damage_multiplier := 0.0
@export_range(0.0, 500.0, 1.0, "suffix:px/s") var knockback_strength := 0.0
@export var strike_damage_multipliers := PackedFloat32Array([1.0])
@export_range(0.0, 1.0, 0.05) var non_final_knockback_multiplier := 1.0
@export_range(0.0, 3.0, 0.01, "suffix:s") var stagger_seconds := 0.0
@export_range(0.0, 1.0, 0.05) var non_final_stagger_multiplier := 1.0
@export_range(0.0, 1000.0, 1.0, "suffix:px/s") var active_movement_speed := 0.0
@export_range(0.0, 2.0, 0.01, "suffix:s") var wind_up_seconds := 0.1
@export_range(0.01, 2.0, 0.01, "suffix:s") var active_seconds := 0.1
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds := 0.2
@export_range(0.0, 30.0, 0.1, "suffix:s") var cooldown_seconds := 1.0


func resolve_damage(equipped_weapon_damage: float) -> float:
	return maxf(damage + equipped_weapon_damage * weapon_damage_multiplier, 0.0)


func strike_count() -> int:
	return maxi(strike_damage_multipliers.size(), 1)


func resolve_strike_damage(equipped_weapon_damage: float, strike_index: int) -> float:
	var multiplier := 1.0
	if not strike_damage_multipliers.is_empty():
		multiplier = strike_damage_multipliers[clampi(strike_index, 0, strike_damage_multipliers.size() - 1)]
	return resolve_damage(equipped_weapon_damage) * maxf(multiplier, 0.0)


func resolve_strike_knockback(strike_index: int) -> float:
	if strike_index >= strike_count() - 1:
		return knockback_strength
	return knockback_strength * non_final_knockback_multiplier


func resolve_strike_stagger(strike_index: int) -> float:
	if strike_index >= strike_count() - 1:
		return stagger_seconds
	return stagger_seconds * non_final_stagger_multiplier
