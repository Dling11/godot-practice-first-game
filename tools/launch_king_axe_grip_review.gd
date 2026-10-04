extends "res://tools/launch_enemy_arrival_review.gd"

## Deliberately stationary, right-facing motion/contact proof. No invented gait.
const Presenter = preload("res://gameplay/presentation/weapon_family_pose_presenter.gd")
const POSES = preload("res://assets/characters/playable/king/axe_proof/poses.tres")
const TARGET = preload("res://entities/training/training_target.tscn")
const SwingTrail = preload("res://gameplay/presentation/axe_swing_trail.gd")
const SWING_ART = preload("res://assets/characters/playable/king/axe_proof/swing.png")
const Combo = preload("res://data/weapons/sword_combo_definition.gd")
var axe_presenter: Presenter
var swing_trail: SwingTrail
var _status: Label
var _contacts := 0
var contact_target: Node2D
var _queued_cut := false
var _auto_cuts_left := 0
var _continuation: Timer

class ReviewInput extends Node:
	var strike: Callable
	var pause: Callable
	func _unhandled_input(event: InputEvent) -> void:
		if event is InputEventKey and event.pressed and not event.echo:
			if event.keycode == KEY_ESCAPE:
				pause.call()
				get_viewport().set_input_as_handled()
			elif event.keycode == KEY_SPACE and not get_tree().paused:
				strike.call()
				get_viewport().set_input_as_handled()
		elif event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT and not get_tree().paused:
			strike.call()
			get_viewport().set_input_as_handled()

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://king_axe_grip_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	root.mode = Window.MODE_WINDOWED
	root.grab_focus()
	await open_review()

func open_review() -> void:
	await super.open_review()
	root.title = "Battle of Gods — Iron Beard 3-cut combo (NO SAVES / REWARDS)"
	_visit(Vector2(520,480))
	var actor: Player = stage.player
	actor.set_physics_process(false)
	actor.set_process_unhandled_input(false)
	stage.set_process_unhandled_input(false)
	actor.velocity = Vector2.ZERO
	actor.facing_direction = Vector2.RIGHT
	actor.facing_changed.emit(Vector2.RIGHT)
	actor.attack_component.cancel_attack()
	var weapon := load("res://data/weapons/king_signature_sword.tres").duplicate(true) as WeaponDefinition
	weapon.weapon_id = &"review_iron_beard_axe"
	weapon.display_name = "Iron Beard · motion proof"
	weapon.combo = Combo.new()
	weapon.combo.windups = PackedFloat32Array([0.24,0.20,0.36])
	weapon.combo.contacts = PackedFloat32Array([0.14,0.14,0.18])
	weapon.combo.recoveries = PackedFloat32Array([0.26,0.26,0.34])
	weapon.wind_up_seconds = 0.24
	weapon.active_seconds = 0.13
	weapon.recovery_seconds = 0.31
	# Existing contact budget is a comparison fixture, not approved axe balance.
	assert(actor.set_weapon_definition(weapon))
	# Keep the current cut audio; hide its sword-specific visual trail.
	actor.get_node("GreatswordEffects").hide()
	actor.get_node("VisualRoot/Body").hide()
	stage.get_node("UI").hide()
	axe_presenter = Presenter.new()
	assert(axe_presenter.configure(POSES,actor.attack_component))
	axe_presenter.position = Vector2(0,-16)
	axe_presenter.scale = Vector2(0.5,0.5)
	actor.get_node("VisualRoot").add_child(axe_presenter)
	swing_trail = SwingTrail.new()
	swing_trail.configure(actor.attack_component,SWING_ART)
	actor.add_child(swing_trail)
	actor.attack_component.hit_landed.connect(_hit)
	actor.attack_component.phase_changed.connect(_phase)
	actor.attack_component.attack_finished.connect(_finished)
	_queued_cut = false
	_auto_cuts_left = 0
	_continuation = Timer.new()
	_continuation.one_shot = true
	_continuation.wait_time = 0.035
	_continuation.timeout.connect(strike)
	stage.add_child(_continuation)
	var input := ReviewInput.new()
	input.strike = strike
	input.pause = toggle_pause
	input.process_mode = Node.PROCESS_MODE_ALWAYS
	stage.add_child(input)
	var column: VBoxContainer = toolbar.get_child(0)
	for child in column.get_children():
		column.remove_child(child)
		child.queue_free()
	var label := Label.new()
	label.text = "IRON BEARD · 3-CUT COMBO\nSPACE / click: cut (one buffered)\nDown → rising → hop slam\nStationary · right-facing\nNo saves / rewards / crafting"
	label.add_theme_font_size_override("font_size",10)
	column.add_child(label)
	_status = Label.new()
	_status.text = "Guard · contacts: 0"
	_status.add_theme_font_size_override("font_size",10)
	column.add_child(_status)
	_button(column,"Next cut →",strike)
	_button(column,"Play three-cut combo",play_combo)
	_button(column,"Place contact target",place_target)
	_button(column,"Spawn moving Rootling",spawn_rootling)
	_button(column,"Reposition rig near foe",reposition_near_foe)
	_button(column,"Cancel combo / guard",cancel_combo)
	_button(column,"Pause / resume · ESC",toggle_pause)
	_button(column,"Reset proof",reset_review)
	_contacts = 0

