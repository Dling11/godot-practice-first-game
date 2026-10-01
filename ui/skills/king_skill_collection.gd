extends CanvasLayer

## Presents training and loadout intent; KingSkillLibrary owns validation and saving.
var library: KingSkillLibrary
var trainer_access := false
var _selected := ""
var _detail: RichTextLabel
var _upgrade_button: Button
var _list: VBoxContainer
var _slots: GridContainer
var _notice: Label
var _status: Label
var _clear_button: Button
var _core_button: Button
var _panel: PanelContainer
var _last_slot := 0
var _owns_pause := false

func _ready() -> void:
	layer = 110
	process_mode = Node.PROCESS_MODE_ALWAYS
	_owns_pause = not get_tree().paused
	get_tree().paused = true
	var veil := ColorRect.new()
	veil.color = Color(0.02,.03,.045,.86)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	_panel = PanelContainer.new()
	_panel.theme = preload("res://assets/ui/themes/battle_of_gods_theme.tres")
	_panel.size = Vector2(820,460)
	_panel.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var style := StyleBoxFlat.new()
	style.bg_color = Color("111d29")
	style.border_color = Color("80734f")
	style.set_border_width_all(2)
	style.set_content_margin_all(18)
	_panel.add_theme_stylebox_override("panel",style)
	_panel.add_theme_font_size_override("font_size",12)
	add_child(_panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",8)
	_panel.add_child(stack)
	var header := HBoxContainer.new()
	stack.add_child(header)
	var title := Label.new()
	title.text = "EIRA · TRAINING & LOADOUT" if trainer_access and not library.is_lab() else "KING · SKILL LOADOUT"
	title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size",16)
	header.add_child(title)
	_core_button = Button.new()
	_core_button.text = "Restore core layout"
	_core_button.tooltip_text = "Place learned core skills in 1–5. This changes your current arrangement."
	_core_button.pressed.connect(_restore_core)
	header.add_child(_core_button)
	var close := Button.new()
	close.text = "Back [Esc]"
	close.pressed.connect(_close)
	header.add_child(close)
	_notice = Label.new()
	_notice.custom_minimum_size.x = 784
	_notice.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_notice.add_theme_font_size_override("font_size",11)
	stack.add_child(_notice)
	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation",16)
	stack.add_child(body)
	var list_scroll := ScrollContainer.new()
	list_scroll.custom_minimum_size = Vector2(246,180)
	list_scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	list_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	list_scroll.follow_focus = true
	body.add_child(list_scroll)
	_list = VBoxContainer.new()
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation",4)
	list_scroll.add_child(_list)
	var detail_column := VBoxContainer.new()
	detail_column.custom_minimum_size = Vector2(0,180)
	detail_column.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	body.add_child(detail_column)
	_detail = RichTextLabel.new()
	_detail.bbcode_enabled = true
	_detail.custom_minimum_size = Vector2(0,144)
	_detail.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_detail.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_detail.add_theme_font_size_override("normal_font_size",13)
	detail_column.add_child(_detail)
	_upgrade_button = Button.new()
	_upgrade_button.pressed.connect(_train_selected)
	detail_column.add_child(_upgrade_button)
	var slot_header := HBoxContainer.new()
	stack.add_child(slot_header)
	var slot_title := Label.new()
	slot_title.text = "COMBAT SLOTS · 1–5 / 6–0"
	slot_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	slot_title.add_theme_font_size_override("font_size",12)
	slot_header.add_child(slot_title)
	_clear_button = Button.new()
	_clear_button.text = "Clear selected slot"
	_clear_button.tooltip_text = "Clear the last slot you clicked. Right-click also clears a slot."
	_clear_button.pressed.connect(func() -> void: _equip_selected(_last_slot,true))
	slot_header.add_child(_clear_button)
	_slots = GridContainer.new()
	_slots.columns = 5
	_slots.add_theme_constant_override("h_separation",6)
	_slots.add_theme_constant_override("v_separation",6)
	stack.add_child(_slots)
	_status = Label.new()
	_status.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_status.custom_minimum_size = Vector2(784,28)
	_status.add_theme_font_size_override("font_size",11)
	_status.text = "Changes take effect immediately. Press Esc to return."
	stack.add_child(_status)
	_selected = String(library.entries()[0].definition.ability_id)
	library.library_changed.connect(_refresh)
	get_viewport().size_changed.connect(_center_panel)
	_refresh()
	_center_panel.call_deferred()
	_list.get_child(0).grab_focus()

func _center_panel() -> void:
	_panel.size = Vector2(820,460)
	_panel.position = (get_viewport().get_visible_rect().size-_panel.size)/2

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()

func _refresh() -> void:
	var focused := get_viewport().gui_get_focus_owner()
	var focus_name: StringName = focused.name if focused != null and is_ancestor_of(focused) else &""
	for container in [_list,_slots]:
		for child in container.get_children():
			container.remove_child(child)
			child.queue_free()
	_notice.text = "Select a technique, then click a combat slot to assign it. Occupied slots swap; right-click clears." if library.can_edit() else "Loadout is read-only here. Return to Sanctuary to arrange skills and visit Eira to train."
	if library.is_lab(): _notice.text = "Lab preview only. Select a technique, then a slot to assign it; right-click clears."
	_core_button.disabled = not library.can_edit()
	_clear_button.disabled = not library.can_edit() or _last_slot == 0 or library.actor.skill_loadout.get_slot(_last_slot).ability == null
	var techniques := library.entries()
	techniques.sort_custom(func(a: AbilityComponent,b: AbilityComponent) -> bool: return KingSkillCatalog.IDS.find(String(a.definition.ability_id)) < KingSkillCatalog.IDS.find(String(b.definition.ability_id)))
	for ability in techniques:
		var id := String(ability.definition.ability_id)
		var button := Button.new()
		button.name = "Technique_"+id
		var assigned: int = library.current_ids().find(id)+1
		var key := library.actor.skill_loadout.get_slot(assigned).get_key_label() if assigned > 0 else "—"
		button.text = "%s\n%s" % [ability.definition.display_name,"Slot "+key if assigned > 0 else "Not equipped"]
		button.icon = ability.definition.icon
		button.expand_icon = true
		button.add_theme_constant_override("icon_max_width",24)
		button.alignment = HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y = 36
		button.add_theme_font_size_override("font_size",11)
		button.toggle_mode = true
		button.set_pressed_no_signal(id == _selected)
		button.pressed.connect(func() -> void: _selected = id; _refresh())
		_list.add_child(button)
		if id == _selected:
			_detail.text = "[b]"+ability.definition.display_name+"[/b]\n"+ability.definition.description
			_detail.text += "\n\n[b]Equipped:[/b] "+("slot "+key if assigned > 0 else "not assigned")
	_refresh_training()
	for index in SkillLoadoutDefinition.SLOT_COUNT:
		var slot := library.actor.skill_loadout.get_slot(index+1)
		var button := Button.new()
		button.name = "Slot%d" % (index+1)
		button.text = "[%s] %s" % [slot.get_key_label(),slot.ability.hud_name if slot.ability else "EMPTY"]
		button.custom_minimum_size = Vector2(148,38)
		button.add_theme_font_size_override("font_size",10)
		button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		button.disabled = not library.can_edit() or not library.is_learned(_selected)
		button.tooltip_text = "Assign selected technique to slot %s. Existing skills swap. Right-click to clear." % slot.get_key_label()
		button.pressed.connect(_equip_selected.bind(index+1,false))
		button.gui_input.connect(func(event: InputEvent) -> void:
			if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_RIGHT:
				button.accept_event()
				_equip_selected(index+1,true))
		_slots.add_child(button)
		if slot.ability != null and String(slot.ability.ability_id) == _selected:
			button.modulate = Color("d7bf81")
	if not focus_name.is_empty():
		var restored := _panel.find_child(String(focus_name),true,false) as Control
		if restored != null: restored.grab_focus()
	_center_panel.call_deferred()

func _refresh_training() -> void:
	var required := 0
	var eligible := false
	var rank := 0
	var next := ""
	var session := library.get_node("/root/RunSession")
	match _selected:
		"sovereign_pursuit":
			required = library.get_pursuit_upgrade_level()
			eligible = library.can_upgrade_pursuit(trainer_access)
			rank = session.king_pursuit_rank
			next = "%d aimed uses · %d px reach" % [rank+2,[250,280][mini(rank,1)]]
		"unbroken_vow":
			required = library.get_vow_upgrade_level()
			eligible = library.can_upgrade_vow(trainer_access)
			rank = session.king_vow_rank
			next = "Advanced: movement bonus" if rank == 0 else "Mature: empowered third basic strike"
		"king_skill_4":
			required = library.get_worldsplitter_upgrade_level()
			eligible = library.can_upgrade_worldsplitter(trainer_access)
			rank = session.king_worldsplitter_rank
			next = "%d summoned blades" % (rank+2)
		_:
			_detail.text += "\n\n[b]Technique:[/b] Ready to equip."
	_upgrade_button.visible = _selected in ["sovereign_pursuit","unbroken_vow","king_skill_4"] and not library.is_lab()
	if not _upgrade_button.visible: return
	_detail.text += "\n[b]Rank:[/b] "+["Foundation","Advanced","Mature"][clampi(rank,0,2)]
	if required == 0:
		_detail.text += "\n[b]Training:[/b] Fully trained."
		_upgrade_button.text = "Fully trained"
	elif not trainer_access:
		_detail.text += "\n[b]Next:[/b] "+next+"\nVisit Eira · requires Level %d (current %d)." % [required,library.actor.progression_component.level]
		_upgrade_button.text = "Visit Eira to train"
	else:
		_detail.text += "\n[b]Next:[/b] "+next+"\n[b]Requirement:[/b] Level %d · current Level %d" % [required,library.actor.progression_component.level]
		_upgrade_button.text = "Train next rank" if eligible else "Requires Level %d" % required
	_upgrade_button.disabled = not eligible

func _equip_selected(slot_number: int, clear: bool) -> void:
	if slot_number <= 0: return
	_last_slot = slot_number
	var slot := library.actor.skill_loadout.get_slot(slot_number)
	var key := slot.get_key_label()
	var previous := slot.get_display_name()
	var selected_name := ""
	for ability in library.entries():
		if String(ability.definition.ability_id) == _selected: selected_name = ability.definition.display_name
	if library.equip("" if clear else _selected,slot_number):
		_status.text = "Slot %s cleared." % key if clear else "%s assigned to [%s]. Previous skill: %s." % [selected_name,key,previous]
		_slots.get_child(slot_number-1).grab_focus()
	else:
		_status.text = "Loadout could not be changed. Return to Sanctuary when King is ready."

func _restore_core() -> void:
	_status.text = "Core skills restored to slots 1–5." if library.equip_core_kit() else "Loadout could not be changed right now."

func _train_selected() -> void:
	var trained := false
	match _selected:
		"sovereign_pursuit": trained = library.upgrade_pursuit(trainer_access)
		"unbroken_vow": trained = library.upgrade_vow(trainer_access)
		"king_skill_4": trained = library.upgrade_worldsplitter(trainer_access)
	_status.text = "Training complete. Your skill and combat slots are updated." if trained else "Training was not applied. Check requirements or try again."

func _close() -> void:
	if _owns_pause: get_tree().paused = false
	queue_free()
