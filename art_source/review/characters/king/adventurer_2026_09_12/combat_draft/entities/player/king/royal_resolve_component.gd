class_name RoyalResolveComponent
extends Node

## Three accepted sword swings empower the next committed skill, once.
signal resolve_changed(stacks: int, maximum: int)
signal skill_empowered(ability: AbilityComponent)

@export var required_hits := 3
@export var power_multiplier := 1.35
@export var retention_seconds := 8.0
var stacks := 0
var _swing_awarded := false
var _expiry: Timer
var actor: Player

func _ready() -> void:
	actor = get_parent() as Player
	_expiry = Timer.new()
	_expiry.one_shot = true
	_expiry.timeout.connect(clear)
	add_child(_expiry)
	# Player's onready references become available after its children are ready.
	actor.ready.connect(_bind)

func _bind() -> void:
	actor.attack_component.attack_started.connect(_on_swing_started)
	actor.attack_component.hit_landed.connect(_on_sword_hit)
	actor.defeated.connect(clear)
	for slot in range(1,5):
		var ability := actor.get_ability_component_for_slot(slot)
		ability.ability_started.connect(_on_skill_started.bind(ability))

func _on_swing_started() -> void:
	_swing_awarded = false

func _on_sword_hit(_target: HurtboxComponent, _info: DamageInfo) -> void:
	if _swing_awarded:
		return
	_swing_awarded = true
	stacks = mini(stacks + 1, required_hits)
	_expiry.start(retention_seconds)
	resolve_changed.emit(stacks, required_hits)

func _on_skill_started(ability: AbilityComponent) -> void:
	actor.attack_component.reset_combo()
	if stacks < required_hits:
		return
	ability.amplify_committed_cast(power_multiplier)
	clear()
	skill_empowered.emit(ability)

func clear() -> void:
	stacks = 0
	if _expiry != null:
		_expiry.stop()
	resolve_changed.emit(stacks, required_hits)
