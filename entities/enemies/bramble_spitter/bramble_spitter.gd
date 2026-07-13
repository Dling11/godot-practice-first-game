class_name BrambleSpitter
extends CharacterBody2D

enum State { SPAWNING, POSITIONING, WIND_UP, RECOVERY, DEAD }

signal state_changed(state: State, duration_seconds: float)
signal facing_changed(direction: Vector2)
signal shot_telegraphed(global_target: Vector2, duration_seconds: float)
signal shot_fired(direction: Vector2)

const SeparationComponentScene = preload("res://entities/enemies/components/enemy_separation_component.tscn")

@export var definition: EnemyDefinition
@export var target: CharacterBody2D
@export var projectile_scene: PackedScene
@export_range(1.0, 200.0, 1.0, "suffix:px") var minimum_attack_range := 95.0

@onready var health_component: HealthComponent = %HealthComponent
@onready var navigation_agent: NavigationAgent2D = %NavigationAgent2D
@onready var knockback_component: KnockbackComponent = %KnockbackComponent

var state := State.SPAWNING
var facing_direction := Vector2.DOWN
var separation_component: EnemySeparationComponent
var _projectile_parent: Node2D
var _state_time_remaining := 0.0
var _repath_time_remaining := 0.0
var _aim_direction := Vector2.DOWN
var _aim_target := Vector2.ZERO
var _applied_knockback_velocity := Vector2.ZERO


func _ready() -> void:
	separation_component = _ensure_separation_component()
	if definition == null or projectile_scene == null:
		push_error("BrambleSpitter requires an EnemyDefinition and projectile scene.")
		set_physics_process(false)
		return
	health_component.maximum_health = definition.maximum_health
	health_component.current_health = definition.maximum_health
	health_component.died.connect(_die)
	state_changed.emit(State.SPAWNING, definition.spawn_seconds)
	get_tree().create_timer(definition.spawn_seconds).timeout.connect(_finish_spawn)


func set_projectile_parent(value: Node2D) -> void:
	_projectile_parent = value


func _ensure_separation_component() -> EnemySeparationComponent:
	var existing := get_node_or_null("EnemySeparationComponent") as EnemySeparationComponent
	if existing != null:
		return existing
	var component := SeparationComponentScene.instantiate() as EnemySeparationComponent
	component.separation_weight = 1.0
	add_child(component)
	return component


func _physics_process(delta: float) -> void:
	velocity -= _applied_knockback_velocity
	_applied_knockback_velocity = Vector2.ZERO
	if state == State.DEAD or state == State.SPAWNING or not is_instance_valid(target):
		velocity = Vector2.ZERO
		return

	match state:
		State.POSITIONING:
			_process_positioning(delta)
		State.WIND_UP, State.RECOVERY:
			velocity = velocity.move_toward(Vector2.ZERO, definition.acceleration * delta)
			_apply_knockback_velocity()
			move_and_slide()
			_tick_attack(delta)


func _process_positioning(delta: float) -> void:
	var offset := target.global_position - global_position
	var distance := offset.length()
	if distance >= minimum_attack_range and distance <= definition.attack_range and _has_clear_shot():
		velocity = Vector2.ZERO
		var muzzle_origin := global_position + Vector2(0.0, -13.0)
		_aim_target = target.global_position + Vector2(0.0, -13.0)
		_aim_direction = muzzle_origin.direction_to(_aim_target)
		_set_facing(_aim_direction)
		shot_telegraphed.emit(target.global_position, definition.wind_up_seconds)
		_enter(State.WIND_UP, definition.wind_up_seconds)
		return

	_repath_time_remaining -= delta
	if _repath_time_remaining <= 0.0:
		var requested_target := target.global_position
		if distance < minimum_attack_range:
			requested_target = global_position - offset.normalized() * (minimum_attack_range - distance + 48.0)
		navigation_agent.target_position = _navigation_safe_target(requested_target)
		_repath_time_remaining = 0.25

	var direction := Vector2.ZERO
	var next_path_position := navigation_agent.get_next_path_position()
	var path_direction := next_path_position - global_position
	if not navigation_agent.is_navigation_finished() and not path_direction.is_zero_approx():
		direction = path_direction
	elif distance > definition.attack_range and _has_clear_shot():
		direction = offset
	elif distance < minimum_attack_range:
		direction = -offset
	direction = separation_component.blend_direction(self, direction)
	# Ranged enemies keep watching their target while kiting; facing the retreat
	# vector caused a visible 180-degree flip immediately before every shot.
	_set_facing(offset if distance < minimum_attack_range else direction)
	velocity = velocity.move_toward(direction.normalized() * definition.move_speed, definition.acceleration * delta)
	_apply_knockback_velocity()
	move_and_slide()


func _tick_attack(delta: float) -> void:
	_state_time_remaining -= delta
	if _state_time_remaining > 0.0:
		return
	match state:
		State.WIND_UP:
			_fire_projectile()
			_enter(State.RECOVERY, definition.recovery_seconds)
		State.RECOVERY:
			_enter(State.POSITIONING, 0.0)


func _fire_projectile() -> void:
	if projectile_scene == null:
		return
	var projectile := projectile_scene.instantiate() as HostileProjectile
	var parent := _projectile_parent if is_instance_valid(_projectile_parent) else get_tree().current_scene
	parent.add_child(projectile)
	projectile.global_position = global_position + Vector2(0.0, -13.0) + _aim_direction * 10.0
	projectile.launch(
		_aim_direction,
		definition.attack_damage,
		self,
		projectile.global_position.distance_to(_aim_target)
	)
	shot_fired.emit(_aim_direction)


func _has_clear_shot() -> bool:
	if not is_instance_valid(target):
		return false
	var query := PhysicsRayQueryParameters2D.create(global_position, target.global_position, 1)
	query.exclude = [get_rid()]
	return get_world_2d().direct_space_state.intersect_ray(query).is_empty()


func _navigation_safe_target(requested: Vector2) -> Vector2:
	var map := navigation_agent.get_navigation_map()
	if not map.is_valid() or NavigationServer2D.map_get_iteration_id(map) == 0:
		return requested
	var safe := NavigationServer2D.map_get_closest_point(map, requested)
	return requested if safe.distance_to(requested) > 64.0 else safe


func _apply_knockback_velocity() -> void:
	_applied_knockback_velocity = knockback_component.velocity
	velocity += _applied_knockback_velocity


func _finish_spawn() -> void:
	if state == State.SPAWNING:
		_enter(State.POSITIONING, 0.0)


func _enter(next_state: State, duration_seconds: float) -> void:
	state = next_state
	_state_time_remaining = duration_seconds
	state_changed.emit(state, duration_seconds)


func _set_facing(direction: Vector2) -> void:
	if direction.is_zero_approx():
		return
	facing_direction = direction.normalized()
	facing_changed.emit(facing_direction)


func _die() -> void:
	state = State.DEAD
	velocity = Vector2.ZERO
	set_physics_process(false)
	collision_layer = 0
	collision_mask = 0
	state_changed.emit(State.DEAD, 0.35)
	get_tree().create_timer(0.35).timeout.connect(queue_free)
