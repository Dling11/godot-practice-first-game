extends Node

## Stage-local selection routed through the global music owner.

@export var music_stream: AudioStream


func _ready() -> void:
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.play_music(music_stream)
