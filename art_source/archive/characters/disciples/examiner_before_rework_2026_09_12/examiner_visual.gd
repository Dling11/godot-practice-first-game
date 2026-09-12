extends Node2D

@export var body: AnimatedSprite2D
@export var shadow: Polygon2D

var _direction := "down"
var _state := Examiner.State.SPAWNING
var _moving := false
var _base_position := Vector2(0.0, -56.0)
var _tween: Tween
var _impact_tween: Tween
var _impact_eyes: Node2D


func _ready() -> void:
	body.position = _base_position
	body.play(&"idle_down")
	_impact_eyes = _build_impact_eyes()


func set_facing(direction: Vector2) -> void:
	_direction = _direction_name(direction)
	_restore()


func set_moving(value: bool) -> void:
	_moving = value
	if _state == Examiner.State.APPROACH:
		_restore()


func play_state(state: Examiner.State, duration_seconds: float) -> void:
	_state = state
	if _tween != null and _tween.is_valid():
		_tween.kill()
	if _impact_tween != null and _impact_tween.is_valid():
		_impact_tween.kill()
	if _impact_eyes != null:
		_impact_eyes.visible = false
	body.position = _base_position
	body.modulate = Color.WHITE
	match state:
		Examiner.State.SPAWNING:
			body.play("idle_down")
			body.modulate.a = 0.0
			_tween = create_tween()
			_tween.tween_property(body, "modulate:a", 1.0, duration_seconds)
		Examiner.State.APPROACH:
			_restore()
		Examiner.State.COMBO_WIND_UP:
			_play_fit("thrust_" + _direction, duration_seconds)
		Examiner.State.THRUST_ACTIVE:
			_hold("thrust_" + _direction, 3)
		Examiner.State.COMBO_GAP:
			_play_fit("thrust_recovery_" + _direction, duration_seconds)
		Examiner.State.SWEEP_WIND_UP:
			_play_fit("sweep_wind_up_" + _direction, duration_seconds)
		Examiner.State.SWEEP_ACTIVE:
			_play_fit("sweep_strike_" + _direction, duration_seconds)
		Examiner.State.COMBO_RECOVERY:
			_play_fit("sweep_recovery_" + _direction, duration_seconds)
		Examiner.State.CHARGE_WIND_UP:
			_play_fit("charge_wind_up_" + _direction, duration_seconds)
		Examiner.State.CHARGE_TRAVEL:
			_play_fit("charge_travel_" + _direction, duration_seconds)
		Examiner.State.CHARGE_IMPACT:
			_hold("charge_travel_" + _direction, 2)
		Examiner.State.CHARGE_RECOVERY:
			_play_fit("charge_recovery_" + _direction, duration_seconds)
		Examiner.State.SLAM_WIND_UP:
			_play_fit("slam_wind_up_" + _direction, duration_seconds)
		Examiner.State.SLAM_ACTIVE:
			_hold("slam_contact_" + _direction, 0)
		Examiner.State.SLAM_RECOVERY:
			_play_fit("slam_recovery_" + _direction, duration_seconds)
		Examiner.State.REFUTATION_WIND_UP:
			_play_fit("refutation_wind_up_" + _direction, duration_seconds)
		Examiner.State.REFUTATION_ACTIVE:
			_play_fit("refutation_active_" + _direction, duration_seconds)
		Examiner.State.REFUTATION_RECOVERY:
			_play_fit("refutation_recovery_" + _direction, duration_seconds)
		Examiner.State.AXIOM_WIND_UP:
			_play_fit("axiom_wind_up_" + _direction, duration_seconds)
		Examiner.State.AXIOM_CUT_ONE:
			_play_fit("axiom_cut_one_" + _direction, duration_seconds)
		Examiner.State.AXIOM_CUT_TWO:
			_play_fit("axiom_cut_two_" + _direction, duration_seconds)
		Examiner.State.AXIOM_DASH:
			_play_fit("axiom_dash_" + _direction, duration_seconds)
		Examiner.State.AXIOM_RECOVERY:
			_play_fit("axiom_recovery_" + _direction, duration_seconds)
		Examiner.State.PHASE_STANCE:
			body.play("idle_" + _direction)
		Examiner.State.DESCENT_PREPARE:
			_play_fit("descent_prepare_" + _direction, duration_seconds)
		Examiner.State.DESCENT_LAUNCH:
			_play_fit("descent_launch_" + _direction, duration_seconds)
		Examiner.State.DESCENT_ABSENT:
			_hold("descent_launch_" + _direction, 3)
		Examiner.State.DESCENT_FALL:
			_play_fit("descent_fall_" + _direction, duration_seconds)
		Examiner.State.DESCENT_IMPACT:
			_hold("descent_impact_" + _direction, 0)
			_play_divine_descent_impact_accent()
		Examiner.State.DESCENT_RECOVERY:
			_play_fit("descent_recovery_" + _direction, duration_seconds)
		Examiner.State.WITHDRAWAL:
			_play_fit("withdrawal_" + _direction, duration_seconds)
			_tween = create_tween()
			_tween.tween_interval(maxf(duration_seconds - 0.55, 0.05))
			_tween.tween_property(body, "modulate:a", 0.0, 0.55)


