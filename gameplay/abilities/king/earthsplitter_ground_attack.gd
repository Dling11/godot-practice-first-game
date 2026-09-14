extends Node2D

## A swept wave front, one hit per target for the entire Foundation cast.
signal hit_landed(target: HurtboxComponent, info: DamageInfo)
signal front_advanced(point: Vector2)
signal travel_finished
var source: Player
var tuning: AbilityDefinition
var origin := Vector2.ZERO
var target := Vector2.ZERO
var damage := 0.0
var critical_chance := 0.0
var critical_multiplier := 1.5
var _contact: MeleeHitbox
var _age := 0.0
var _last := Vector2.ZERO
var _ended := false

func _ready() -> void:
	add_to_group("earthsplitter_review_attacks")
	_last = origin
	_contact = MeleeHitbox.new()
	# Queries own the swept shape; disable Area monitoring to avoid a second,
	# stale overlap path after the front has advanced or stopped at terrain.
	_contact.collision_layer = 0
	_contact.collision_mask = 0
	var shape := CollisionShape2D.new()
	var capsule := CapsuleShape2D.new()
	capsule.radius = tuning.lane_radius
	capsule.height = tuning.lane_radius * 2.0
	shape.shape = capsule
	_contact.add_child(shape)
	add_child(_contact)
	_contact.global_position = origin
	_contact.activate(damage, source, (target-origin).normalized(), tuning.knockback_strength, tuning.stagger_seconds, critical_chance, critical_multiplier, 0.0)
	_contact.set_physics_process(false)
	_contact.hit_landed.connect(func(hurtbox: HurtboxComponent, info: DamageInfo) -> void: hit_landed.emit(hurtbox, info))
	front_advanced.emit(origin)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated:
		_cancel()
		return
	_age += delta
	var point := origin.lerp(target, minf(_age / tuning.travel_seconds, 1.0))
	# Recheck new geometry while the wave travels. Radius-wide terrain sweep
	# prevents the hurtbox radius reaching through a wall beside the center ray.
	var terrain := PhysicsShapeQueryParameters2D.new()
	var terrain_shape := CircleShape2D.new()
	terrain_shape.radius = tuning.lane_radius
	terrain.shape = terrain_shape
	terrain.transform = Transform2D(0, _last)
	terrain.collision_mask = 1
	terrain.exclude = [source.get_rid()]
	if not get_world_2d().direct_space_state.intersect_shape(terrain, 1).is_empty():
		_cancel()
		return
	terrain.motion = point - _last
	var fractions := get_world_2d().direct_space_state.cast_motion(terrain)
	var stopped := fractions[0] < 1.0
	if stopped:
		point = _last + terrain.motion * fractions[0]
	var distance := _last.distance_to(point)
	var capsule := _contact.get_child(0).shape as CapsuleShape2D
	capsule.height = tuning.lane_radius * 2.0 + distance
	_contact.global_position = (_last + point) * .5
	_contact.rotation = (point - _last).angle() + PI * .5
	var query := PhysicsShapeQueryParameters2D.new()
	query.shape = capsule
	query.transform = _contact.global_transform
	query.collision_mask = 16
	query.collide_with_areas = true
	query.collide_with_bodies = false
	for result in get_world_2d().direct_space_state.intersect_shape(query, 128):
		_contact._try_hit(result.collider)
	front_advanced.emit(point)
	_last = point
	if stopped or _age >= tuning.travel_seconds:
		_cancel()

func _cancel() -> void:
	if _ended:
		return
	_ended = true
	_contact.deactivate()
	travel_finished.emit()
	set_physics_process(false)
	queue_free()
