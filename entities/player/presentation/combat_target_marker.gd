class_name CombatTargetMarker
extends Node2D

## Lightweight world-space selection mark; target authority stays in the
## targeting component and this node only follows/presents it.

@export var targeting_component: PlayerCombatTargetingComponent

var _pulse_time := 0.0


func _ready() -> void:
	top_level = true
	z_index = 30
	visible = false
	if targeting_component == null:
		push_error("CombatTargetMarker requires a targeting component.")
		return
	targeting_component.target_changed.connect(_on_target_changed)
	set_process(false)


func _process(delta: float) -> void:
	if not targeting_component.has_valid_target():
		visible = false
		set_process(false)
		return
	_pulse_time += delta
	global_position = targeting_component.target_actor.global_position + Vector2(0.0, -3.0)
	queue_redraw()


func _draw() -> void:
	var pulse := 1.0 + sin(_pulse_time * 6.0) * 0.08
	var definition: Variant = targeting_component.target_actor.get("definition")
	var footprint: float = (definition as EnemyDefinition).movement_footprint_radius if definition is EnemyDefinition else 8.0
	var tier: int = (definition as EnemyDefinition).crowd_control_tier if definition is EnemyDefinition else EnemyDefinition.CrowdControlTier.LIGHT
	var radius: float = (footprint + 8.0) * pulse
	var color := Color(1.0, 0.22, 0.2, 0.96)
	if tier == EnemyDefinition.CrowdControlTier.BOSS:
		color = Color(1.0, 0.36, 0.12, 0.98)
	draw_arc(Vector2.ZERO, radius + 1.0, 0.0, TAU, 24, Color(0.12, 0.01, 0.01, 0.8), 3.0)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 24, color, 2.0)
	if tier == EnemyDefinition.CrowdControlTier.BOSS:
		draw_arc(Vector2.ZERO, radius + 5.0, 0.0, TAU, 24, color.darkened(0.18), 1.0)
	draw_polyline(
		PackedVector2Array([Vector2(-5, -25), Vector2(0, -20), Vector2(5, -25)]),
		color,
		2.0
	)


func _on_target_changed(actor: Node2D, _health: HealthComponent, _display_name: String) -> void:
	visible = actor != null
	set_process(actor != null)
	if actor != null:
		global_position = actor.global_position + Vector2(0.0, -3.0)
		_pulse_time = 0.0
		queue_redraw()
