class_name PlayerActionSfx
extends Node2D

## Presents local player action sounds; combat components remain authoritative.

@export var sword_swing_player: AudioStreamPlayer2D
@export var ability_player: AudioStreamPlayer2D
@export var dash_player: AudioStreamPlayer2D


func play_attack_phase(phase: int, _duration_seconds: float) -> void:
	if phase == MeleeAttackComponent.Phase.ACTIVE:
		_play(sword_swing_player, 1.0)


func play_ability_phase(phase: int, _duration_seconds: float) -> void:
	if phase == AbilityComponent.Phase.ACTIVE:
		_play(ability_player, 1.08)


func play_dash(_direction: Vector2) -> void:
	_play(dash_player, 1.08)


func _play(player: AudioStreamPlayer2D, pitch: float) -> void:
	if player == null or player.stream == null or DisplayServer.get_name() == "headless":
		return
	player.pitch_scale = pitch
	player.play()
