class_name ProgressionDefinition
extends Resource

## Immutable session-progression curve for the introductory character.

@export_range(1, 99, 1) var maximum_level := 10
@export var total_experience_by_level := PackedInt32Array([0, 20, 50, 90, 140, 200, 270, 350, 440, 540])


func get_level_for_total_experience(total_experience: int) -> int:
	var resolved_level := 1
	while (
		resolved_level < maximum_level
		and resolved_level < total_experience_by_level.size()
		and total_experience >= total_experience_by_level[resolved_level]
	):
		resolved_level += 1
	return resolved_level
