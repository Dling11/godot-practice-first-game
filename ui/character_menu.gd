class_name CharacterMenu
extends Control

## Paused, read-only character and authored skill-path presentation.

signal menu_closed

@export var player: Player

@onready var level_label: Label = %LevelLabel
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var experience_label: Label = %ExperienceLabel
@onready var coin_label: Label = %CoinLabel
@onready var close_button: Button = %CloseButton

var _owns_pause := false


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	if player == null:
		push_error("CharacterMenu requires a Player reference.")
		return
	var progression := player.progression_component
	progression.progression_changed.connect(_update_progression)
	progression.coins_changed.connect(_update_coins)
	_update_progression(progression.level, progression.total_experience, 0)
	_update_coins(progression.coins)
	hide()


func _unhandled_input(event: InputEvent) -> void:
	if visible and event.is_action_pressed("ui_cancel"):
		get_viewport().set_input_as_handled()
		close_menu()
		return
	if visible or not event.is_action_pressed("player_character_menu"):
		return
	get_viewport().set_input_as_handled()
	open_menu()


func open_menu() -> void:
	if visible:
		return
	show()
	_owns_pause = not get_tree().paused
	if _owns_pause:
		get_tree().paused = true
	close_button.grab_focus()


func close_menu() -> void:
	if not visible:
		return
	hide()
	if _owns_pause:
		get_tree().paused = false
	_owns_pause = false
	menu_closed.emit()


func _exit_tree() -> void:
	if _owns_pause and get_tree() != null:
		get_tree().paused = false


func _update_progression(_level: int, _total_experience: int, _next_level_experience: int) -> void:
	if not is_instance_valid(player):
		return
	var progression := player.progression_component
	level_label.text = "LEVEL %d / %d" % [progression.level, progression.definition.maximum_level]
	if progression.level >= progression.definition.maximum_level:
		experience_bar.max_value = 1.0
		experience_bar.value = 1.0
		experience_label.text = "MAXIMUM LEVEL"
		return
	var required := progression.experience_required_for_current_level()
	experience_bar.max_value = required
	experience_bar.value = progression.experience_into_current_level()
	experience_label.text = "%d / %d XP" % [experience_bar.value, required]


func _update_coins(total_coins: int) -> void:
	coin_label.text = "%d COINS" % total_coins
