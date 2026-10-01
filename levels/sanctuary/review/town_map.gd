extends CanvasLayer

const MapDrawing = preload("res://levels/sanctuary/review/town_map_drawing.gd")
var entries: Array[Dictionary] = []
var player: Node2D
var hub: Node
var panel: PanelContainer
var drawing: Control
var guidance: Label
var selected_id := ""
var enabled := false
var _timer: Timer

func configure(owner_hub: Node, service_entries: Array[Dictionary], path_routes: Array[PackedVector2Array]) -> void:
	hub = owner_hub
	player = hub.get_node("World/Actors/Player")
	entries = service_entries
	layer = 16
	panel = PanelContainer.new()
	panel.position = Vector2(702, 82)
	panel.custom_minimum_size = Vector2(244, 0)
	var style := StyleBoxFlat.new()
	style.bg_color = Color(.045,.065,.075,.97)
	style.border_color = Color(.48,.43,.28)
	style.set_border_width_all(1)
	style.set_content_margin_all(10)
	panel.add_theme_stylebox_override("panel",style)
	add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",4)
	panel.add_child(stack)
	var heading := HBoxContainer.new()
	stack.add_child(heading)
	var title := Label.new()
	title.text = "SANCTUARY  ·  M"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size",13)
	heading.add_child(title)
	var close := Button.new()
	close.text = "×"
	close.pressed.connect(func() -> void: panel.hide())
	heading.add_child(close)
	drawing = MapDrawing.new()
	drawing.custom_minimum_size = Vector2(220,120)
	drawing.player = player
	drawing.entries = entries
	drawing.routes = path_routes
	stack.add_child(drawing)
	for entry in entries:
		var button := Button.new()
		button.text = str(entry.name) + " · " + str(entry.role)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.add_theme_font_size_override("font_size",12)
		button.add_theme_color_override("font_color",entry.color)
		button.pressed.connect(select_destination.bind(str(entry.id)))
		stack.add_child(button)
	var clear := Button.new()
	clear.text = "Clear destination"
	clear.add_theme_font_size_override("font_size",11)
	clear.pressed.connect(clear_destination)
	stack.add_child(clear)
	guidance = Label.new()
	guidance.position = Vector2(348,80)
	guidance.size = Vector2(300,24)
	guidance.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	guidance.mouse_filter = Control.MOUSE_FILTER_IGNORE
	guidance.add_theme_font_size_override("font_size",13)
	guidance.add_theme_constant_override("outline_size",5)
	guidance.add_theme_color_override("font_outline_color",Color(.025,.035,.045,.95))
	add_child(guidance)
	_timer = Timer.new()
	_timer.wait_time = .15
	_timer.timeout.connect(_refresh)
	add_child(_timer)
	panel.hide()
	guidance.hide()
	for modal: Control in [hub.dialogue_panel,hub.character_menu,hub.rootforge_menu,hub.umi_exchange_menu,hub.expedition_menu,hub.get_node("UI/PauseMenu")]:
		modal.visibility_changed.connect(_on_modal_visibility_changed.bind(modal))

func _on_modal_visibility_changed(modal: Control) -> void:
	if modal.visible:
		panel.hide()
		guidance.hide()

func set_enabled(value: bool) -> void:
	enabled = value
	if value: _timer.start()
	else:
		_timer.stop()
		panel.hide()
		clear_destination()

func toggle() -> void:
	if enabled and not get_tree().paused and not hub.dialogue_panel.visible:
		panel.visible = not panel.visible
		_refresh()

func select_destination(service_id: String) -> void:
	if not enabled: return
	selected_id = service_id
	for entry in entries:
		if entry.has("beacon"): entry.beacon.set_selected(str(entry.id) == selected_id)
	panel.hide()
	_refresh()

func clear_destination() -> void:
	selected_id = ""
	for entry in entries:
		if entry.has("beacon"): entry.beacon.set_selected(false)
	guidance.hide()
	if is_instance_valid(drawing):
		drawing.selected_id = ""
		drawing.queue_redraw()

func _unhandled_key_input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed and not event.echo and event.physical_keycode == KEY_M and enabled and not hub.dialogue_panel.visible:
		toggle()
		get_viewport().set_input_as_handled()

func _refresh() -> void:
	if not enabled: return
	if hub.dialogue_panel.visible or get_tree().paused:
		panel.hide()
		guidance.hide()
		return
	drawing.selected_id = selected_id
	if panel.visible: drawing.queue_redraw()
	guidance.visible = not selected_id.is_empty()
	for entry in entries:
		if str(entry.id) != selected_id: continue
		var target: Node2D = entry.node
		var offset := target.global_position - player.global_position
		var direction := "→" if offset.x >= 0 else "←"
		if absf(offset.y) > absf(offset.x): direction = "↓" if offset.y >= 0 else "↑"
		if offset.length() < 50: direction = "[F]"
		guidance.text = direction + "  " + str(entry.name) + " · " + str(entry.role)
		guidance.modulate = entry.color
		return
