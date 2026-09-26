extends Node2D

## Lab-only tuning controls. The production body and Skills 1-3 are already active.
var lab: Node
var actor: Player
var body: AnimatedSprite2D
var _panel: PanelContainer
var _message: Label
var _earth_form: Button
var _molten_form: Button
var _speed_button: Button
var _zoom_button: Button
var _zoomed := false
var _speed_mode := 0
var _show_reach := false


func _ready() -> void:
	lab = get_parent()
	actor = lab.player
	body = actor.get_node("VisualRoot/Body")
	z_index = 20
	set_process(false)
	_build_panel()
	actor.equipment_stats_changed.connect(_restore_speed)


func open_review() -> void:
	_panel.show()
	_message.text = "Current King C · Earthsplitter · Molten Crash · Sovereign Pursuit. FORM changes are Lab-only."


func can_switch() -> bool:
	return not actor.is_defeated and not actor.is_restrained() and not actor.is_in_hit_recovery() and not actor._is_targeting_any_ability() and not actor.is_any_ability_casting() and not actor.evade_component.is_dashing() and actor.attack_component.phase == MeleeAttackComponent.Phase.IDLE


func set_earthsplitter_form(value: int) -> bool:
	if value < EarthsplitterDefinition.Form.FOUNDATION or value > EarthsplitterDefinition.Form.CASCADE or not can_switch():
		return false
	for sequence in get_tree().get_nodes_in_group("earthsplitter_sequences"):
		if sequence.source == actor:
			return false
	var next := actor.ability_1_component.definition.duplicate(true) as EarthsplitterDefinition
	next.configure_form(value)
	actor.ability_1_component.definition = next
	actor.ability_1_component.collision_shape.shape = next.hitbox_shape
	actor.ability_1_component.clear_cooldown()
	actor.get_node("KingSkillLibrary").refresh()
	_earth_form.text = ["SKILL 1: FOUNDATION", "SKILL 1: FAN", "SKILL 1: CASCADE TEST"][value]
	_message.text = "Skill 1 form preview only; campaign starts with Foundation."
	return true


func set_molten_form(value: int) -> bool:
	if value < MoltenCrashDefinition.Form.FOUNDATION or value > MoltenCrashDefinition.Form.MATURE or not can_switch():
		return false
	for pulse in get_tree().get_nodes_in_group("molten_crash_pulses"):
		if pulse.source == actor:
			return false
	var next := actor.ability_2_component.definition.duplicate(true) as MoltenCrashDefinition
	next.configure_form(value)
	actor.ability_2_component.definition = next
	actor.ability_2_component.collision_shape.shape = next.hitbox_shape
	actor.ability_2_component.clear_cooldown()
	actor.get_node("KingSkillLibrary").refresh()
	_molten_form.text = ["SKILL 2: FOUNDATION", "SKILL 2: ADVANCED", "SKILL 2: AWAKENED", "SKILL 2: MATURE"][value]
	_message.text = "Skill 2 form preview only; campaign starts with blue Foundation."
	return true


func cycle_speed() -> void:
	if not can_switch():
		return
	_speed_mode = (_speed_mode + 1) % 3
	if _speed_mode == 0:
		actor._apply_equipment_stats()
	else:
		actor.movement_component.set_equipment_speed_bonus(.35 if _speed_mode == 2 else 0.0)
		actor.attack_component.set_equipment_attack_speed_bonus(.5 if _speed_mode == 2 else 0.0)
		body.call("_refresh_stride")
	_speed_button.text = ["SPEED: GEAR", "SPEED: BASE", "SPEED: CAPS"][_speed_mode]


func _restore_speed() -> void:
	_speed_mode = 0
	if _speed_button != null:
		_speed_button.text = "SPEED: GEAR"


func sample_hit(seconds: float) -> void:
	if not can_switch():
		return
	var health := actor.health_component
	var was_immune := health.is_damage_immune
	var was_invulnerable: bool = health.is_invulnerable
	var before := health.current_health
	health.is_damage_immune = false
	health.set_invulnerable(false)
	var sample := DamageInfo.new(minf(1.0, before * .25), self, Vector2.LEFT)
	if seconds >= .3:
		sample.stun_seconds = seconds
	else:
		sample.stagger_seconds = seconds
	health.apply_damage(sample)
	health.set_current_health(before)
	health.is_damage_immune = was_immune
	health.set_invulnerable(was_invulnerable)


func _build_panel() -> void:
	_panel = PanelContainer.new()
	_panel.position = Vector2(46, 150)
	_panel.size = Vector2(648, 64)
	_panel.theme = lab.get_node("UI/LabPanel").theme
	var stack := VBoxContainer.new()
	_panel.add_child(stack)
	var row := HBoxContainer.new()
	stack.add_child(row)
	_speed_button = _button(row, "SPEED: GEAR", cycle_speed)
	_zoom_button = _button(row, "VIEW: GAME", _toggle_zoom)
	_button(row, "HIT", sample_hit.bind(.11))
	_button(row, "STUN", sample_hit.bind(.8))
	_button(row, "REACH", func() -> void: _show_reach = not _show_reach; set_process(_show_reach); queue_redraw())
	_button(row, "HIDE", func() -> void: _panel.hide())
	var forms := HBoxContainer.new()
	stack.add_child(forms)
	_earth_form = _button(forms, "SKILL 1: FOUNDATION", func() -> void: set_earthsplitter_form(((actor.ability_1_component.definition as EarthsplitterDefinition).form + 1) % 3))
	_molten_form = _button(forms, "SKILL 2: FOUNDATION", func() -> void: set_molten_form(((actor.ability_2_component.definition as MoltenCrashDefinition).form + 1) % 4))
	_message = Label.new()
	_message.add_theme_font_size_override("font_size", 10)
	stack.add_child(_message)
	lab.get_node("UI").add_child(_panel)
	_panel.hide()


func _button(row: HBoxContainer, label: String, action: Callable) -> Button:
	var button := Button.new()
	button.text = label
	button.focus_mode = Control.FOCUS_NONE
	button.pressed.connect(action)
	row.add_child(button)
	return button


func _toggle_zoom() -> void:
	_zoomed = not _zoomed
	lab.camera.zoom = Vector2(2, 2) if _zoomed else Vector2.ONE
	_zoom_button.text = "VIEW: CLOSE" if _zoomed else "VIEW: GAME"


func _process(_delta: float) -> void:
	queue_redraw()


func _draw() -> void:
	if not _show_reach:
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
