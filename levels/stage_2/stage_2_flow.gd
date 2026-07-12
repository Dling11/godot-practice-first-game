extends Node

@export var player: Player
@export var combat_hud: CombatHUD
@export var return_portal: StagePortal


func _ready() -> void:
	combat_hud.bind_player(player)
	return_portal.proximity_changed.connect(combat_hud.show_interaction_prompt)
