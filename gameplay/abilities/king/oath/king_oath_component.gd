class_name KingOathComponent
extends AbilityComponent

## Contact timing and shapes remain authoritative; presentation observes signals.
var elapsed := 0.0
var contact_origin := Vector2.ZERO
var contact_radius := 0.0
var _origin := Vector2.ZERO
var _target := Vector2.ZERO
var _landing := Vector2.ZERO
var _next_beat := 0
var _contact_remaining := 0.0
var _travel_invulnerable := false

func _ready() -> void:
	definition = (definition as KingOathDefinition).at_rank(0)
	hitbox = MeleeHitbox.new()
	hitbox.name = "Contact"
	hitbox.collision_layer = 8
	hitbox.collision_mask = 16
	add_child(hitbox)
	hitbox.top_level = true
	collision_shape = CollisionShape2D.new()
	hitbox.add_child(collision_shape)
	super._ready()

func request_cast(direction: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if not is_ready():
		return false
	var tuning := definition as KingOathDefinition
	_origin = (owner as Node2D).global_position
	_target = _origin + direction.normalized()*tuning.travel_range
	elapsed = 0.0
	_next_beat = 0
	_contact_remaining = 0.0
	return super.request_cast(direction,equipped_weapon_damage)

func request_cast_at(target_global_position: Vector2, equipped_weapon_damage := 0.0) -> bool:
	if not request_cast(target_global_position-(owner as Node2D).global_position,equipped_weapon_damage):
		return false
	var tuning := definition as KingOathDefinition
	_target = _origin+(target_global_position-_origin).limit_length(tuning.travel_range)
	return true

func supports_ground_targeting() -> bool:
	return (definition as KingOathDefinition).technique == KingOathDefinition.Technique.STARFALL

func get_target_range_pixels() -> float:
	return (definition as KingOathDefinition).travel_range

func get_target_radius_pixels() -> float:
	return (definition as KingOathDefinition).beat_radii[0]

func has_active_movement() -> bool:
	return (definition as KingOathDefinition).travel_seconds > 0

func get_active_velocity() -> Vector2:
	var tuning := definition as KingOathDefinition
	if phase != Phase.ACTIVE or elapsed>=tuning.travel_seconds:
		return Vector2.ZERO
	var remaining := _target-(owner as Node2D).global_position
	return remaining.limit_length(tuning.travel_range/maxf(tuning.travel_seconds,.01)*get_physics_process_delta_time())/maxf(get_physics_process_delta_time(),.001)

func _physics_process(delta: float) -> void:
	if _contact_remaining>0:
		if (definition as KingOathDefinition).technique==KingOathDefinition.Technique.CROSSCUT:
			contact_origin=(owner as Node2D).global_position+Vector2(0,-12)
			hitbox.global_position=contact_origin
		_contact_remaining-=delta
		if _contact_remaining<=0:
			hitbox.deactivate()
	super._physics_process(delta)

func _start_current_strike() -> void:
	# Base phase entry calls this once; the authored timeline owns later contacts.
	var tuning := definition as KingOathDefinition
	if tuning.technique == KingOathDefinition.Technique.STARFALL:
		_travel_invulnerable = true
		invulnerability_changed.emit(true)
	_fire_due_beats()

func _advance_active_strikes(delta: float) -> void:
	elapsed += delta
	var tuning := definition as KingOathDefinition
	if _travel_invulnerable and elapsed>=tuning.travel_seconds:
		_travel_invulnerable = false
		invulnerability_changed.emit(false)
	_fire_due_beats()

func _fire_due_beats() -> void:
	var tuning := definition as KingOathDefinition
	# At most one contact per physics frame, so even a large delta cannot erase
	# an earlier hit window before the physics server has observed its shape.
	if _next_beat<tuning.beat_times.size() and elapsed+.0001>=tuning.beat_times[_next_beat]:
		_fire_beat(_next_beat)
		_next_beat+=1

func _fire_beat(index: int) -> void:
	var tuning := definition as KingOathDefinition
	_current_strike_index = index
	contact_radius = tuning.beat_radii[index]
	contact_origin = (owner as Node2D).global_position
	if tuning.technique == KingOathDefinition.Technique.GRIEFWAKE:
		contact_origin = _origin+_cast_direction*tuning.beat_distances[index]
	elif tuning.technique == KingOathDefinition.Technique.STARFALL:
		if index == 0:
			_landing = contact_origin
		contact_origin = _landing
	hitbox.global_position = contact_origin
	hitbox.global_rotation = 0.0
	if tuning.technique == KingOathDefinition.Technique.CROSSCUT:
		contact_origin+=Vector2(0,-12)
		hitbox.global_position=contact_origin
		var fan := ConvexPolygonShape2D.new()
		var points := PackedVector2Array([Vector2.ZERO])
		for sample in 13:
			points.append(Vector2.from_angle(lerpf(-1.1,1.1,sample/12.0))*contact_radius)
		fan.points = points
		collision_shape.shape = fan
		hitbox.global_rotation = _cast_direction.angle()
	else:
		var circle := CircleShape2D.new()
		circle.radius = contact_radius
		collision_shape.shape = circle
	_contact_remaining = .1
	hitbox.activate_radial(tuning.resolve_strike_damage(_equipped_weapon_damage,index),owner,contact_origin,
		tuning.resolve_strike_knockback(index),tuning.resolve_strike_stagger(index),_critical_chance_ratio,_critical_damage_multiplier)
	strike_started.emit(index,tuning.strike_count(),.1)

func cancel_cast() -> void:
	_contact_remaining = 0.0
	_next_beat = 999
	if _travel_invulnerable:
		_travel_invulnerable = false
		invulnerability_changed.emit(false)
	super.cancel_cast()
