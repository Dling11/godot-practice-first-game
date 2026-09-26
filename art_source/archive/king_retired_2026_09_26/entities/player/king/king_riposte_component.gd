class_name KingRiposteComponent
extends Node

signal riposte_changed(available: bool)
var actor: Player
var step: KingOathComponent
var _window: Timer

func _ready() -> void:
	actor = get_parent() as Player
	_window = Timer.new()
	_window.one_shot = true
	_window.timeout.connect(clear)
	add_child(_window)
	actor.ready.connect(_bind)

func _bind() -> void:
	step = actor.get_node("OathAbility3")
	actor.health_component.damage_blocked.connect(_on_blocked)
	actor.attack_component.attack_started.connect(_on_attack)
	actor.defeated.connect(clear)
	for ability in actor.get_all_ability_components():
		ability.ability_started.connect(clear)

func _on_blocked(info: DamageInfo) -> void:
	if not step._travel_invulnerable or actor.health_component.is_damage_immune or info.ignores_invulnerability:
		return
	if not is_instance_valid(info.source) or info.source == actor or info.amount <= 0:
		return
	_window.start(2.0)
	riposte_changed.emit(true)

func _on_attack() -> void:
	if _window.is_stopped():
		return
	actor.attack_component.committed_damage_multiplier = 1.5
	actor.attack_component.committed_animation_key = "return_cut"
	clear()

func clear() -> void:
	_window.stop()
	riposte_changed.emit(false)
