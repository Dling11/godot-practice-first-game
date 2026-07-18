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
	if player.global_position != Vector2(768, 760):
		_fail("Stage 2 player did not arrive at the authored spawn point.")
		return
	var controller: EncounterController = current_scene.get_node("GameplayServices/EncounterController")
	if controller.waves.size() != 7:
		_fail("Stage 2 must contain its authored seven-wave encounter.")
		return
	var spitter_wave := controller.waves[1] as EncounterWaveDefinition
	if spitter_wave.bramble_spitter_count != 1:
		_fail("Stage 2 does not introduce exactly one Bramble Spitter in Wave 2.")
		return
	if current_scene.get_node("World/Effects").get_child_count() != 0:
		_fail("Stage 2 exit portal should not exist before its encounter is cleared.")
		return
	var story_state := root.get_node("StoryState")
	story_state.reset_story()
	controller._spawn_portal()
	await process_frame
	if (
		not story_state.has_story_flag(&"forgotten_grove_completed")
		or not story_state.has_discovery(&"remembered_thorn_shrine")
	):
		_fail("Clearing the current grove route did not record its story memories.")
		return
	var return_portal: StagePortal = current_scene.get_node("World/Effects").get_child(0)
	if return_portal.target_scene_path != "res://levels/sanctuary/sanctuary.tscn":
		_fail("Cleared Stage 2 portal is not configured to return to Sanctuary.")
		return
	print("Scene transition smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
