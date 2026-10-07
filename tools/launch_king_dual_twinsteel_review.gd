extends "res://tools/launch_enemy_arrival_review.gd"

## One isolated prototype rig. Real melee/collision, no rewards or saved gear.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const CardinalMotion = preload("res://gameplay/movement/weapon_review_cardinal_motion.gd")
const StepMotion = preload("res://gameplay/movement/melee_step_motion.gd")
const Trail = preload("res://gameplay/presentation/axe_swing_trail.gd")
const WEAPON = preload("res://data/weapons/families/twinsteel_prototype/weapon.tres")
const POSES = preload("res://assets/characters/playable/king/dual_twinsteel/descending.tres")
const IDLE = preload("res://assets/characters/playable/king/dual_twinsteel/idle.tres")
const PROFILE = preload("res://data/weapons/families/twinsteel_prototype/presentation.tres")
const TARGET = preload("res://entities/training/training_target.tscn")
const LABELS := ["Double thrust","Crosscut","Return cut","Hop spin","Springing X"]
var presenter: Presenter
var cardinal_motion: CardinalMotion
var step_motion: StepMotion
var trail: Trail
var status: Label
var targets: Array[Node2D] = []
var contacts := 0
var queued := false
var auto_left := 0
var continuation_scheduled := false
var continuation_generation := 0
var control_column: VBoxContainer
var input_controller: ReviewInput

class ReviewInput extends Node:
	var owner_review: SceneTree
	func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo:
			match event.keycode:
				KEY_ESCAPE: owner_review.toggle_pause()
				KEY_TAB: owner_review.toggle_controls()
				KEY_SPACE: owner_review.strike()
				KEY_G: owner_review.play_combo()
				_: return
			get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.pressed and event.button_index==MOUSE_BUTTON_LEFT:
			owner_review.strike()
			get_viewport().set_input_as_handled()

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_twinsteel_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await open_review()

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — TWINSTEEL / CLOSER SIDE HILTS (NO SAVES / REWARDS)"
	_visit(Vector2(768,500))
	var actor: Player = stage.player
	var attack: MeleeAttackComponent = actor.attack_component
	actor.set_physics_process(false)
	actor.set_process_unhandled_input(false)
	stage.set_process_unhandled_input(false)
	stage.character_menu.set_process_input(false)
	stage.get_node("UI").hide()
	actor.velocity = Vector2.ZERO
	actor.facing_direction = Vector2.RIGHT
	attack.cancel_attack()
	assert(actor.set_weapon_definition(WEAPON))
	var old_effects := actor.get_node("GreatswordEffects")
	if attack.phase_changed.is_connected(old_effects._on_attack_phase): attack.phase_changed.disconnect(old_effects._on_attack_phase)
	old_effects.hide()
	actor.get_node("VisualRoot/Body").hide()
	var feedback := CombatFeedbackPresenter.find_for_player(actor)
	if feedback!=null: feedback.hitstop_enabled = false
	presenter = Presenter.new()
	presenter.continuation_requested = has_pending_cut
	presenter.continuation_pending = has_pending_cut
	assert(presenter.configure(POSES,attack))
	assert(presenter.configure_idle(IDLE))
	presenter.position = Vector2(0,-16)
	presenter.scale = Vector2.ONE*0.5
	actor.get_node("VisualRoot").add_child(presenter)
	cardinal_motion = CardinalMotion.new()
	cardinal_motion.actor = actor
	cardinal_motion.presenter = presenter
	cardinal_motion.profile = PROFILE
	cardinal_motion.speed = 110.0
	actor.add_child(cardinal_motion)
	step_motion = StepMotion.new()
	step_motion.actor = actor
	step_motion.attack = attack
	step_motion.step_distances = PackedFloat32Array([4,4,4,0,6])
	actor.add_child(step_motion)
	trail = Trail.new()
	trail.configure(attack,PROFILE.swing_atlas)
	trail.rows = PROFILE.swing_rows
	trail.origins = PROFILE.swing_origins
	trail.world_pixels_per_texel = 1.0
	trail.world_origin = Vector2(0,-16)
	trail.edge_feather_pixels = 2
	trail.rotate_vertical_sampling = true
	actor.add_child(trail)
	actor.move_child(trail,actor.get_node("VisualRoot").get_index())
	continuation_scheduled = false
	continuation_generation += 1
	attack.hit_landed.connect(_hit)
	attack.phase_changed.connect(_phase)
	attack.attack_finished.connect(_finished)
	queued = false
	auto_left = 0
	contacts = 0
	targets.clear()
	input_controller = ReviewInput.new()
	input_controller.owner_review = self
	input_controller.process_mode = Node.PROCESS_MODE_ALWAYS
	stage.add_child(input_controller)
	control_column = toolbar.get_child(0)
	toolbar.process_mode = Node.PROCESS_MODE_ALWAYS
	for child in control_column.get_children():
		control_column.remove_child(child)
		child.queue_free()
	control_column.position = Vector2(12,110)
	var label := Label.new()
	label.text = "TWINSTEEL · FOUR DIRECTIONS\nW / A / S / D: run and face · SPACE / click: cut\nG: full chain · TAB: controls · ESC: pause\nThrust → crosscut → return → hop spin → X\nIsolated prototype · NO SAVES / REWARDS"
	label.add_theme_font_size_override("font_size",10)
	control_column.add_child(label)
	status = Label.new()
	status.add_theme_font_size_override("font_size",10)
	control_column.add_child(status)
	_button(control_column,"Next cut · SPACE",strike)
	_button(control_column,"Five-cut combo · G",play_combo)
	_button(control_column,"Try spin",try_spin)
	_button(control_column,"Face up / back",func() -> void: face_and_targets(Vector2.UP))
	_button(control_column,"Face down / front",func() -> void: face_and_targets(Vector2.DOWN))
	_button(control_column,"Place front / rear targets",place_targets)
	_button(control_column,"Spawn moving Rootling",spawn_rootling)
	_button(control_column,"Cancel / carry",cancel_combo)
	_button(control_column,"Pause / resume · ESC",toggle_pause)
	_button(control_column,"Reset proof",reset_review)
	place_targets()
	_status()