func play_hurt(_info: DamageInfo) -> void:
	if _state != Examiner.State.APPROACH:
		return
	_play_fit("hurt_" + _direction, 0.18)


func play_refutation_flash() -> void:
	if _tween != null and _tween.is_valid():
		_tween.kill()
	body.modulate = Color(1.35, 1.22, 0.72, 1.0)
	_tween = create_tween()
	_tween.tween_property(body, "modulate", Color.WHITE, 0.18)


func _restore() -> void:
	if _state == Examiner.State.APPROACH:
		body.speed_scale = 1.0
		body.play(("walk_" if _moving else "idle_") + _direction)


func _play_fit(animation: String, duration_seconds: float) -> void:
	body.speed_scale = 1.0
	var frames := body.sprite_frames
	var count := frames.get_frame_count(animation)
	if duration_seconds > 0.0 and count > 0:
		var authored := float(count) / maxf(frames.get_animation_speed(animation), 0.01)
		body.speed_scale = authored / maxf(duration_seconds, 0.01)
	body.play(animation)


func _hold(animation: String, frame_index: int) -> void:
	body.speed_scale = 1.0
	body.play(animation)
	body.set_frame_and_progress(mini(frame_index, body.sprite_frames.get_frame_count(animation) - 1), 0.0)
	body.pause()


func _build_impact_eyes() -> Node2D:
	var accent := Node2D.new()
	accent.name = "DivineDescentImpactEyes"
	accent.position = Vector2(0.0, -68.0)
	accent.z_index = 30
	accent.visible = false
	for x in [-3.5, 3.5]:
		var eye := Polygon2D.new()
		eye.polygon = PackedVector2Array([Vector2(-2.0, -1.0), Vector2(2.0, -1.0), Vector2(1.0, 1.0), Vector2(-1.0, 1.0)])
		eye.position = Vector2(x, 0.0)
		eye.color = Color(1.0, 0.08, 0.025, 1.0)
		accent.add_child(eye)
	add_child(accent)
	return accent


func _play_divine_descent_impact_accent() -> void:
	# One ~three-frame anime accent: the existing landing silhouette goes
	# black, the eyes cut red, and then the authored ivory/gold body returns.
	body.modulate = Color(0.018, 0.012, 0.022, 1.0)
	_impact_eyes.visible = true
	_impact_tween = create_tween()
	_impact_tween.tween_interval(0.055)
	_impact_tween.tween_callback(func() -> void:
		body.modulate = Color.WHITE
		_impact_eyes.visible = false
	)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"
