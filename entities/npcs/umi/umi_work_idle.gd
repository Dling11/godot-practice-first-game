extends Timer

@export var actor: AnimatedSprite2D


func _ready() -> void:
	timeout.connect(_play_work)
	if actor != null:
		actor.animation_finished.connect(_on_animation_finished)


func _play_work() -> void:
	if actor != null and actor.animation == &"idle":
		actor.play(&"work")


func _on_animation_finished() -> void:
	if actor != null and actor.animation == &"work":
		actor.play(&"idle")
