class_name SwordComboDefinition
extends Resource

## One immutable, character-authored chain. The attack component owns progress.
@export var animation_keys := PackedStringArray(["attack", "return_cut", "heavy_cleave"])
@export var windups := PackedFloat32Array([0.17, 0.13, 0.24])
@export var contacts := PackedFloat32Array([0.10, 0.10, 0.14])
@export var recoveries := PackedFloat32Array([0.32, 0.27, 0.38])
@export var damage_multipliers := PackedFloat32Array([1.0, 1.15, 1.8])
@export var knockback_multipliers := PackedFloat32Array([1.0, 1.15, 2.0])
@export var continue_seconds := 0.9

func step_count() -> int:
	return mini(animation_keys.size(), mini(windups.size(), mini(contacts.size(), mini(recoveries.size(), mini(damage_multipliers.size(), knockback_multipliers.size())))))
