class_name WeaponDefinition
extends Resource

## Immutable tuning shared by weapon runtime instances.

@export var display_name: String = "Weapon"
@export_range(0.0, 9999.0, 1.0) var damage: float = 10.0
@export_range(0.0, 2.0, 0.01, "suffix:s") var wind_up_seconds: float = 0.1
@export_range(0.01, 2.0, 0.01, "suffix:s") var active_seconds: float = 0.1
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds: float = 0.2

