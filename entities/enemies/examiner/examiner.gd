class_name Examiner
extends CharacterBody2D

const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")
const TrialComponent = preload("res://entities/enemies/examiner/examiner_trial.gd")
const AxiomLaneScene = preload("res://entities/enemies/examiner/examiner_axiom_lane.tscn")

enum State {
	SPAWNING,
	APPROACH,
	COMBO_WIND_UP,
	THRUST_ACTIVE,
	COMBO_GAP,
	SWEEP_WIND_UP,
	SWEEP_ACTIVE,
	COMBO_RECOVERY,
	CHARGE_WIND_UP,
	CHARGE_TRAVEL,
	CHARGE_IMPACT,
	CHARGE_RECOVERY,
	SLAM_WIND_UP,
	SLAM_ACTIVE,
	SLAM_RECOVERY,
	REFUTATION_WIND_UP,
	REFUTATION_ACTIVE,
	REFUTATION_RECOVERY,
	AXIOM_WIND_UP,
	AXIOM_CUT_ONE,
	AXIOM_CUT_TWO,
	AXIOM_DASH,
	AXIOM_RECOVERY,
	PURSUIT_WIND_UP,
	PURSUIT_TRAVEL,
	PURSUIT_RECOVERY,
	HELD_JUDGMENT,
	TRIAL_CHANNEL,
	PHASE_STANCE,
	DESCENT_PREPARE,
	DESCENT_LAUNCH,
	DESCENT_ABSENT,
	DESCENT_FALL,
	DESCENT_IMPACT,
	DESCENT_RECOVERY,
	WITHDRAWAL,
}

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal movement_changed(is_moving: bool)
signal axiom_started
signal measure_recognized
signal refutation_triggered
signal action_impact(kind: StringName, world_position: Vector2, direction: Vector2)
signal phase_transition_requested
signal divine_descent_launched(charge_seconds: float)
signal divine_descent_impact(world_position: Vector2)
signal trial_started
signal trial_progressed(damage: float, required: float, seconds_left: float)
signal trial_finished(success: bool, sanctuary_position: Vector2)
signal phase_two_started

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
@onready var slam_hitbox: MeleeHitbox = %SlamHitbox

var trial: ExaminerTrial
var _sanctuary_position := Vector2.ZERO
var _trial_succeeded := false
var _final_trial_requested := false
var _thrust_step_remaining := 0.0
var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var _state_remaining := 0.0
var _axiom_cooldown := 0.0
var _charge_cooldown := 0.0
var _slam_cooldown := 0.0
var _refutation_cooldown := 0.0
var _is_moving := false
var _travel_start := Vector2.ZERO
var _travel_target := Vector2.ZERO
var _travel_elapsed := 0.0
var _active_travel_seconds := 0.2
var _axiom_lanes: Array[Dictionary] = []
var _axiom_hit_player := false
var _refutation_spent := false
var _close_exchange_count := 0
var _recent_player_hits := 0
var _attack_pressure_remaining := 0.0
var _phase_transition_requested := false
var _phase_two := false
var _descent_origin := Vector2.ZERO
var _descent_destination := Vector2.ZERO
var _original_collision_layer := 0
var _original_collision_mask := 0

