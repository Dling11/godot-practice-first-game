class_name StaggerComponent
extends Node

## Resolves temporary attack interruption from accepted damage. It observes
## health only; each enemy controller remains responsible for its own state,
## movement, and visuals while staggered.

signal stagger_started(duration_seconds: float)
signal stagger_finished

@export var health_component: HealthComponent

var remaining_seconds := 0.0
var _duration_multiplier := 1.0


func _ready() -> void:
	set_physics_process(false)
	if health_component == null:
		push_error("StaggerComponent requires a HealthComponent reference.")
		return
	health_component.damaged.connect(_on_damaged)
	health_component.died.connect(clear)


func configure(enemy_definition: EnemyDefinition) -> void:
	_duration_multiplier = enemy_definition.stagger_multiplier() if enemy_definition != null else 1.0


func is_staggered() -> bool:
	return remaining_seconds > 0.0


func clear() -> void:
	remaining_seconds = 0.0
	set_physics_process(false)


func _physics_process(delta: float) -> void:
	remaining_seconds = maxf(remaining_seconds - delta, 0.0)
	if remaining_seconds <= 0.0:
		set_physics_process(false)
		stagger_finished.emit()


func _on_damaged(info: DamageInfo) -> void:
	var resolved_duration := info.stagger_seconds * _duration_multiplier
	if resolved_duration <= 0.0:
		return
	var was_staggered := is_staggered()
	remaining_seconds = maxf(remaining_seconds, resolved_duration)
	set_physics_process(true)
	if not was_staggered:
		stagger_started.emit(resolved_duration)
