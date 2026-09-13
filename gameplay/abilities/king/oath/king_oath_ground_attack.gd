extends Node2D

## Released authority outlives the cast, never borrows a later cast's snapshots.
signal impacted
signal hit_landed(target: HurtboxComponent, info: DamageInfo)

const AreaHitbox = preload("res://gameplay/abilities/king/oath/king_oath_area_hitbox.gd")
var source: Player
var tuning: KingOathDefinition
var damage := 0.0
var critical_chance := 0.0
var critical_multiplier := 1.5
var origin := Vector2.ZERO
var delay := .25
var contact: AreaHitbox
var _age := 0.0
var _released := false
var _contact_age := 0.0

func _ready() -> void:
	global_position = origin
	contact = AreaHitbox.new()
	contact.core_radius = tuning.core_radius
	contact.outer_ratio = tuning.outer_damage_ratio
	contact.slows_outer = tuning.technique == KingOathDefinition.Technique.GRIEFWAKE
	contact.collision_layer = 8
	contact.collision_mask = 16
	var shape := CollisionShape2D.new()
	var circle := CircleShape2D.new()
	circle.radius = tuning.beat_radii[0]
	shape.shape = circle
	contact.add_child(shape)
	add_child(contact)
	contact.hit_landed.connect(func(target: HurtboxComponent, info: DamageInfo) -> void: hit_landed.emit(target, info))
	source.defeated.connect(_cancel)

func _physics_process(delta: float) -> void:
	if not is_instance_valid(source) or source.is_defeated:
		_cancel()
		return
	_age += delta
	if not _released and _age >= delay:
		_released = true
		contact.activate_radial(damage, source, origin, tuning.knockback_strength, tuning.stagger_seconds, critical_chance, critical_multiplier)
		impacted.emit()
	elif _released:
		_contact_age += delta
	if _released and _contact_age >= .10:
		_cancel()

func _cancel() -> void:
	if is_instance_valid(contact):
		contact.deactivate()
	set_physics_process(false)
	queue_free()
