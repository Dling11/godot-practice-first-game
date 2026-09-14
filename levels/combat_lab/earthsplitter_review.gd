extends Node

## Reversible session-only Skill 1 prototype; existing signal/Player owners stay.
const Component = preload("res://gameplay/abilities/king/earthsplitter_component.gd")
const Definition = preload("res://data/abilities/king/earthsplitter_definition.gd")
var actor: Player
var enabled := false
var advanced := false
var _script: Script
var _definition: AbilityDefinition
var _slots: Array
var _connections: Array[Dictionary] = []

func set_enabled(value: bool) -> bool:
	if enabled == value:
		return true
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	if not library.can_edit():
		return false
	var ability: AbilityComponent = actor.ability_1_component
	var box := ability.hitbox
	var shape := ability.collision_shape
	ability.clear_cooldown()
	if value:
		_script = ability.get_script()
		_definition = ability.definition
		_slots = library.current_ids()
		# Existing Echo presentation is disconnected only for this local review.
		for signal_name in [&"phase_changed", &"strike_started", &"ability_finished"]:
			for connection in ability.get_signal_connection_list(signal_name):
				var callback: Callable = connection.callable
				if callback.get_object() == actor.get_node("AbilityPivot/EchoingSeverVisual") or (signal_name == &"strike_started" and callback.get_object() == actor.get_node("PlayerActionSfx")):
					_connections.append({"signal": signal_name, "callback": callback})
					ability.disconnect(signal_name, callback)
		actor.get_node("AbilityPivot/EchoingSeverVisual").hide_visual()
		var tuning := Definition.new()
		# Stable legacy slot ID is retained only inside the reversible Lab adapter.
		tuning.ability_id = &"echoing_sever"
		tuning.display_name = "Earthsplitter (Review)"
		tuning.hud_name = "EARTHSPLIT"
		tuning.icon = _definition.icon
		tuning.activation_mode = AbilityDefinition.ActivationMode.GROUND_TARGETED
		tuning.hitbox_shape = CircleShape2D.new()
		tuning.hitbox_shape.radius = tuning.lane_radius
		tuning.weapon_damage_multiplier = 1.65
		tuning.stagger_seconds = .10
		tuning.knockback_strength = 45.0
		tuning.wind_up_seconds = .20
		tuning.active_seconds = .04
		tuning.recovery_seconds = .12
		tuning.cooldown_seconds = 5.0
		tuning.dash_cancelable = true
		tuning.impact_weight = AbilityDefinition.ImpactWeight.HEAVY
		tuning.description = "Aim a quick summoned sword smash. The earth tears forward; each enemy is hit once. No stun. Control returns after 0.36s."
		tuning.set_meta("earthsplitter_review", true)
		tuning.configure_form(advanced)
		ability.set_script(Component)
		ability.definition = tuning
		ability.hitbox = box
		ability.collision_shape = shape
		library.equip("echoing_sever", 1)
	else:
		for sequence in get_tree().get_nodes_in_group("earthsplitter_review_sequences"):
			if sequence.source == actor:
				sequence._cancel()
		for attack in get_tree().get_nodes_in_group("earthsplitter_review_attacks"):
			if attack.source == actor:
				attack._cancel()
		for effect in get_tree().get_nodes_in_group("earthsplitter_review_effects"):
			if effect.source == actor:
				effect.queue_free()
		ability.set_script(_script)
		ability.definition = _definition
		ability.hitbox = box
		ability.collision_shape = shape
		for connection in _connections:
			ability.connect(connection.signal, connection.callback)
		_connections.clear()
		library._apply_slots(_slots)
	enabled = value
	return true

func set_advanced(value: bool) -> bool:
	if not enabled or not actor.get_node("KingSkillLibrary").can_edit():
		return false
	for sequence in get_tree().get_nodes_in_group("earthsplitter_review_sequences"):
		if sequence.source == actor:
			return false
	advanced = value
	var next: AbilityDefinition = actor.ability_1_component.definition.duplicate(true)
	next.configure_form(advanced)
	actor.ability_1_component.definition = next
	actor.ability_1_component.clear_cooldown()
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	# Slots resolve components by definition identity, not just the stable ID.
	library._apply_slots(library.current_ids())
	return true
