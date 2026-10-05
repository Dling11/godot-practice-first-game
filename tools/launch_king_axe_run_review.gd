extends "res://tools/launch_king_axe_expanded_review.gd"

const RUN_POSES = preload("res://assets/characters/playable/king/greatsword_confidence_v2/axe_run.tres")
const HorizontalMotion = preload("res://gameplay/movement/weapon_review_horizontal_motion.gd")
const GAME_ITEM = preload("res://data/items/equipment/king_iron_beard_axe.tres")
var horizontal_motion: HorizontalMotion

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — Axe V6 BACK MOUNT (NO SAVES / REWARDS)"
	var feedback := CombatFeedbackPresenter.find_for_player(stage.player)
	if feedback!=null: feedback.hitstop_enabled = false
	horizontal_motion = HorizontalMotion.new()
	horizontal_motion.actor = stage.player
	horizontal_motion.presenter = axe_presenter
	horizontal_motion.running_clip = RUN_POSES
	stage.player.add_child(horizontal_motion)
	var column: VBoxContainer = toolbar.get_child(0)
	(column.get_child(0) as Label).text = "AXE V6 · BACK MOUNT\nA / D: side-facing run, axe at back\nSPACE / click: draw / cut\nTAB: playable practice / Bag\nFive-move combo · NO SAVES"
	_button(column,"Playable practice / Bag [TAB]",open_playable_practice)
	for child in stage.get_children():
		if child is ReviewInput: child.practice = open_playable_practice

func open_playable_practice() -> void:
	await open_playable_practice_with(GAME_ITEM)

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

func toggle_pause() -> void:
	super.toggle_pause()
	if not paused and is_instance_valid(horizontal_motion): horizontal_motion.set_direction(horizontal_motion.direction)

func place_target() -> void:
	if paused: return
	if is_instance_valid(contact_target):
		contact_target.get_parent().remove_child(contact_target)
		contact_target.queue_free()
	contact_target = make_target(stage.player.facing_direction*60)

func spawn_rootling() -> void:
	if paused: return
	var encounter: ReviewEncounter = stage.encounter_controller
	encounter.offsets = [stage.player.facing_direction*100]
	encounter._spawn_enemy(encounter.rootling_scene)