func strike() -> void:
	if paused: return
	if stage.player.attack_component.phase != MeleeAttackComponent.Phase.IDLE:
		_queued_cut = true
		return
	stage.player.attack_component.request_attack(Vector2.RIGHT)

func play_combo() -> void:
	if paused or stage.player.attack_component.phase!=MeleeAttackComponent.Phase.IDLE or not _continuation.is_stopped(): return
	stage.player.attack_component.reset_combo()
	_auto_cuts_left = 2
	strike()

func cancel_combo() -> void:
	_queued_cut = false
	_auto_cuts_left = 0
	_continuation.stop()
	stage.player.attack_component.cancel_attack()

func place_target() -> void:
	if paused: return
	if is_instance_valid(contact_target):
		contact_target.get_parent().remove_child(contact_target)
		contact_target.queue_free()
	var target: Node2D = TARGET.instantiate()
	contact_target = target
	target.position = stage.player.global_position+Vector2(24,0)
	stage.get_node("World/Actors").add_child(target)
	var health: HealthComponent = target.get_node("HealthComponent")
	health.set_maximum_health(10000,false)
	health.set_current_health(10000)

func spawn_rootling() -> void:
	if paused: return
	var encounter: ReviewEncounter = stage.encounter_controller
	encounter.offsets = [Vector2(100,0)]
	encounter._spawn_enemy(encounter.rootling_scene)

func toggle_pause() -> void:
	paused = not paused

func reposition_near_foe() -> void:
	if paused or stage.player.attack_component.phase != MeleeAttackComponent.Phase.IDLE: return
	for child in stage.get_node("World/Actors").get_children():
		if child is Rootling and child.health_component.current_health>0:
			_visit(child.global_position-Vector2(24,0))
			return

func _hit(_target: HurtboxComponent,_info: DamageInfo) -> void:
	_contacts += 1
	_status.text = "Accepted contacts: %d" % _contacts

func _phase(phase: int,_duration: float) -> void:
	_status.text = "%s · %s · hits: %d" % [["Down cut","Rising cut","Hop slam"][stage.player.attack_component.combo_step],["Guard","Wind-up","Contact","Recovery"][phase],_contacts]

func _finished() -> void:
	_status.text = "Guard · contacts: %d" % _contacts
	if _auto_cuts_left>0 or _queued_cut:
		if _auto_cuts_left>0: _auto_cuts_left -= 1
		_queued_cut = false
		_continuation.start()

func reset_review() -> void:
	_queued_cut = false
	_auto_cuts_left = 0
	if is_instance_valid(_continuation): _continuation.stop()
	await super.reset_review()
