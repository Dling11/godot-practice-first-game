extends SummonEffect

## Raster comparison only. The encounter still owns the arrival and its sound.
@export_enum("a", "b", "c") var art_key := "a"
var sprite: AnimatedSprite2D

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -1
	sprite = AnimatedSprite2D.new()
	sprite.sprite_frames = load("res://assets/vfx/enemy_arrival_review/" + art_key + "_frames.tres")
	# All 64px cells share the same (32,52) floor pivot.
	sprite.position = Vector2(0, -20)
	add_child(sprite)
	sprite.animation_finished.connect(_finished)
	sprite.frame_changed.connect(_fade_remnant)
	sprite.play("warning")

func release() -> void:
	released = true
	sprite.play("release")

func _finished() -> void:
	if released:
		queue_free()

func _fade_remnant() -> void:
	if released and sprite.animation == &"release" and sprite.frame == 3:
		create_tween().tween_property(sprite, "modulate:a", 0.0, 0.14)

func _draw() -> void:
	# Suppress the inherited procedural seam in this dedicated raster review.
	pass
