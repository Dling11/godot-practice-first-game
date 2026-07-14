class_name AbilityDefinition
extends Resource

## Immutable tuning shared by ability runtime instances.

@export var display_name := "Ability"
@export var hud_name := "ABILITY"
@export_multiline var description := ""
@export var icon: Texture2D
@export_range(0.0, 9999.0, 1.0) var damage := 0.0
@export_range(0.0, 500.0, 1.0, "suffix:px/s") var knockback_strength := 0.0
@export_range(0.0, 2.0, 0.01, "suffix:s") var wind_up_seconds := 0.1
@export_range(0.01, 2.0, 0.01, "suffix:s") var active_seconds := 0.1
@export_range(0.0, 3.0, 0.01, "suffix:s") var recovery_seconds := 0.2
@export_range(0.0, 30.0, 0.1, "suffix:s") var cooldown_seconds := 1.0
