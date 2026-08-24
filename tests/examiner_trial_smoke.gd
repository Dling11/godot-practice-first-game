extends SceneTree

const LabScene = preload("res://levels/combat_lab/combat_lab.tscn")


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var lab := LabScene.instantiate()
	root.add_child(lab)
	await process_frame
	await process_frame
	await physics_frame

	if lab.get_live_enemy_count() != 1 or lab._active_enemies.is_empty():
		_fail("Examiner trial did not create its opening actor.")
		return
	var examiner := lab._active_enemies[0] as Examiner
	if examiner == null:
		_fail("Combat Lab opening actor is not the Examiner.")
		return
	if examiner.definition.maximum_health != 1800.0 or examiner.definition.axiom_damage != 38.0 or examiner.definition.ground_judgment_damage != 42.0:
		_fail("Examiner did not receive its data-driven trial tuning.")
		return
	var body := examiner.get_node("Visual/Body") as AnimatedSprite2D
	if not is_equal_approx(body.position.y, -56.0):
		_fail("Examiner lost its normalized visual origin.")
		return
	var expected_frames := {
		&"idle_down": 2,
		&"walk_right": 4,
		&"thrust_down": 5,
		&"thrust_recovery_up": 2,
		&"sweep_wind_up_left": 4,
		&"sweep_strike_right": 3,
		&"charge_wind_up_down": 4,
		&"charge_travel_right": 3,
		&"slam_wind_up_up": 4,
		&"slam_contact_left": 1,
		&"slam_recovery_down": 2,
		&"refutation_active_down": 3,
		&"hurt_up": 3,
		&"withdrawal_left": 3,
		&"axiom_wind_up_up": 3,
		&"axiom_cut_one_down": 4,
		&"axiom_cut_two_right": 4,
		&"axiom_dash_left": 4,
		&"descent_prepare_down": 3,
		&"descent_launch_right": 3,
		&"descent_fall_up": 2,
		&"descent_impact_left": 2,
		&"descent_recovery_down": 3,
	}
	for animation: StringName in expected_frames:
		if not body.sprite_frames.has_animation(animation) or body.sprite_frames.get_frame_count(animation) != expected_frames[animation]:
			_fail("Examiner lost required animation %s." % animation)
			return
		for frame_index in body.sprite_frames.get_frame_count(animation):
			var frame_texture := body.sprite_frames.get_frame_texture(animation, frame_index) as AtlasTexture
			if frame_texture == null or frame_texture.region.size != Vector2(192.0, 128.0):
				_fail("Examiner animation %s lost its exact 192x128 frame grid." % animation)
				return
	if examiner.get_node_or_null("CombatPresentation") == null or examiner.get_node_or_null("ActionSfx") == null:
		_fail("Examiner lost its readable telegraph/VFX or action-audio presenter.")
		return
	if examiner.get_node_or_null("Visual/DivineDescentImpactEyes") == null:
		_fail("Divine Descent lost its brief body-owned impact accent.")
		return
	if not ResourceLoader.exists("res://assets/environment/arenas/divine_order/court_of_first_measure/examiner_divine_descent_circle_512.png"):
		_fail("Divine Descent lost its identity-owned arena seal.")
		return
	if not ResourceLoader.exists("res://assets/audio/music/boss/examiner/examiner_ethereal_vocal_loop.mp3"):
		_fail("Examiner lost its single phase-aware music foundation.")
		return
	var director := lab.get_node("Services/ExaminerEncounterDirector") as ExaminerEncounterDirector
	if director == null or director.get_child_count() == 0:
		_fail("Examiner lost its encounter-owned music lifecycle.")
		return
	var music_players := director.find_children("*", "AudioStreamPlayer", true, false)
	if music_players.size() != 1:
		_fail("Examiner encounter must own exactly one complete music foundation, not overlapping songs.")
		return
	director.bind(examiner)
	director.bind(examiner)
	if director.find_children("*", "AudioStreamPlayer", true, false).size() != 1:
		_fail("Repeated Examiner binding duplicated the encounter music player.")
		return
	if examiner.get_node_or_null("SlamHitbox") == null:
		_fail("Ground Judgment lost its authoritative radial hitbox.")
		return

	await create_timer(examiner.definition.spawn_seconds + 0.05).timeout
	examiner._enter(Examiner.State.APPROACH, 0.0)
	examiner._axiom_cooldown = 99.0
	examiner._charge_cooldown = 99.0
	examiner._slam_cooldown = 99.0
	examiner._refutation_cooldown = 99.0
	examiner.global_position = Vector2(320.0, 220.0)
	examiner.target.global_position = Vector2(620.0, 220.0)
	examiner.velocity = Vector2(-80.0, 0.0)
	examiner._process_approach(0.016)
	if examiner.facing_direction.x >= 0.0:
		_fail("Examiner facing followed desired input instead of his actual travel velocity.")
		return
	examiner.velocity = Vector2.ZERO
	var charge_offset := examiner.target.global_position - examiner.global_position
	examiner._begin_judgment_charge(charge_offset)
	if examiner.state != Examiner.State.CHARGE_WIND_UP or examiner.judgment_charge_endpoint().is_equal_approx(examiner.global_position):
		_fail("Judgment Charge did not snapshot a real, telegraphed travel lane.")
		return
	examiner._state_remaining = 0.0
	examiner._tick_state(0.0)
	if examiner.state != Examiner.State.CHARGE_TRAVEL:
		_fail("Judgment Charge warning did not resolve into its physical dash state.")
		return
	examiner.dash_hitbox.deactivate()
	examiner._enter(Examiner.State.APPROACH, 0.0)
	examiner._begin_ground_judgment(charge_offset)
	if examiner.state != Examiner.State.SLAM_WIND_UP:
		_fail("Ground Judgment did not expose its dedicated anticipation state.")
		return
	examiner._state_remaining = 0.0
	examiner._tick_state(0.0)
	if examiner.state != Examiner.State.SLAM_ACTIVE:
		_fail("Ground Judgment did not synchronize damage with the contact pose.")
		return
	examiner.slam_hitbox.deactivate()
	examiner._enter(Examiner.State.APPROACH, 0.0)
	var effects_before_axiom: int = lab.effects.get_child_count()
	examiner._axiom_cooldown = 0.0
	examiner._physics_process(0.016)
	if examiner.state != Examiner.State.AXIOM_WIND_UP:
		_fail("Examiner did not enter Axiom Divide when the signature became ready.")
		return
	if lab.effects.get_child_count() != effects_before_axiom + 3:
		_fail("Axiom Divide did not create three independent readable lane warnings.")
		return
	if examiner.health_component.is_invulnerable:
		_fail("Axiom Divide incorrectly made the Examiner invulnerable.")
		return

	examiner._enter(Examiner.State.APPROACH, 0.0)
	if not director.force_divine_descent() or examiner.state != Examiner.State.PHASE_STANCE or not examiner.health_component.is_invulnerable:
		_fail("Examiner phase threshold did not create a safe cinematic hold.")
		return
	if director.force_divine_descent():
		_fail("Repeated force-phase input restarted an active Divine Descent transition.")
		return
	if not lab.player.is_cinematic_locked():
		_fail("Phase dialogue did not temporarily lock King before the launch.")
		return
	await create_timer(0.50).timeout
	var dialogue := lab.get_node("UI/DialoguePanel") as DialoguePanel
	if not dialogue.visible:
		_fail("Examiner phase transition did not present its short calm dialogue.")
		return
	dialogue.close_dialogue(true)
	await create_timer(0.30).timeout
	if examiner.state != Examiner.State.DESCENT_PREPARE:
		_fail("Dialogue completion did not begin authored Divine Descent preparation.")
		return
	examiner._state_remaining = 0.0
	examiner._process_divine_descent(0.0)
	if examiner.state != Examiner.State.DESCENT_LAUNCH:
		_fail("Divine Descent preparation did not enter its launch movement.")
		return
	if Examiner.DESCENT_LAUNCH_SECONDS > 0.18 or examiner._descent_destination.y > examiner.arena_bounds.position.y - 128.0:
		_fail("Divine Descent launch is no longer an immediate complete offscreen exit.")
		return
	examiner._state_remaining = 0.0
	examiner._process_divine_descent(0.0)
	if examiner.state != Examiner.State.DESCENT_ABSENT or examiner.visible:
		_fail("Divine Descent did not leave a real player-controlled cover window.")
		return
	if Examiner.DESCENT_FALL_SECONDS > 0.16:
		_fail("Divine Descent meteor fall became floaty again.")
		return
	var pylon: Vector2 = lab.court_arena.protection_points()[0]
	if not lab.court_arena.is_position_protected(pylon) or lab.court_arena.is_position_protected(Vector2(365.0, 287.0)):
		_fail("Court protection geometry does not match the four visible pylons.")
		return
	lab.set_player_invincible(false)
	lab.player.health_component.set_current_health(lab.player.health_component.maximum_health)
	lab.player.global_position = pylon
	var protected_health: float = lab.player.health_component.current_health
	if not lab.court_arena.resolve_divine_descent(lab.player, 260.0, examiner) or not is_equal_approx(lab.player.health_component.current_health, protected_health):
		_fail("A correctly occupied pylon zone did not fully protect King.")
		return
	lab.player.global_position = Vector2(365.0, 287.0)
	if lab.court_arena.resolve_divine_descent(lab.player, 260.0, examiner) or lab.player.health_component.current_health >= protected_health:
		_fail("An exposed King did not receive finite Divine Descent damage.")
		return

	await create_timer(0.80).timeout
	lab.queue_free()
	await process_frame
	await process_frame
	print("Examiner physical attacks, facing, Divine Descent phases, exact pylon cover, finite damage, presentation/audio, court, and Axiom lanes passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