const PHASE_TRIGGER_RATIO := 0.70
const DESCENT_PREPARE_SECONDS := 0.64
const DESCENT_LAUNCH_SECONDS := 0.17
const DESCENT_FALL_SECONDS := 0.15
const DESCENT_IMPACT_SECONDS := 0.32
const DESCENT_RECOVERY_SECONDS := 0.90


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
	trial = TrialComponent.new() as ExaminerTrial
	add_child(trial)
	trial.progressed.connect(func(damage: float, required: float, seconds_left: float) -> void: trial_progressed.emit(damage, required, seconds_left))
	trial.completed.connect(_finish_trial)
	trial.cut_released.connect($ActionSfx.play_trial_cut)
	health_component.damaged.connect(trial.record_damage)
	health_component.damaged.connect(_on_damaged)
	_original_collision_layer = collision_layer
	_original_collision_mask = collision_mask
	_axiom_cooldown = definition.initial_axiom_delay
	_charge_cooldown = 1.4
	_slam_cooldown = 2.8
	_refutation_cooldown = 3.0
	_enter(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func _physics_process(delta: float) -> void:
	_axiom_cooldown = maxf(_axiom_cooldown - delta, 0.0)
	_charge_cooldown = maxf(_charge_cooldown - delta, 0.0)
	_slam_cooldown = maxf(_slam_cooldown - delta, 0.0)
	_refutation_cooldown = maxf(_refutation_cooldown - delta, 0.0)
	_attack_pressure_remaining = maxf(_attack_pressure_remaining - delta, 0.0)
	if _attack_pressure_remaining <= 0.0:
		_recent_player_hits = 0
	if state == State.TRIAL_CHANNEL:
		return
	if state in [State.PHASE_STANCE, State.DESCENT_PREPARE, State.DESCENT_LAUNCH, State.DESCENT_ABSENT, State.DESCENT_FALL, State.DESCENT_IMPACT, State.DESCENT_RECOVERY]:
		_process_divine_descent(delta)
		return
	if state in [State.SPAWNING, State.WITHDRAWAL] or not is_instance_valid(target):
		velocity = Vector2.ZERO
		_set_moving(false)
		return
	if state == State.APPROACH:
		_process_approach(delta)
	elif state in [State.CHARGE_TRAVEL, State.AXIOM_DASH, State.PURSUIT_TRAVEL]:
		_process_travel(delta)
	else:
		velocity = Vector2.ZERO
		_set_moving(false)
		if state == State.THRUST_ACTIVE and _thrust_step_remaining > 0.0:
			var step := minf(_thrust_step_remaining, definition.thrust_step_distance * delta / definition.active_seconds)
			move_and_collide(facing_direction * step)
			_thrust_step_remaining -= step
		_track_target_before_commit()
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
	if _slam_cooldown <= 0.0 and distance <= 92.0 and _close_exchange_count >= 1:
		_begin_ground_judgment(offset)
		return
	if _charge_cooldown <= 0.0 and distance >= 138.0:
		_begin_judgment_charge(offset)
		return
	if distance <= definition.attack_range:
		_begin_combo(offset)
		return
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	var phase_speed := 1.12 if _phase_two else 1.0
	velocity = velocity.move_toward(direction * definition.move_speed * phase_speed, definition.acceleration * delta)
	# The sprite must describe physical travel, not the new desired direction
	# while acceleration is still carrying the body the other way.
	_set_facing(velocity.normalized() if not velocity.is_zero_approx() else direction)
	move_and_slide()
	global_position = global_position.clamp(arena_bounds.position, arena_bounds.end)
	_set_moving(not velocity.is_zero_approx())


func _begin_combo(offset: Vector2) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	thrust_pivot.rotation = direction.angle()
	_enter(State.COMBO_WIND_UP, definition.wind_up_seconds)


func _begin_judgment_charge(offset: Vector2) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	_travel_start = global_position
	_travel_target = (global_position + direction * minf(definition.judgment_charge_distance, maxf(offset.length() - 38.0, 72.0))).clamp(
		arena_bounds.position + Vector2(20.0, 20.0), arena_bounds.end - Vector2(20.0, 20.0)
	)
	_active_travel_seconds = definition.judgment_charge_travel_seconds
	_travel_elapsed = 0.0
	_charge_cooldown = definition.judgment_charge_cooldown_seconds
	_enter(State.CHARGE_WIND_UP, definition.judgment_charge_wind_up_seconds)


func _begin_ground_judgment(offset: Vector2) -> void:
	_set_facing(offset.normalized() if not offset.is_zero_approx() else facing_direction)
	_slam_cooldown = definition.ground_judgment_cooldown_seconds
	_close_exchange_count = 0
	_enter(State.SLAM_WIND_UP, definition.ground_judgment_wind_up_seconds)


func _begin_refutation(offset: Vector2) -> void:
	_set_facing(offset.normalized() if not offset.is_zero_approx() else facing_direction)
	_refutation_spent = false
	_refutation_cooldown = definition.refutation_cooldown_seconds
	_recent_player_hits = 0
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
	var desired := _travel_start.lerp(_travel_target, progress * progress * (3.0 - 2.0 * progress))
	var collision := move_and_collide(desired - global_position)
	if progress < 1.0 and collision == null:
		return
	# A grounded charge stops at physical geometry instead of teleporting
	# through it. Aerial Divine Descent has its own explicit collision policy.
	velocity = Vector2.ZERO
	if state == State.PURSUIT_TRAVEL:
		dash_hitbox.deactivate()
		action_impact.emit(&"judgment_charge", global_position + Vector2(0, -20), facing_direction)
		_enter(State.PURSUIT_RECOVERY, definition.pursuit_recovery_seconds)
	elif state == State.CHARGE_TRAVEL:
		dash_hitbox.deactivate()
		action_impact.emit(&"judgment_charge", global_position + Vector2(0.0, -20.0), facing_direction)
		_enter(State.CHARGE_IMPACT, definition.judgment_charge_impact_seconds)
	else:
		_resolve_axiom_lane(2)
		_enter(State.AXIOM_RECOVERY, 0.72)


func _tick_state(delta: float) -> void:
	_state_remaining -= delta
	if _state_remaining > 0.0:
		return
	match state:
		State.COMBO_WIND_UP:
			_thrust_step_remaining = definition.thrust_step_distance
			thrust_hitbox.activate(definition.attack_damage, self, facing_direction, 110.0, 0.08)
			action_impact.emit(&"precision_thrust", global_position + facing_direction * 58.0 + Vector2(0.0, -24.0), facing_direction)
			_enter(State.THRUST_ACTIVE, definition.active_seconds)
		State.THRUST_ACTIVE:
			thrust_hitbox.deactivate()
			_enter(State.COMBO_GAP, definition.combo_gap_seconds)
		State.COMBO_GAP:
			_choose_follow_up()
		State.SWEEP_WIND_UP:
			sweep_hitbox.activate(definition.sweep_damage, self, facing_direction, 150.0, 0.10)
			action_impact.emit(&"divine_sweep", global_position + Vector2(0.0, -24.0), facing_direction)
			_enter(State.SWEEP_ACTIVE, definition.sweep_seconds)
		State.SWEEP_ACTIVE:
			sweep_hitbox.deactivate()
			_enter(State.COMBO_RECOVERY, definition.combo_recovery_seconds)
		State.COMBO_RECOVERY:
			_close_exchange_count += 1
			_enter(State.APPROACH, 0.0)
		State.PURSUIT_WIND_UP:
			dash_hitbox.activate(definition.judgment_charge_damage, self, facing_direction, 160.0, 0.12)
			_enter(State.PURSUIT_TRAVEL, definition.pursuit_travel_seconds)
		State.PURSUIT_RECOVERY:
			_close_exchange_count += 1
			_enter(State.APPROACH, 0.0)
		State.CHARGE_WIND_UP:
			dash_hitbox.activate(definition.judgment_charge_damage, self, facing_direction, 180.0, 0.14)
			_enter(State.CHARGE_TRAVEL, definition.judgment_charge_travel_seconds)
		State.CHARGE_IMPACT:
			_enter(State.CHARGE_RECOVERY, definition.judgment_charge_recovery_seconds)
		State.CHARGE_RECOVERY:
			_enter(State.APPROACH, 0.0)
		State.SLAM_WIND_UP, State.HELD_JUDGMENT:
			slam_hitbox.activate_radial(definition.ground_judgment_damage, self, global_position, 220.0, 0.18)
			action_impact.emit(&"ground_judgment", global_position + Vector2(0.0, -6.0), facing_direction)
			_enter(State.SLAM_ACTIVE, definition.ground_judgment_active_seconds)
		State.SLAM_ACTIVE:
			slam_hitbox.deactivate()
			_enter(State.SLAM_RECOVERY, definition.ground_judgment_recovery_seconds)
		State.SLAM_RECOVERY:
			_close_exchange_count += 1
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


func _on_damaged(_info: DamageInfo) -> void:
	if health_component.current_health <= 0.0 or state in [State.TRIAL_CHANNEL, State.WITHDRAWAL]:
		return
	if _phase_two and not _final_trial_requested and health_component.current_health <= health_component.maximum_health * 0.35:
		_final_trial_requested = true
		_deactivate_hitboxes()
		_begin_trial()
		return
	if not _phase_transition_requested and health_component.current_health <= health_component.maximum_health * PHASE_TRIGGER_RATIO:
		request_phase_transition()
		return
	_recent_player_hits += 1
	_attack_pressure_remaining = 1.25
	if _recent_player_hits >= 3:
		# A short repeated offensive string teaches the Examiner to ready a
		# counter soon; it never interrupts an action or bypasses its cooldown.
		_refutation_cooldown = minf(_refutation_cooldown, 0.18)


func request_phase_transition() -> bool:
	if _phase_transition_requested or state == State.WITHDRAWAL:
		return false
	_phase_transition_requested = true
	_deactivate_hitboxes()
	health_component.set_invulnerable(true)
	velocity = Vector2.ZERO
	_enter(State.PHASE_STANCE, 0.0)
	phase_transition_requested.emit()
	return true


func begin_divine_descent() -> bool:
	if state != State.PHASE_STANCE:
		return false
	_begin_trial()
	return true


func is_phase_two() -> bool:
	return _phase_two


func _track_target_before_commit() -> void:
	if not is_instance_valid(target):
		return
	var can_track := (
		(state == State.COMBO_WIND_UP and _state_remaining > 0.15)
		or (state == State.SWEEP_WIND_UP and _state_remaining > 0.16)
	)
	if not can_track:
		return
	var offset := target.global_position - global_position
	if offset.is_zero_approx():
		return
	_set_facing(offset.normalized())
	thrust_pivot.rotation = facing_direction.angle()


func _process_divine_descent(delta: float) -> void:
	velocity = Vector2.ZERO
	_set_moving(false)
	if state == State.PHASE_STANCE:
		return
	_state_remaining -= delta
	if state == State.DESCENT_LAUNCH:
		var launch_progress := 1.0 - clampf(_state_remaining / DESCENT_LAUNCH_SECONDS, 0.0, 1.0)
		global_position = _descent_origin.lerp(_descent_destination, ease(launch_progress, 0.48))
	elif state == State.DESCENT_FALL:
		var fall_progress := 1.0 - clampf(_state_remaining / DESCENT_FALL_SECONDS, 0.0, 1.0)
		global_position = _descent_origin.lerp(_descent_destination, ease(fall_progress, 0.56))
	if _state_remaining > 0.0:
		return
	match state:
		State.DESCENT_PREPARE:
			_descent_origin = global_position
			# Clear the complete 128px frame beyond the court's upper edge. The
			# old -190px offset could leave him visibly hovering at the top.
			_descent_destination = Vector2(global_position.x, arena_bounds.position.y - 150.0)
			collision_layer = 0
			collision_mask = 0
			_enter(State.DESCENT_LAUNCH, DESCENT_LAUNCH_SECONDS)
		State.DESCENT_LAUNCH:
			visible = false
			divine_descent_launched.emit(definition.sanctuary_escape_seconds)
			_enter(State.DESCENT_ABSENT, definition.sanctuary_escape_seconds)
		State.DESCENT_ABSENT:
			_descent_destination = arena_bounds.get_center()
			_descent_origin = _descent_destination + Vector2(0.0, -340.0)
			global_position = _descent_origin
			visible = true
			_enter(State.DESCENT_FALL, DESCENT_FALL_SECONDS)
		State.DESCENT_FALL:
			global_position = _descent_destination
			divine_descent_impact.emit(global_position)
			action_impact.emit(&"divine_descent", global_position, Vector2.DOWN)
			_enter(State.DESCENT_IMPACT, DESCENT_IMPACT_SECONDS)
		State.DESCENT_IMPACT:
			_enter(State.DESCENT_RECOVERY, DESCENT_RECOVERY_SECONDS)
		State.DESCENT_RECOVERY:
			collision_layer = _original_collision_layer
			collision_mask = _original_collision_mask
			health_component.set_invulnerable(false)
			_phase_two = true
			_axiom_cooldown = minf(_axiom_cooldown, 2.6)
			phase_two_started.emit()
			_enter(State.APPROACH, 0.0)


func _deactivate_hitboxes() -> void:
	thrust_hitbox.deactivate()
	sweep_hitbox.deactivate()
	dash_hitbox.deactivate()
	slam_hitbox.deactivate()


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


func judgment_charge_endpoint() -> Vector2:
	return _travel_target


func _withdraw() -> void:
	state = State.WITHDRAWAL
	if trial != null:
		trial.cancel()
	velocity = Vector2.ZERO
	_deactivate_hitboxes()
	health_component.set_invulnerable(true)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.WITHDRAWAL, 1.25)
	set_physics_process(false)
	get_tree().create_timer(1.4).timeout.connect(queue_free)


