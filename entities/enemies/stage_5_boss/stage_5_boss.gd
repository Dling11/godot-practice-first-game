class_name Stage5Boss
extends CharacterBody2D

const EnemyFootprint = preload("res://entities/enemies/components/enemy_footprint_system.gd")
const ImpactScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss_jump_impact.tscn")
const MarkerScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss_jump_marker.tscn")
const RootPrisonScene = preload("res://entities/enemies/stage_5_boss/stage_5_boss_root_prison.tscn")

enum State { SPAWNING, CHASE, LUNGE_WIND_UP, LUNGE_ACTIVE, LUNGE_RECOVERY, SLAP_WIND_UP, SLAP_ACTIVE, SLAP_RECOVERY, JUMP_WIND_UP, JUMP_TRAVEL, JUMP_LAND, JUMP_RECOVERY, ROOT_WIND_UP, ROOT_TRACK, ROOT_CHANNEL, ROOT_EXECUTION, ROOT_RECOVERY, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal movement_changed(is_moving: bool)
signal jump_height_changed(height_pixels: float)
signal jump_target_locked(target_position: Vector2)
signal landed(position: Vector2)
signal slap_landed(position: Vector2)
signal root_executed(position: Vector2, hit_player: bool)

@export var definition: EnemyDefinition
@export var target: CharacterBody2D
@export var arena_bounds := Rect2(64.0, 80.0, 832.0, 400.0)
@export_range(1.0, 100.0, 1.0) var jump_damage := 36.0
@export_range(32.0, 160.0, 1.0) var jump_radius := 72.0
@export_range(0.1, 3.0, 0.05) var jump_wind_up_seconds := 0.72
@export_range(0.1, 3.0, 0.05) var jump_travel_seconds := 0.9
@export_range(0.1, 3.0, 0.05) var jump_recovery_seconds := 1.05
@export_range(1.0, 100.0, 1.0) var slap_damage := 42.0
@export_range(0.1, 3.0, 0.05) var slap_wind_up_seconds := 0.78
@export_range(0.05, 1.0, 0.05) var slap_active_seconds := 0.14
@export_range(0.1, 3.0, 0.05) var slap_recovery_seconds := 0.72
@export_range(1.0, 100.0, 1.0) var root_capture_damage := 12.0
@export_range(100.0, 999.0, 1.0) var root_execution_damage := 300.0
@export_range(0.1, 2.0, 0.05) var root_wind_up_seconds := 0.72
@export_range(0.1, 2.0, 0.05) var root_tracking_seconds := 0.55
@export_range(1.0, 5.0, 0.05) var root_escape_seconds := 2.2
@export_range(0.1, 2.0, 0.05) var root_execution_seconds := 0.9
@export_range(0.1, 3.0, 0.05) var root_recovery_seconds := 1.15
@export_range(8.0, 80.0, 1.0) var root_capture_radius := 34.0
@export_range(1, 10, 1) var root_break_points := 5

@onready var health_component: HealthComponent = %HealthComponent
@onready var body_collision: CollisionShape2D = $BodyCollision
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var knockback_component: KnockbackComponent = %KnockbackComponent
@onready var lunge_pivot: Node2D = %LungePivot
@onready var lunge_hitbox: MeleeHitbox = %LungeHitbox
@onready var slap_pivot: Node2D = %SlapPivot
@onready var slap_hitbox: MeleeHitbox = %SlapHitbox
@onready var jump_hitbox: MeleeHitbox = %JumpHitbox

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var _state_remaining := 0.0
var _jump_cooldown := 2.2
var _attacks_since_jump := 0
var _jump_start := Vector2.ZERO
var _jump_target := Vector2.ZERO
var _jump_elapsed := 0.0
var _marker: Node2D
var _is_moving := false
var _next_melee_is_slap := false
var _root_ready := false
var _root_effect: Stage5BossRootPrison
var _root_target_position := Vector2.ZERO


func _ready() -> void:
	if definition == null:
		push_error("Stage5Boss requires an EnemyDefinition.")
		set_physics_process(false)
		return
	if not EnemyFootprint.configure(definition, body_collision, navigation_agent):
		set_physics_process(false)
		return
	health_component.maximum_health = definition.maximum_health
	health_component.current_health = definition.maximum_health
	health_component.died.connect(_die)
	knockback_component.configure(definition)
	_enter(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func _physics_process(delta: float) -> void:
	_jump_cooldown = maxf(_jump_cooldown - delta, 0.0)
	if state in [State.DEAD, State.SPAWNING] or not is_instance_valid(target):
		velocity = Vector2.ZERO
		_set_moving(false)
		return
	if state == State.CHASE:
		_process_chase(delta)
	elif state == State.JUMP_TRAVEL:
		_process_jump_travel(delta)
	else:
		velocity = Vector2.ZERO
		_set_moving(false)
		_tick_state(delta)


func _process_chase(delta: float) -> void:
	var offset := target.global_position - global_position
	if _root_ready:
		_begin_root_prison(offset)
		return
	if _jump_cooldown <= 0.0 and _attacks_since_jump >= 2:
		_begin_jump(offset)
		return
	if offset.length() <= definition.attack_range:
		_begin_melee(offset)
		return
	_set_facing(offset)
	velocity = velocity.move_toward(offset.normalized() * definition.move_speed, definition.acceleration * delta)
	move_and_slide()
	global_position = global_position.clamp(arena_bounds.position, arena_bounds.end)
	_set_moving(not velocity.is_zero_approx())


func _begin_melee(offset: Vector2) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	lunge_pivot.rotation = direction.angle()
	slap_pivot.rotation = direction.angle()
	_attacks_since_jump += 1
	if _next_melee_is_slap:
		_next_melee_is_slap = false
		_enter(State.SLAP_WIND_UP, slap_wind_up_seconds)
	else:
		_next_melee_is_slap = true
		_enter(State.LUNGE_WIND_UP, definition.wind_up_seconds)


func _begin_jump(offset: Vector2) -> void:
	var direction := offset.normalized() if not offset.is_zero_approx() else facing_direction
	_set_facing(direction)
	_jump_start = global_position
	_jump_target = target.global_position.clamp(arena_bounds.position + Vector2(24.0, 24.0), arena_bounds.end - Vector2(24.0, 24.0))
	_jump_elapsed = 0.0
	_attacks_since_jump = 0
	_jump_cooldown = 4.6
	_spawn_marker(_jump_target)
	jump_target_locked.emit(_jump_target)
	_enter(State.JUMP_WIND_UP, jump_wind_up_seconds)


func _begin_root_prison(offset: Vector2) -> void:
	_root_ready = false
	_set_facing(offset.normalized() if not offset.is_zero_approx() else facing_direction)
	_enter(State.ROOT_WIND_UP, root_wind_up_seconds)


func _process_jump_travel(delta: float) -> void:
	_jump_elapsed += delta
	var progress := clampf(_jump_elapsed / jump_travel_seconds, 0.0, 1.0)
	var eased := progress * progress * (3.0 - 2.0 * progress)
	global_position = _jump_start.lerp(_jump_target, eased)
	jump_height_changed.emit(sin(progress * PI) * 96.0)
	if progress < 1.0:
		return
	global_position = _jump_target
	jump_height_changed.emit(0.0)
	health_component.set_invulnerable(false)
	_set_collision_enabled(true)
	_clear_marker()
	_spawn_impact()
	jump_hitbox.activate_radial(jump_damage, self, global_position, 180.0, 0.0)
	landed.emit(global_position)
	_enter(State.JUMP_LAND, definition.active_seconds)


func _tick_state(delta: float) -> void:
	_state_remaining -= delta
	if _state_remaining > 0.0:
		return
	match state:
		State.LUNGE_WIND_UP:
			lunge_hitbox.activate(definition.attack_damage, self, facing_direction, 120.0, 0.0)
			_enter(State.LUNGE_ACTIVE, definition.active_seconds)
		State.LUNGE_ACTIVE:
			lunge_hitbox.deactivate()
			_enter(State.LUNGE_RECOVERY, definition.recovery_seconds)
		State.LUNGE_RECOVERY:
			_enter(State.CHASE, 0.0)
		State.SLAP_WIND_UP:
			slap_hitbox.activate(slap_damage, self, facing_direction, 185.0, 0.0)
			slap_landed.emit(global_position + facing_direction * 36.0)
			_enter(State.SLAP_ACTIVE, slap_active_seconds)
		State.SLAP_ACTIVE:
			slap_hitbox.deactivate()
			_enter(State.SLAP_RECOVERY, slap_recovery_seconds)
		State.SLAP_RECOVERY:
			_enter(State.CHASE, 0.0)
		State.JUMP_WIND_UP:
			health_component.set_invulnerable(true)
			_set_collision_enabled(false)
			_enter(State.JUMP_TRAVEL, jump_travel_seconds)
		State.JUMP_LAND:
			jump_hitbox.deactivate()
			_enter(State.JUMP_RECOVERY, jump_recovery_seconds)
		State.JUMP_RECOVERY:
			_root_ready = true
			_enter(State.CHASE, 0.0)
		State.ROOT_WIND_UP:
			_spawn_root_prison()
			_enter(State.ROOT_TRACK, root_tracking_seconds)
		State.ROOT_TRACK:
			_lock_root_prison()
			_enter(State.ROOT_CHANNEL, root_escape_seconds)
		State.ROOT_CHANNEL:
			_execute_root_prison()
			_enter(State.ROOT_EXECUTION, root_execution_seconds)
		State.ROOT_EXECUTION:
			_enter(State.ROOT_RECOVERY, root_recovery_seconds)
		State.ROOT_RECOVERY:
			_enter(State.CHASE, 0.0)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_remaining = duration_seconds
	if next_state != State.CHASE:
		_set_moving(false)
	state_changed.emit(state, duration_seconds)


func _finish_spawn() -> void:
	if state == State.SPAWNING:
		_enter(State.CHASE, 0.0)


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


func _set_collision_enabled(enabled: bool) -> void:
	body_collision.set_deferred("disabled", not enabled)
	set_collision_layer_value(3, enabled)
	set_collision_mask_value(1, enabled)


func _spawn_marker(position: Vector2) -> void:
	_clear_marker()
	_marker = MarkerScene.instantiate() as Node2D
	_effects_parent().add_child(_marker)
	_marker.global_position = position


func _clear_marker() -> void:
	if is_instance_valid(_marker):
		_marker.queue_free()
	_marker = null


func _spawn_impact() -> void:
	var impact := ImpactScene.instantiate() as Node2D
	_effects_parent().add_child(impact)
	impact.global_position = global_position


func _spawn_root_prison() -> void:
	_clear_root_prison()
	_root_effect = RootPrisonScene.instantiate() as Stage5BossRootPrison
	_effects_parent().add_child(_root_effect)
	_root_effect.global_position = target.global_position
	if target is Player:
		_root_effect.begin_tracking(target as Player, self)


func _lock_root_prison() -> void:
	if not is_instance_valid(_root_effect) or not is_instance_valid(target):
		return
	_root_target_position = _root_effect.global_position
	var captured := false
	if target is Player and target.global_position.distance_to(_root_target_position) <= root_capture_radius:
		var player := target as Player
		captured = player.try_begin_root_restraint(self, root_break_points)
		if captured:
			_root_target_position = player.global_position
			_root_effect.global_position = _root_target_position
			_root_effect.bind_restraint(player, self)
			player.health_component.apply_damage(DamageInfo.new(root_capture_damage, self, facing_direction, 0.0, 0.0))
	_root_effect.lock_target(captured, root_break_points)


func _execute_root_prison() -> void:
	var hit_player := false
	if target is Player:
		var player := target as Player
		if player.is_restrained_by(self):
			hit_player = player.health_component.apply_damage(
				DamageInfo.new(root_execution_damage, self, (player.global_position - global_position).normalized(), 0.0, 0.0)
			)
			player.release_root_restraint(self, false)
	if is_instance_valid(_root_effect):
		_root_effect.play_execution()
	root_executed.emit(_root_target_position, hit_player)


func _clear_root_prison() -> void:
	if target is Player:
		(target as Player).release_root_restraint(self, false)
	if is_instance_valid(_root_effect):
		_root_effect.cancel_effect()
	_root_effect = null


func _effects_parent() -> Node2D:
	var effects := get_tree().get_first_node_in_group("boss_effects") as Node2D
	return effects if effects != null else get_parent() as Node2D


func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	lunge_hitbox.deactivate()
	slap_hitbox.deactivate()
	jump_hitbox.deactivate()
	_clear_marker()
	_clear_root_prison()
	health_component.set_invulnerable(false)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.DEAD, 1.25)
	set_physics_process(false)
