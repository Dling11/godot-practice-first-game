extends Node2D

const LocomotionTexture = preload("res://assets/characters/enemies/examiner/examiner_locomotion_sheet_192x128.png")
const ThrustTexture = preload("res://assets/characters/enemies/examiner/examiner_thrust_sheet_192x128.png")
const SweepTexture = preload("res://assets/characters/enemies/examiner/examiner_sweep_sheet_192x128.png")
const ZeroIntervalTexture = preload("res://assets/characters/enemies/examiner/examiner_zero_interval_sheet_192x128.png")
const RefutationTexture = preload("res://assets/characters/enemies/examiner/examiner_refutation_sheet_192x128.png")
const ReactionTexture = preload("res://assets/characters/enemies/examiner/examiner_reaction_withdraw_sheet_192x128.png")

@export var body: AnimatedSprite2D
@export var shadow: Polygon2D

var _direction := "down"
var _state := Examiner.State.SPAWNING
var _moving := false
var _base_position := Vector2(0.0, -56.0)
var _tween: Tween


func _ready() -> void:
	body.sprite_frames = _build_frames()
	body.position = _base_position
	body.play(&"idle_down")


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
			_hold("thrust_" + _direction, 4)
		Examiner.State.SWEEP_ACTIVE:
			_play_fit("sweep_" + _direction, duration_seconds)
		Examiner.State.COMBO_RECOVERY:
			_hold("sweep_" + _direction, 3)
		Examiner.State.ZERO_WIND_UP:
			_play_fit("zero_wind_up_" + _direction, duration_seconds)
		Examiner.State.ZERO_TRAVEL:
			_play_fit("zero_travel_" + _direction, duration_seconds)
		Examiner.State.ZERO_RECOVERY:
			_play_fit("zero_recovery_" + _direction, duration_seconds)
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


func _build_frames() -> SpriteFrames:
	var frames := SpriteFrames.new()
	frames.remove_animation(&"default")
	var directions := ["down", "left", "right", "up"]
	for row in range(4):
		var direction: String = directions[row]
		_add_range(frames, "idle_" + direction, LocomotionTexture, 6, row, 0, 2, 3.0, true)
		_add_range(frames, "walk_" + direction, LocomotionTexture, 6, row, 2, 6, 7.0, true)
		_add_range(frames, "thrust_" + direction, ThrustTexture, 6, row, 0, 6, 10.0, false)
		_add_range(frames, "sweep_" + direction, SweepTexture, 6, row, 0, 6, 10.0, false)
		_add_range(frames, "zero_wind_up_" + direction, ZeroIntervalTexture, 5, row, 0, 2, 8.0, false)
		_add_range(frames, "zero_travel_" + direction, ZeroIntervalTexture, 5, row, 1, 4, 12.0, false)
		_add_range(frames, "zero_recovery_" + direction, ZeroIntervalTexture, 5, row, 3, 5, 8.0, false)
		_add_range(frames, "refutation_wind_up_" + direction, RefutationTexture, 5, row, 0, 2, 7.0, false)
		_add_range(frames, "refutation_active_" + direction, RefutationTexture, 5, row, 1, 4, 10.0, false)
		_add_range(frames, "refutation_recovery_" + direction, RefutationTexture, 5, row, 3, 5, 7.0, false)
		_add_range(frames, "hurt_" + direction, ReactionTexture, 6, row, 0, 3, 12.0, false)
		_add_range(frames, "withdrawal_" + direction, ReactionTexture, 6, row, 3, 6, 4.5, false)
		# Axiom composes the clean physical sweep/dash poses. Lane geometry and
		# energy remain separate, so cross-cell weapon fragments are unnecessary.
		_add_range(frames, "axiom_wind_up_" + direction, SweepTexture, 6, row, 0, 3, 7.0, false)
		_add_range(frames, "axiom_cut_one_" + direction, SweepTexture, 6, row, 2, 6, 11.0, false)
		_add_reverse_range(frames, "axiom_cut_two_" + direction, SweepTexture, 6, row, 1, 5, 11.0)
		_add_range(frames, "axiom_dash_" + direction, ZeroIntervalTexture, 5, row, 1, 5, 13.0, false)
		_add_range(frames, "axiom_recovery_" + direction, ReactionTexture, 6, row, 4, 6, 5.0, false)
	return frames


func _add_range(frames: SpriteFrames, name: String, texture: Texture2D, columns: int, row: int, start: int, end: int, speed: float, loop: bool) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, loop)
	for column in range(start, mini(end, columns)):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(column * 192, row * 128, 192, 128)
		frames.add_frame(name, atlas)


func _add_reverse_range(frames: SpriteFrames, name: String, texture: Texture2D, columns: int, row: int, start: int, end: int, speed: float) -> void:
	frames.add_animation(name)
	frames.set_animation_speed(name, speed)
	frames.set_animation_loop(name, false)
	for column in range(mini(end, columns) - 1, start - 1, -1):
		var atlas := AtlasTexture.new()
		atlas.atlas = texture
		atlas.region = Rect2(column * 192, row * 128, 192, 128)
		frames.add_frame(name, atlas)


func _direction_name(direction: Vector2) -> String:
	if absf(direction.x) > absf(direction.y):
		return "right" if direction.x > 0.0 else "left"
	return "down" if direction.y > 0.0 else "up"