func _choose_follow_up() -> void:
	if not is_instance_valid(target):
		_enter(State.COMBO_RECOVERY, definition.combo_recovery_seconds)
		return
	var offset := target.global_position - global_position
	# Getting behind the committed first strike earns an actual punish window.
	if offset.normalized().dot(facing_direction) < -0.15:
		_enter(State.COMBO_RECOVERY, definition.combo_recovery_seconds)
	elif offset.length() > 92.0:
		_begin_pursuit(offset)
	elif _phase_two and _close_exchange_count % 2 == 0:
		_enter(State.HELD_JUDGMENT, 1.05)
	else:
		_enter(State.SWEEP_WIND_UP, definition.sweep_wind_up_seconds)


func _begin_pursuit(offset: Vector2) -> void:
	_set_facing(offset.normalized())
	_travel_start = global_position
	_travel_target = (global_position + facing_direction * minf(definition.pursuit_distance, offset.length() + definition.pursuit_overshoot)).clamp(arena_bounds.position + Vector2(20,20), arena_bounds.end - Vector2(20,20))
	_active_travel_seconds = definition.pursuit_travel_seconds
	_travel_elapsed = 0.0
	_enter(State.PURSUIT_WIND_UP, definition.pursuit_warning_seconds)


func _begin_trial() -> void:
	velocity = Vector2.ZERO
	_deactivate_hitboxes()
	_set_facing(Vector2.DOWN)
	_trial_succeeded = false
	health_component.set_invulnerable(false)
	_enter(State.TRIAL_CHANNEL, definition.trial_duration_seconds)
	trial_started.emit()
	trial.begin(self, target, definition)


func _finish_trial(success: bool) -> void:
	if state != State.TRIAL_CHANNEL:
		return
	_trial_succeeded = success
	# Pick the nearest reachable sanctuary at resolution; never move it afterward.
	var points := CourtOfFirstMeasure.PYLON_POINTS
	var player_position := target.global_position if is_instance_valid(target) else global_position
	_sanctuary_position = points[0]
	for point: Vector2 in points:
		if player_position.distance_squared_to(point) < player_position.distance_squared_to(_sanctuary_position):
			_sanctuary_position = point
	health_component.set_invulnerable(true)
	trial_finished.emit(success, _sanctuary_position)
	_enter(State.DESCENT_PREPARE, DESCENT_PREPARE_SECONDS)
