class_name StagePortal
extends Area2D

signal player_entered
signal proximity_changed(is_near: bool, prompt_text: String, prompt_icon: Texture2D)

enum PortalTier {
	NORMAL,
	MINI_BOSS,
	BOSS,
	GOD,
	TRANSCENDENT,
}

const TIER_PRESENTATION := {
	PortalTier.NORMAL: {
		"color": Color(0.28, 0.65, 1.0), "scale": 0.88, "speed": 0.9,
		"particles": 12, "burst": 18, "flow": 0.88,
	},
	PortalTier.MINI_BOSS: {
		"color": Color(1.0, 0.42, 0.18), "scale": 1.0, "speed": 1.05,
		"particles": 18, "burst": 28, "flow": 1.0,
	},
	PortalTier.BOSS: {
		"color": Color(1.0, 0.16, 0.22), "scale": 1.12, "speed": 1.2,
		"particles": 28, "burst": 42, "flow": 1.14,
	},
	PortalTier.GOD: {
		"color": Color(0.68, 0.28, 1.0), "scale": 1.24, "speed": 1.35,
		"particles": 40, "burst": 60, "flow": 1.3,
	},
	PortalTier.TRANSCENDENT: {
		"color": Color(1.0, 0.84, 0.34), "scale": 1.36, "speed": 1.5,
		"particles": 54, "burst": 80, "flow": 1.48,
	},
}

@export_file("*.tscn") var target_scene_path := ""
@export var portal_tier: PortalTier = PortalTier.NORMAL
@export var portal_visual: AnimatedSprite2D
@export var inner_flow: StagePortalInnerFlow
@export var ambient_particles: CPUParticles2D
@export var spawn_particles: CPUParticles2D
@export var guidance_arrow: Label
@export var offscreen_guide: Label
@export var travel_sound: AudioStreamPlayer
@export var interaction_text := "PRESS F TO ENTER PORTAL"
@export var interaction_icon: Texture2D

var _player_inside := false
var _nearby_player: Player
var _travel_started := false
var _tier_color := Color.WHITE
var _portal_scale := Vector2.ONE


func _ready() -> void:
	body_entered.connect(_on_body_entered)
	body_exited.connect(_on_body_exited)
	_apply_tier_presentation()
	_play_spawn_sequence()
	if guidance_arrow != null:
		var arrow_origin: Vector2 = guidance_arrow.position
		var guide := create_tween().set_loops()
		guide.tween_property(guidance_arrow, "position", arrow_origin + Vector2(0.0, 5.0), 0.42).set_trans(Tween.TRANS_SINE)
		guide.tween_property(guidance_arrow, "position", arrow_origin, 0.42).set_trans(Tween.TRANS_SINE)


func _process(_delta: float) -> void:
	_update_offscreen_guide()


func _apply_tier_presentation() -> void:
	var presentation: Dictionary = TIER_PRESENTATION.get(portal_tier, TIER_PRESENTATION[PortalTier.NORMAL])
	_tier_color = presentation["color"] as Color
	var scale_factor: float = presentation["scale"]
	_portal_scale = Vector2.ONE * scale_factor
	if portal_visual != null:
		portal_visual.speed_scale = presentation["speed"]
		portal_visual.scale = _portal_scale * 0.18
		portal_visual.modulate = Color(_tier_color, 0.0)
		var appearance := create_tween().set_parallel(true)
		appearance.tween_property(portal_visual, "scale", _portal_scale, 0.48).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		appearance.tween_property(portal_visual, "modulate", _tier_color, 0.3)
		appearance.chain().tween_callback(_start_energy_pulse)
	if ambient_particles != null:
		ambient_particles.amount = int(presentation["particles"])
		ambient_particles.color = _tier_color
	if spawn_particles != null:
		spawn_particles.amount = int(presentation["burst"])
		spawn_particles.color = _tier_color.lightened(0.16)
	if inner_flow != null:
		inner_flow.configure(
			_tier_color,
			float(presentation["speed"]),
			float(presentation["flow"])
		)
	if guidance_arrow != null:
		guidance_arrow.add_theme_color_override("font_color", _tier_color)
	if offscreen_guide != null:
		offscreen_guide.add_theme_color_override("font_color", _tier_color)
		offscreen_guide.pivot_offset = offscreen_guide.size * 0.5


