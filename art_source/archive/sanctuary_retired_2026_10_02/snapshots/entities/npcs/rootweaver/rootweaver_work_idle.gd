class_name RootweaverWorkIdle
extends Timer

## Event-driven presentation loop for Nema. Gameplay collision and interaction
## remain stationary while the actor occasionally demonstrates forge work.

@export var actor: AnimatedSprite2D
@export var strike_audio: AudioStreamPlayer2D

var _strike_played := false


func _ready() -> void:
	if actor == null:
		push_error("RootweaverWorkIdle requires an AnimatedSprite2D actor.")
		return
	timeout.connect(_begin_work)
	actor.animation_finished.connect(_finish_work)
	actor.frame_changed.connect(_on_frame_changed)
	start()


func _begin_work() -> void:
	if actor.animation == &"work":
		return
	_strike_played = false
	actor.play(&"work")


func _finish_work() -> void:
	if actor.animation == &"work":
		actor.play(&"idle")


func _on_frame_changed() -> void:
	if actor.animation != &"work" or actor.frame != 2 or _strike_played:
		return
	_strike_played = true
	if strike_audio != null:
		strike_audio.play()
