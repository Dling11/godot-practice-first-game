extends "res://tools/launch_king_greatsword_review.gd"

const PRIDE_POSES = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const RUN_POSES = preload("res://assets/characters/playable/king/greatsword_readability/side/run.tres")
const RETURN_POSES = preload("res://assets/characters/playable/king/greatsword_oathbound/side/return.tres")
const GAME_COMBO = preload("res://data/weapons/families/royal_greatsword/combo.tres")
const GAME_POSES = preload("res://data/weapons/families/royal_greatsword/poses.tres")
const GAME_ITEM = preload("res://data/items/equipment/king_royal_greatsword.tres")
const HorizontalMotion = preload("res://gameplay/movement/weapon_review_horizontal_motion.gd")
const BladeTrail = preload("res://gameplay/presentation/greatsword_blade_trail.gd")
const ReturnFollowThrough = preload("res://gameplay/presentation/weapon_return_follow_through.gd")
var horizontal_motion: HorizontalMotion
var _plant_marker: Node2D
var reviewed_poses: Resource

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — Greatsword OATHBOUND FIVE-CUT COMBO (NO SAVES / REWARDS)"
	var actor: Player = stage.player
	var attack: MeleeAttackComponent = actor.attack_component
	impact_presenter.mirror_horizontal_landing = true
	# Same immutable production chain; only the fixture/input/rewards differ.
	attack.weapon.combo = GAME_COMBO.duplicate(true)
	_continuation.wait_time = 1.0/120.0
	step_motion.step_distances.append(8)
	move_names = PackedStringArray(NAMES)
	move_names.append("Low return · forward hit, rear follow-through")
	move_sounds = PackedInt32Array([0,1,2,2,1])
	reviewed_poses = GAME_POSES.duplicate(false)
	axe_presenter.get_parent().remove_child(axe_presenter)
	axe_presenter.queue_free()
	axe_presenter = Presenter.new()
	axe_presenter.continuation_requested = has_queued_cut
	axe_presenter.continuation_pending = has_pending_cut
	assert(axe_presenter.configure(reviewed_poses,attack))
	assert(axe_presenter.configure_idle(PRIDE_POSES))
	axe_presenter.position = Vector2(0,-16)
	axe_presenter.scale = Vector2.ONE*0.5
	actor.get_node("VisualRoot").add_child(axe_presenter)
	impact_presenter.ground_position_provider = func() -> Vector2:
		return actor.to_local(axe_presenter.get_parent().to_global(axe_presenter.get_contact_tip_in_parent()))
	axe_presenter.pose_changed.connect(_idle_plant)
	swing_trail.get_parent().remove_child(swing_trail)
	swing_trail.queue_free()
	swing_trail = BladeTrail.new()
	configure_trail(swing_trail)
	actor.add_child(swing_trail)
	install_return_follow_through(axe_presenter)
	horizontal_motion = HorizontalMotion.new()
	horizontal_motion.actor = actor
	horizontal_motion.presenter = axe_presenter
	horizontal_motion.running_clip = RUN_POSES
	actor.add_child(horizontal_motion)
	var column: VBoxContainer = toolbar.get_child(0)
	(column.get_child(0) as Label).text = "GREATSWORD · OATHBOUND FIVE-CUT COMBO\nA / D: side-facing run\nSPACE / click: cut (one buffered)\nTAB: playable practice / Bag\nNew motion / same King / 3.00s · NO SAVES"
	(column.get_child(3) as Button).text = "Play five-move combo"
	(column.get_child(6) as Button).text = "Place three-target front"
	_button(column,"Plant sword / proud idle",proud_idle)
	_button(column,"Try return slash",try_return_slash)
	_button(column,"Try linked 4 → 5",try_linked_return)
	_button(column,"Playable practice / Bag [TAB]",open_playable_practice)
	for child in stage.get_children():
		if child is ReviewInput:
			child.practice = open_playable_practice
	place_target()

func open_playable_practice() -> void:
	await open_playable_practice_with(GAME_ITEM)

func has_queued_cut() -> bool:
	return is_instance_valid(_continuation) and not _continuation.is_stopped()

func install_return_follow_through(body: Node2D) -> void:
	var follow := ReturnFollowThrough.new()
	follow.presenter = body
	follow.attack = stage.player.attack_component
	follow.return_clip = RETURN_POSES
	follow.atlas = GREAT_SWING
	body.add_child(follow)

