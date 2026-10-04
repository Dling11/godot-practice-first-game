extends "res://tools/launch_king_greatsword_review.gd"

const CONFIDENT_POSES = preload("res://assets/characters/playable/king/greatsword_confidence_v2/opening.tres")
const PRIDE_POSES = preload("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres")
const RUN_POSES = preload("res://assets/characters/playable/king/greatsword_confidence_v2/greatsword_run.tres")
const HorizontalMotion = preload("res://gameplay/movement/weapon_review_horizontal_motion.gd")
const BladeTrail = preload("res://gameplay/presentation/greatsword_blade_trail.gd")
var horizontal_motion: HorizontalMotion
var _plant_marker: Node2D

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — Greatsword V4 GRIP / SHALLOW PRIDE (NO SAVES / REWARDS)"
	var actor: Player = stage.player
	var attack: MeleeAttackComponent = actor.attack_component
	impact_presenter.mirror_horizontal_landing = true
	attack.weapon.combo.windups[0] = 0.38
	attack.weapon.combo.contacts[0] = 0.16
	attack.weapon.combo.recoveries[0] = 0.32
	attack.weapon.combo.damage_multipliers[0] = 1.25
	attack.weapon.combo.knockback_multipliers[0] = 1.60
	axe_presenter.get_parent().remove_child(axe_presenter)
	axe_presenter.queue_free()
	axe_presenter = Presenter.new()
	assert(axe_presenter.configure(CONFIDENT_POSES,attack))
	assert(axe_presenter.configure_idle(PRIDE_POSES))
	axe_presenter.position = Vector2(0,-16)
	axe_presenter.scale = Vector2.ONE*0.5
	actor.get_node("VisualRoot").add_child(axe_presenter)
	axe_presenter.pose_changed.connect(_idle_plant)
	swing_trail.get_parent().remove_child(swing_trail)
	swing_trail.queue_free()
	swing_trail = BladeTrail.new()
	configure_trail(swing_trail)
	actor.add_child(swing_trail)
	horizontal_motion = HorizontalMotion.new()
	horizontal_motion.actor = actor
	horizontal_motion.presenter = axe_presenter
	horizontal_motion.running_clip = RUN_POSES
	actor.add_child(horizontal_motion)
	var column: VBoxContainer = toolbar.get_child(0)
	(column.get_child(0) as Label).text = "GREATSWORD V4 · GRIP / SHALLOW PRIDE\nA / D: side-facing run\nSPACE / click: cut (one buffered)\n4s AFK: plant tip / crossed arms\nSide directions only · NO SAVES"
	_button(column,"Plant sword / proud idle",proud_idle)
	place_target()

func configure_trail(trail: SwingTrail) -> void:
	super.configure_trail(trail)
	if trail is BladeTrail: trail.meteor_clip = GREAT_POSES.follow_up_clips[1]

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
