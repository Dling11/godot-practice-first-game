extends SceneTree

const PlayerScene = preload("res://entities/player/player.tscn")
const HudScene = preload("res://ui/combat_hud.tscn")
const REVIEW_DIR := "res://art_source/review/ui/eclipse_bind_tuned_2026_09_27"


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.get_node("RunSession").reset_run()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(REVIEW_DIR))
	var backdrop := ColorRect.new()
	backdrop.color = Color("111b29")
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	root.add_child(backdrop)
	var player := PlayerScene.instantiate() as Player
	root.add_child(player)
	player.set_physics_process(false)
	player.apply_debug_testing_preset()
	var pursuit := player.ability_3_component as SovereignPursuitComponent
	pursuit.apply_rank(SovereignPursuitDefinition.Rank.MATURE)
	var hud := HudScene.instantiate() as CombatHUD
	root.add_child(hud)
	hud.bind_player(player)
	await process_frame
	await process_frame
	_save("01_ready.png")
	pursuit.charges_available = 1
	pursuit.cooldown_remaining = 5.3
	pursuit.charges_changed.emit(1, 3)
	await process_frame
	_save("02_one_charge.png")
	backdrop.color = Color("5f6b5d")
	await process_frame
	_save("03_contrast.png")
	hud.queue_free()
	player.queue_free()
	backdrop.queue_free()
	await process_frame
	print("Captured skill HUD review.")
	quit(0)


func _save(filename: String) -> void:
	var image := root.get_viewport().get_texture().get_image()
	var error := image.save_png(ProjectSettings.globalize_path("%s/%s" % [REVIEW_DIR, filename]))
	if error != OK:
		push_error("Could not save skill HUD review image: %s" % filename)
