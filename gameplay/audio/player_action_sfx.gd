class_name PlayerActionSfx
extends Node2D

## Presents local player action sounds; combat components remain authoritative.

@export var sword_swing_player: AudioStreamPlayer2D
@export var ability_player: AudioStreamPlayer2D
@export var dash_player: AudioStreamPlayer2D
@export var ability_component: AbilityComponent
@export var ability_2_component: AbilityComponent
@export var piercing_charge_player: AudioStreamPlayer2D
@export var piercing_thrust_player: AudioStreamPlayer2D
@export var consecutive_charge_player: AudioStreamPlayer2D
@export var consecutive_flurry_player: AudioStreamPlayer2D
@export var consecutive_final_player: AudioStreamPlayer2D

var _consecutive_flurry_index := 0


func play_attack_phase(phase: int, _duration_seconds: float) -> void:
	if phase == MeleeAttackComponent.Phase.ACTIVE:
		_play(sword_swing_player, 1.0)


func play_ability_phase(phase: int, _duration_seconds: float) -> void:
	var active_ability := _get_casting_ability()
	if _is_piercing_rush(active_ability):
		if phase == AbilityComponent.Phase.WIND_UP:
			_play(piercing_charge_player, 0.92)
		elif phase == AbilityComponent.Phase.ACTIVE:
			_play(piercing_thrust_player, 0.98)
		return
	if _is_consecutive_thrust(active_ability):
		if phase == AbilityComponent.Phase.WIND_UP:
			_consecutive_flurry_index = 0
			_play(consecutive_charge_player, 0.96)
		return
	if phase == AbilityComponent.Phase.ACTIVE:
		_play(ability_player, 1.08)


func play_ability_strike(strike_index: int, strike_count: int, _duration_seconds: float) -> void:
	if not _is_consecutive_thrust(_get_casting_ability()):
		return
	if strike_index >= strike_count - 1:
		_play(consecutive_final_player, 0.96)
		return
	## Three evenly spaced steel-thrust beats communicate the rapid flurry without
	## restarting a short clip on every one of the seven damage contacts.
	if strike_index % 2 != 0:
		return
	var flurry_pitch: float = [1.03, 0.98, 1.06][_consecutive_flurry_index % 3]
	_consecutive_flurry_index += 1
	_play(consecutive_flurry_player, flurry_pitch)


func play_dash(_direction: Vector2) -> void:
	_play(dash_player, 1.08)


func _play(player: AudioStreamPlayer2D, pitch: float) -> void:
	if player == null or player.stream == null or DisplayServer.get_name() == "headless":
		return
	player.pitch_scale = pitch
	player.play()


func _get_casting_ability() -> AbilityComponent:
	for component in [ability_component, ability_2_component]:
		if component != null and component.is_casting():
			return component
	return null


func _is_piercing_rush(component: AbilityComponent) -> bool:
	return component != null and component.definition != null and component.definition.ability_id == &"piercing_rush"


func _is_consecutive_thrust(component: AbilityComponent) -> bool:
	return component != null and component.definition != null and component.definition.ability_id == &"consecutive_thrust"
