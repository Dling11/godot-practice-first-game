extends MeleeHitbox

## One contact chooses exactly one damage tier from the target's ground anchor.
var core_radius := 28.0
var outer_ratio := 0.4
var slows_outer := false

func _try_hit(area: Area2D) -> void:
	if not area is HurtboxComponent or not _enabled or _hit_targets.has(area):
		return
	var ground := area.global_position
	if area.owner is CharacterBody2D:
		ground = (area.owner as Node2D).global_position
	var outside_core := ground.distance_to(_radial_origin) > core_radius
	var core_damage := _damage
	var core_knockback := _knockback_strength
	var core_stagger := _stagger_seconds
	if outside_core:
		_damage *= outer_ratio
		_stagger_seconds *= .25
	if slows_outer:
		_knockback_strength = 0.0
	super._try_hit(area)
	_damage = core_damage
	_knockback_strength = core_knockback
	_stagger_seconds = core_stagger

func _ready() -> void:
	super._ready()
	hit_landed.connect(_on_accepted_hit)

func _on_accepted_hit(target: HurtboxComponent, _info: DamageInfo) -> void:
	if not slows_outer or not is_instance_valid(target.owner):
		return
	var definition: Variant = target.owner.get("definition")
	if not definition is EnemyDefinition or definition.crowd_control_tier != EnemyDefinition.CrowdControlTier.LIGHT:
		return
	if (target.owner as Node2D).global_position.distance_to(_radial_origin) <= core_radius:
		return
	for child in target.owner.get_children():
		if child is EnemyMovementComponent:
			child.apply_slow(.25, 1.2)
			break
