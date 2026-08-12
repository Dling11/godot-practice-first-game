class_name KingSkill4Definition
extends AbilityDefinition

## Immutable authority values for King's two-stage targeted spirit-sword strike.

@export_range(96.0, 360.0, 1.0, "suffix:px") var target_range_pixels := 260.0
@export_range(24.0, 120.0, 1.0, "suffix:px") var first_impact_radius_pixels := 58.0
@export_range(48.0, 180.0, 1.0, "suffix:px") var explosion_radius_pixels := 104.0
@export var explosion_hitbox_shape: Shape2D
@export_range(-32.0, 32.0, 1.0, "suffix:px") var ground_center_offset_y := 0.0
