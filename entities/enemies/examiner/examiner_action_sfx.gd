class_name ExaminerActionSfx
extends Node

const Thrust = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_thrust.wav")
const Sweep = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_sweep.wav")
const ChargePrepare = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_charge_prepare.wav")
const ChargeDash = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_charge_dash.wav")
const ChargeImpact = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_charge_impact.wav")
const SlamPrepare = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_slam_prepare.wav")
const SlamImpact = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_slam_impact.wav")
const Refutation = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_refutation.wav")
const AxiomPrepare = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_axiom_prepare.wav")
const AxiomCut = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_axiom_cut.wav")
const DescentChime = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_descent_chime.wav")
const DescentLaunch = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_descent_launch.wav")
const DescentCharge = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_descent_charge.wav")
const DescentFall = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_descent_fall.wav")
const DescentImpact = preload("res://assets/audio/sfx/characters/disciples/examiner/examiner_descent_impact.wav")

@export var action_player: AudioStreamPlayer2D
@export var impact_player: AudioStreamPlayer2D


func play_state(state: Examiner.State, _duration_seconds: float) -> void:
	match state:
		Examiner.State.THRUST_ACTIVE:
			_play(action_player, Thrust, -4.0)
		Examiner.State.SWEEP_ACTIVE:
			_play(action_player, Sweep, -3.0)
		Examiner.State.CHARGE_WIND_UP:
			_play(action_player, ChargePrepare, -5.0)
		Examiner.State.CHARGE_TRAVEL:
			_play(action_player, ChargeDash, -2.0)
		Examiner.State.SLAM_WIND_UP:
			_play(action_player, SlamPrepare, -5.0)
		Examiner.State.REFUTATION_ACTIVE:
			_play(action_player, Refutation, -4.0)
		Examiner.State.AXIOM_WIND_UP:
			_play(action_player, AxiomPrepare, -4.0)
		Examiner.State.AXIOM_CUT_ONE, Examiner.State.AXIOM_CUT_TWO, Examiner.State.AXIOM_DASH:
			_play(action_player, AxiomCut, -3.0)
		Examiner.State.PHASE_STANCE:
			_play(action_player, DescentChime, -2.0)
		Examiner.State.DESCENT_LAUNCH:
			_play(action_player, DescentLaunch, -1.0)
		Examiner.State.DESCENT_ABSENT:
			_play(action_player, DescentCharge, -5.0)
		Examiner.State.DESCENT_FALL:
			_play(action_player, DescentFall, -1.0)


func play_impact(kind: StringName, _world_position: Vector2, _direction: Vector2) -> void:
	if kind == &"ground_judgment":
		_play(impact_player, SlamImpact, -1.0)
	elif kind == &"judgment_charge":
		_play(impact_player, ChargeImpact, -2.0)
	elif kind == &"divine_descent":
		_play(impact_player, DescentImpact, 0.0)


func _play(player: AudioStreamPlayer2D, stream: AudioStream, volume_db: float) -> void:
	if player == null:
		return
	player.stream = stream
	player.volume_db = volume_db
	player.pitch_scale = randf_range(0.97, 1.03)
	player.play()
