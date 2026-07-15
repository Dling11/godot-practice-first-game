extends Node

@export var player: Player
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu

var _restart_enabled := false


func _ready() -> void:
	if player == null or combat_hud == null or character_menu == null:
		push_error("ArenaFlow requires a Player, CombatHUD, and CharacterMenu.")
		return
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	player.defeated.connect(_on_player_defeated)


func _unhandled_input(event: InputEvent) -> void:
	if _restart_enabled and event.is_action_pressed("arena_restart"):
		restart_arena()


func restart_arena() -> void:
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		run_session.reset_run()
	get_tree().reload_current_scene()


func _on_player_defeated() -> void:
	await get_tree().create_timer(0.4).timeout
	combat_hud.show_defeat()
	_restart_enabled = true
