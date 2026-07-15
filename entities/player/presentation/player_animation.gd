extends AnimatedSprite2D

var _direction := "down"
var _action_direction := "down"
var _is_moving := false
var _action_locked := false
var _base_position: Vector2


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


func _play_action_phase(phase: int, _duration_seconds: float) -> void:
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		_action_direction = _direction
	_action_locked = true
	stop()
	animation = "attack_" + _action_direction
	# The authoritative combat phase chooses the matching body pose. The
	# separately equipped weapon owns the actual swing arc and hit timing.
	frame = clampi(int(phase) - 1, 0, 2)
	var forward := _direction_vector(_action_direction)
	match phase:
		MeleeAttackComponent.Phase.WIND_UP:
			position = (_base_position - forward).round()
		MeleeAttackComponent.Phase.ACTIVE:
			position = (_base_position + forward * 2.0).round()
		MeleeAttackComponent.Phase.RECOVERY:
			position = _base_position


func play_dash(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	_action_locked = true
	position = _base_position
	play("dash_" + _direction)


func play_interaction() -> void:
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	play("interact_" + _action_direction)


func play_hurt(_info: DamageInfo) -> void:
	if _action_locked:
		return
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	play("hurt_" + _action_direction)


func resume_locomotion() -> void:
	_action_locked = false
	position = _base_position
	_play_locomotion()


func play_defeat() -> void:
	_action_locked = true
	position = _base_position
	play("defeat_" + _direction)


func _play_locomotion() -> void:
	play(("walk_" if _is_moving else "idle_") + _direction)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"


func _direction_vector(direction: String) -> Vector2:
	match direction:
		"left":
			return Vector2.LEFT
		"right":
			return Vector2.RIGHT
		"up":
			return Vector2.UP
	return Vector2.DOWN


func _on_animation_finished() -> void:
	if String(animation).begins_with("hurt_"):
		resume_locomotion()
