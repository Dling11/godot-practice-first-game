extends SceneTree

const StageScene = preload("res://levels/stage_4/stage_4.tscn")
const HogScene = preload("res://entities/enemies/armored_hog/armored_hog.tscn")


func _initialize() -> void:
	call_deferred("_capture")


func _capture() -> void:
	var stage := StageScene.instantiate()
	stage.get_node("GameplayServices/EncounterController").auto_start = false
	root.add_child(stage)
	stage.get_node("UI").visible = false
	var player := stage.get_node("World/Actors/Player") as Player
	player.global_position = Vector2(768.0, 470.0)
	player.set_physics_process(false)
	var actors := stage.get_node("World/Actors") as Node2D
	for entry in [
		[Vector2(640.0, 470.0), ArmoredHog.State.BRACE, Vector2.RIGHT],
		[Vector2(890.0, 410.0), ArmoredHog.State.CHARGE, Vector2.LEFT],
		[Vector2(880.0, 550.0), ArmoredHog.State.DAZED, Vector2.LEFT],
	]:
		var hog := HogScene.instantiate() as ArmoredHog
		hog.target = player
		actors.add_child(hog)
		hog.global_position = entry[0]
		hog.set_physics_process(false)
		hog.facing_direction = entry[2]
		hog.get_node("VisualPivot").set_facing_direction(entry[2])
		hog.get_node("AttackPivot").set_facing_direction(entry[2])
		hog.get_node("VisualPivot").play_state(entry[1], 0.62)
	for frame in range(5):
		await process_frame
	var image := root.get_viewport().get_texture().get_image()
	var path := ProjectSettings.globalize_path(
		"res://art_source/review/characters/enemies/stage_4_armored_hog/armored_hog_stage_4_gameplay_review.png"
	)
	var error := image.save_png(path)
	if error != OK:
		push_error("Unable to save Armored Hog gameplay review.")
		quit(1)
		return
	print("Saved Armored Hog Stage 4 gameplay review.")
	quit(0)
