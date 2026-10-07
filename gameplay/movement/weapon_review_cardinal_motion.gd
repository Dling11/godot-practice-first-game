extends Node

## Isolated review input; actual collision/travel drives authored cardinal gait.
var actor: Player
var presenter: Node2D
var profile: WeaponFamilyPresentationDefinition
var speed := 110.0
var direction := Vector2.ZERO
var _held := {}

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	actor.attack_component.attack_started.connect(_stop)
	actor.attack_component.attack_finished.connect(_resume)
	set_physics_process(false)

func _unhandled_key_input(event: InputEvent) -> void:
	if not event is InputEventKey or event.echo: return
	if event.physical_keycode not in [KEY_A,KEY_D,KEY_W,KEY_S]: return
	_held[event.physical_keycode] = event.pressed
	set_direction(Vector2(float(_held.get(KEY_D,false))-float(_held.get(KEY_A,false)),float(_held.get(KEY_S,false))-float(_held.get(KEY_W,false))))
	get_viewport().set_input_as_handled()

func set_direction(axis: Vector2) -> void:
	direction = axis.limit_length()
	if get_tree().paused: return
	if direction.is_zero_approx():
		_stop()
		presenter.stop_locomotion()
		return
	if actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	_start()

func face(facing: Vector2) -> void:
	# A cut owns its committed facing until recovery is complete.
	if actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	actor.facing_direction = facing.normalized()
	var next: Resource = profile.attack_for(actor.facing_direction)
	if presenter._default_definition!=next:
		presenter.cancel_presentation_transition()
		presenter._default_definition = next
		presenter.idle_definition = profile.idle_for(actor.facing_direction)
		presenter._carry()
	presenter.face_horizontal(signf(facing.x) if absf(facing.x)>absf(facing.y) else 1.0)

func _start() -> void:
	if direction.is_zero_approx() or actor.attack_component.phase!=MeleeAttackComponent.Phase.IDLE: return
	face(direction)
	var run: Resource = profile.run_for(direction)
	if not presenter._running or presenter.definition!=run: presenter.play_locomotion(run,48.0/speed,true)
	set_physics_process(true)

func _physics_process(delta: float) -> void:
	if get_tree().paused: return
	var origin := actor.global_position
	var wanted := (origin+direction*speed*delta).clamp(actor.movement_bounds.position,actor.movement_bounds.end)
	actor.move_and_collide(wanted-origin)
	presenter.advance_locomotion(actor.global_position.distance_to(origin))

func _stop() -> void:
	set_physics_process(false)

func stop_and_clear() -> void:
	direction = Vector2.ZERO
	_held.clear()
	_stop()
	presenter.stop_locomotion()

func _resume() -> void:
	if not direction.is_zero_approx(): call_deferred("set_direction",direction)

func _notification(what: int) -> void:
	if what==NOTIFICATION_WM_WINDOW_FOCUS_OUT and is_instance_valid(presenter): stop_and_clear()

func _exit_tree() -> void:
	_stop()
	if is_instance_valid(actor):
		if actor.attack_component.attack_started.is_connected(_stop): actor.attack_component.attack_started.disconnect(_stop)
		if actor.attack_component.attack_finished.is_connected(_resume): actor.attack_component.attack_finished.disconnect(_resume)
