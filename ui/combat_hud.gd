class_name CombatHUD
extends Control

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var blocked_label: Label = %BlockedLabel
@onready var defeat_panel: PanelContainer = %DefeatPanel
@onready var stage_label: Label = %StageLabel
@onready var spawn_indicator: Label = %SpawnIndicator
@onready var interaction_panel: PanelContainer = %InteractionPanel
@onready var interaction_label: Label = %InteractionLabel
@onready var ability_panel: PanelContainer = %AbilityPanel
@onready var ability_key_label: Label = %KeyLabel
@onready var ability_cooldown: ProgressBar = %AbilityCooldown
@onready var ability_cooldown_label: Label = %CooldownLabel
@onready var ability_cooldown_tick: Timer = %AbilityCooldownTick

var _blocked_tween: Tween
var _player: Player
var _spawn_tween: Tween
var _ability_cooldown_tween: Tween


func bind_player(player: Player) -> void:
	_player = player
	var health: HealthComponent = player.health_component
	health.health_changed.connect(_update_health)
	health.damage_blocked.connect(_show_blocked)
	var ability := player.ability_1_component
	ability.cooldown_started.connect(_show_ability_cooldown)
	ability.cooldown_finished.connect(_show_ability_ready)
	ability_panel.tooltip_text = ability.definition.display_name
	_show_ability_ready()
	_update_health(health.current_health, health.maximum_health)


func _show_ability_cooldown(duration_seconds: float) -> void:
	if _ability_cooldown_tween != null and _ability_cooldown_tween.is_valid():
		_ability_cooldown_tween.kill()
	ability_panel.modulate = Color(0.58, 0.58, 0.58, 1.0)
	ability_cooldown_label.text = "%.1f" % duration_seconds
	ability_cooldown_label.add_theme_color_override("font_color", Color(0.94, 0.72, 0.38, 1))
	ability_cooldown.max_value = duration_seconds
	ability_cooldown.value = duration_seconds
	ability_cooldown_tick.start()
	_ability_cooldown_tween = create_tween()
	_ability_cooldown_tween.tween_property(
		ability_cooldown,
		"value",
		0.0,
		duration_seconds
	)


func _show_ability_ready() -> void:
	if _ability_cooldown_tween != null and _ability_cooldown_tween.is_valid():
		_ability_cooldown_tween.kill()
	ability_cooldown.value = 0.0
	ability_panel.modulate = Color.WHITE
	ability_key_label.text = "Q"
	ability_cooldown_label.text = "READY"
	ability_cooldown_label.add_theme_color_override("font_color", Color(0.62, 0.9, 0.54, 1))
	ability_cooldown_tick.stop()


func _on_ability_cooldown_tick() -> void:
	if not is_instance_valid(_player):
		ability_cooldown_tick.stop()
		return
	var remaining := _player.ability_1_component.cooldown_remaining
	ability_cooldown_label.text = "%.1f" % remaining


func show_spawn_direction(global_position: Vector2) -> void:
	if not is_instance_valid(_player): return
	var direction := (global_position - _player.global_position).normalized()
	spawn_indicator.position = Vector2(480, 270) + Vector2(direction.x * 420.0, direction.y * 225.0) - Vector2(10, 10)
	spawn_indicator.rotation = direction.angle() + PI * 0.5
	spawn_indicator.modulate.a = 0.9
	spawn_indicator.show()
	if _spawn_tween != null and _spawn_tween.is_valid(): _spawn_tween.kill()
	_spawn_tween = create_tween()
	_spawn_tween.tween_interval(0.7)
	_spawn_tween.tween_property(spawn_indicator, "modulate:a", 0.0, 0.25)
	_spawn_tween.tween_callback(spawn_indicator.hide)


func show_defeat() -> void:
	defeat_panel.visible = true
	defeat_panel.modulate.a = 0.0
	var tween := create_tween()
	tween.tween_property(defeat_panel, "modulate:a", 1.0, 0.25)


func show_wave(index: int, total: int, title: String) -> void:
	_show_announcement("WAVE %d/%d  %s" % [index, total, title], 1.6)


func show_wave_clear(index: int, total: int) -> void:
	_show_announcement("WAVE %d/%d CLEARED" % [index, total], 1.25)


func show_stage_clear() -> void:
	_show_announcement("STAGE CLEAR  •  PORTAL OPEN", 2.4)


func show_portal_sealed() -> void:
	_show_announcement("THE NEXT STAGE IS SEALED", 2.0)


func show_interaction_prompt(is_visible: bool, prompt_text: String) -> void:
	interaction_label.text = prompt_text
	interaction_panel.visible = is_visible


func _show_announcement(message: String, hold_seconds: float) -> void:
	stage_label.text = message
	stage_label.modulate.a = 0.0
	stage_label.show()
	var tween := create_tween()
	tween.tween_property(stage_label, "modulate:a", 1.0, 0.2)
	tween.tween_interval(hold_seconds)
	tween.tween_property(stage_label, "modulate:a", 0.0, 0.3)
	tween.tween_callback(stage_label.hide)


func _update_health(current: float, maximum: float) -> void:
	health_bar.max_value = maximum
	health_bar.value = current
	health_label.text = "HP  %d / %d" % [ceili(current), ceili(maximum)]


func _show_blocked(_info: DamageInfo) -> void:
	blocked_label.visible = true
	blocked_label.modulate.a = 1.0
	if _blocked_tween != null and _blocked_tween.is_valid():
		_blocked_tween.kill()
	_blocked_tween = create_tween()
	_blocked_tween.tween_interval(0.25)
	_blocked_tween.tween_property(blocked_label, "modulate:a", 0.0, 0.2)
	_blocked_tween.tween_callback(blocked_label.hide)
