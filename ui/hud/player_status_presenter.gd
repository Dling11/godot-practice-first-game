extends Node

## Event-driven HUD presentation. Health/progression components retain authority.
const Readout = preload("res://ui/hud/progression_readout.gd")
var hud: CombatHUD
var frame: Panel
var health_trail: ProgressBar
var health_state: Label
var level_toast: PanelContainer
var _toast_text: Label
var _health_tween: Tween
var _toast_tween: Tween
var _last_health := -1.0
var _last_maximum := -1.0
var actor: Player

func configure(owner_hud: CombatHUD) -> void:
	hud = owner_hud
	frame = Panel.new()
	frame.name = "SlimRunicFrame"
	frame.position = Vector2(12,12)
	frame.size = Vector2(248,38)
	frame.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	var style := StyleBoxTexture.new()
	style.texture = preload("res://assets/ui/player_readability/slim_runic_hp.png")
	frame.add_theme_stylebox_override("panel",style)
	hud.add_child(frame)
	hud.move_child(frame,0)
	# The small HP frame owns only health; growth remains a separate quiet row.
	_place(hud.get_node("ProgressPanel"),Rect2(12,67,248,49))
	hud.get_node("ProgressPanel").add_theme_stylebox_override("panel",_flat(Color("131c28"),Color("514b44")))
	_place(hud.character_menu_button,Rect2(12,132,248,30))
	hud.character_menu_button.add_theme_font_size_override("font_size",11)
	var button_style := _flat(Color("131c28"),Color("827052"))
	button_style.set_content_margin_all(4)
	hud.character_menu_button.add_theme_stylebox_override("normal",button_style)
	hud.character_menu_button.add_theme_stylebox_override("hover",_flat(Color("30283d"),Color("c0a66a")))
	hud.level_label.add_theme_font_size_override("font_size",11)
	hud.coin_label.add_theme_font_size_override("font_size",10)
	hud.experience_label.add_theme_font_size_override("font_size",9)
	hud.experience_label.mouse_filter = Control.MOUSE_FILTER_STOP
	hud.experience_bar.custom_minimum_size.y = 6
	hud.experience_bar.add_theme_stylebox_override("background",_flat(Color("0b111a"),Color("435066")))
	hud.experience_bar.add_theme_stylebox_override("fill",_flat(Color("668dc1"),Color("aacce5")))
	var label := hud.health_label
	var label_owner := label.owner
	label.get_parent().remove_child(label)
	frame.add_child(label)
	label.owner = label_owner
	_place(label,Rect2(66,3,116,13))
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size",10)
	health_state = Label.new()
	health_state.name = "HealthState"
	health_state.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	health_state.add_theme_font_size_override("font_size",9)
	health_state.add_theme_color_override("font_outline_color",Color("110e17"))
	health_state.add_theme_constant_override("outline_size",2)
	hud.add_child(health_state)
	_place(health_state,Rect2(12,51,248,12))
	# Two overlaid bars: the live red value is immediate; gold shows recent loss.
	var bar := hud.health_bar
	var bar_owner := bar.owner
	bar.get_parent().remove_child(bar)
	var track := Control.new()
	track.name = "HealthTrack"
	track.mouse_filter = Control.MOUSE_FILTER_IGNORE
	frame.add_child(track)
	_place(track,Rect2(17,20,214,9))
	health_trail = ProgressBar.new()
	health_trail.show_percentage = false
	health_trail.mouse_filter = Control.MOUSE_FILTER_IGNORE
	health_trail.add_theme_stylebox_override("background",_flat(Color("110e17"),Color("5d4650")))
	health_trail.add_theme_stylebox_override("fill",_flat(Color("bc9b61"),Color("f1d89a")))
	track.add_child(health_trail)
	health_trail.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	track.add_child(bar)
	bar.owner = bar_owner
	bar.custom_minimum_size = Vector2.ZERO
	bar.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	bar.add_theme_stylebox_override("background",StyleBoxEmpty.new())
	bar.add_theme_stylebox_override("fill",_flat(Color("ae404e"),Color("e16a71")))
	hud.get_node("HealthPanel").hide()
	level_toast = PanelContainer.new()
	level_toast.name = "LevelUpNotice"
	level_toast.position = Vector2(12,214)
	level_toast.size = Vector2(248,52)
	level_toast.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var toast_style := _flat(Color("171e2d"),Color("c3a76a"))
	toast_style.set_content_margin_all(8)
	level_toast.add_theme_stylebox_override("panel",toast_style)
	hud.add_child(level_toast)
	_toast_text = Label.new()
	_toast_text.custom_minimum_size.x = 232
	_toast_text.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_toast_text.add_theme_font_size_override("font_size",11)
	level_toast.add_child(_toast_text)
	level_toast.hide()

func bind_player(player: Player) -> void:
	actor = player
	player.progression_component.leveled_up.connect(_show_level_up)

func set_health(current: float, maximum: float) -> void:
	var lost_health := _last_health >= 0 and current < _last_health and is_equal_approx(maximum,_last_maximum)
	if is_instance_valid(_health_tween): _health_tween.kill()
	health_trail.max_value = maximum
	if lost_health:
		health_trail.value = maxf(health_trail.value,_last_health)
		_health_tween = create_tween()
		_health_tween.tween_interval(.25)
		_health_tween.tween_property(health_trail,"value",current,.55)
	else:
		health_trail.value = current
	var critical := current > 0 and current/maximum <= .25
	health_state.text = "CRITICAL" if critical else ("DEFEATED" if current <= 0 else "")
	health_state.add_theme_color_override("font_color",Color("ff8a80"))
	hud.health_label.add_theme_color_override("font_color",Color("ff9c91") if critical else Color("f6e5d0"))
	hud.health_bar.add_theme_stylebox_override("fill",_flat(Color("d5363e") if critical else Color("ae404e"),Color("ef8b83") if critical else Color("e16a71")))
	var delay: float = actor.vitality_component.definition.regeneration_delay_seconds if is_instance_valid(actor) else 5.0
	hud.health_label.tooltip_text = "Vitality · %d%% remaining. Regeneration starts after %s seconds without damage." % [roundi(100*current/maximum),str(delay)]
	_last_health = current
	_last_maximum = maximum

func _show_level_up(level: int) -> void:
	if is_instance_valid(_toast_tween): _toast_tween.kill()
	_toast_text.text = "LEVEL UP · %d\n%s" % [level,Readout.training_at(level)]
	level_toast.modulate.a = 1
	level_toast.show()
	_toast_tween = create_tween()
	_toast_tween.tween_interval(3)
	_toast_tween.tween_property(level_toast,"modulate:a",0,.3)
	_toast_tween.tween_callback(level_toast.hide)

func _place(control: Control, rect: Rect2) -> void:
	control.position = rect.position
	control.size = rect.size

func _flat(background: Color, border: Color) -> StyleBoxFlat:
	var style := StyleBoxFlat.new()
	style.bg_color = background
	style.border_color = border
	style.set_border_width_all(1)
	return style
