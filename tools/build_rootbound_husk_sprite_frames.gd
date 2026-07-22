extends SceneTree

const BODY_OUTPUT := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_sprite_frames.tres"
const VFX_OUTPUT := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sprite_frames.tres"
const WALK_TEXTURE := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_walk_sheet_72x64.png"
const ROOT_ATTACK_TEXTURE := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_attack_body_sheet_96x64.png"
const REACTION_TEXTURE := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_reaction_sheet_64x64.png"
const VFX_TEXTURE := "res://assets/characters/enemies/rootbound_husk/rootbound_husk_root_spear_vfx_sheet_128x64.png"
const DIRECTIONS := [&"down", &"left", &"right", &"up"]


func _initialize() -> void:
	var walk_texture := load(WALK_TEXTURE) as Texture2D
	var root_attack_texture := load(ROOT_ATTACK_TEXTURE) as Texture2D
	var reaction_texture := load(REACTION_TEXTURE) as Texture2D
	var vfx_texture := load(VFX_TEXTURE) as Texture2D
	if walk_texture == null or root_attack_texture == null or reaction_texture == null or vfx_texture == null:
		push_error("Rootbound Husk runtime textures must be imported before building SpriteFrames.")
		quit(1)
		return
	var body_frames := SpriteFrames.new()
	body_frames.remove_animation(&"default")
	for row in DIRECTIONS.size():
		var direction: StringName = DIRECTIONS[row]
		_add_animation(body_frames, &"idle_%s" % direction, walk_texture, Vector2i(72, 64), row, [0], 1.0, true)
		_add_animation(body_frames, &"walk_%s" % direction, walk_texture, Vector2i(72, 64), row, [0, 1, 2, 3], 6.5, true)
		_add_animation(body_frames, &"root_attack_wind_up_%s" % direction, root_attack_texture, Vector2i(96, 64), row, [0, 1, 2, 3], 6.0, false)
		_add_animation(body_frames, &"root_attack_active_%s" % direction, root_attack_texture, Vector2i(96, 64), row, [3, 4], 10.0, false)
		_add_animation(body_frames, &"root_attack_recovery_%s" % direction, root_attack_texture, Vector2i(96, 64), row, [4, 5], 6.0, false)
		_add_animation(body_frames, &"hurt_%s" % direction, reaction_texture, Vector2i(64, 64), row, [1, 2], 12.0, false)
		_add_animation(body_frames, &"dead_%s" % direction, reaction_texture, Vector2i(64, 64), row, [3], 1.0, false)
	var body_error := ResourceSaver.save(body_frames, BODY_OUTPUT)
	if body_error != OK:
		push_error("Unable to save Rootbound Husk body SpriteFrames.")
		quit(1)
		return
	var vfx_frames := SpriteFrames.new()
	vfx_frames.remove_animation(&"default")
	_add_animation(vfx_frames, &"telegraph", vfx_texture, Vector2i(128, 64), 0, [0, 1, 2], 4.5, true)
	_add_animation(vfx_frames, &"erupt", vfx_texture, Vector2i(128, 64), 0, [3, 4, 5], 12.0, false)
	var vfx_error := ResourceSaver.save(vfx_frames, VFX_OUTPUT)
	if vfx_error != OK:
		push_error("Unable to save Rootbound Husk VFX SpriteFrames.")
		quit(1)
		return
	print("Built Rootbound Husk SpriteFrames resources.")
	quit(0)


func _add_animation(
	frames: SpriteFrames,
	animation_name: StringName,
	texture: Texture2D,
	cell_size: Vector2i,
	row: int,
	columns: Array,
	speed: float,
	looping: bool
) -> void:
	frames.add_animation(animation_name)
	frames.set_animation_speed(animation_name, speed)
	frames.set_animation_loop(animation_name, looping)
	for column in columns:
		var frame := AtlasTexture.new()
		frame.atlas = texture
		frame.region = Rect2(column * cell_size.x, row * cell_size.y, cell_size.x, cell_size.y)
		frames.add_frame(animation_name, frame)
