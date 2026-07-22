class_name MinibossMusicTrigger
extends Node

@export var encounter_controller: EncounterController
@export var miniboss_music: AudioStream


func _ready() -> void:
	if encounter_controller == null:
		push_error("MinibossMusicTrigger requires an EncounterController.")
		return
	encounter_controller.wave_changed.connect(_on_wave_changed)


func _on_wave_changed(index: int, _total: int, _title: String) -> void:
	if index < 1 or index > encounter_controller.waves.size():
		return
	var wave := encounter_controller.waves[index - 1] as EncounterWaveDefinition
	if wave == null or wave.rootbound_husk_count <= 0:
		return
	var audio_director := get_node_or_null("/root/AudioDirector")
	if audio_director != null:
		audio_director.play_music(miniboss_music)
