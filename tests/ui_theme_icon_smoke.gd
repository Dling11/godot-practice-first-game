extends SceneTree

const HudScene = preload("res://ui/combat_hud.tscn")
const CharacterMenuScene = preload("res://ui/character_menu.tscn")
const PortalScene = preload("res://gameplay/encounters/stage_portal.tscn")
const ThemeResource = preload("res://assets/ui/themes/battle_of_gods_theme.tres")

const ICON_SIZES := {
	"res://assets/ui/icons/actions/icon_action_primary_attack_24x24.png": Vector2i(24, 24),
	"res://assets/ui/icons/actions/icon_action_dash_24x24.png": Vector2i(24, 24),
	"res://assets/ui/icons/skills/icon_skill_sweeping_cut_24x24.png": Vector2i(24, 24),
	"res://assets/ui/icons/economy/icon_currency_coin_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/status/icon_status_health_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/status/icon_status_experience_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/interactions/icon_interaction_portal_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/interactions/icon_interaction_talk_16x16.png": Vector2i(16, 16),
	"res://assets/ui/icons/states/icon_slot_locked_16x16.png": Vector2i(16, 16),
}


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ThemeResource.has_stylebox("panel", "PanelContainer"):
		_fail("Shared UI theme is missing its PanelContainer style.")
		return
	if not ThemeResource.has_stylebox("normal", "Button"):
		_fail("Shared UI theme is missing its Button normal state.")
		return
	for path: String in ICON_SIZES:
		var texture := load(path) as Texture2D
		if texture == null or texture.get_size() != Vector2(ICON_SIZES[path]):
			_fail("UI icon has an invalid texture or size: %s" % path)
			return
		var image := texture.get_image()
		for y in image.get_height():
			for x in image.get_width():
				var alpha := image.get_pixel(x, y).a
				if alpha > 0.001 and alpha < 0.999:
					_fail("UI icon contains soft alpha instead of hard pixels: %s" % path)
					return
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(hud)
	if hud.theme != ThemeResource:
		_fail("CombatHUD is not using the shared UI theme.")
		return
	if hud.get_node("HealthPanel/Margin/Stack/Header/HealthIcon").texture == null:
		_fail("CombatHUD health icon is not configured.")
		return
	var menu := CharacterMenuScene.instantiate() as CharacterMenu
	if menu.theme != ThemeResource:
		_fail("CharacterMenu is not using the shared UI theme.")
		return
	var portal := PortalScene.instantiate() as StagePortal
	root.add_child(portal)
	if portal.interaction_icon == null:
		_fail("StagePortal is not configured with its contextual prompt icon.")
		return
	hud.queue_free()
	portal.queue_free()
	menu.free()
	await process_frame
	print("UI theme and named icon smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
