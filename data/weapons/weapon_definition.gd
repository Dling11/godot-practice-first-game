class_name WeaponDefinition
extends Resource

## Immutable tuning shared by weapon runtime instances.

@export var weapon_id: StringName
@export var display_name: String = "Weapon"
@export var world_texture: Texture2D
## Multiple sword grades may share one style/body animation, while a different
## sword family can reference another style without changing player code.
@export var attack_style: SwordAttackStyleDefinition
## Local Sprite2D offset that places the texture's authored grip on the
## WeaponVisual pivot. This keeps short swords and future greatswords on the
## same hand-driven swing rig without assuming their texture centers match.
@export var sprite_offset_from_grip := Vector2.ZERO
@export_range(0.25, 4.0, 0.05) var world_visual_scale: float = 1.0
@export_range(4.0, 48.0, 0.5, "suffix:px") var swing_visual_radius: float = 12.0
@export_range(0.0, 9999.0, 1.0) var damage: float = 10.0
@export_range(0.0, 500.0, 1.0, "suffix:px/s") var knockback_strength: float = 0.0
@export_range(0.0, 2.0, 0.01, "suffix:s") var wind_up_seconds: float = 0.1
@export_range(0.01, 2.0, 0.01, "suffix:s") var active_seconds: float = 0.1
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds: float = 0.2
