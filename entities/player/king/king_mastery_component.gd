class_name KingMasteryComponent
extends Node

## Session-local combat modifiers. No resource mutation, extra input, or saving.
signal resolve_changed(stacks: int, maximum: int)
signal technique_empowered(ability: AbilityComponent, from_resolve: bool, from_link: bool)
signal link_changed(available: bool)

@export var definition: KingMasteryDefinition
var stacks := 0
var actor: Player
var _swing_awarded := false
var _expiry: Timer
var _link: Timer

func _ready() -> void:
	actor = get_parent() as Player
	_expiry = Timer.new()
	_expiry.one_shot = true
	_expiry.timeout.connect(clear_resolve)
	add_child(_expiry)
	_link = Timer.new()
	_link.one_shot = true
	_link.timeout.connect(func() -> void: link_changed.emit(false))
	add_child(_link)
	actor.ready.connect(_bind)

func _bind() -> void:
	actor.attack_component.attack_started.connect(_on_swing_started)
	actor.attack_component.hit_landed.connect(_on_sword_hit)
	actor.evade_component.evade_started.connect(func(_direction: Vector2) -> void: actor.attack_component.reset_combo())
	actor.defeated.connect(clear)
	for ability in [actor.ability_1_component,actor.ability_2_component,actor.ability_3_component,actor.ability_4_component]:
		if ability != null:
			ability.ability_started.connect(_on_skill_started.bind(ability))
	actor.ability_3_component.strike_started.connect(_on_pursuit_landed)

func _on_swing_started() -> void:
	_swing_awarded = false

func _on_sword_hit(_target: HurtboxComponent, _info: DamageInfo) -> void:
	if _swing_awarded:
		return
	_swing_awarded = true
	stacks = mini(stacks + 1, definition.resolve_hits)
	_expiry.start(definition.resolve_retention_seconds)
	resolve_changed.emit(stacks, definition.resolve_hits)

func _on_skill_started(ability: AbilityComponent) -> void:
	actor.attack_component.reset_combo()
	var resolved := stacks >= definition.resolve_hits
	var linked := not _link.is_stopped() and ability == actor.ability_2_component
	var multiplier := definition.level_multiplier(actor.progression_component.level)
	if resolved:
		multiplier *= definition.resolve_multiplier
		clear_resolve()
	if linked:
		multiplier *= definition.pursuit_rift_multiplier
	_link.stop()
	link_changed.emit(false)
	ability.amplify_committed_cast(multiplier)
	technique_empowered.emit(ability, resolved, linked)

func _on_pursuit_landed(_index: int, _count: int, _duration: float) -> void:
	_link.start(definition.pursuit_rift_window_seconds)
	link_changed.emit(true)

func clear_resolve() -> void:
	stacks = 0
	_expiry.stop()
	resolve_changed.emit(stacks, definition.resolve_hits)

func clear() -> void:
	clear_resolve()
	_link.stop()
	link_changed.emit(false)
