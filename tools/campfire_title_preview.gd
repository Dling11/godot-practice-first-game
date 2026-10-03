extends Control

const SOURCE := "res://art_source/generated/ui/campfire_title_2026_10_03/"
const KING := preload("res://assets/characters/playable/king/spellward/spellward_frames.tres")
const ROOTLING := preload("res://assets/characters/enemies/rootling/rootling_walk_sheet_32x32.png")
var fire: AnimatedSprite2D
var king: AnimatedSprite2D
var watchers: Array[AnimatedSprite2D] = []
var backdrop: TextureRect

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	mouse_filter = Control.MOUSE_FILTER_IGNORE
	set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop = TextureRect.new()
	backdrop.texture = _image_texture("background.png")
	backdrop.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	backdrop.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	backdrop.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(backdrop)
	var canvas := Node2D.new()
	canvas.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	add_child(canvas)
	fire = AnimatedSprite2D.new()
	fire.sprite_frames = _frames(_image_texture("flame.png"), Vector2i(80,80), 8, 1, &"burn", 8.0)
	fire.position = Vector2(690, 282 - 32)
	canvas.add_child(fire)
	fire.play(&"burn")
	king = AnimatedSprite2D.new()
	king.sprite_frames = KING
	king.scale = Vector2.ONE * 1.5
	king.position = Vector2(616, 306 - 48)
	var outline := ShaderMaterial.new()
	outline.shader = preload("res://entities/player/presentation/king_spellward_outline.gdshader")
	king.material = outline
	canvas.add_child(king)
	king.play(&"idle_right")
	_add_watcher(canvas, Vector2(846,356), Vector2(-32,-8), 1.0)
	_add_watcher(canvas, Vector2(380,420), Vector2(30,-8), 2.2)

func _add_watcher(canvas: Node2D, feet: Vector2, drift: Vector2, delay: float) -> void:
	var actor := AnimatedSprite2D.new()
	actor.sprite_frames = _frames(ROOTLING, Vector2i(32,32), 4, 4, &"walk", 4.0)
	actor.scale = Vector2.ONE * 2
	actor.position = feet - Vector2(0,32)
	actor.modulate = Color(1.0,.94,.8,1.0)
	canvas.add_child(actor)
	watchers.append(actor)
	var rest := actor.position
	var forward := &"walk_1" if drift.x < 0 else &"walk_2"
	var back := &"walk_2" if drift.x < 0 else &"walk_1"
	actor.animation = forward
	var watching := create_tween().set_loops()
	watching.tween_interval(delay)
	watching.tween_callback(func() -> void: actor.play(forward))
	watching.tween_property(actor,"position",rest+drift,2.4)
	watching.tween_callback(func() -> void: actor.pause())
	watching.tween_interval(1.1)
	watching.tween_callback(func() -> void: actor.play(back))
	watching.tween_property(actor,"position",rest,2.4)
	watching.tween_callback(func() -> void: actor.pause())

func _image_texture(key: String) -> ImageTexture:
	return ImageTexture.create_from_image(Image.load_from_file(ProjectSettings.globalize_path(SOURCE + key)))

func _frames(texture: Texture2D, cell: Vector2i, columns: int, rows: int, key: StringName, speed: float) -> SpriteFrames:
	var result := SpriteFrames.new()
	result.remove_animation(&"default")
	for row in rows:
		var name := key if rows == 1 else StringName(str(key) + "_%d" % row)
		result.add_animation(name)
		result.set_animation_speed(name,speed)
		for column in columns:
			var region := AtlasTexture.new()
			region.atlas = texture
			region.region = Rect2(column * cell.x, row * cell.y, cell.x, cell.y)
			result.add_frame(name,region)
	return result
