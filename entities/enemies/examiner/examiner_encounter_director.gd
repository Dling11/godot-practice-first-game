class_name ExaminerEncounterDirector
extends Node

const ExaminerTheme = preload("res://assets/audio/music/boss/examiner/examiner_ethereal_vocal_loop.mp3")

@export var player: Player
@export var camera: Camera2D
@export var arena: CourtOfFirstMeasure
@export var dialogue: DialoguePanel
@export var combat_hud: CombatHUD

var examiner: Examiner
var _transition_running := false
var _camera_home := Vector2.ZERO
var _music_player: AudioStreamPlayer
var _music_tween: Tween
var _silence_timer: Timer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_camera_home = camera.position if camera != null else Vector2.ZERO
	_music_player = _make_music_player(ExaminerTheme, -14.0)
	_silence_timer = Timer.new()
	_silence_timer.one_shot = true
	_silence_timer.process_callback = Timer.TIMER_PROCESS_IDLE
	_silence_timer.process_mode = Node.PROCESS_MODE_ALWAYS
	_silence_timer.timeout.connect(_on_impact_silence)
	add_child(_silence_timer)
	if dialogue != null:
		dialogue.dialogue_closed.connect(_on_dialogue_closed)


func bind(next_examiner: Examiner) -> void:
	if examiner != null and is_instance_valid(examiner):
		_stop_theme()
		_disconnect_examiner()
	examiner = next_examiner
	_transition_running = false
	if examiner == null:
		_stop_theme()
		return
	examiner.phase_transition_requested.connect(_on_phase_transition_requested)
	examiner.divine_descent_launched.connect(_on_divine_descent_launched)
	examiner.divine_descent_impact.connect(_on_divine_descent_impact)
	examiner.phase_two_started.connect(_on_phase_two_started)
	examiner.tree_exited.connect(_on_examiner_exited)
	_start_theme()


func force_divine_descent() -> bool:
	return examiner != null and is_instance_valid(examiner) and examiner.request_phase_transition()


func _on_phase_transition_requested() -> void:
	if _transition_running or examiner == null:
		return
	_transition_running = true
	player.set_cinematic_locked(true)
	_duck_for_dialogue()
	var focus_offset := examiner.global_position - player.global_position + Vector2(0.0, -24.0)
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "position", focus_offset, 0.42).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	await tween.finished
	if examiner == null or not is_instance_valid(examiner):
		return
	dialogue.show_dialogue("THE EXAMINER", ["Interesting.", "Then let us continue."])


func _on_dialogue_closed(_completed: bool) -> void:
	if not _transition_running or examiner == null or not is_instance_valid(examiner):
		return
	var tween := create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	tween.tween_property(camera, "position", _camera_home, 0.24).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	if examiner != null and is_instance_valid(examiner):
		_tween_theme(-9.5, 0.24)
		examiner.begin_divine_descent()


func _on_divine_descent_launched(charge_seconds: float) -> void:
	arena.begin_divine_descent_charge(charge_seconds)
	player.set_cinematic_locked(false)
	_tween_theme(-12.0, 0.32)
	_silence_timer.start(maxf(charge_seconds - 0.10, 0.05))
	if combat_hud != null:
		combat_hud.show_story_message("DIVINE DESCENT  |  SEEK THE FOUR PYLONS", charge_seconds - 0.25)


func _on_divine_descent_impact(world_position: Vector2) -> void:
	# Leave the foundation nearly absent at contact so the dedicated landing
	# body pose and impact SFX carry the weight without a competing song.
	_tween_theme(-28.0, 0.06)
	var protected := arena.resolve_divine_descent(player, 260.0, examiner)
	if combat_hud != null:
		combat_hud.show_story_message("PYLON MEASURE: PROTECTED" if protected else "DIVINE DESCENT: EXPOSED", 1.35)
	var feedback := get_tree().current_scene.find_child("CombatFeedback", true, false) if get_tree().current_scene != null else null
	if feedback != null and feedback.has_method("request_camera_pulse"):
		feedback.request_camera_pulse(8.0)
	# The actor owns the visible body impact; the arena owns the exact damage.
	if examiner != null:
		examiner.global_position = world_position


func _on_impact_silence() -> void:
	if examiner == null or not is_instance_valid(examiner):
		return
	_tween_theme(-42.0, 0.07)


func _on_phase_two_started() -> void:
	_transition_running = false
	_tween_theme(-10.0, 0.72)
	if combat_hud != null:
		combat_hud.show_story_message("SECOND MEASURE", 1.8)


func _make_music_player(stream: AudioStream, volume_db: float) -> AudioStreamPlayer:
	var audio := AudioStreamPlayer.new()
	audio.process_mode = Node.PROCESS_MODE_ALWAYS
	audio.bus = &"Music"
	audio.stream = stream
	audio.volume_db = volume_db
	if stream is AudioStreamMP3:
		(stream as AudioStreamMP3).loop = true
	add_child(audio)
	return audio


func _start_theme() -> void:
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.call("stop_music")
	if DisplayServer.get_name() == "headless":
		return
	_music_player.volume_db = -14.0
	_music_player.play()


func _duck_for_dialogue() -> void:
	_tween_theme(-22.0, 0.28)


func _tween_theme(volume_db: float, duration: float) -> void:
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	_music_tween = create_tween().set_pause_mode(Tween.TWEEN_PAUSE_PROCESS)
	_music_tween.tween_property(_music_player, "volume_db", volume_db, duration)


func _stop_theme() -> void:
	if _silence_timer != null:
		_silence_timer.stop()
	if _music_tween != null and _music_tween.is_valid():
		_music_tween.kill()
	if _music_player != null:
		_music_player.stop()


func _disconnect_examiner() -> void:
	if examiner.phase_transition_requested.is_connected(_on_phase_transition_requested):
		examiner.phase_transition_requested.disconnect(_on_phase_transition_requested)
	if examiner.divine_descent_launched.is_connected(_on_divine_descent_launched):
		examiner.divine_descent_launched.disconnect(_on_divine_descent_launched)
	if examiner.divine_descent_impact.is_connected(_on_divine_descent_impact):
		examiner.divine_descent_impact.disconnect(_on_divine_descent_impact)
	if examiner.phase_two_started.is_connected(_on_phase_two_started):
		examiner.phase_two_started.disconnect(_on_phase_two_started)
	if examiner.tree_exited.is_connected(_on_examiner_exited):
		examiner.tree_exited.disconnect(_on_examiner_exited)


func _on_examiner_exited() -> void:
	player.set_cinematic_locked(false)
	camera.position = _camera_home
	_stop_theme()
	examiner = null
