class_name EncounterController
extends Node

signal wave_changed(index: int, total: int, title: String)
signal wave_cleared(index: int, total: int)
signal stage_cleared
signal portal_sealed
signal portal_prompt_changed(is_visible: bool, prompt_text: String)
signal enemy_spawned(global_position: Vector2)

@export var player: Player
@export var actors: Node2D
@export var spawn_points_root: Node2D
@export var waves: Array[Resource]
@export var mireling_scene: PackedScene
@export var thrall_scene: PackedScene
@export var portal_scene: PackedScene
@export var portal_parent: Node2D
@export var portal_spawn_point: Marker2D
@export_file("*.tscn") var portal_target_scene := ""
@export var summon_effect_scene: PackedScene
@export var effects_parent: Node2D
@export var auto_start := true
@export_range(0.5, 10.0, 0.25, "suffix:s") var inter_wave_delay := 2.25

var wave_index := -1
var _active_enemies := 0
var _spawning := false
var _spawn_points: Array[Marker2D] = []
var _transition_pending := false


func _ready() -> void:
	for child in spawn_points_root.get_children():
		if child is Marker2D and child != portal_spawn_point: _spawn_points.append(child)
	if auto_start:
		call_deferred("_start_encounter")


func _start_encounter() -> void:
	for frame in range(2): await get_tree().physics_frame
	_advance_wave()


func _advance_wave() -> void:
	wave_index += 1
	if wave_index >= waves.size():
		_spawn_portal()
		return
	var wave := waves[wave_index] as EncounterWaveDefinition
	wave_changed.emit(wave_index + 1, waves.size(), wave.title)
	_spawning = true
	var queue: Array[PackedScene] = []
	for count in range(wave.mireling_count): queue.append(mireling_scene)
	for count in range(wave.thrall_count): queue.append(thrall_scene)
	for scene in queue:
		_spawn_enemy(scene)
		await get_tree().create_timer(wave.spawn_interval).timeout
	_spawning = false
	_try_finish_stage()


func _spawn_enemy(scene: PackedScene) -> void:
	if scene == null or _spawn_points.is_empty(): return
	var enemy := scene.instantiate()
	enemy.target = player
	actors.add_child(enemy)
	var spawn_position := _choose_spawn_position()
	enemy.global_position = spawn_position
	_spawn_summon_effect(spawn_position)
	enemy_spawned.emit(enemy.global_position)
	_active_enemies += 1
	enemy.tree_exited.connect(_on_enemy_removed)


func _spawn_summon_effect(global_position: Vector2) -> void:
	if summon_effect_scene == null or effects_parent == null: return
	var effect := summon_effect_scene.instantiate() as SummonEffect
	effects_parent.add_child(effect)
	effect.global_position = global_position


func _choose_spawn_position() -> Vector2:
	var navigation_map := player.get_world_2d().get_navigation_map()
	for attempt in range(8):
		var angle := randf_range(0.0, TAU)
		var requested := player.global_position + Vector2.RIGHT.rotated(angle) * randf_range(250.0, 340.0)
		var safe := NavigationServer2D.map_get_closest_point(navigation_map, requested)
		var distance := safe.distance_to(player.global_position)
		if distance >= 210.0 and distance <= 380.0:
			return safe
	var nearest := _spawn_points[0]
	for point in _spawn_points:
		if point.global_position.distance_to(player.global_position) < nearest.global_position.distance_to(player.global_position):
			nearest = point
	return nearest.global_position


func _on_enemy_removed() -> void:
	_active_enemies = maxi(0, _active_enemies - 1)
	if not is_inside_tree(): return
	_try_finish_stage()


func _try_finish_stage() -> void:
	if not is_inside_tree() or _transition_pending: return
	if not _spawning and _active_enemies == 0:
		_transition_pending = true
		wave_cleared.emit(wave_index + 1, waves.size())
		await get_tree().create_timer(inter_wave_delay).timeout
		_transition_pending = false
		_advance_wave()


func _spawn_portal() -> void:
	if portal_scene == null or portal_parent == null or portal_spawn_point == null:
		push_error("EncounterController requires a portal scene, parent, and spawn point.")
		return
	var portal := portal_scene.instantiate() as StagePortal
	portal.target_scene_path = portal_target_scene
	portal_parent.add_child(portal)
	portal.global_position = portal_spawn_point.global_position
	portal.player_entered.connect(func() -> void:
		if portal.target_scene_path.is_empty(): portal_sealed.emit()
	)
	portal.proximity_changed.connect(func(is_near: bool, prompt_text: String) -> void:
		portal_prompt_changed.emit(is_near, prompt_text)
	)
	stage_cleared.emit()
