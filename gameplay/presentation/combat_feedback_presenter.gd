class_name CombatFeedbackPresenter
extends Node

## Presents accepted hits without owning combat state, damage, or timing.

const PLAYER_HIT_TINT := Color(1.0, 0.9, 0.42, 1.0)
const PLAYER_DAMAGED_TINT := Color(1.0, 0.42, 0.42, 1.0)
const HIT_FLASH_SHADER := preload("res://gameplay/presentation/hit_flash.gdshader")
const HIT_FLASH_SECONDS := 0.1
const HITSTOP_SECONDS := 0.045

@export var player: Player
@export var effects_parent: Node2D
@export var camera: Camera2D
@export var damage_number_scene: PackedScene
@export var hit_burst_scene: PackedScene
@export var sword_hit_sound: AudioStream
@export var ability_hit_sound: AudioStream
@export var consecutive_final_hit_sound: AudioStream
@export var player_hurt_sound: AudioStream

var _camera_base_offset := Vector2.ZERO
var _camera_tween: Tween
var _hitstop_active := false
var _last_ability_impact_physics_frame := -1
var _hit_flash_material: ShaderMaterial


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player == null or effects_parent == null or camera == null:
		push_error("CombatFeedbackPresenter requires player, effects parent, and camera references.")
		return
	if damage_number_scene == null or hit_burst_scene == null:
		push_error("CombatFeedbackPresenter requires damage-number and hit-burst scenes.")
		return
	_camera_base_offset = camera.offset
	_hit_flash_material = ShaderMaterial.new()
	_hit_flash_material.shader = HIT_FLASH_SHADER
	_hit_flash_material.set_shader_parameter("flash_amount", 1.0)
	player.attack_component.hit_landed.connect(_on_player_hit_landed)
	player.ability_1_component.hit_landed.connect(_on_player_ability_hit_landed)
	player.ability_2_component.hit_landed.connect(_on_player_ability_hit_landed)
	player.health_component.damaged.connect(_on_player_damaged)


func _on_player_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	_show_hit(target.global_position + Vector2(0.0, -22.0), info, PLAYER_HIT_TINT, 1.5)
	_flash_target(target)
	_request_hitstop()
	_play_sound_at(sword_hit_sound, target.global_position, 1.0)


func _on_player_ability_hit_landed(target: HurtboxComponent, info: DamageInfo) -> void:
	var active_ability := player.get_active_ability_component()
	var is_consecutive_thrust := (
		active_ability != null
		and active_ability.definition != null
		and active_ability.definition.ability_id == &"consecutive_thrust"
	)
	var is_final_consecutive_hit := is_consecutive_thrust and active_ability.is_current_strike_final()
	var consecutive_strike_index := active_ability.get_current_strike_index() if is_consecutive_thrust else -1
	## One thrust can land on several enemies in the same physics tick. Preserve
	## each target's flash/number/burst, but coalesce shared camera, hitstop, and
	## audio work so a clustered hit does not repeatedly rebuild those effects.
	var is_first_impact_this_frame := Engine.get_physics_frames() != _last_ability_impact_physics_frame
	if is_first_impact_this_frame:
		_last_ability_impact_physics_frame = Engine.get_physics_frames()
	if is_consecutive_thrust and not is_final_consecutive_hit:
		## A rapid flurry can land seven contacts in under a second. Its small hits
		## deliberately avoid seven burst instances, flash timers, camera pulses, and
		## hitstops; every other strike keeps a readable damage tick instead.
		if consecutive_strike_index % 2 == 0:
			_show_minor_consecutive_tick(target.global_position + Vector2(0.0, -22.0), info)
			_flash_target(target)
		return
	_show_hit(
		target.global_position + Vector2(0.0, -22.0),
		info,
		PLAYER_HIT_TINT,
		2.8 if is_final_consecutive_hit else 2.5 if is_first_impact_this_frame else 0.0
	)
	_flash_target(target)
	if is_first_impact_this_frame and (not is_consecutive_thrust or is_final_consecutive_hit):
		_request_hitstop()
		if is_final_consecutive_hit:
			_play_sound_at(consecutive_final_hit_sound, target.global_position, 1.0)
		else:
			_play_sound_at(ability_hit_sound if ability_hit_sound != null else sword_hit_sound, target.global_position, 0.96)


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
	if camera_strength > 0.0:
		_pulse_camera(camera_strength)


func _show_minor_consecutive_tick(position: Vector2, info: DamageInfo) -> void:
	var number := damage_number_scene.instantiate() as DamageNumber
	number.global_position = position
	number.configure(info.amount, PLAYER_HIT_TINT)
	effects_parent.add_child(number)


func _pulse_camera(strength: float) -> void:
	if _camera_tween != null and _camera_tween.is_valid():
		_camera_tween.kill()
	camera.offset = _camera_base_offset
	_camera_tween = create_tween()
	_camera_tween.tween_property(camera, "offset", _camera_base_offset + Vector2(strength, 0.0), 0.025)
	_camera_tween.tween_property(camera, "offset", _camera_base_offset + Vector2(-strength, 0.0), 0.04)
	_camera_tween.tween_property(camera, "offset", _camera_base_offset, 0.045)


func _flash_target(target: HurtboxComponent) -> void:
	var actor := target.get_parent()
	if actor == null:
		return
	var body := actor.find_child("Body", true, false) as CanvasItem
	if body == null:
		return
	var original_material := body.material
	body.material = _hit_flash_material
	var timer := get_tree().create_timer(HIT_FLASH_SECONDS, true, false, true)
	timer.timeout.connect(func() -> void:
		if is_instance_valid(body) and body.material == _hit_flash_material:
			body.material = original_material
	)


func _request_hitstop() -> void:
	if _hitstop_active or get_tree().paused:
		return
	_hitstop_active = true
	get_tree().paused = true
	var timer := get_tree().create_timer(HITSTOP_SECONDS, true, false, true)
	timer.timeout.connect(_finish_hitstop)


func _finish_hitstop() -> void:
	if not _hitstop_active:
		return
	_hitstop_active = false
	get_tree().paused = false


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
