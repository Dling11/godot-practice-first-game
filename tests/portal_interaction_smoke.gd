extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")


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
	var trigger_shape := trigger.shape as CircleShape2D
	if trigger_shape.radius < 48.0:
		_fail("Portal interaction radius is too small to behave as a proximity prompt.")
		return
	var prompt := {"visible": false, "text": "", "entered": false}
	portal.proximity_changed.connect(func(visible: bool, text: String) -> void:
		prompt.visible = visible
		prompt.text = text
	)
	portal.player_entered.connect(func() -> void: prompt.entered = true)
	player.global_position = Vector2(200.0, 200.0)
	portal.global_position = Vector2(200.0, 200.0)
	for frame in range(3): await physics_frame
	if not hud.interaction_panel.visible or not portal.interaction_label.visible:
		_fail("Real physics overlap did not display both portal interaction prompts.")
		return
	player.global_position = Vector2(400.0, 400.0)
	for frame in range(3): await physics_frame
	if hud.interaction_panel.visible or portal.interaction_label.visible:
		_fail("Real physics separation did not hide both portal interaction prompts.")
		return
	portal._on_body_entered(player)
	if not prompt.visible or not prompt.text.contains("PRESS F TO ENTER PORTAL"):
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
