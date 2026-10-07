extends Node

## Horizontal-only review locomotion, separate from family art and campaign input.
var actor: Player
var presenter: Node2D
var running_clip: Resource
var speed := 90.0
var direction := 0.0
var _left := false
var _right := false

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	actor.attack_component.attack_started.connect(_stop)
	# Deferred resume runs after the pose observer returns to carry.
	actor.attack_component.attack_finished.connect(_resume)
	set_physics_process(false)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo: return
	if event.physical_keycode==KEY_A: _left = event.pressed
	elif event.physical_keycode==KEY_D: _right = event.pressed
	else: return
	set_direction(float(_right)-float(_left))
	get_viewport().set_input_as_handled()

func set_direction(axis: float) -> void:
	direction = signf(axis)
	if get_tree().paused: return
	if direction==0:
		_stop()
		presenter.stop_locomotion()
		return
	if actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	if presenter._drawing: return
	if presenter._resting and presenter.retrieve_from_rest(_start): return
	_start()

func _start() -> void:
	if actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	if direction==0:
		presenter.cancel_presentation_transition()
		return
	actor.facing_direction = Vector2(direction,0)
	presenter.face_horizontal(direction)
	if not presenter._running: presenter.play_locomotion(running_clip,48.0/speed,true)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if get_tree().paused: return
	if direction==0:
		set_direction(0)
		return
	var origin := actor.global_position
	var wanted := (origin+Vector2(direction*speed*delta,0)).clamp(actor.movement_bounds.position,actor.movement_bounds.end)
	actor.move_and_collide(wanted-origin)
	# Feet advance with actual displacement, including collision/bounds blocking.
	presenter.advance_locomotion(actor.global_position.distance_to(origin))

func _stop() -> void:
	set_physics_process(false)

func stop_and_clear() -> void:
	direction = 0
	_left = false
	_right = false
	_stop()
	presenter.stop_locomotion()

func _resume() -> void:
	if direction!=0: call_deferred("set_direction",direction)

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_WINDOW_FOCUS_OUT and is_instance_valid(presenter): stop_and_clear()

func _exit_tree() -> void:
	_stop()
	if is_instance_valid(actor):
		if actor.attack_component.attack_started.is_connected(_stop): actor.attack_component.attack_started.disconnect(_stop)
		if actor.attack_component.attack_finished.is_connected(_resume): actor.attack_component.attack_finished.disconnect(_resume)
