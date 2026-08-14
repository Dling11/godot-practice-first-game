extends Node

const LandingFeedback = preload("res://entities/enemies/stage_5_boss/stage_5_boss_landing_feedback.gd")
const ROSTER := [
	{"label": "Mireling", "scene": preload("res://entities/enemies/mireling/mireling.tscn")},
	{"label": "Rootling", "scene": preload("res://entities/enemies/rootling/rootling.tscn")},
	{"label": "Forsaken Thrall", "scene": preload("res://entities/enemies/forsaken_thrall/forsaken_thrall.tscn")},
	{"label": "Bramble Spitter", "scene": preload("res://entities/enemies/bramble_spitter/bramble_spitter.tscn")},
	{"label": "Armored Hog [ELITE]", "scene": preload("res://entities/enemies/armored_hog/armored_hog.tscn")},
	{"label": "Rootbound Husk [MINI-BOSS]", "scene": preload("res://entities/enemies/rootbound_husk/rootbound_husk.tscn")},
	{"label": "Stage 5 Boss [PROOF]", "scene": preload("res://entities/enemies/stage_5_boss/stage_5_boss.tscn")},
]
const ARENA_BOUNDS := Rect2(40.0, 92.0, 650.0, 390.0)

@export var player: Player
@export var actors: Node2D
@export var projectiles: Node2D
@export var effects: Node2D
@export var camera: Camera2D
@export var combat_hud: CombatHUD
@export var enemy_selector: OptionButton
@export var spawn_one_button: Button
@export var spawn_four_button: Button
@export var spawn_eight_button: Button
@export var clear_button: Button
@export var reset_button: Button
@export var exit_button: Button
@export var ai_toggle: CheckButton
@export var invincible_toggle: CheckButton
@export var combat_tools_button: Button
@export var status_label: Label
@export var latest_label: Label

var _active_enemies: Array[Node2D] = []
var _ai_enabled := true
var _invincible := true


func _ready() -> void:
	if not OS.is_debug_build():
		_transition_to_sanctuary()
		return
	if not _has_required_dependencies():
		push_error("CombatLab is missing a required dependency.")
		return
	var admin_state := get_node_or_null("/root/DebugAdminState")
	if admin_state != null:
		admin_state.call("set_enabled", true)
	combat_hud.bind_player(player)
	player.enable_debug_combat_tools()
	player.health_component.set_current_health(player.health_component.maximum_health)
	player.health_component.set_invulnerable(true)
	for entry: Dictionary in ROSTER:
		enemy_selector.add_item(String(entry["label"]))
	enemy_selector.select(ROSTER.size() - 1)
	_bind_controls()
	_update_latest_label()
	_update_status()
	combat_hud.show_story_message("ADMIN COMBAT LAB  |  REAL ACTORS  |  NO REWARDS OR SAVES", 3.5)
	call_deferred("spawn_selected", 1)


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_combat_lab"):
		get_viewport().set_input_as_handled()
		_transition_to_sanctuary()
	elif event.is_action_pressed("arena_restart"):
		get_viewport().set_input_as_handled()
		get_tree().reload_current_scene()


func spawn_selected(count: int) -> void:
	if not OS.is_debug_build() or enemy_selector.selected < 0:
		return
	var entry: Dictionary = ROSTER[enemy_selector.selected]
	var scene := entry["scene"] as PackedScene
	for index in range(clampi(count, 1, 8)):
		_spawn_enemy(scene, index, count)
	_update_latest_label()
	_update_status()


func clear_simulation() -> void:
	for enemy in _active_enemies.duplicate():
		if is_instance_valid(enemy):
			enemy.queue_free()
	_active_enemies.clear()
	_clear_children(projectiles)
	_clear_children(effects)
	latest_label.text = "LATEST: NONE"
	_update_status()


func set_enemy_ai_enabled(enabled: bool) -> void:
	_ai_enabled = enabled
	for enemy in _active_enemies:
		if is_instance_valid(enemy) and "target" in enemy:
			enemy.set("target", player if enabled else null)
	_update_status()


func set_player_invincible(enabled: bool) -> void:
	_invincible = enabled
	player.health_component.set_invulnerable(enabled)
	if enabled:
		player.health_component.set_current_health(player.health_component.maximum_health)
	_update_status()


func get_live_enemy_count() -> int:
	var count := 0
	for enemy in _active_enemies:
		if not is_instance_valid(enemy):
			continue
		var health := enemy.find_child("HealthComponent", true, false) as HealthComponent
		if health != null and health.current_health > 0.0:
			count += 1
	return count


