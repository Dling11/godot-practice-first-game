extends SceneTree

const Stage1Scene = preload("res://levels/test_arena/test_arena.tscn")
const TEST_PROFILE_PATH := "user://battle_of_gods_safe_milestone_smoke.json"

var _save_service: Node


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	_save_service = root.get_node("SaveService")
	if not _save_service.configure_storage_path_for_testing(TEST_PROFILE_PATH):
		_fail("SaveService refused the isolated safe-milestone test path.")
		return
	_save_service.delete_profile()
	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	root.get_node("WeaponInventory").reset_inventory()

	var stage := Stage1Scene.instantiate()
	root.add_child(stage)
	await process_frame
	root.get_node("RunSession").update_progression(304, 46)
	root.get_node("RunSession").update_player_health(118.0)
	var controller := stage.get_node("GameplayServices/EncounterController")
	controller.stage_cleared.emit()
	if not _save_service.has_valid_profile():
		_fail("Stage completion did not create a safe autosave.")
		return

	root.get_node("RunSession").reset_run()
	root.get_node("StoryState").reset_story()
	if _save_service.load_profile() != _save_service.DEFAULT_SAFE_SCENE:
		_fail("The stage-clear autosave did not resume safely in Sanctuary.")
		return
	if (
		root.get_node("RunSession").total_experience != 304
		or root.get_node("RunSession").coins != 46
		or not is_equal_approx(root.get_node("RunSession").player_current_health, 118.0)
		or not root.get_node("StoryState").has_story_flag(
			&"forgotten_grove_stage_1_cleared"
		)
	):
		_fail("The stage-clear autosave omitted progression or completion memory.")
		return

	_cleanup()
	print("Safe milestone autosave smoke test passed.")
	quit(0)


func _cleanup() -> void:
	if _save_service != null:
		_save_service.delete_profile()
		_save_service.reset_storage_path_after_testing()


func _fail(message: String) -> void:
	_cleanup()
	push_error(message)
	quit(1)
