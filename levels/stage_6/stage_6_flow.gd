class_name Stage6EnvironmentFlow
extends Node

const ExpeditionDefeatReturnScript = preload(
	"res://gameplay/expeditions/expedition_defeat_return.gd"
)

@export var player: Player
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu

var _defeat_return_enabled := false


func _ready() -> void:
	if player == null or combat_hud == null or character_menu == null:
		push_error("Stage6EnvironmentFlow is missing a required preview dependency.")
		return
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	player.defeated.connect(_on_player_defeated)
	combat_hud.show_story_message("STAGE VI  •  THE ELDER ASCENT", 3.2)
	await get_tree().create_timer(3.35).timeout
	combat_hud.show_story_message("THE FOREST OPENS ABOVE AN ANCIENT DEEP", 2.8)


func _unhandled_input(event: InputEvent) -> void:
	if not _defeat_return_enabled or not event.is_action_pressed("arena_restart"):
		return
	ExpeditionDefeatReturnScript.request(self)


func _on_player_defeated() -> void:
	await get_tree().create_timer(0.4).timeout
	combat_hud.show_defeat()
	_defeat_return_enabled = true
