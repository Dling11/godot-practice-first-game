extends SceneTree

const STAGE_2 := "res://levels/stage_2/stage_2.tscn"


func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	if not ResourceLoader.exists(STAGE_2):
		_fail("Stage 2 destination scene does not exist.")
		return
	var transition_service := root.get_node_or_null("SceneTransition")
	if transition_service == null:
		_fail("SceneTransition autoload is unavailable.")
		return
	var result: bool = await transition_service.transition_to(STAGE_2)
	if not result:
		_fail("SceneTransition rejected the valid Stage 2 destination.")
		return
	if current_scene == null or current_scene.scene_file_path != STAGE_2:
		_fail("Fade transition did not install Stage 2 as the current scene.")
		return
	var player: Player = current_scene.get_node("World/Actors/Player")
	if player.global_position != Vector2(640, 560):
		_fail("Stage 2 player did not arrive at the authored spawn point.")
		return
	var return_portal: StagePortal = current_scene.get_node("World/Effects/ReturnPortal")
	if return_portal.target_scene_path != "res://levels/test_arena/test_arena.tscn":
		_fail("Stage 2 return portal is not configured.")
		return
	print("Scene transition smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
