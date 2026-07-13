class_name MeleeHitbox
extends Area2D

signal hit_landed(target: HurtboxComponent, info: DamageInfo)

var _damage: float
var _direction := Vector2.RIGHT
var _source: Node
var _knockback_strength := 0.0
var _hit_targets: Dictionary = {}
var _enabled := false


func _ready() -> void:
	area_entered.connect(_on_area_entered)
	_set_enabled(false)
	set_physics_process(false)


func _physics_process(_delta: float) -> void:
	if not monitoring:
		return
	for area in get_overlapping_areas():
		_try_hit(area)


func activate(
	damage: float,
	source: Node,
	direction: Vector2,
	knockback_strength := 0.0
) -> void:
	_damage = damage
	_source = source
	_direction = direction.normalized()
	_knockback_strength = maxf(knockback_strength, 0.0)
	_hit_targets.clear()
	_set_enabled(true)
	set_physics_process(true)


func deactivate() -> void:
	_set_enabled(false)
	set_physics_process(false)


func _set_enabled(enabled: bool) -> void:
	_enabled = enabled
	set_deferred("monitoring", enabled)
	set_deferred("monitorable", false)


func _on_area_entered(area: Area2D) -> void:
	_try_hit(area)


func _try_hit(area: Area2D) -> void:
	if not _enabled:
		return
	if not area is HurtboxComponent:
		return
	var hurtbox := area as HurtboxComponent
	if _hit_targets.has(hurtbox):
		return
	_hit_targets[hurtbox] = true
	var info := DamageInfo.new(_damage, _source, _direction, _knockback_strength)
	if hurtbox.receive_hit(info):
		hit_landed.emit(hurtbox, info)
