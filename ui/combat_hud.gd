class_name CombatHUD
extends Control

const SkillBarSlotScene = preload("res://ui/skills/skill_bar_slot.tscn")
const StageChestIcon = preload(
	"res://assets/gameplay/loot/stage_clear_chest/"
	+ "forest_stage_clear_chest_closed_64x48.png"
)

signal character_menu_requested

@onready var health_bar: ProgressBar = %HealthBar
@onready var health_label: Label = %HealthLabel
@onready var blocked_label: Label = %BlockedLabel
@onready var defeat_panel: PanelContainer = %DefeatPanel
@onready var stage_label: Label = %StageLabel
@onready var spawn_indicator: Label = %SpawnIndicator
@onready var interaction_panel: PanelContainer = %InteractionPanel
@onready var interaction_icon: TextureRect = %InteractionIcon
@onready var interaction_label: Label = %InteractionLabel
@onready var skill_bar: HBoxContainer = %SkillBar
@onready var level_label: Label = %LevelLabel
@onready var experience_bar: ProgressBar = %ExperienceBar
@onready var experience_label: Label = %ExperienceLabel
@onready var coin_label: Label = %CoinLabel
@onready var character_menu_button: Button = %CharacterMenuButton
@onready var options_button: Button = %OptionsButton
@onready var dash_slot: DashBarSlot = %DashBarSlot
@onready var loot_toast_panel: PanelContainer = %LootToastPanel
@onready var loot_toast_icon: TextureRect = %LootToastIcon
@onready var loot_toast_label: Label = %LootToastLabel
@onready var loot_toast_source_label: Label = %LootToastSourceLabel

var _blocked_tween: Tween
var _player: Player
var _spawn_tween: Tween
var ability_panel: SkillBarSlot
var _skill_slots: Array[SkillBarSlot] = []
var _loot_notifications: Array[Dictionary] = []
var _loot_toast_busy := false
var _announcement_tween: Tween


