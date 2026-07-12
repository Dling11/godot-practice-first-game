extends Node

@export var player: Player
@export var combat_hud: CombatHUD

var _restart_enabled := false


func _ready() -> void:
	if player == null or combat_hud == null:
		push_error("ArenaFlow requires a Player and CombatHUD.")
		return
	combat_hud.bind_player(player)
	player.defeated.connect(_on_player_defeated)


func _unhandled_input(event: InputEvent) -> void:
	if _restart_enabled and event.is_action_pressed("arena_restart"):
		restart_arena()


func restart_arena() -> void:
	get_tree().reload_current_scene()


func _on_player_defeated() -> void:
	await get_tree().create_timer(0.4).timeout
	combat_hud.show_defeat()
	_restart_enabled = true

