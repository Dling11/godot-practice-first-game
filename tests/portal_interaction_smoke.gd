extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const PORTAL_BASE_SHEET_PATH := (
	"res://assets/environment/portals/generated/stage_abyssal_veil_base_16x_160x192.png"
)
const PORTAL_FX_SHEET_PATH := (
	"res://assets/environment/portals/generated/stage_abyssal_veil_lightning_fx_16x_256x224.png"
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
	var portal_fx := portal.get_node_or_null("PortalFx") as AnimatedSprite2D
	var guidance_arrow := portal.get_node_or_null("GuidanceArrow") as Label
	var offscreen_guide := portal.get_node_or_null("PortalGuideLayer/OffscreenGuide") as Label
	var travel_sound := portal.get_node_or_null("TravelSound") as AudioStreamPlayer
	if (
		portal_visual == null
		or portal_fx == null
		or not portal_visual.is_playing()
		or not portal_fx.is_playing()
		or portal_visual.sprite_frames.get_frame_count("active") != 16
		or portal_fx.sprite_frames.get_frame_count("active") != 16
		or guidance_arrow == null
		or offscreen_guide == null
		or travel_sound == null
		or travel_sound.stream == null
	):
		_fail("The stage portal is missing either layered animation, guidance, or travel audio.")
		return
	if not _validate_threat_tier_ladder():
		return
	if portal_fx.visible or not is_zero_approx(portal_fx.speed_scale):
		_fail("A Normal portal still presents higher-tier lightning.")
		return
	portal.portal_tier = StagePortal.PortalTier.GOD
	portal._apply_tier_presentation()
	if (
		portal_visual.speed_scale < 1.2
		or portal_fx.speed_scale <= portal_visual.speed_scale
		or not portal_fx.visible
		or portal_visual.scale.x <= 0.0
		or portal_fx.scale.x <= 0.0
	):
		_fail("Portal superiority tiers do not alter both layered animations.")
		return
	if not _validate_layer_sheet(PORTAL_BASE_SHEET_PATH, Vector2i(2560, 192), "base"):
		return
	if not _validate_base_motion_is_full_surface(PORTAL_BASE_SHEET_PATH):
		return
	if not _validate_layer_sheet(PORTAL_FX_SHEET_PATH, Vector2i(4096, 224), "FX"):
		return
	if not _validate_fx_is_dense_and_distributed(PORTAL_FX_SHEET_PATH):
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


func _validate_threat_tier_ladder() -> bool:
	var normal: Dictionary = StagePortal.TIER_PRESENTATION[StagePortal.PortalTier.NORMAL]
	var mini_boss: Dictionary = StagePortal.TIER_PRESENTATION[StagePortal.PortalTier.MINI_BOSS]
	var boss: Dictionary = StagePortal.TIER_PRESENTATION[StagePortal.PortalTier.BOSS]
	var god: Dictionary = StagePortal.TIER_PRESENTATION[StagePortal.PortalTier.GOD]
	var transcendent: Dictionary = StagePortal.TIER_PRESENTATION[StagePortal.PortalTier.TRANSCENDENT]
	var normal_color: Color = normal["color"]
	var mini_boss_color: Color = mini_boss["color"]
	var boss_color: Color = boss["color"]
	var god_color: Color = god["color"]
	var transcendent_color: Color = transcendent["color"]
	if (
		normal_color.b <= normal_color.r
		or mini_boss_color.b <= mini_boss_color.r
		or mini_boss_color.r <= mini_boss_color.g
		or boss_color.r <= boss_color.b
		or minf(god_color.r, minf(god_color.g, god_color.b)) < 0.9
		or maxf(transcendent_color.r, maxf(transcendent_color.g, transcendent_color.b)) > 0.15
	):
		_fail("Portal tier colors no longer read blue, purple, red, searing light, then near-black.")
		return false
	var ordered_tiers := [normal, mini_boss, boss, god, transcendent]
	for index in range(ordered_tiers.size() - 1):
		if (
			float(ordered_tiers[index]["fx_alpha"]) >= float(ordered_tiers[index + 1]["fx_alpha"])
			or float(ordered_tiers[index]["fx_reach"]) >= float(ordered_tiers[index + 1]["fx_reach"])
		):
			_fail("Portal lightning intensity and reach do not rise with threat tier.")
			return false
	if not is_zero_approx(float(normal["fx_alpha"])) or not is_zero_approx(float(normal["fx_reach"])):
		_fail("Normal portals must remain lightning-free.")
		return false
	var transcendent_field_width := 256.0 * float(transcendent["scale"]) * float(transcendent["fx_reach"])
	if transcendent_field_width < 480.0:
		_fail("The highest portal tier no longer throws lightning across at least half the viewport.")
		return false
	return true


func _validate_layer_sheet(path: String, expected_size: Vector2i, layer_name: String) -> bool:
	var image := Image.load_from_file(ProjectSettings.globalize_path(path))
	if image == null or image.get_size() != expected_size:
		_fail("The layered portal %s sheet does not match its 16-frame grid." % layer_name)
		return false
	var has_clear := false
	var has_translucent := false
	var has_bright := false
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a
			has_clear = has_clear or alpha <= 0.0
			has_translucent = has_translucent or (alpha > 0.0 and alpha < 0.75)
			has_bright = has_bright or alpha >= 0.75
	if not has_clear or not has_translucent or not has_bright:
		_fail("The layered portal %s sheet lost transparent gaps or readable energy." % layer_name)
		return false
	return true


func _validate_base_motion_is_full_surface(path: String) -> bool:
	var sheet := Image.load_from_file(ProjectSettings.globalize_path(path))
	var first := sheet.get_region(Rect2i(0, 0, 160, 192))
	for frame_index in 16:
		var anchored_frame := sheet.get_region(Rect2i(frame_index * 160, 0, 160, 192))
		if _alpha_weighted_center(anchored_frame).distance_to(Vector2(80.0, 96.0)) > 2.0:
			_fail("The portal base drifts around its cell instead of holding a stable vortex anchor.")
			return false
	var zones := [Rect2i(50, 28, 60, 42), Rect2i(43, 72, 74, 48), Rect2i(50, 122, 60, 42)]
	var changed_by_zone := [0, 0, 0]
	var rim_changes := 0
	var inner_body := Rect2i(44, 28, 72, 136)
	for frame_index in range(1, 16):
		var frame := sheet.get_region(Rect2i(frame_index * 160, 0, 160, 192))
		if frame.get_pixel(80, 96).a <= 0.25:
			_fail("A portal frame left the exact middle empty or visually flat.")
			return false
		for y in 192:
			for x in 160:
				if frame.get_pixel(x, y) == first.get_pixel(x, y):
					continue
				var point := Vector2i(x, y)
				for zone_index in zones.size():
					if zones[zone_index].has_point(point):
						changed_by_zone[zone_index] += 1
				if not inner_body.has_point(point):
					rim_changes += 1
	for changed_pixels in changed_by_zone:
		if changed_pixels < 500:
			_fail("Portal motion does not cross the full inner surface at every depth.")
			return false
	if rim_changes < 500:
		_fail("The outer portal edge remains static instead of rippling between frames.")
		return false
	return true


func _alpha_weighted_center(image: Image) -> Vector2:
	var weighted_position := Vector2.ZERO
	var weight_total := 0.0
	for y in image.get_height():
		for x in image.get_width():
			var alpha := image.get_pixel(x, y).a
			var weight := alpha * alpha
			weighted_position += Vector2(x, y) * weight
			weight_total += weight
	return weighted_position / maxf(weight_total, 0.001)


func _validate_fx_is_dense_and_distributed(path: String) -> bool:
	var sheet := Image.load_from_file(ProjectSettings.globalize_path(path))
	var side_counts := [0, 0, 0, 0]
	for frame_index in 16:
		var active_pixels := 0
		for y in 224:
			for local_x in 256:
				if sheet.get_pixel(frame_index * 256 + local_x, y).a <= 0.0:
					continue
				active_pixels += 1
				if local_x < 48: side_counts[0] += 1
				if local_x >= 208: side_counts[1] += 1
				if y < 32: side_counts[2] += 1
				if y >= 192: side_counts[3] += 1
		var density := float(active_pixels) / float(256 * 224)
		if density < 0.18:
			_fail("A portal FX frame lacks the requested frequent layered lightning.")
			return false
	for side_count in side_counts:
		if side_count < 1000:
			_fail("Lightning is not distributed around the complete portal circumference.")
			return false
	if side_counts[0] + side_counts[1] + side_counts[2] + side_counts[3] < 8000:
		_fail("Portal lightning does not extend far enough beyond the doorway.")
		return false
	return true


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
