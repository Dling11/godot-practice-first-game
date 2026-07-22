class_name DialoguePanel
extends Control

signal dialogue_closed(completed: bool)

@onready var speaker_label: Label = %SpeakerLabel
@onready var body_label: Label = %BodyLabel
@onready var continue_button: Button = %ContinueButton
@onready var portrait: TextureRect = %Portrait

var _lines: Array[String] = []
var _line_index := 0
var _owns_pause := false
var _accept_input := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if not visible or not _accept_input:
		return
	if event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_dialogue(false)
		return
	if event.is_action_pressed("player_interact") or event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		advance()


func show_dialogue(speaker: String, lines: Array[String], portrait_texture: Texture2D = null) -> void:
	if lines.is_empty():
		return
	Input.mouse_mode = Input.MOUSE_MODE_VISIBLE
	_lines = lines.duplicate()
	_line_index = 0
	speaker_label.text = speaker
	portrait.texture = portrait_texture
	portrait.visible = portrait_texture != null
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	show()
	_show_current_line()
	_accept_input = false
	continue_button.disabled = true
	call_deferred("_enable_input")


func advance() -> void:
	if not visible:
		return
	_line_index += 1
	if _line_index >= _lines.size():
		close_dialogue(true)
		return
	_show_current_line()


func close_dialogue(completed := false) -> void:
	if not visible:
		return
	hide()
	_accept_input = false
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	dialogue_closed.emit(completed)


func _show_current_line() -> void:
	body_label.text = _lines[_line_index]
	continue_button.text = "F / ENTER  •  %s" % ("CLOSE" if _line_index == _lines.size() - 1 else "CONTINUE")


func _enable_input() -> void:
	_accept_input = true
	continue_button.disabled = false
	continue_button.grab_focus()
