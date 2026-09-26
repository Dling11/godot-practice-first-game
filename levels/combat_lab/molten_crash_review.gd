extends Node

## Session-only Skill 2 swap; preserves component identity, signals and loadout.
const Component = preload("res://gameplay/abilities/king/molten_crash_component.gd")
const Definition = preload("res://data/abilities/king/molten_crash_definition.gd")
var actor: Player
var enabled := false
var form := Definition.Form.FOUNDATION
var _script: Script
var _definition: AbilityDefinition
var _slots: Array
var _connections: Array[Dictionary] = []

func set_enabled(value: bool) -> bool:
	if value==enabled:
		return true
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	if not library.can_edit():
		return false
	var ability := actor.ability_2_component
	var box := ability.hitbox
	var shape := ability.collision_shape
	ability.clear_cooldown()
	if value:
		_script = ability.get_script()
		_definition = ability.definition
		_slots = library.current_ids()
		for signal_name in [&"phase_changed",&"strike_started",&"ability_finished"]:
			for connection in ability.get_signal_connection_list(signal_name):
				var callback: Callable = connection.callable
				if callback.get_object()==actor.get_node("AbilityPivot/RiftbreakVisual") or (signal_name==&"strike_started" and callback.get_object()==actor.get_node("PlayerActionSfx")):
					_connections.append({"signal":signal_name,"callback":callback})
					ability.disconnect(signal_name,callback)
		actor.get_node("AbilityPivot/RiftbreakVisual")._clear_visual()
		var tuning := Definition.new()
		tuning.icon = _definition.icon
		tuning.configure_form(form)
		ability.set_script(Component)
		ability.definition = tuning
		ability.hitbox = box
		ability.collision_shape = shape
		library.equip("riftbreak",2)
	else:
		box.set("damage_core_radius",0.0)
		for effect in get_tree().get_nodes_in_group("molten_crash_review_effects"):
			if effect.source==actor:
				effect.queue_free()
		for pulse in get_tree().get_nodes_in_group("molten_crash_review_pulses"):
			if pulse.source==actor:
				pulse.queue_free()
		ability.set_script(_script)
		ability.definition = _definition
		ability.hitbox = box
		ability.collision_shape = shape
		for connection in _connections:
			ability.connect(connection.signal,connection.callback)
		_connections.clear()
		library._apply_slots(_slots)
	enabled = value
	return true

func set_form(value: int) -> bool:
	if value < Definition.Form.FOUNDATION or value > Definition.Form.MATURE:
		return false
	if not enabled or not actor.get_node("KingSkillLibrary").can_edit():
		return false
	for pulse in get_tree().get_nodes_in_group("molten_crash_review_pulses"):
		if pulse.source==actor:
			return false
	form = value
	var next: MoltenCrashDefinition = actor.ability_2_component.definition.duplicate(true)
	next.configure_form(form)
	actor.ability_2_component.definition = next
	actor.ability_2_component.clear_cooldown()
	var library: KingSkillLibrary = actor.get_node("KingSkillLibrary")
	library._apply_slots(library.current_ids())
	return true
