extends AnimatedSprite2D

var _direction := "down"
var _action_direction := "down"
var _is_moving := false
var _action_locked := false
var _base_position: Vector2
var _attack_phase_tween: Tween


func _ready() -> void:
	_base_position = position
	animation_finished.connect(_on_animation_finished)
	_play_locomotion()


func set_facing_direction(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	if not _action_locked:
		_play_locomotion()


func set_movement(_direction_vector: Vector2, is_moving: bool) -> void:
	if _is_moving == is_moving:
		return
	_is_moving = is_moving
	if not _action_locked:
		_play_locomotion()


func play_attack_phase(phase: MeleeAttackComponent.Phase, duration_seconds: float) -> void:
	_play_action_phase(phase, duration_seconds)


func play_ability_phase(phase: AbilityComponent.Phase, duration_seconds: float) -> void:
	_play_action_phase(phase, duration_seconds)


func _play_action_phase(phase: int, duration_seconds: float) -> void:
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		_action_direction = _direction
	_action_locked = true
	_kill_attack_phase_tween()
	stop()
	animation = "attack_" + _action_direction
	var phase_index := clampi(int(phase) - 1, 0, 2)
	var attack_frame_count := sprite_frames.get_frame_count(animation)
	if attack_frame_count >= 6:
		# King's six-frame proof spends two readable body frames on each
		# authoritative combat phase: anticipation, contact, then recovery.
		var first_frame := phase_index * 2
		var last_frame := first_frame + 1
		frame = first_frame
		_attack_phase_tween = create_tween()
		_attack_phase_tween.set_trans(Tween.TRANS_LINEAR)
		_attack_phase_tween.tween_method(_set_attack_frame, float(first_frame), float(last_frame), maxf(duration_seconds, 0.01))
	else:
		# Existing three-frame characters keep their one-pose-per-phase contract.
		frame = clampi(phase_index, 0, attack_frame_count - 1)
	position = _base_position


func play_dash(direction: Vector2) -> void:
	_kill_attack_phase_tween()
	_direction = _direction_name(direction)
	_action_locked = true
	position = _base_position
	play("dash_" + _direction)


func play_interaction() -> void:
	_kill_attack_phase_tween()
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	play("interact_" + _action_direction)


func play_hurt(_info: DamageInfo) -> void:
	if _action_locked:
		return
	_kill_attack_phase_tween()
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	play("hurt_" + _action_direction)


func resume_locomotion() -> void:
	_kill_attack_phase_tween()
	_action_locked = false
	position = _base_position
	_play_locomotion()


func play_defeat() -> void:
	_kill_attack_phase_tween()
	_action_locked = true
	position = _base_position
	play("defeat_" + _direction)


func _play_locomotion() -> void:
	play(("walk_" if _is_moving else "idle_") + _direction)


func _set_attack_frame(value: float) -> void:
	# Round at the phase midpoint so both authored poses receive visible time.
	# Flooring held on 0/2/4 until the final instant and made the slash teleport.
	frame = clampi(roundi(value), 0, 5)


func _kill_attack_phase_tween() -> void:
	if _attack_phase_tween != null and _attack_phase_tween.is_valid():
		_attack_phase_tween.kill()
	_attack_phase_tween = null


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"


func _on_animation_finished() -> void:
	if String(animation).begins_with("hurt_"):
		resume_locomotion()
