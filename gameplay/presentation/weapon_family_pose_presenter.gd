extends Node2D

## Fixed raster follows authored hand positions; it cannot issue attacks/damage.
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
var definition: Definition
var _default_definition: Definition
var pose_index := 0
var body_sprite: Sprite2D
var hand_sprite: Sprite2D
var weapon_rig: Node2D
var weapon_sprite: Sprite2D
var _attack: MeleeAttackComponent
var _pose_tween: Tween
var _body_frame: AtlasTexture
var _hand_frame: AtlasTexture
var _observe_melee := true
var _base_position := Vector2.ZERO
var idle_definition: Definition
var _rest_timer: Timer
var _resting := false

func configure_idle(poses: Definition, rest_seconds := 4.0) -> bool:
	if is_inside_tree() or poses==null or not poses.has_valid_layout(): return false
	idle_definition = poses
	_rest_timer = Timer.new()
	_rest_timer.one_shot = true
	_rest_timer.wait_time = maxf(rest_seconds,0.1)
	_rest_timer.timeout.connect(_rest)
	add_child(_rest_timer)
	return true

func configure(poses: Definition, attack: MeleeAttackComponent, observe_melee := true) -> bool:
	if is_inside_tree() or poses == null or not poses.has_valid_layout() or attack == null:
		return false
	definition = poses
	_default_definition = poses
	_attack = attack
	_observe_melee = observe_melee
	return true

func _ready() -> void:
	assert(definition != null and _attack != null)
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_base_position = position
	_body_frame = AtlasTexture.new()
	_body_frame.atlas = definition.body_atlas
	body_sprite = Sprite2D.new()
	body_sprite.texture = _body_frame
	add_child(body_sprite)
	weapon_rig = Node2D.new()
	add_child(weapon_rig)
	weapon_sprite = Sprite2D.new()
	weapon_sprite.texture = definition.weapon_texture
	weapon_sprite.centered = false
	weapon_sprite.position = -definition.weapon_primary_grip
	weapon_rig.add_child(weapon_sprite)
	_hand_frame = AtlasTexture.new()
	_hand_frame.atlas = definition.hand_atlas
	hand_sprite = Sprite2D.new()
	hand_sprite.texture = _hand_frame
	add_child(hand_sprite)
	_bind_attack()
	set_process(false)
	set_physics_process(false)
	set_pose(0)
	if idle_definition!=null: _carry()

func _enter_tree() -> void:
	# Reattaching an already-built idle presentation must restore observers.
	if body_sprite != null:
		_bind_attack()
		if idle_definition!=null: call_deferred("_resume_idle")

func _resume_idle() -> void:
	if is_inside_tree() and is_instance_valid(_attack) and _attack.phase==MeleeAttackComponent.Phase.IDLE:
		_stop_tween()
		_carry()

func _bind_attack() -> void:
	if _observe_melee and is_instance_valid(_attack):
		if not _attack.phase_changed.is_connected(_on_phase):
			_attack.phase_changed.connect(_on_phase)
		if not _attack.attack_finished.is_connected(_on_finished):
			_attack.attack_finished.connect(_on_finished)

func set_pose(index: int) -> void:
	pose_index = clampi(index, 0, 7)
	var cell := Vector2i(pose_index % definition.columns, pose_index / definition.columns)
	var region := Rect2(Vector2(cell * definition.cell_size), Vector2(definition.cell_size))
	_body_frame.region = region
	_hand_frame.region = region
	position = _base_position + Vector2(0,definition.lift_pixels[pose_index]*scale.y)
	var grip_position: Vector2 = definition.primary_hands[pose_index] - Vector2(definition.cell_size) * 0.5
	var hand_axis: Vector2 = definition.secondary_hands[pose_index] - definition.primary_hands[pose_index]
	var basis := Transform2D(hand_axis.angle()-definition.weapon_handle_axis.angle(),Vector2.ZERO)
	if definition.mirror_cutting_edge:
		var axis: Vector2 = definition.weapon_handle_axis.normalized()
		# Reflection about the SHAFT, rather than screen X, keeps both grips fixed.
		var reflection := Transform2D(Vector2(2*axis.x*axis.x-1,2*axis.x*axis.y),Vector2(2*axis.x*axis.y,2*axis.y*axis.y-1),Vector2.ZERO)
		basis = basis * reflection
	basis.origin = grip_position
	weapon_rig.transform = basis
	# Local draw order: negative global Z can put the axe under terrain/backdrops.
	var layer_index := 0 if definition.weapon_behind_body[pose_index]>0 else 1
	if weapon_rig.get_index()!=layer_index: move_child(weapon_rig,layer_index)

func select_clip(clip: Definition) -> void:
	definition = clip
	_body_frame.atlas = clip.body_atlas
	_hand_frame.atlas = clip.hand_atlas
	weapon_sprite.texture = clip.weapon_texture
	weapon_sprite.position = -clip.weapon_primary_grip

func _on_phase(phase: int, duration: float) -> void:
	_stop_tween()
	if _rest_timer!=null: _rest_timer.stop()
	_resting = false
	if phase < MeleeAttackComponent.Phase.WIND_UP or phase > MeleeAttackComponent.Phase.RECOVERY:
		return
	if phase == MeleeAttackComponent.Phase.WIND_UP:
		var step: int = _attack.combo_step
		select_clip(_default_definition.follow_up_clips[step-1] if step>0 and step<=_default_definition.follow_up_clips.size() else _default_definition)
	var window: Vector2 = definition.phase_windows[phase - 1]
	set_pose(int(window.x))
	_pose_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_pose_tween.tween_method(_advance_pose, window.x, window.y + 0.999, maxf(duration, 0.0001))

func _advance_pose(value: float) -> void:
	set_pose(int(value))

func _on_finished() -> void:
	# An earlier listener may have already started the next buffered attack.
	if is_instance_valid(_attack) and _attack.phase != MeleeAttackComponent.Phase.IDLE: return
	_stop_tween()
	if idle_definition!=null:
		_carry()
		return
	select_clip(_default_definition)
	set_pose(0)

func _carry() -> void:
	_resting = false
	select_clip(idle_definition)
	set_pose(0)
	_rest_timer.start()

func _rest() -> void:
	if not is_instance_valid(_attack) or _attack.phase!=MeleeAttackComponent.Phase.IDLE: return
	_stop_tween()
	_resting = true
	select_clip(idle_definition)
	set_pose(4)
	_pose_tween = create_tween().set_process_mode(Tween.TWEEN_PROCESS_PHYSICS)
	_pose_tween.tween_method(_advance_pose,4.0,7.999,0.48)

func _stop_tween() -> void:
	if _pose_tween != null and _pose_tween.is_valid():
		_pose_tween.kill()

func _exit_tree() -> void:
	_stop_tween()
	if _rest_timer!=null: _rest_timer.stop()
	if is_instance_valid(_attack):
		if _attack.phase_changed.is_connected(_on_phase):
			_attack.phase_changed.disconnect(_on_phase)
		if _attack.attack_finished.is_connected(_on_finished):
			_attack.attack_finished.disconnect(_on_finished)
