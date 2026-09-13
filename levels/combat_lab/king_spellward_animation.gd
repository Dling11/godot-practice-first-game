extends "res://entities/player/presentation/king_greatsword_animation.gd"

## Opt-in presentation only. Player/StaggerComponent retain all control timing.
func _play_locomotion() -> void:
	var previous := animation
	var previous_count := maxi(1, sprite_frames.get_frame_count(previous))
	var stride_phase := (frame + frame_progress) / previous_count
	super._play_locomotion()
	# Side walks have eight drawings, front/back have four. Preserve cycle phase
	# across a turn rather than wrapping the raw frame number into a shorter clip.
	if previous != animation and String(previous).begins_with("walk_") and String(animation).begins_with("walk_"):
		var next_frame := stride_phase * sprite_frames.get_frame_count(animation)
		set_frame_and_progress(int(next_frame), fposmod(next_frame, 1.0))

func resume_locomotion() -> void:
	var actor := owner as Player
	if actor != null and (actor.is_defeated or actor.is_in_hit_recovery()):
		return
	super.resume_locomotion()

func play_hit_recovery(duration_seconds: float) -> void:
	_kill_recoil_tween()
	_kill_attack_phase_tween()
	speed_scale = 1.0
	_action_direction = _direction
	_action_locked = true
	position = _base_position
	# A longer real stagger gets a held dazed stance; short contacts stay brisk.
	play(("stagger_" if duration_seconds >= .3 else "hurt_") + _action_direction)

func _on_animation_finished() -> void:
	var actor := owner as Player
	if actor != null and (actor.is_defeated or actor.is_in_hit_recovery()):
		return
	super._on_animation_finished()