func has_pending_cut() -> bool:
	return _auto_cuts_left>0 or _queued_cut or has_queued_cut()

func try_linked_return() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	_continuation.stop()
	_queued_cut = false
	_auto_cuts_left = 1
	stage.player.attack_component._next_combo_step = 3
	place_target()
	strike()

func play_combo() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE or not _continuation.is_stopped(): return
	stage.player.attack_component.reset_combo()
	_auto_cuts_left = 4
	strike()

func configure_trail(trail: SwingTrail) -> void:
	super.configure_trail(trail)
	if trail is BladeTrail:
		trail.pose_presenter = axe_presenter
		trail.modulate.a = .85
	# This is a new chronological cut, not reversed fourth contact playback.
	trail.reverse_steps = PackedByteArray([0,0,0,0,0])
	if trail is BladeTrail:
		trail.meteor_clip = GREAT_POSES.follow_up_clips[1]

func try_return_slash() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	_continuation.stop()
	_auto_cuts_left = 0
	_queued_cut = false
	stage.player.attack_component._next_combo_step = 4
	place_target()
	strike()

func strike() -> void:
	if paused: return
	var attack: MeleeAttackComponent = stage.player.attack_component
	if attack.phase!=MeleeAttackComponent.Phase.IDLE or axe_presenter._drawing:
		_queued_cut = true
		return
	horizontal_motion.stop_and_clear()
	if axe_presenter._resting and axe_presenter.retrieve_from_rest(strike): return
	attack.request_attack(stage.player.facing_direction)

func cancel_combo() -> void:
	if is_instance_valid(horizontal_motion): horizontal_motion.stop_and_clear()
	super.cancel_combo()
	if is_instance_valid(axe_presenter): axe_presenter.cancel_presentation_transition()

func proud_idle() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	horizontal_motion.stop_and_clear()
	_continuation.stop()
	_auto_cuts_left = 0
	_queued_cut = false
	axe_presenter.cancel_presentation_transition()
	axe_presenter._rest_timer.stop()
	axe_presenter._rest()

func _idle_plant(pose: int) -> void:
	if axe_presenter.definition!=PRIDE_POSES or axe_presenter._drawing or pose<5:
		if is_instance_valid(_plant_marker):
			_plant_marker.get_parent().remove_child(_plant_marker)
			_plant_marker.queue_free()
	if pose!=5 or axe_presenter.definition!=PRIDE_POSES or not axe_presenter._resting or axe_presenter._drawing: return
	var point := axe_presenter.get_plant_ground_position()*0.5+Vector2(0,-16)
	point.x *= -1 if axe_presenter.scale.x<0 else 1
	impact_presenter._spawn(1,point,0.28,0.24)
	_plant_marker = ImpactPresenter.Burst.new()
	_plant_marker.atlas = IMPACT_ART
	_plant_marker.row = 1
	_plant_marker.frame = 3
	_plant_marker.animate = false
	_plant_marker.position = point
	_plant_marker.scale = Vector2.ONE*0.18
	stage.player.add_child(_plant_marker)

func place_target() -> void:
	if not is_instance_valid(horizontal_motion):
		super.place_target()
		return
	if paused: return
	if is_instance_valid(contact_target):
		contact_target.get_parent().remove_child(contact_target)
		contact_target.queue_free()
	contact_target = make_target(stage.player.facing_direction*88)

func toggle_pause() -> void:
	super.toggle_pause()
	if not paused and is_instance_valid(horizontal_motion): horizontal_motion.set_direction(horizontal_motion.direction)

func place_crowd() -> void:
	if paused: return
	for target in extra_targets:
		if is_instance_valid(target):
			target.get_parent().remove_child(target)
			target.queue_free()
	extra_targets.clear()
	var facing: float = stage.player.facing_direction.x
	for offset in [Vector2(72*facing,-24),Vector2(72*facing,24)]: extra_targets.append(make_target(offset))

func spawn_rootling() -> void:
	if paused: return
	var encounter: ReviewEncounter = stage.encounter_controller
	encounter.offsets = [stage.player.facing_direction*100]
	encounter._spawn_enemy(encounter.rootling_scene)
