class_name Examiner
extends CharacterBody2D

const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")
const AxiomLaneScene = preload("res://entities/enemies/examiner/examiner_axiom_lane.tscn")

enum State {
	SPAWNING,
	APPROACH,
	COMBO_WIND_UP,
	THRUST_ACTIVE,
	COMBO_GAP,
	SWEEP_ACTIVE,
	COMBO_RECOVERY,
	ZERO_WIND_UP,
	ZERO_TRAVEL,
	ZERO_RECOVERY,
	REFUTATION_WIND_UP,
	REFUTATION_ACTIVE,
	REFUTATION_RECOVERY,
	AXIOM_WIND_UP,
	AXIOM_CUT_ONE,
	AXIOM_CUT_TWO,
	AXIOM_DASH,
	AXIOM_RECOVERY,
	WITHDRAWAL,
}

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal movement_changed(is_moving: bool)
signal axiom_started
signal measure_recognized
signal refutation_triggered

@export var definition: ExaminerDefinition
@export var target: CharacterBody2D
@export var arena_bounds := Rect2(40.0, 92.0, 650.0, 390.0)

@onready var health_component: HealthComponent = %HealthComponent
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var thrust_pivot: Node2D = %ThrustPivot
@onready var thrust_hitbox: MeleeHitbox = %ThrustHitbox
@onready var sweep_hitbox: MeleeHitbox = %SweepHitbox
@onready var dash_hitbox: MeleeHitbox = %DashHitbox

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var _state_remaining := 0.0
var _axiom_cooldown := 0.0
var _zero_cooldown := 0.0
var _refutation_cooldown := 0.0
var _is_moving := false
var _travel_start := Vector2.ZERO
var _travel_target := Vector2.ZERO
var _travel_elapsed := 0.0
var _active_travel_seconds := 0.2
var _axiom_lanes: Array[Dictionary] = []
var _axiom_hit_player := false
var _refutation_spent := false