func _ready() -> void:
	character_menu_button.pressed.connect(_on_character_menu_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	dash_slot.activation_requested.connect(_on_dash_activation_requested)


func bind_player(player: Player) -> void:
	_player = player
	var health: HealthComponent = player.health_component
	health.health_changed.connect(_update_health)
	health.damage_blocked.connect(_show_blocked)
	dash_slot.bind_evade(player.evade_component)
	_build_skill_bar(player)
	_update_health(health.current_health, health.maximum_health)
	var progression := player.progression_component
	progression.progression_changed.connect(_update_progression)
	progression.coins_changed.connect(_update_coins)
	player.testing_preset_applied.connect(_show_testing_preset)
	player.skill_loadout_changed.connect(_on_skill_loadout_changed)
	player.restraint_started.connect(_on_restraint_started)
	player.restraint_progress.connect(_on_restraint_progress)
	player.restraint_ended.connect(_on_restraint_ended)
	var loot_service := get_node_or_null("/root/LootService")
	if (
		loot_service != null
		and not loot_service.material_granted.is_connected(_on_material_granted)
	):
		loot_service.material_granted.connect(_on_material_granted)
	if (
		loot_service != null
		and not loot_service.stage_reward_granted.is_connected(
			_on_stage_reward_granted
		)
	):
		loot_service.stage_reward_granted.connect(_on_stage_reward_granted)
	_update_progression(progression.level, progression.total_experience, 0)
	_update_coins(progression.coins)

func get_skill_slot(slot_number: int) -> SkillBarSlot:
	for slot: SkillBarSlot in _skill_slots:
		if slot.slot_definition != null and slot.slot_definition.slot_number == slot_number:
			return slot
	return null


func _build_skill_bar(player: Player) -> void:
	for child: Node in skill_bar.get_children():
		skill_bar.remove_child(child)
		child.queue_free()
	_skill_slots.clear()
	ability_panel = null
	if player.skill_loadout == null or not player.skill_loadout.has_complete_layout():
		push_error("CombatHUD requires a complete four-slot skill loadout.")
		return
	for definition: SkillSlotDefinition in player.skill_loadout.get_ordered_slots():
		var slot := SkillBarSlotScene.instantiate() as SkillBarSlot
		skill_bar.add_child(slot)
		slot.configure(definition)
		slot.bind_ability(player.get_ability_component_for_slot(definition.slot_number))
		slot.activation_requested.connect(_on_skill_activation_requested)
		_skill_slots.append(slot)
		if definition.slot_number == 1:
			ability_panel = slot


func _on_skill_activation_requested(slot_number: int) -> void:
	if is_instance_valid(_player):
		_player.request_ability(slot_number)


func _on_dash_activation_requested() -> void:
	if not is_instance_valid(_player):
		return
	var direction := _player.input_source.get_move_direction()
	if direction.is_zero_approx():
		direction = _player.facing_direction
	_player.request_evade(direction)


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


func show_reinforcement_warning(_delay_seconds: float) -> void:
	_show_announcement("REINFORCEMENTS APPROACH", 0.9)


func show_stage_clear() -> void:
	_show_announcement("STAGE CLEAR  •  PORTAL OPEN", 2.4)


func show_reward_chest_ready(_global_position: Vector2) -> void:
	_show_announcement("STAGE CLEAR  •  CLAIM THE FOREST CHEST", 2.2)


func show_story_message(message: String, hold_seconds := 3.0) -> void:
	_show_announcement(message, hold_seconds)


func _update_progression(_level: int, _total_experience: int, _next_level_experience: int) -> void:
	if not is_instance_valid(_player):
		return
	var progression := _player.progression_component
	level_label.text = "LEVEL %d" % progression.level
	if progression.level >= progression.definition.maximum_level:
		experience_bar.max_value = 1.0
		experience_bar.value = 1.0
		experience_label.text = "MAX"
		return
	var required := progression.experience_required_for_current_level()
	experience_bar.max_value = required
	experience_bar.value = progression.experience_into_current_level()
	experience_label.text = "%d / %d XP" % [experience_bar.value, required]


func _update_coins(total_coins: int) -> void:
	coin_label.text = "COINS %d" % total_coins


func _show_testing_preset(level: int, coins: int) -> void:
	_show_announcement("DEBUG TEST  •  LEVEL %d  •  %d COINS  •  UNLIMITED SKILLS" % [level, coins], 2.0)


func _on_skill_loadout_changed() -> void:
	if is_instance_valid(_player):
		_build_skill_bar(_player)


func show_portal_sealed() -> void:
	_show_announcement("THE NEXT STAGE IS SEALED", 2.0)


func show_interaction_prompt(is_visible: bool, prompt_text: String, prompt_icon: Texture2D = null) -> void:
	interaction_label.text = prompt_text
	interaction_icon.texture = prompt_icon
	interaction_icon.visible = prompt_icon != null
	interaction_panel.visible = is_visible


func _show_announcement(message: String, hold_seconds: float) -> void:
	if _announcement_tween != null and _announcement_tween.is_valid():
		_announcement_tween.kill()
	stage_label.text = message
	stage_label.modulate.a = 0.0
	stage_label.show()
	_announcement_tween = create_tween()
	_announcement_tween.tween_property(stage_label, "modulate:a", 1.0, 0.2)
	_announcement_tween.tween_interval(hold_seconds)
	_announcement_tween.tween_property(stage_label, "modulate:a", 0.0, 0.3)
	_announcement_tween.tween_callback(stage_label.hide)


func _on_restraint_started(_source: Node, total: int) -> void:
	dash_slot.show_restraint_progress(total, total)
	_show_restraint_message("ROOTED  •  MASH DASH / TAP  •  0/%d" % total)


func _on_restraint_progress(_source: Node, remaining: int, total: int) -> void:
	dash_slot.show_restraint_progress(remaining, total)
	_show_restraint_message("ROOTED  •  MASH DASH / TAP  •  %d/%d" % [total - remaining, total])


func _on_restraint_ended(_source: Node, escaped: bool) -> void:
	dash_slot.clear_restraint_progress()
	_show_announcement("ROOT PRISON BROKEN  •  MOVE!" if escaped else "ROOT EXECUTION", 0.8)


func _show_restraint_message(message: String) -> void:
	if _announcement_tween != null and _announcement_tween.is_valid():
		_announcement_tween.kill()
	stage_label.text = message
	stage_label.modulate.a = 1.0
	stage_label.show()


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


func _on_character_menu_button_pressed() -> void:
	character_menu_requested.emit()


func _on_options_button_pressed() -> void:
	var pause_menu := get_tree().get_first_node_in_group("pause_menu") as PauseMenu
	if pause_menu != null:
		pause_menu.open_menu()


func _on_material_granted(
	material: MaterialDefinition,
	quantity: int,
	source_kind: StringName
) -> void:
	var source_text := "ENEMY DROP"
	if source_kind == &"stage_chest":
		source_text = "STAGE CHEST"
	_queue_loot_notification(
		material.icon,
		"%s  ×%d" % [material.display_name.to_upper(), quantity],
		source_text
	)


func _on_stage_reward_granted(result: Dictionary) -> void:
	var materials: Array = result.get("materials", [])
	var total_quantity := 0
	for stack: Dictionary in materials:
		total_quantity += int(stack.get("quantity", 0))
	var recipe_ids: PackedStringArray = result.get(
		"recipe_ids",
		PackedStringArray()
	)
	var title := "%d MATERIALS" % total_quantity
	if not recipe_ids.is_empty():
		title += "  •  %d BLUEPRINTS" % recipe_ids.size()
	_queue_loot_notification(
		StageChestIcon,
		title,
		"FIRST CLEAR" if bool(result.get("first_clear", false)) else "REPLAY CHEST"
	)


func _queue_loot_notification(
	icon: Texture2D,
	title: String,
	source_text: String
) -> void:
	_loot_notifications.append({
		"icon": icon,
		"title": title,
		"source": source_text,
	})
	_play_next_loot_notification()


func _play_next_loot_notification() -> void:
	if _loot_toast_busy or _loot_notifications.is_empty() or not is_inside_tree():
		return
	_loot_toast_busy = true
	var notification: Dictionary = _loot_notifications.pop_front()
	loot_toast_icon.texture = notification.get("icon") as Texture2D
	loot_toast_icon.visible = loot_toast_icon.texture != null
	loot_toast_label.text = String(notification.get("title", "MATERIAL ACQUIRED"))
	loot_toast_source_label.text = String(notification.get("source", "LOOT"))
	loot_toast_panel.modulate.a = 0.0
	loot_toast_panel.show()
	var toast := create_tween()
	toast.tween_property(loot_toast_panel, "modulate:a", 1.0, 0.12)
	toast.tween_interval(1.05)
	toast.tween_property(loot_toast_panel, "modulate:a", 0.0, 0.2)
	await toast.finished
	if is_instance_valid(loot_toast_panel):
		loot_toast_panel.hide()
	_loot_toast_busy = false
	_play_next_loot_notification()
