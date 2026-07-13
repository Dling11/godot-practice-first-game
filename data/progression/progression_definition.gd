class_name ProgressionDefinition
extends Resource

## Immutable session-progression curve for the introductory character.

@export_range(1, 99, 1) var maximum_level := 10
@export var total_experience_by_level := PackedInt32Array([0, 20, 50, 90, 140, 200, 270, 350, 440, 540])
