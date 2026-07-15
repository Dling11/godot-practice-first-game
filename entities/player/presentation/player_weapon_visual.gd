extends Node2D

## Presentation-only grip-anchored weapon. It observes authoritative combat
## phases; the sibling SwordPivot and MeleeHitbox continue to own reach/damage.

@export var weapon: WeaponDefinition
@export var weapon_sprite: Sprite2D
@export var swing_trail: Line2D

var _direction := &"down"
var _action_direction := &"down"
var _action_locked := false
var _pose_tween: Tween
var _trail_tween: Tween


func _ready() -> void:
	if weapon == null or weapon.world_texture == null or weapon_sprite == null:
		push_error("PlayerWeaponVisual requires a weapon with world art and a Sprite2D.")
		visible = false
		return
	weapon_sprite.texture = weapon.world_texture
	weapon_sprite.position = weapon.sprite_offset_from_grip
	weapon_sprite.scale = Vector2.ONE * weapon.world_visual_scale
	if swing_trail != null:
		swing_trail.visible = false
		swing_trail.width = 2.0
	_apply_idle_pose()


func set_facing_direction(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	if not _action_locked:
		_apply_idle_pose()


func play_attack_phase(phase: int, duration_seconds: float) -> void:
	_play_action_phase(phase, duration_seconds, false)


func play_ability_phase(phase: int, duration_seconds: float) -> void:
	_play_action_phase(phase, duration_seconds, true)


func resume_locomotion() -> void:
	_kill_pose_tween()
	_hide_swing_trail()
	_action_locked = false
	_apply_idle_pose()


func play_defeat() -> void:
	_kill_pose_tween()
	_hide_swing_trail()
	_action_locked = true
	z_index = 2
	_pose_tween = create_tween().set_parallel(true)
	_pose_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_pose_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_pose_tween.tween_property(self, "position", position + Vector2(3.0, 9.0), 0.55)
	_pose_tween.tween_property(self, "rotation", rotation + 1.15, 0.55)


func _play_action_phase(phase: int, duration_seconds: float, is_ability: bool) -> void:
	if weapon_sprite == null or not visible:
		return
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		_action_locked = true
		_action_direction = _direction
	_set_depth(_action_direction)
	var forward := _direction_vector(_action_direction)
	var side := Vector2(-forward.y, forward.x)
	var hand_anchor := _hand_anchor(_action_direction)
	var forward_rotation := Vector2.UP.angle_to(forward)
	var wind_up_arc := 1.45 if is_ability else 1.15
	match phase:
		MeleeAttackComponent.Phase.WIND_UP:
			_hide_swing_trail()
			var target_position := (hand_anchor - forward - side * 2.0).round()
			_tween_pose(target_position, forward_rotation - wind_up_arc, duration_seconds)
		MeleeAttackComponent.Phase.ACTIVE:
			var target_position := (hand_anchor + forward * 2.0 + side).round()
			var strike_arc := 1.0 if is_ability else 0.72
			_tween_pose(target_position, forward_rotation + strike_arc, duration_seconds)
			_show_swing_trail(forward_rotation, wind_up_arc, strike_arc, duration_seconds)
		MeleeAttackComponent.Phase.RECOVERY:
			var idle: Transform2D = _idle_transform(_action_direction)
			_tween_pose(idle.origin, idle.get_rotation(), duration_seconds)


func _apply_idle_pose() -> void:
	var idle: Transform2D = _idle_transform(_direction)
	position = idle.origin
	rotation = idle.get_rotation()
	_set_depth(_direction)


func _idle_transform(direction: StringName) -> Transform2D:
	match direction:
		&"left":
			return Transform2D(-1.9, _hand_anchor(direction))
		&"right":
			return Transform2D(1.9, _hand_anchor(direction))
		&"up":
			return Transform2D(-0.35, _hand_anchor(direction))
	return Transform2D(0.45, _hand_anchor(direction))


func _hand_anchor(direction: StringName) -> Vector2:
	match direction:
		&"left":
			return Vector2(-5.0, -13.0)
		&"right":
			return Vector2(5.0, -13.0)
		&"up":
			return Vector2(-5.0, -14.0)
	return Vector2(5.0, -12.0)


func _set_depth(direction: StringName) -> void:
	z_index = -1 if direction == &"up" else 2


func _tween_pose(target_position: Vector2, target_rotation: float, duration_seconds: float) -> void:
	_kill_pose_tween()
	var closest_target := rotation + wrapf(target_rotation - rotation, -PI, PI)
	_pose_tween = create_tween().set_parallel(true)
	_pose_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_pose_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	var duration := maxf(duration_seconds, 0.001)
	_pose_tween.tween_property(self, "position", target_position, duration)
	_pose_tween.tween_property(self, "rotation", closest_target, duration)


func _show_swing_trail(
	forward_rotation: float,
	wind_up_arc: float,
	strike_arc: float,
	duration_seconds: float
) -> void:
	if swing_trail == null:
		return
	if _trail_tween != null and _trail_tween.is_valid():
		_trail_tween.kill()
	var points := PackedVector2Array()
	var center := Vector2(0.0, -13.0)
	var point_count := 7
	for point_index in range(point_count):
		var weight := float(point_index) / float(point_count - 1)
		var angle := lerpf(forward_rotation - wind_up_arc, forward_rotation + strike_arc, weight)
		points.append(center + Vector2.UP.rotated(angle) * weapon.swing_visual_radius)
	swing_trail.points = points
	swing_trail.z_index = -1 if _action_direction == &"up" else 1
	swing_trail.modulate.a = 0.72
	swing_trail.visible = true
	_trail_tween = create_tween()
	_trail_tween.set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_trail_tween.tween_property(
		swing_trail,
		"modulate:a",
		0.0,
		maxf(duration_seconds + 0.06, 0.08)
	).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_trail_tween.tween_callback(swing_trail.hide)


func _hide_swing_trail() -> void:
	if _trail_tween != null and _trail_tween.is_valid():
		_trail_tween.kill()
	if swing_trail != null:
		swing_trail.visible = false
		swing_trail.modulate.a = 1.0


func _kill_pose_tween() -> void:
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()


func _direction_vector(direction: StringName) -> Vector2:
	match direction:
		&"left":
			return Vector2.LEFT
		&"right":
			return Vector2.RIGHT
		&"up":
			return Vector2.UP
	return Vector2.DOWN


func _direction_name(direction: Vector2) -> StringName:
	if absf(direction.x) > absf(direction.y):
		return &"right" if direction.x > 0.0 else &"left"
	return &"down" if direction.y > 0.0 else &"up"
