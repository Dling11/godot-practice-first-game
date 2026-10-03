extends SceneTree

## Isolated visual rehearsal: no loading, gameplay, saves or title changes.
const BACKGROUND := "res://art_source/generated/ui/quiet_threshold_previews_2026_10_03/loading_quiet_threshold.png"
const EVIDENCE := "res://art_source/generated/ui/threat_portal_previews_2026_10_03/loading_frames/"
const FRAMES = preload("res://assets/characters/playable/king/spellward/spellward_frames.tres")
var _king: AnimatedSprite2D
var _sparks: Array[Polygon2D] = []

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	root.mode = Window.MODE_WINDOWED
	root.title = "Battle of Gods — Animated Loading ART PREVIEW · NO SAVES"
	root.grab_focus()
	var scene := Node2D.new()
	scene.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(scene)
	current_scene = scene
	var image := Image.load_from_file(BACKGROUND)
	if image == null:
		push_error("Loading preview background is missing.")
		quit(1)
		return
	var backdrop := Sprite2D.new()
	backdrop.texture = ImageTexture.create_from_image(image)
	backdrop.centered = false
	backdrop.scale = Vector2(960.0/image.get_width(),540.0/image.get_height())
	scene.add_child(backdrop)
	_king = AnimatedSprite2D.new()
	_king.sprite_frames = FRAMES
	_king.animation = &"walk_right"
	# Twice the production body scale makes the small loading mascot readable.
	_king.scale = Vector2.ONE
	_king.position = Vector2(688,365)
	var material := ShaderMaterial.new()
	material.shader = load("res://entities/player/presentation/king_spellward_outline.gdshader")
	_king.material = material
	scene.add_child(_king)
	for index in range(3):
		var spark := Polygon2D.new()
		spark.polygon = PackedVector2Array([Vector2(-2,0),Vector2(-1,-1),Vector2(0,-3),Vector2(1,-1),Vector2(2,0),Vector2(1,1),Vector2(0,3),Vector2(-1,1)])
		spark.color = Color(0.75,0.66,0.95,0.55)
		scene.add_child(spark)
		_sparks.append(spark)
	await create_timer(0.4).timeout
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(EVIDENCE))
	var count := FRAMES.get_frame_count(&"walk_right")
	assert(count == 8)
	for index in range(40):
		_king.frame = index % count
		var phase := TAU * float(index) / 40.0
		for j in range(_sparks.size()):
			var angle := phase + TAU * j/3.0
			_sparks[j].position = Vector2(480,225) + Vector2(cos(angle)*82,sin(angle)*78)
			_sparks[j].modulate.a = 0.4 + 0.3*(sin(angle)+1.0)
		await RenderingServer.frame_post_draw
		var error := root.get_texture().get_image().save_png(EVIDENCE+"frame_%02d.png" % index)
		if error != OK:
			push_error("Cannot capture loading preview.")
			quit(1)
			return
		await process_frame
	print("QUIET_LOADING_PREVIEW: 40 rendered frames, 8 existing King walk poses, no loading/save mutations")
	quit()