func _play_spawn_sequence() -> void:
	if portal_visual == null:
		return
	portal_visual.play(&"appear")
	if spawn_particles != null:
		spawn_particles.restart()
	await portal_visual.animation_finished
	if is_instance_valid(portal_visual):
		portal_visual.play(&"active")


func _start_energy_pulse() -> void:
	if portal_visual == null or not is_instance_valid(portal_visual):
		return
	var bright := _tier_color.lightened(0.18)
	var pulse := create_tween().set_loops()
	pulse.tween_property(portal_visual, "modulate", bright, 0.55).set_trans(Tween.TRANS_SINE)
	pulse.parallel().tween_property(
		portal_visual,
		"scale",
		_portal_scale * Vector2(1.035, 0.99),
		0.55
	).set_trans(Tween.TRANS_SINE)
	pulse.tween_property(portal_visual, "modulate", _tier_color, 0.7).set_trans(Tween.TRANS_SINE)
	pulse.parallel().tween_property(
		portal_visual,
		"scale",
		_portal_scale,
		0.7
	).set_trans(Tween.TRANS_SINE)


func _update_offscreen_guide() -> void:
	if offscreen_guide == null or guidance_arrow == null:
		return
	var viewport_size := get_viewport().get_visible_rect().size
	if viewport_size.x <= 0.0 or viewport_size.y <= 0.0:
		offscreen_guide.visible = false
		return
	var screen_position := get_viewport().get_canvas_transform() * global_position
	var margin := Vector2(34.0, 34.0)
	var safe_rect := Rect2(margin, viewport_size - margin * 2.0)
	var portal_is_on_screen := safe_rect.has_point(screen_position)
	guidance_arrow.visible = portal_is_on_screen
	offscreen_guide.visible = not portal_is_on_screen
	if portal_is_on_screen:
		return
	var center := viewport_size * 0.5
	var direction := (screen_position - center).normalized()
	var clamped_position := Vector2(
		clampf(screen_position.x, margin.x, viewport_size.x - margin.x),
		clampf(screen_position.y, margin.y, viewport_size.y - margin.y)
	)
	offscreen_guide.position = clamped_position - offscreen_guide.size * 0.5
	offscreen_guide.rotation = direction.angle()


func _unhandled_input(event: InputEvent) -> void:
	if not _player_inside or _travel_started or not event.is_action_pressed("player_interact"):
		return
	get_viewport().set_input_as_handled()
	player_entered.emit()
	if target_scene_path.is_empty():
		return
	proximity_changed.emit(false, "", null)
	_player_inside = false
	_travel_started = true
	_fade_player_into_portal(_nearby_player)


func _fade_player_into_portal(player: Player) -> void:
	if is_instance_valid(player):
		player.set_physics_process(false)
		player.set_process_unhandled_input(false)
		if travel_sound != null:
			travel_sound.play()
		var departure := create_tween().set_parallel(true)
		departure.tween_property(player, "global_position", global_position + Vector2(0.0, -24.0), 0.36).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
		departure.tween_property(player, "modulate:a", 0.0, 0.34)
		departure.tween_property(player, "scale", Vector2(0.72, 0.72), 0.36).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_IN)
		await departure.finished
	var transition_service := get_node_or_null("/root/SceneTransition")
	if transition_service == null:
		push_error("StagePortal requires the SceneTransition autoload.")
		_restore_player_after_failed_travel(player)
		return
	if not await transition_service.transition_to(target_scene_path):
		_restore_player_after_failed_travel(player)


func _restore_player_after_failed_travel(player: Player) -> void:
	_travel_started = false
	if not is_instance_valid(player):
		return
	player.modulate.a = 1.0
	player.scale = Vector2.ONE
	player.set_physics_process(true)
	player.set_process_unhandled_input(true)


func _on_body_entered(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = true
	_nearby_player = body as Player
	proximity_changed.emit(true, interaction_text, interaction_icon)


func _on_body_exited(body: Node2D) -> void:
	if not body is Player: return
	_player_inside = false
	if body == _nearby_player:
		_nearby_player = null
	proximity_changed.emit(false, "", null)
