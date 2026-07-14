class_name ExpeditionMenu
extends Control

signal menu_closed

@export_file("*.tscn") var first_expedition_scene := "res://levels/test_arena/test_arena.tscn"
@onready var first_expedition_button: Button = %FirstExpeditionButton
@onready var close_button: Button = %CloseButton
var _owns_pause := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()


func open_menu() -> void:
	if visible: return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_owns_pause = not get_tree().paused
	if _owns_pause: get_tree().paused = true
	show()
	first_expedition_button.grab_focus()


func close_menu() -> void:
	if not visible: return
	hide()
	if _owns_pause: get_tree().paused = false
	_owns_pause = false
	menu_closed.emit()


func begin_first_expedition() -> void:
	if not ResourceLoader.exists(first_expedition_scene): return
	if _owns_pause: get_tree().paused = false
	_owns_pause = false
	var transition_service := get_node_or_null("/root/SceneTransition")
	if transition_service != null:
		transition_service.transition_to(first_expedition_scene)
