extends Node

## Reversible presentation for the real modal controls. No duplicate menu/service authority.
const ThemeKit = preload("res://ui/themes/sanctuary_theme.gd")
var _modals: Array[Dictionary] = []
var _portraits: Array[Dictionary] = []
var _theme: Theme
var _hud: Control
var _tray: Control
var _compact: Panel
var _old_tray: Vector2
var _enabled := false
var _collection_panels: Array[Dictionary] = []
var _hints: Array[Dictionary] = []
var _review_controls: Control
var _fonts: Array[Dictionary] = []
var _town_map: Node
var _study: Node

func configure(hub: Node, review_controls: Control) -> void:
	_review_controls = review_controls
	_study = hub.get_node("SanctuaryStudy")
	_town_map = _study.town_map
	_theme = ThemeKit.build()
	var library := hub.get_node("World/Actors/Player/KingSkillLibrary")
	library.child_entered_tree.connect(func(child: Node) -> void:
		if child.get_script() != null and child.get_script().resource_path == "res://ui/skills/king_skill_collection.gd":
			child.ready.connect(_on_collection_ready.bind(child),CONNECT_ONE_SHOT))
	for modal: Control in [hub.dialogue_panel,hub.character_menu,hub.rootforge_menu,hub.umi_exchange_menu,hub.expedition_menu,hub.get_node("UI/PauseMenu")]:
		var panel: PanelContainer = modal.get_node("Panel")
		_modals.append({"node":modal,"theme":modal.theme,"panel":panel,
			"override":panel.get_theme_stylebox("panel") if panel.has_theme_stylebox_override("panel") else null})
		modal.visibility_changed.connect(_sync_review_controls)
	for recipe in [[hub.dialogue_panel.skip_button,11],[hub.dialogue_panel.continue_button,10],[hub.dialogue_panel.body_label,12]]:
		_fonts.append({"node":recipe[0],"size":recipe[1],"old":recipe[0].get_theme_font_size("font_size"),"override":recipe[0].has_theme_font_size_override("font_size")})
	for recipe in [[hub.rootforge_menu,"rootweaver"],[hub.umi_exchange_menu,"umi"]]:
		var portrait: TextureRect = recipe[0].get_node("Panel/Margin/Root/Header/Portrait")
		_portraits.append({"node":portrait,"old":portrait.texture,"new":load("res://assets/characters/npcs/"+recipe[1]+"/renewal/portrait.png")})
	_hud = hub.combat_hud
	_tray = _hud.get_node("ActionTray")
	_old_tray = Vector2(_tray.offset_top,_tray.offset_bottom)
	for node_name in ["ResolveLabel"]:
		var hint: Control = _hud.get_node(node_name)
		_hints.append({"node":hint,"top":hint.offset_top,"bottom":hint.offset_bottom})
	_compact = Panel.new()
	_compact.name = "CompactSanctuaryFrame"
	_compact.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_compact.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	_hud.add_child(_compact)
	_hud.move_child(_compact,_tray.get_index())
	_compact.set_anchors_and_offsets_preset(Control.PRESET_CENTER_BOTTOM)
	_compact.offset_left = -330
	_compact.offset_right = 330
	_compact.offset_top = -68
	_compact.offset_bottom = -2
	_compact.add_theme_stylebox_override("panel",ThemeKit.frame())

func set_enabled(value: bool) -> void:
	_enabled = value
	for record in _modals:
		record.node.theme = _theme if value else record.theme
		if value: record.panel.add_theme_stylebox_override("panel",ThemeKit.frame())
		elif record.override != null: record.panel.add_theme_stylebox_override("panel",record.override)
		else: record.panel.remove_theme_stylebox_override("panel")
	for record in _portraits: record.node.texture = record.new if value else record.old
	for record in _fonts:
		if value: record.node.add_theme_font_size_override("font_size",record.size)
		elif record.override: record.node.add_theme_font_size_override("font_size",record.old)
		else: record.node.remove_theme_font_size_override("font_size")
	_hud.get_node("EclipseFrame").visible = not value
	_hud.get_node("EclipseVeil").visible = not value
	_compact.visible = value
	_tray.offset_top = -62 if value else _old_tray.x
	_tray.offset_bottom = -8 if value else _old_tray.y
	for record in _hints:
		record.node.offset_top = record.top+34 if value else record.top
		record.node.offset_bottom = record.bottom+34 if value else record.bottom
	for record in _collection_panels:
		if not is_instance_valid(record.node): continue
		record.node.theme = _theme if value else record.theme
		record.node.add_theme_stylebox_override("panel",ThemeKit.frame(18) if value else record.style)

func _on_collection_ready(collection: Node) -> void:
	_collection_panels = _collection_panels.filter(func(record: Dictionary) -> bool: return is_instance_valid(record.node))
	collection.tree_exited.connect(_sync_review_controls)
	for child in collection.get_children():
		if child is PanelContainer:
			_collection_panels.append({"node":child,"theme":child.theme,"style":child.get_theme_stylebox("panel")})
			if _enabled:
				child.theme = _theme
				child.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
				child.add_theme_stylebox_override("panel",ThemeKit.frame(18))
	_sync_review_controls()

func _sync_review_controls() -> void:
	var modal_open := false
	for record in _modals: modal_open = modal_open or record.node.visible
	for record in _collection_panels:
		if is_instance_valid(record.node): modal_open = modal_open or record.node.is_inside_tree()
	var inside: bool = _study.workshop_visit != null and _study.workshop_visit.inside
	_review_controls.visible = not modal_open and not inside
	if _study.workshop_visit != null: _study.workshop_visit.set_modal_open(modal_open)
	if modal_open: _town_map.hide_for_modal()
