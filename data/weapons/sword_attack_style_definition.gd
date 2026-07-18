class_name SwordAttackStyleDefinition
extends Resource

## Immutable presentation tuning for a sword's detached swing. Authoritative
## timing, damage, knockback, and hitboxes remain on WeaponDefinition/combat.

@export var style_id: StringName = &"balanced_slash"
@export var display_name: String = "Balanced Slash"
@export_range(0.1, 3.0, 0.01, "suffix:rad") var normal_wind_up_arc: float = 1.68
@export_range(0.1, 3.0, 0.01, "suffix:rad") var normal_strike_arc: float = 1.36
@export_range(0.0, 8.0, 0.25, "suffix:px") var normal_active_extension: float = 1.0
@export_range(0.1, 3.0, 0.01, "suffix:rad") var ability_wind_up_arc: float = 1.82
@export_range(0.1, 3.0, 0.01, "suffix:rad") var ability_strike_arc: float = 1.48
@export_range(0.0, 12.0, 0.25, "suffix:px") var ability_active_extension: float = 3.0
@export_range(5, 21, 1) var trail_point_count: int = 13
@export_range(1.0, 8.0, 0.25, "suffix:px") var trail_width: float = 4.0
@export var trail_color := Color(1.0, 0.96, 0.82, 1.0)
@export_range(0.0, 0.3, 0.01, "suffix:s") var trail_fade_padding_seconds: float = 0.06
@export_range(1.0, 1.5, 0.01) var strike_scale_multiplier: float = 1.12
@export var strike_tint := Color(1.24, 1.12, 0.82, 1.0)


func is_valid_style() -> bool:
	return (
		not style_id.is_empty()
		and normal_wind_up_arc > 0.0
		and normal_strike_arc > 0.0
		and ability_wind_up_arc > 0.0
		and ability_strike_arc > 0.0
		and trail_point_count >= 5
		and trail_width > 0.0
		and strike_scale_multiplier >= 1.0
	)
