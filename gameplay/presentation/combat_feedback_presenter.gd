class_name CombatFeedbackPresenter
extends Node

## Presents accepted hits without owning combat state, damage, or timing.

const PLAYER_HIT_TINT := Color(1.0, 0.9, 0.42, 1.0)
const PLAYER_DAMAGED_TINT := Color(1.0, 0.42, 0.42, 1.0)

@export var player: Player
@export var effects_parent: Node2D
@export var camera: Camera2D
@export var damage_number_scene: PackedScene
@export var hit_burst_scene: PackedScene
@export var sword_hit_sound: AudioStream
@export var player_hurt_sound: AudioStream

var _camera_base_offset := Vector2.ZERO
var _camera_tween: Tween


func _ready() -> void:
	if player == null or effects_parent == null or camera == null:
		push_error("CombatFeedbackPresenter requires player, effects parent, and camera references.")
		return
	if damage_number_scene == null or hit_burst_scene == null:
		push_error("CombatFeedbackPresenter requires damage-number and hit-burst scenes.")
		return
	_camera_base_offset = camera.offset
	player.attack_component.hit_landed.connect(_on_player_hit_landed)
	player.ability_1_component.hit_landed.connect(_on_player_ability_hit_landed)
	player.health_component.damaged.connect(_on_player_damaged)


func _on_player_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	_show_hit(target.global_position + Vector2(0.0, -22.0), info, PLAYER_HIT_TINT, 1.5)
	_play_sound_at(sword_hit_sound, target.global_position, 1.0)


func _on_player_ability_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	_show_hit(target.global_position + Vector2(0.0, -22.0), info, PLAYER_HIT_TINT, 2.5)
	_play_sound_at(sword_hit_sound, target.global_position, 0.88)


func _on_player_damaged(info: DamageInfo) -> void:
	_show_hit(player.global_position + Vector2(0.0, -26.0), info, PLAYER_DAMAGED_TINT, 2.0)
	_play_sound_at(player_hurt_sound, player.global_position, 1.0)


func _show_hit(position: Vector2, info: DamageInfo, tint: Color, camera_strength: float) -> void:
	var number := damage_number_scene.instantiate() as DamageNumber
	number.global_position = position
	number.configure(info.amount, tint)
	effects_parent.add_child(number)

	var burst := hit_burst_scene.instantiate() as HitBurst
	burst.global_position = position + info.direction * 3.0
	burst.configure(info.direction, tint)
	effects_parent.add_child(burst)
	_pulse_camera(camera_strength)


func _pulse_camera(strength: float) -> void:
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	camera.offset = _camera_base_offset
	_camera_tween = create_tween()
	_camera_tween.tween_property(camera, "offset", _camera_base_offset + Vector2(strength, 0.0), 0.025)
	_camera_tween.tween_property(camera, "offset", _camera_base_offset + Vector2(-strength, 0.0), 0.04)
	_camera_tween.tween_property(camera, "offset", _camera_base_offset, 0.045)


func _play_sound_at(stream: AudioStream, position: Vector2, pitch: float) -> void:
	if stream == null or DisplayServer.get_name() == "headless":
		return
	var player_2d := AudioStreamPlayer2D.new()
	player_2d.stream = stream
	player_2d.bus = AudioDirector.SFX_BUS
	player_2d.pitch_scale = pitch
	effects_parent.add_child(player_2d)
	player_2d.global_position = position
	player_2d.finished.connect(player_2d.queue_free)
	player_2d.play()
