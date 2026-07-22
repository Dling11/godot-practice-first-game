extends Node

@export var player: Player
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu
@export var encounter_controller: EncounterController

var _restart_enabled := false


func _ready() -> void:
	if player == null or combat_hud == null or character_menu == null or encounter_controller == null:
		push_error("Stage2Flow requires Player, CombatHUD, CharacterMenu, and EncounterController.")
		return
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	player.defeated.connect(_on_player_defeated)
	encounter_controller.stage_cleared.connect(_on_stage_cleared)
	_begin_stage()


func _begin_stage() -> void:
	combat_hud.show_story_message("THE THORNS REMEMBER YOUR FOOTSTEPS", 2.5)
	await get_tree().create_timer(2.0).timeout
	if is_instance_valid(encounter_controller):
		encounter_controller.start_encounter()


func _unhandled_input(event: InputEvent) -> void:
	if _restart_enabled and event.is_action_pressed("arena_restart"):
		var run_session := get_node_or_null("/root/RunSession")
		if run_session != null:
			run_session.reset_run()
		get_tree().reload_current_scene()


func _on_stage_cleared() -> void:
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.remember_story(&"forgotten_grove_completed")
		story_state.record_discovery(&"remembered_thorn_shrine")
	combat_hud.show_story_message("THE GROVE RELENTS  •  THE HOLLOW OPENS", 2.8)


func _on_player_defeated() -> void:
	await get_tree().create_timer(0.4).timeout
	combat_hud.show_defeat()
	_restart_enabled = true
