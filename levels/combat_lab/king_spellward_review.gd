extends Node2D

## Session-local presentation comparison. Never grants gear or writes a profile.
const PreviewAnimation = preload("res://levels/combat_lab/king_spellward_animation.gd")
const PreviewFrames = preload("res://assets/characters/playable/king/spellward_preview/spellward_frames.tres")
const PreviewOutline = preload("res://levels/combat_lab/king_spellward_outline.gdshader")
const REF_PROPERTIES := ["attack_component", "ability_component", "ability_2_component", "ability_3_component", "ability_4_component"]
var lab: Node
var actor: Player
var body: AnimatedSprite2D
var enabled := false
var show_contact := false
var speed_mode := 0
var _original_script: Script
var _original_frames: SpriteFrames
var _original_scale: Vector2
var _original_material: Material
var _outline_material: ShaderMaterial
var _panel: PanelContainer
var _appearance_button: Button
var _speed_button: Button
var _zoom_button: Button
var _message: Label
var _zoomed := false
var _opened := false

func _ready() -> void:
	lab = get_parent()
	actor = lab.player
	body = actor.get_node("VisualRoot/Body")
	_original_script = body.get_script()
	_original_frames = body.sprite_frames
	_original_scale = body.scale
	_original_material = body.material
	_outline_material = ShaderMaterial.new()
	_outline_material.shader = PreviewOutline
	z_index = 20
	set_process(false)
	actor.attack_component.phase_changed.connect(func(_phase: int, _duration: float) -> void: queue_redraw())
	actor.attack_component.attack_finished.connect(queue_redraw)
	actor.equipment_stats_changed.connect(_restore_equipment_mode)
	_build_panel()

func open_review() -> void:
	_panel.show()
	if _opened:
		return
	if not set_preview_enabled(true):
		return
	_opened = true
	lab.clear_simulation()
	lab.enemy_selector.select(2)
	lab._on_roster_selected(2)
	# Retain the approved Court tiles while reviewing normal actors.
	lab._set_examiner_arena(true)
	lab.set_enemy_ai_enabled(false)
	lab.ai_toggle.set_pressed_no_signal(false)
	lab.spawn_selected(1)
	lab._set_examiner_arena(true)
	actor.global_position = Vector2(340, 300)
	_message.text = "King C · four directions / three cuts · skills retain provisional body poses"

func can_switch() -> bool:
	return not actor.is_defeated and not actor.is_restrained() and not actor.is_in_hit_recovery() and not actor._is_targeting_any_ability() and not actor.is_any_ability_casting() and not actor.evade_component.is_dashing() and actor.attack_component.phase == MeleeAttackComponent.Phase.IDLE

func set_preview_enabled(value: bool) -> bool:
	if value == enabled:
		return true
	if not can_switch():
		if _message != null:
			_message.text = "Finish the current action before switching appearance."
		return false
	var refs: Dictionary = {}
	for key: String in REF_PROPERTIES:
		refs[key] = body.get(key)
	var direction: String = body.get("_direction")
	var moving: bool = body.get("_is_moving")
	body.call("_kill_attack_phase_tween")
	body.call("_kill_recoil_tween")
	body.stop()
	body.set_script(PreviewAnimation if value else _original_script)
	for key: String in refs:
		body.set(key, refs[key])
	body.set("_base_position", Vector2(0, -16))
	body.set("_direction", direction)
	body.set("_action_direction", direction)
	body.set("_is_moving", moving)
	body.set("_action_locked", false)
	body.position = Vector2(0, -16)
	body.sprite_frames = PreviewFrames if value else _original_frames
	body.scale = Vector2(.5, .5) if value else _original_scale
	body.material = _outline_material if value else _original_material
	enabled = value
	actor.get_node("GreatswordEffects").set("review_trails_enabled", value)
	body.call("resume_locomotion")
	_appearance_button.text = "LOOK: C" if value else "LOOK: ORIGINAL"
	return true

func cycle_speed() -> void:
	if not can_switch():
		_message.text = "Finish the current action before changing the speed sample."
		return
	speed_mode = (speed_mode + 1) % 3
	if speed_mode == 0:
		actor._apply_equipment_stats()
	else:
		actor.movement_component.set_equipment_speed_bonus(.35 if speed_mode == 2 else 0.0)
		actor.attack_component.set_equipment_attack_speed_bonus(.5 if speed_mode == 2 else 0.0)
		body.call("_refresh_stride")
	_update_speed_label()

func _restore_equipment_mode() -> void:
	speed_mode = 0
	_update_speed_label()

func _update_speed_label() -> void:
	if _speed_button != null:
		_speed_button.text = ["SPEED: GEAR", "SPEED: BASE", "SPEED: CAPS"][speed_mode]

func sample_hit(stagger_seconds: float) -> void:
	if not can_switch():
		_message.text = "Finish the current action before the reaction sample."
		return
	var health := actor.health_component
	var was_immune := health.is_damage_immune
	var was_invulnerable: bool = health.is_invulnerable
	var before := health.current_health
	health.is_damage_immune = false
	health.set_invulnerable(false)
	health.apply_damage(DamageInfo.new(minf(1.0, before * .25), self, Vector2.LEFT, 0.0, stagger_seconds))
	health.set_current_health(before)
	health.is_damage_immune = was_immune
	health.set_invulnerable(was_invulnerable)
	_message.text = "Real stagger sample · %.2f s · health restored" % stagger_seconds

func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.name = "KingReviewPanel"
	_panel.position = Vector2(46, 150)
	_panel.size = Vector2(648, 64)
	_panel.theme = lab.get_node("UI/LabPanel").theme
	var stack := VBoxContainer.new()
	_panel.add_child(stack)
	var row := HBoxContainer.new()
	stack.add_child(row)
	_appearance_button = _button(row, "LOOK: ORIGINAL", func() -> void: set_preview_enabled(not enabled))
	_speed_button = _button(row, "SPEED: GEAR", cycle_speed)
	_zoom_button = _button(row, "VIEW: GAME", _toggle_zoom)
	_button(row, "HIT", sample_hit.bind(.11))
	_button(row, "STUN", sample_hit.bind(.8))
	_button(row, "REACH", func() -> void: show_contact = not show_contact; set_process(show_contact); queue_redraw())
	_button(row, "HIDE", func() -> void: _panel.hide())
	_message = Label.new()
	_message.add_theme_font_size_override("font_size", 10)
	stack.add_child(_message)
	lab.get_node("UI").add_child(_panel)
	_panel.hide()

func _button(row: HBoxContainer, text: String, callback: Callable) -> Button:
	var button := Button.new()
	button.text = text
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(callback)
	row.add_child(button)
	return button

func _toggle_zoom() -> void:
	_zoomed = not _zoomed
	lab.camera.zoom = Vector2(2, 2) if _zoomed else Vector2.ONE
	_zoom_button.text = "VIEW: CLOSE" if _zoomed else "VIEW: GAME"

func _process(_delta: float) -> void:
	queue_redraw()

func _draw() -> void:
	if not show_contact or actor == null:
		return
	var shape := actor.attack_component.collision_shape.shape as ConvexPolygonShape2D
	if shape == null:
		return
	var transform := global_transform.affine_inverse() * actor.attack_component.collision_shape.global_transform
	var points := PackedVector2Array()
	for point in shape.points:
		points.append(transform * point)
	points.append(points[0])
	draw_polyline(points, Color("c6edff") if actor.attack_component.phase == MeleeAttackComponent.Phase.ACTIVE else Color("607c86"), 1.0)

func _exit_tree() -> void:
	if is_instance_valid(_panel):
		_panel.queue_free()
