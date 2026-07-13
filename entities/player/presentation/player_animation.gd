extends AnimatedSprite2D

var _direction := "down"
var _is_moving := false
var _action_locked := false
var _phase_tween: Tween


func _ready() -> void:
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
	_action_locked = true
	stop()
	animation = "attack_" + _direction
	if _phase_tween != null and _phase_tween.is_valid():
		_phase_tween.kill()
	var first_frame := 0
	match phase:
		1:
			first_frame = 0
		2:
			first_frame = 2
		3:
			first_frame = 4
	frame = first_frame
	frame_progress = 0.0
	_phase_tween = create_tween()
	_phase_tween.tween_interval(maxf(duration_seconds * 0.5, 0.001))
	_phase_tween.tween_callback(func() -> void: frame = mini(first_frame + 1, 5))


func play_dash(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	_action_locked = true
	play("dash_" + _direction)


func resume_locomotion() -> void:
	if _phase_tween != null and _phase_tween.is_valid():
		_phase_tween.kill()
	_action_locked = false
	_play_locomotion()


func play_defeat() -> void:
	_action_locked = true
	stop()


func _play_locomotion() -> void:
	play(("walk_" if _is_moving else "idle_") + _direction)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"
