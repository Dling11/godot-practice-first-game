extends "res://gameplay/presentation/axe_swing_trail.gd"

## Camera-authored generated rasters; base melee contact remains authoritative.
@export var upward_atlas: Texture2D
@export var downward_atlas: Texture2D
var _side_atlas: Texture2D
var _side_origins := PackedVector2Array()
var _side_scale := 1.0

func _ready() -> void:
	_side_atlas = atlas
	_side_origins = origins.duplicate()
	_side_scale = world_pixels_per_texel
	super._ready()

func _phase(phase: int,duration: float) -> void:
	var direction := _attack.get_attack_direction()
	var vertical := absf(direction.y)>=absf(direction.x)
	atlas = (upward_atlas if direction.y<0 else downward_atlas) if vertical else _side_atlas
	origins = PackedVector2Array([Vector2(96,96),Vector2(96,96),Vector2(96,96),Vector2(96,96),Vector2(96,96)]) if vertical else _side_origins
	world_pixels_per_texel = .85 if vertical else _side_scale
	rotate_vertical_sampling = not vertical
	# The family adapter owns facing depth (rear contact behind the body).
	super._phase(phase,duration)