func has_pending_cut() -> bool:
	return queued or auto_left>0 or continuation_scheduled

func strike() -> void:
	if paused: return
	var attack: MeleeAttackComponent = stage.player.attack_component
	if attack.phase!=MeleeAttackComponent.Phase.IDLE:
		queued = true
		return
	cardinal_motion.stop_and_clear()
	attack.request_attack(stage.player.facing_direction)

func play_combo() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE or continuation_scheduled: return
	stage.player.attack_component.reset_combo()
	auto_left = 4
	strike()

func try_spin() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	continuation_scheduled = false
	continuation_generation += 1
	queued = false
	auto_left = 0
	stage.player.attack_component._next_combo_step = 3
	strike()

func _finished() -> void:
	_status()
	if auto_left>0 or queued:
		if auto_left>0: auto_left -= 1
		queued = false
		continuation_scheduled = true
		_continue_cut.call_deferred(continuation_generation)

func _continue_cut(generation: int) -> void:
	if generation!=continuation_generation or not continuation_scheduled: return
	if paused: return
	continuation_scheduled = false
	strike()

func cancel_combo() -> void:
	queued = false
	auto_left = 0
	continuation_scheduled = false
	continuation_generation += 1
	cardinal_motion.stop_and_clear()
	stage.player.attack_component.cancel_attack()
	presenter.cancel_presentation_transition()

func toggle_controls() -> void:
	control_column.visible = not control_column.visible

func toggle_pause() -> void:
	paused = not paused
	if not paused and continuation_scheduled: _continue_cut.call_deferred(continuation_generation)
	control_column.show()
	_status()

func place_targets() -> void:
	if paused: return
	for target in targets:
		if is_instance_valid(target): target.queue_free()
	targets.clear()
	for distance in [36.0,-32.0]:
		var target: Node2D = TARGET.instantiate()
		target.position = stage.player.global_position+stage.player.facing_direction*distance
		stage.get_node("World/Actors").add_child(target)
		var health: HealthComponent = target.get_node("HealthComponent")
		health.set_maximum_health(10000,false)
		health.set_current_health(10000)
		targets.append(target)

func spawn_rootling() -> void:
	if paused: return
	var encounter: ReviewEncounter = stage.encounter_controller
	encounter.offsets = [stage.player.facing_direction*100]
	encounter._spawn_enemy(encounter.rootling_scene)

func _hit(_target: HurtboxComponent,_info: DamageInfo) -> void:
	contacts += 1
	_status()

func _phase(_value: int,_duration: float) -> void:
	var direction: Vector2 = stage.player.attack_component.get_attack_direction()
	trail.z_index = 0 if direction.y<0 and absf(direction.y)>=absf(direction.x) else 3
	_status()

func face_and_targets(direction: Vector2) -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	cardinal_motion.stop_and_clear()
	cardinal_motion.face(direction)
	place_targets()

func _status() -> void:
	if not is_instance_valid(status): return
	var attack: MeleeAttackComponent = stage.player.attack_component
	status.text = "%s · %s · contacts: %d%s"%[LABELS[attack.combo_step],["Carry","Wind-up","Contact","Recovery"][attack.phase],contacts," · PAUSED" if paused else ""]

func reset_review() -> void:
	cancel_combo()
	await super.reset_review()
