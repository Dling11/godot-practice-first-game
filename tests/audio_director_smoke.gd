extends SceneTree

func _initialize() -> void:
	call_deferred("_run")


func _run() -> void:
	var audio_director := root.get_node_or_null("AudioDirector")
	if audio_director == null:
		_fail("AudioDirector autoload is unavailable.")
		return
	await process_frame
	if AudioServer.get_bus_index("Music") < 0:
		_fail("AudioDirector did not create the dedicated Music bus.")
		return
	var grove_music := load("res://assets/audio/music/cathedral_in_the_forest.ogg") as AudioStream
	audio_director.play_music(grove_music)
	await process_frame
	if audio_director.music_player.stream != grove_music:
		_fail("AudioDirector did not assign the approved Grove music stream.")
		return
	audio_director.stop_music()
	grove_music = null
	await process_frame
	print("Audio director smoke test passed.")
	quit(0)


func _fail(message: String) -> void:
	push_error(message)
	quit(1)
