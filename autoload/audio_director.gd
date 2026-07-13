extends Node

## Owns music playback and its dedicated bus. Gameplay emits events; it does not own combat rules.

const MUSIC_BUS := "Music"
const SFX_BUS := "SFX"
const UI_BUS := "UI"

var music_player: AudioStreamPlayer


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_ensure_bus(MUSIC_BUS)
	_ensure_bus(SFX_BUS)
	_ensure_bus(UI_BUS)
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = MUSIC_BUS
	music_player.volume_db = -13.0
	add_child(music_player)


func play_music(stream: AudioStream) -> void:
	if stream == null:
		stop_music()
		return
	if music_player.stream == stream and music_player.playing:
		return
	if stream is AudioStreamOggVorbis:
		(stream as AudioStreamOggVorbis).loop = true
	music_player.stream = stream
	# Headless verification has no audio device. Retaining the stream assignment
	# validates scene routing without leaving native OGG playback objects alive at
	# process shutdown.
	if DisplayServer.get_name() == "headless":
		return
	music_player.play()


func stop_music() -> void:
	if music_player == null:
		return
	music_player.stop()
	music_player.stream = null


func _exit_tree() -> void:
	stop_music()


func _ensure_bus(bus_name: String) -> void:
	if AudioServer.get_bus_index(bus_name) >= 0:
		return
	AudioServer.add_bus()
	AudioServer.set_bus_name(AudioServer.bus_count - 1, bus_name)
