extends CanvasLayer

var library: KingSkillLibrary
var _selected := ""
var _detail: RichTextLabel
var _list: VBoxContainer
var _slots: HBoxContainer
var _notice: Label
var _owns_pause := false

func _ready() -> void:
	layer=110
	process_mode=Node.PROCESS_MODE_ALWAYS
	_owns_pause=not get_tree().paused
	get_tree().paused=true
	var veil := ColorRect.new()
	veil.color=Color(0.02,.03,.045,.86)
	veil.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	add_child(veil)
	var panel := PanelContainer.new()
	panel.theme=preload("res://assets/ui/themes/battle_of_gods_theme.tres")
	panel.position=Vector2(70,48)
	panel.size=Vector2(820,444)
	var style := StyleBoxFlat.new()
	style.bg_color=Color("111d29")
	style.border_color=Color("80734f")
	style.set_border_width_all(2)
	style.set_content_margin_all(18)
	panel.add_theme_stylebox_override("panel",style)
	panel.add_theme_font_size_override("font_size",12)
	add_child(panel)
	var stack := VBoxContainer.new()
	stack.add_theme_constant_override("separation",10)
	panel.add_child(stack)
	var header := HBoxContainer.new()
	stack.add_child(header)
	var title := Label.new()
	title.text="KING  /  TECHNIQUE COLLECTION"
	title.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	title.add_theme_font_size_override("font_size",16)
	header.add_child(title)
	var close := Button.new()
	close.text="Close"
	close.pressed.connect(_close)
	header.add_child(close)
	_notice=Label.new()
	_notice.add_theme_font_size_override("font_size",11)
	stack.add_child(_notice)
	if library.is_lab():
		var preview := HBoxContainer.new()
		stack.add_child(preview)
		var label := Label.new()
		label.text="LAB FORM"
		preview.add_child(label)
		var ranks := OptionButton.new()
		ranks.add_item("Campaign progression")
		for form in KingOathDefinition.RANK_NAMES:
			ranks.add_item(form+" preview")
		ranks.select(library.preview_rank+1)
		ranks.item_selected.connect(func(index: int) -> void: library.set_preview_rank(index-1))
		preview.add_child(ranks)
		var preset := Button.new()
		preset.text="Equip all four Oath skills"
		preset.pressed.connect(func() -> void:
			if library.equip_oath_preview():
				ranks.select(library.preview_rank+1)
		)
		preview.add_child(preset)
	var body := HBoxContainer.new()
	body.add_theme_constant_override("separation",18)
	stack.add_child(body)
	_list=VBoxContainer.new()
	_list.custom_minimum_size=Vector2(255,280)
	body.add_child(_list)
	_detail=RichTextLabel.new()
	_detail.bbcode_enabled=true
	_detail.custom_minimum_size=Vector2(475,280)
	_detail.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	_detail.add_theme_font_size_override("normal_font_size",13)
	body.add_child(_detail)
	_slots=HBoxContainer.new()
	_slots.add_theme_constant_override("separation",6)
	stack.add_child(_slots)
	_selected=String(library.entries()[0].definition.ability_id)
	library.library_changed.connect(_refresh)
	_refresh()
	close.grab_focus()

func _input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		_close()

func _refresh() -> void:
	for child in _list.get_children():
		_list.remove_child(child)
		child.queue_free()
	for child in _slots.get_children():
		_slots.remove_child(child)
		child.queue_free()
	_notice.text="Learn techniques. Equip four. Swap in Sanctuary." if not library.is_lab() else "Combat Lab preview · future forms do not change campaign progress."
	for ability in library.entries():
		var id := String(ability.definition.ability_id)
		var button := Button.new()
		button.text=ability.definition.display_name+("  [LOCKED]" if not library.is_learned(id) else "")
		button.icon=ability.definition.icon
		button.alignment=HORIZONTAL_ALIGNMENT_LEFT
		button.custom_minimum_size.y=30
		button.add_theme_font_size_override("font_size",12)
		button.pressed.connect(func() -> void: _selected=id; _refresh())
		_list.add_child(button)
		if id==_selected:
			button.modulate=Color("aee8ff")
			_detail.text="[b]"+ability.definition.display_name+"[/b]\n\n"+ability.definition.description
			if ability is KingOathComponent:
				var tuning := ability.definition as KingOathDefinition
				_detail.text+="\n\n[b]EVOLUTION[/b]\n"+" → ".join(KingOathDefinition.NAMES[tuning.technique])
				_detail.text+="\n\nMortal → Stage V: Resonant\nAscendant / Unbound: future story milestones; Lab preview available."
				if not library.is_learned(id):
					_detail.text+="\n\n[b]Learn after clearing Stage "+("II" if id=="griefwake" else "V")+".[/b]"
			if not library.can_edit():
				_detail.text+="\n\nReturn to Sanctuary to change equipped techniques."
	for i in 4:
		var slot := library.actor.skill_loadout.get_slot(i+1)
		var button := Button.new()
		button.text="[%d]  %s" % [i+1,slot.ability.hud_name if slot.ability else "SEALED"]
		button.add_theme_font_size_override("font_size",11)
		button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
		button.custom_minimum_size.y=32
		button.disabled=not library.can_edit() or not library.is_learned(_selected)
		button.tooltip_text="Equip selected technique in slot "+str(i+1)
		button.pressed.connect(func() -> void: library.equip(_selected,i+1))
		_slots.add_child(button)

func _close() -> void:
	if _owns_pause:
		get_tree().paused=false
	queue_free()
