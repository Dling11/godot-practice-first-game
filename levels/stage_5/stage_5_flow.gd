extends Node

const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")

@export var player: Player
@export var boss: Stage5Boss
@export var combat_hud: CombatHUD
@export var character_menu: CharacterMenu
@export var boss_hud: BossHealthHUD
@export var boss_trigger: Area2D
@export var portal_parent: Node2D
@export var portal_spawn_point: Marker2D
@export var dialogue_panel: DialoguePanel
@export var boss_portrait: Texture2D
@export var boss_music: AudioStream
@export var entrance_descent: AudioStreamPlayer
@export var entrance_landing: AudioStreamPlayer

var _boss_started := false
var _restart_enabled := false


func _ready() -> void:
	if (
		player == null
		or boss == null
		or combat_hud == null
		or character_menu == null
		or boss_hud == null
		or boss_trigger == null
		or portal_parent == null
		or portal_spawn_point == null
	):
		push_error("Stage5Flow is missing a required dependency.")
		return
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.begin_expedition()
	combat_hud.bind_player(player)
	combat_hud.character_menu_requested.connect(character_menu.open_menu)
	player.defeated.connect(_on_player_defeated)
	boss.health_component.died.connect(_on_boss_died)
	boss.target = null
	boss.set_physics_process(false)
	boss.visible = false
	boss_trigger.body_entered.connect(_on_boss_trigger_entered)
	combat_hud.show_story_message("STAGE V  •  THE DEAD FOREST", 3.0)


func _on_boss_trigger_entered(body: Node2D) -> void:
	if _boss_started or body != player:
		return
	_boss_started = true
	boss_trigger.set_deferred("monitoring", false)
	_run_boss_entrance()


func _run_boss_entrance() -> void:
	if dialogue_panel == null or boss_portrait == null or boss_music == null or entrance_descent == null or entrance_landing == null:
		push_error("Stage5Flow is missing an entrance presentation dependency: dialogue=%s portrait=%s music=%s descent=%s landing=%s" % [dialogue_panel != null, boss_portrait != null, boss_music != null, entrance_descent != null, entrance_landing != null])
		return
	combat_hud.show_story_message("THE GROVE HOLDS ITS BREATH", 1.0)
	await get_tree().create_timer(0.65).timeout
	boss.visible = true
	entrance_descent.play()
	var visual := boss.get_node_or_null("Visual")
	if visual != null:
		visual.call("set_jump_height", 158.0)
		var descent := create_tween().set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		descent.tween_method(func(height: float) -> void: visual.call("set_jump_height", height), 158.0, 0.0, 0.62)
		await descent.finished
	entrance_landing.play()
	boss.play_entrance_landing()
	await get_tree().create_timer(0.22).timeout
	dialogue_panel.dialogue_closed.connect(_on_boss_dialogue_closed, CONNECT_ONE_SHOT)
	dialogue_panel.show_dialogue(
		"VARKUUN, LORD OF THE WITHERED GROVE",
		[
			"You crossed the grave of my grove and called its silence victory.",
			"These roots fed your roads before your blood learned fear.",
			"Kneel, wanderer. Let the dead forest remember your name.",
		],
		boss_portrait
	)
	if DisplayServer.get_name() == "headless":
		dialogue_panel.close_dialogue(true)


func _on_boss_dialogue_closed(_completed: bool) -> void:
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.play_music(boss_music, -7.0)
	boss.target = player
	boss.set_physics_process(true)
	boss_hud.bind_boss(boss.health_component, "VARKUUN, LORD OF THE WITHERED GROVE", "DEAD FOREST")
	combat_hud.show_story_message("THE WITHERED GROVE ANSWERS", 2.0)


func _on_boss_died() -> void:
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.commit_expedition_rewards()
	var story_state := get_node_or_null("/root/StoryState")
	if story_state != null:
		story_state.remember_story(&"forest_stage_5_cleared")
		story_state.record_boss_victory(&"stage_5_boss")
		story_state.record_discovery(&"dead_forest")
	var save_service := get_node_or_null("/root/SaveService")
	if save_service != null:
		save_service.save_profile()
	combat_hud.show_story_message("THE DEAD FOREST FALLS SILENT", 3.0)
	_spawn_return_portal()


func _spawn_return_portal() -> void:
	var portal := PortalScene.instantiate() as StagePortal
	portal.target_scene_path = "res://levels/sanctuary/sanctuary.tscn"
	portal_parent.add_child(portal)
	portal.global_position = portal_spawn_point.global_position
	portal.proximity_changed.connect(combat_hud.show_interaction_prompt)


func _unhandled_input(event: InputEvent) -> void:
	if not _restart_enabled or not event.is_action_pressed("arena_restart"):
		return
	var loot_service := get_node_or_null("/root/LootService")
	if loot_service != null:
		loot_service.abort_expedition_rewards()
	var run_session := get_node_or_null("/root/RunSession")
	if run_session != null:
		run_session.reset_run()
	get_tree().reload_current_scene()


func _on_player_defeated() -> void:
	await get_tree().create_timer(0.4).timeout
	combat_hud.show_defeat()
	_restart_enabled = true