func _ready() -> void:
	if definition == null:
		push_error("Examiner requires an ExaminerDefinition.")
		set_physics_process(false)
		return
	if not EnemyFootprint.configure(definition, body_collision, navigation_agent):
		set_physics_process(false)
		return
	health_component.maximum_health = definition.maximum_health
	health_component.current_health = definition.maximum_health
	health_component.armor_rating = definition.armor_rating
	health_component.died.connect(_withdraw)
	health_component.damage_blocked.connect(_on_damage_blocked)
	knockback_component.configure(definition)
	_axiom_cooldown = definition.initial_axiom_delay
	_zero_cooldown = 1.4
	_refutation_cooldown = 3.0
	_enter(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func _physics_process(delta: float) -> void:
	_axiom_cooldown = maxf(_axiom_cooldown - delta, 0.0)
	_zero_cooldown = maxf(_zero_cooldown - delta, 0.0)
	_refutation_cooldown = maxf(_refutation_cooldown - delta, 0.0)
	if state in [State.SPAWNING, State.WITHDRAWAL] or not is_instance_valid(target):
		velocity = Vector2.ZERO
		_set_moving(false)
		return
	if state == State.APPROACH:
		_process_approach(delta)
	elif state in [State.ZERO_TRAVEL, State.AXIOM_DASH]:
		_process_travel(delta)
	else:
		velocity = Vector2.ZERO
		_set_moving(false)
		_tick_state(delta)


func _process_approach(delta: float) -> void:
	var offset := target.global_position - global_position
	var distance := offset.length()
	if _axiom_cooldown <= 0.0:
		_begin_axiom(offset)
		return
	if _refutation_cooldown <= 0.0 and distance <= 112.0:
		_begin_refutation(offset)
		return
	if _zero_cooldown <= 0.0 and distance >= 138.0:
		_begin_zero_interval(offset)
		return
	if distance <= definition.attack_range:
		_begin_combo(offset)
		return
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	velocity = velocity.move_toward(direction * definition.move_speed, definition.acceleration * delta)
	move_and_slide()
	global_position = global_position.clamp(arena_bounds.position, arena_bounds.end)
	_set_moving(not velocity.is_zero_approx())


func _begin_combo(offset: Vector2) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	thrust_pivot.rotation = direction.angle()
	_enter(State.COMBO_WIND_UP, definition.wind_up_seconds)


func _begin_zero_interval(offset: Vector2) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	_travel_start = global_position
	_travel_target = (global_position + direction * minf(definition.zero_interval_distance, offset.length() - 38.0)).clamp(
		arena_bounds.position + Vector2(20.0, 20.0), arena_bounds.end - Vector2(20.0, 20.0)
	)
	_active_travel_seconds = definition.zero_interval_travel_seconds
	_travel_elapsed = 0.0
	_zero_cooldown = definition.zero_interval_cooldown_seconds
	_enter(State.ZERO_WIND_UP, definition.zero_interval_wind_up_seconds)


func _begin_refutation(offset: Vector2) -> void:
	_set_facing(offset.normalized() if not offset.is_zero_approx() else facing_direction)
	_refutation_spent = false
	_refutation_cooldown = definition.refutation_cooldown_seconds
	_enter(State.REFUTATION_WIND_UP, definition.refutation_wind_up_seconds)


func _begin_axiom(offset: Vector2) -> void:
	var aim := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(aim)
	_axiom_hit_player = false
	_axiom_cooldown = definition.axiom_cooldown_seconds
	var center := arena_bounds.get_center()
	var horizontal_center := Vector2(center.x, clampf(target.global_position.y, arena_bounds.position.y + 36.0, arena_bounds.end.y - 36.0))
	var vertical_offset := 86.0 if target.global_position.x <= center.x else -86.0
	var vertical_center := Vector2(
		clampf(target.global_position.x + vertical_offset, arena_bounds.position.x + 36.0, arena_bounds.end.x - 36.0),
		center.y
	)
	_axiom_lanes = [
		{"center": horizontal_center, "direction": Vector2.RIGHT, "length": arena_bounds.size.x - 34.0, "width": definition.axiom_lane_width},
		{"center": vertical_center, "direction": Vector2.DOWN, "length": arena_bounds.size.y - 28.0, "width": definition.axiom_lane_width},
		{"center": center, "direction": aim, "length": minf(arena_bounds.size.x, 560.0), "width": definition.axiom_lane_width + 6.0},
	]
	_spawn_lane_preview(_axiom_lanes[0], definition.axiom_telegraph_seconds)
	_spawn_lane_preview(_axiom_lanes[1], definition.axiom_telegraph_seconds + 0.34)
	_spawn_lane_preview(_axiom_lanes[2], definition.axiom_telegraph_seconds + 0.76)
	axiom_started.emit()
	_enter(State.AXIOM_WIND_UP, definition.axiom_telegraph_seconds)


func _process_travel(delta: float) -> void:
	_travel_elapsed += delta
	var progress := clampf(_travel_elapsed / maxf(_active_travel_seconds, 0.01), 0.0, 1.0)
	global_position = _travel_start.lerp(_travel_target, progress * progress * (3.0 - 2.0 * progress))
	if progress < 1.0:
		return
	global_position = _travel_target
	if state == State.ZERO_TRAVEL:
		dash_hitbox.deactivate()
		_enter(State.ZERO_RECOVERY, definition.zero_interval_recovery_seconds)
	else:
		_resolve_axiom_lane(2)
		_enter(State.AXIOM_RECOVERY, 0.72)


func _tick_state(delta: float) -> void:
	_state_remaining -= delta
	if _state_remaining > 0.0:
		return
	match state:
		State.COMBO_WIND_UP:
			thrust_hitbox.activate(definition.attack_damage, self, facing_direction, 110.0, 0.08)
			_enter(State.THRUST_ACTIVE, definition.active_seconds)
		State.THRUST_ACTIVE:
			thrust_hitbox.deactivate()
			_enter(State.COMBO_GAP, definition.combo_gap_seconds)
		State.COMBO_GAP:
			sweep_hitbox.activate(definition.sweep_damage, self, facing_direction, 150.0, 0.10)
			_enter(State.SWEEP_ACTIVE, definition.sweep_seconds)
		State.SWEEP_ACTIVE:
			sweep_hitbox.deactivate()
			_enter(State.COMBO_RECOVERY, definition.combo_recovery_seconds)
		State.COMBO_RECOVERY:
			_enter(State.APPROACH, 0.0)
		State.ZERO_WIND_UP:
			dash_hitbox.activate(definition.zero_interval_damage, self, facing_direction, 120.0, 0.06)
			_enter(State.ZERO_TRAVEL, definition.zero_interval_travel_seconds)
		State.ZERO_RECOVERY:
			_enter(State.APPROACH, 0.0)
		State.REFUTATION_WIND_UP:
			health_component.set_invulnerable(true)
			_enter(State.REFUTATION_ACTIVE, definition.refutation_active_seconds)
		State.REFUTATION_ACTIVE:
			health_component.set_invulnerable(false)
			_enter(State.REFUTATION_RECOVERY, definition.refutation_recovery_seconds)
		State.REFUTATION_RECOVERY:
			_enter(State.APPROACH, 0.0)
		State.AXIOM_WIND_UP:
			_resolve_axiom_lane(0)
			_enter(State.AXIOM_CUT_ONE, 0.34)
		State.AXIOM_CUT_ONE:
			_resolve_axiom_lane(1)
			_enter(State.AXIOM_CUT_TWO, 0.42)
		State.AXIOM_CUT_TWO:
			var lane: Dictionary = _axiom_lanes[2]
			var direction: Vector2 = lane["direction"]
			_travel_start = global_position
			_travel_target = (global_position + direction * 226.0).clamp(
				arena_bounds.position + Vector2(20.0, 20.0), arena_bounds.end - Vector2(20.0, 20.0)
			)
			_travel_elapsed = 0.0
			_active_travel_seconds = 0.30
			_enter(State.AXIOM_DASH, _active_travel_seconds)
		State.AXIOM_RECOVERY:
			if not _axiom_hit_player:
				measure_recognized.emit()
			_enter(State.APPROACH, 0.0)


func _spawn_lane_preview(lane: Dictionary, resolve_delay: float) -> void:
	var preview := AxiomLaneScene.instantiate() as ExaminerAxiomLane
	_effects_parent().add_child(preview)
	preview.configure(
		lane["center"], lane["direction"], lane["length"], lane["width"],
		definition.axiom_telegraph_seconds, resolve_delay
	)


func _resolve_axiom_lane(index: int) -> void:
	if not is_instance_valid(target) or index < 0 or index >= _axiom_lanes.size():
		return
	var lane: Dictionary = _axiom_lanes[index]
	var direction: Vector2 = lane["direction"]
	var half_length: float = lane["length"] * 0.5
	var start: Vector2 = lane["center"] - direction * half_length
	var finish: Vector2 = lane["center"] + direction * half_length
	if _distance_to_segment(target.global_position, start, finish) > lane["width"] * 0.5:
		return
	var target_health := target.get_node_or_null("HealthComponent") as HealthComponent
	if target_health == null:
		target_health = target.find_child("HealthComponent", true, false) as HealthComponent
	if target_health != null:
		_axiom_hit_player = target_health.apply_damage(
			DamageInfo.new(definition.axiom_damage, self, direction, 120.0, 0.10)
		) or _axiom_hit_player


func _distance_to_segment(point: Vector2, start: Vector2, finish: Vector2) -> float:
	var segment := finish - start
	var denominator := segment.length_squared()
	if denominator <= 0.001:
		return point.distance_to(start)
	var amount := clampf((point - start).dot(segment) / denominator, 0.0, 1.0)
	return point.distance_to(start + segment * amount)


func _on_damage_blocked(_info: DamageInfo) -> void:
	if state != State.REFUTATION_ACTIVE or _refutation_spent or not is_instance_valid(target):
		return
	_refutation_spent = true
	refutation_triggered.emit()
	var away := (global_position - target.global_position).normalized()
	if away.is_zero_approx():
		away = -facing_direction
	global_position = (global_position + away * 36.0).clamp(arena_bounds.position, arena_bounds.end)
	var target_health := target.find_child("HealthComponent", true, false) as HealthComponent
	if target_health != null:
		target_health.apply_damage(DamageInfo.new(definition.refutation_damage, self, -away, 90.0, 0.08))


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_remaining = duration_seconds
	if next_state != State.APPROACH:
		_set_moving(false)
	state_changed.emit(state, duration_seconds)


func _finish_spawn() -> void:
	if state == State.SPAWNING:
		_enter(State.APPROACH, 0.0)


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	facing_direction = direction.normalized()
	facing_changed.emit(facing_direction)


func _set_moving(value: bool) -> void:
	if _is_moving == value:
		return
	_is_moving = value
	movement_changed.emit(value)


func _effects_parent() -> Node2D:
	var effects := get_tree().get_first_node_in_group("boss_effects") as Node2D
	return effects if effects != null else get_parent() as Node2D


func _withdraw() -> void:
	state = State.WITHDRAWAL
	velocity = Vector2.ZERO
	thrust_hitbox.deactivate()
	sweep_hitbox.deactivate()
	dash_hitbox.deactivate()
	health_component.set_invulnerable(true)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.WITHDRAWAL, 1.25)
	set_physics_process(false)
	get_tree().create_timer(1.4).timeout.connect(queue_free)
