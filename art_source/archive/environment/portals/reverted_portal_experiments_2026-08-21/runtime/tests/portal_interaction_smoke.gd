extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const PORTAL_SHEET_PATH := (
	"res://assets/environment/portals/generated/stage_dimensional_portal_wide_16x_96x128_v3.png"
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
	var inner_flow := portal.get_node_or_null("InnerFlow") as StagePortalInnerFlow
	var ambient_particles := portal.get_node_or_null("AmbientParticles") as CPUParticles2D
	var spawn_particles := portal.get_node_or_null("SpawnParticles") as CPUParticles2D
	var guidance_arrow := portal.get_node_or_null("GuidanceArrow") as Label
	var offscreen_guide := portal.get_node_or_null("PortalGuideLayer/OffscreenGuide") as Label
	var travel_sound := portal.get_node_or_null("TravelSound") as AudioStreamPlayer
	if (
		portal_visual == null
		or inner_flow == null
		or inner_flow.z_index <= 0
		or StagePortalInnerFlow.VORTEX_RADIUS_X < 26.0
		or StagePortalInnerFlow.SPIRAL_ARM_COUNT < 3
		or not portal_visual.is_playing()
		or portal_visual.sprite_frames.get_frame_count("appear") != 6
		or portal_visual.sprite_frames.get_frame_count("active") != 10
		or ambient_particles == null
		or spawn_particles == null
		or guidance_arrow == null
		or offscreen_guide == null
		or travel_sound == null
		or travel_sound.stream == null
	):
		_fail("The stage gate is missing its spawn/loop animation, tier particles, guidance, or travel audio.")
		return
	await create_timer(0.75).timeout
	if portal_visual.animation != &"active" or not portal_visual.is_playing():
		_fail("The stage gate did not transition from materialization into its active loop.")
		return
	portal.portal_tier = StagePortal.PortalTier.GOD
	portal._apply_tier_presentation()
	if (
		portal_visual.speed_scale < 1.3
		or portal_visual.scale.x <= 0.0
		or ambient_particles.amount < 40
		or spawn_particles.amount < 60
		or portal_visual.modulate.b <= portal_visual.modulate.r
	):
		_fail("God-tier gate presentation does not escalate color, speed, scale, and particles.")
		return
	var portal_image := Image.load_from_file(ProjectSettings.globalize_path(PORTAL_SHEET_PATH))
	var found_substantial_veil := false
	var found_opaque_edge := false
	for y in portal_image.get_height():
		for x in portal_image.get_width():
			var alpha := portal_image.get_pixel(x, y).a
			found_substantial_veil = found_substantial_veil or (alpha >= 0.34 and alpha <= 0.62)
			found_opaque_edge = found_opaque_edge or is_equal_approx(alpha, 1.0)
	if not found_substantial_veil or not found_opaque_edge:
		_fail("The dimensional tear must preserve both its substantial translucent veil and hard energy edge.")
		return
	for frame_index in range(6, 16):
		var cell_origin := Vector2i((frame_index % 4) * 96, floori(frame_index / 4.0) * 128)
		var minimum_x := 96
		var maximum_x := -1
		for local_y in range(128):
			for local_x in range(96):
				if portal_image.get_pixelv(cell_origin + Vector2i(local_x, local_y)).a <= 0.0:
					continue
				minimum_x = mini(minimum_x, local_x)
				maximum_x = maxi(maximum_x, local_x)
		var visible_width := maximum_x - minimum_x + 1
		var visible_center := (minimum_x + maximum_x) * 0.5
		if visible_width < 58 or visible_width > 68 or absf(visible_center - 47.5) > 1.5:
			_fail("An active dimensional portal lost its wide doorway silhouette or drifted off its stable center.")
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
