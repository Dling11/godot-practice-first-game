extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const PORTAL_SHEET_PATH := (
	"res://assets/environment/portals/generated/stage_vortex_portal_8x_128x96.png"
)


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var player := PlayerScene.instantiate()
	var portal := PortalScene.instantiate() as StagePortal
	root.add_child(player)
	root.add_child(portal)
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(hud)
	portal.proximity_changed.connect(hud.show_interaction_prompt)
	player.set_physics_process(false)
	var trigger := portal.get_node("Trigger") as CollisionShape2D
	var portal_visual := portal.get_node("PortalVisual") as AnimatedSprite2D
	var guidance_arrow := portal.get_node_or_null("GuidanceArrow") as Label
	var offscreen_guide := portal.get_node_or_null("PortalGuideLayer/OffscreenGuide") as Label
	var travel_sound := portal.get_node_or_null("TravelSound") as AudioStreamPlayer
	if (
		portal_visual == null
		or not portal_visual.is_playing()
		or portal_visual.sprite_frames.get_frame_count("active") != 8
		or guidance_arrow == null
		or offscreen_guide == null
		or travel_sound == null
		or travel_sound.stream == null
	):
		_fail("The stage portal is missing generated animation, guidance, or travel audio.")
		return
	portal.portal_tier = StagePortal.PortalTier.GOD
	portal._apply_tier_presentation()
	if portal_visual.speed_scale < 1.3 or portal_visual.scale.x <= 0.0:
		_fail("Portal superiority tiers do not alter vortex presentation.")
		return
	var portal_image := Image.load_from_file(ProjectSettings.globalize_path(PORTAL_SHEET_PATH))
	for y in portal_image.get_height():
		for x in portal_image.get_width():
			var alpha := portal_image.get_pixel(x, y).a
			if alpha > 0.0 and alpha < 1.0:
				_fail("The generated stage portal contains soft-alpha pixels.")
				return
	var trigger_shape := trigger.shape as CircleShape2D
	if trigger_shape.radius < 48.0:
		_fail("Portal interaction radius is too small to behave as a proximity prompt.")
		return
	portal.global_position = Vector2(5000.0, 200.0)
	portal._update_offscreen_guide()
	if not offscreen_guide.visible or guidance_arrow.visible:
		_fail("A distant portal did not switch to the screen-edge direction pointer.")
		return
	portal.global_position = Vector2(200.0, 200.0)
	portal._update_offscreen_guide()
	if offscreen_guide.visible or not guidance_arrow.visible:
		_fail("An on-screen portal did not restore its local downward pointer.")
		return
	var prompt := {"visible": false, "text": "", "icon": null, "entered": false}
	portal.proximity_changed.connect(func(visible: bool, text: String, icon: Texture2D) -> void:
		prompt.visible = visible
		prompt.text = text
		prompt.icon = icon
	)
	portal.player_entered.connect(func() -> void: prompt.entered = true)
	player.global_position = Vector2(200.0, 200.0)
	portal.global_position = Vector2(200.0, 200.0)
	for frame in range(3): await physics_frame
	if not hud.interaction_panel.visible:
		_fail("Real physics overlap did not display the portal interaction prompt.")
		return
	player.global_position = Vector2(400.0, 400.0)
	for frame in range(3): await physics_frame
	if hud.interaction_panel.visible:
		_fail("Real physics separation did not hide the portal interaction prompt.")
		return
	portal._on_body_entered(player)
	if not prompt.visible or not prompt.text.contains("PRESS F TO ENTER PORTAL") or prompt.icon == null:
		_fail("Entering portal range did not show the interaction prompt.")
		return
	portal._on_body_exited(player)
	if prompt.visible:
		_fail("Leaving portal range did not remove the interaction prompt.")
		return
	portal._on_body_entered(player)
	var interact := InputEventAction.new()
	interact.action = "player_interact"
	interact.pressed = true
	portal._unhandled_input(interact)
	if not prompt.entered:
		_fail("Pressing interact in portal range did not request entry.")
		return
	print("Portal interaction smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