func _spawn_enemy(scene: PackedScene, index: int, requested_count: int) -> void:
	if scene == null:
		return
	var enemy := scene.instantiate() as Node2D
	if enemy == null or not "target" in enemy:
		if enemy != null:
			enemy.free()
		return
	var reward := enemy.get_node_or_null("EnemyRewardComponent")
	if reward != null:
		enemy.remove_child(reward)
		reward.free()
	enemy.set("target", player if _ai_enabled else null)
	if "arena_bounds" in enemy:
		enemy.set("arena_bounds", ARENA_BOUNDS)
	if enemy.has_method("set_projectile_parent"):
		enemy.call("set_projectile_parent", projectiles)
	actors.add_child(enemy)
	enemy.global_position = _spawn_position(index, requested_count)
	_active_enemies.append(enemy)
	enemy.tree_exited.connect(_on_enemy_exited.bind(enemy))
	var health := enemy.find_child("HealthComponent", true, false) as HealthComponent
	if health != null:
		health.died.connect(_on_enemy_died.bind(enemy))
		health.health_changed.connect(_on_enemy_health_changed.bind(enemy))
	if enemy is Stage5Boss:
		var feedback := LandingFeedback.new()
		feedback.boss = enemy
		feedback.camera = camera
		add_child(feedback)
		enemy.tree_exited.connect(feedback.queue_free)


func _spawn_position(index: int, requested_count: int) -> Vector2:
	var columns := 4 if requested_count >= 4 else requested_count
	var rows := ceili(float(requested_count) / float(maxi(columns, 1)))
	var column := index % maxi(columns, 1)
	var row := index / maxi(columns, 1)
	var x := lerpf(120.0, 620.0, float(column + 1) / float(columns + 1))
	var y := lerpf(140.0, 300.0, float(row + 1) / float(rows + 1))
	return Vector2(x, y)


func _bind_controls() -> void:
	spawn_one_button.pressed.connect(spawn_selected.bind(1))
	spawn_four_button.pressed.connect(spawn_selected.bind(4))
	spawn_eight_button.pressed.connect(spawn_selected.bind(8))
	clear_button.pressed.connect(clear_simulation)
	reset_button.pressed.connect(get_tree().reload_current_scene)
	exit_button.pressed.connect(_transition_to_sanctuary)
	ai_toggle.toggled.connect(set_enemy_ai_enabled)
	invincible_toggle.toggled.connect(set_player_invincible)
	combat_tools_button.pressed.connect(player.enable_debug_combat_tools)
	enemy_selector.item_selected.connect(func(_index: int) -> void: _update_latest_label())


func _on_enemy_health_changed(current: float, maximum: float, enemy: Node2D) -> void:
	if is_instance_valid(enemy) and enemy == _latest_valid_enemy():
		latest_label.text = "LATEST: %s  |  %d / %d HP" % [enemy.name, roundi(current), roundi(maximum)]


func _on_enemy_died(_enemy: Node2D) -> void:
	_update_status()


func _on_enemy_exited(enemy: Node2D) -> void:
	_active_enemies.erase(enemy)
	_update_latest_label()
	_update_status()


func _latest_valid_enemy() -> Node2D:
	for index in range(_active_enemies.size() - 1, -1, -1):
		if is_instance_valid(_active_enemies[index]):
			return _active_enemies[index]
	return null


func _update_latest_label() -> void:
	var enemy := _latest_valid_enemy()
	if enemy == null:
		latest_label.text = "LATEST: %s" % String(ROSTER[enemy_selector.selected]["label"])
		return
	var health := enemy.find_child("HealthComponent", true, false) as HealthComponent
	latest_label.text = "LATEST: %s" % enemy.name
	if health != null:
		latest_label.text += "  |  %d / %d HP" % [roundi(health.current_health), roundi(health.maximum_health)]


func _update_status() -> void:
	status_label.text = "LIVE: %d  |  AI: %s  |  KING: %s" % [
		get_live_enemy_count(),
		"ON" if _ai_enabled else "PAUSED",
		"INVINCIBLE" if _invincible else "VULNERABLE",
	]


func _clear_children(parent: Node) -> void:
	for child in parent.get_children():
		child.queue_free()


func _transition_to_sanctuary() -> void:
	var transition := get_node_or_null("/root/SceneTransition")
	if transition != null:
		transition.call("transition_to", "res://levels/sanctuary/sanctuary.tscn")


func _has_required_dependencies() -> bool:
	return (
		player != null
		and actors != null
		and projectiles != null
		and effects != null
		and camera != null
		and combat_hud != null
		and enemy_selector != null
		and spawn_one_button != null
		and spawn_four_button != null
		and spawn_eight_button != null
		and clear_button != null
		and reset_button != null
		and exit_button != null
		and ai_toggle != null
		and invincible_toggle != null
		and combat_tools_button != null
		and status_label != null
		and latest_label != null
	)
