extends SceneTree

const Portal = preload("res://gameplay/encounters/stage_portal.tscn")
const OUTPUT := "res://art_source/review/ui/portal_stability_2026_10_03/"

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	root.mode = Window.MODE_WINDOWED
	var scene := Node2D.new()
	scene.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	root.add_child(scene)
	current_scene = scene
	var background := Sprite2D.new()
	background.texture = QuietLoadingView.BACKGROUND
	background.centered = false
	scene.add_child(background)
	label(scene,"PORTAL MOTION · BEFORE / AFTER",Vector2(180,30),Vector2(600,30),20)
	label(scene,"Before: changing doorway poses",Vector2(55,91),Vector2(380,30),16)
	label(scene,"After: stable outline + flowing currents",Vector2(525,91),Vector2(380,30),16)
	for row in 2:
		for column in 2:
			var origin := Vector2(255+column*460,255+row*193)
			var portal := Portal.instantiate() as StagePortal
			portal.portal_tier = StagePortal.PortalTier.NORMAL if row == 0 else StagePortal.PortalTier.BOSS
			scene.add_child(portal)
			portal.position = origin
			portal.set_process(false)
			portal.portal_fx.hide()
			portal.guidance_arrow.hide()
			portal.offscreen_guide.hide()
			if column == 0: portal.portal_visual.material = null
			var king := AnimatedSprite2D.new()
			king.sprite_frames = QuietLoadingView.KING_FRAMES
			king.scale = Vector2.ONE*.5
			king.position = origin+Vector2(-94,0)
			var outline := ShaderMaterial.new()
			outline.shader = preload("res://entities/player/presentation/king_spellward_outline.gdshader")
			king.material = outline
			scene.add_child(king)
			king.play(&"idle_down")
			var line := Line2D.new()
			line.points = PackedVector2Array([origin+Vector2(-70,1),origin+Vector2(70,1)])
			line.width = 1
			line.default_color = Color(.48,.43,.29,.35)
			scene.add_child(line)
		label(scene,"CALM / NORMAL" if row == 0 else "GRASP / BOSS",Vector2(330,273+row*193),Vector2(300,22),12)
	label(scene,"Same native scale · lightning hidden to compare body geometry · no gameplay/save changes",Vector2(80,507),Vector2(800,23),12)
	DirAccess.make_dir_recursive_absolute(OUTPUT+"comparison_frames/")
	await create_timer(.8).timeout
	for index in 32:
		await RenderingServer.frame_post_draw
		assert(root.get_texture().get_image().save_png(OUTPUT+"comparison_frames/frame_%02d.png" % index) == OK)
		await create_timer(.1).timeout
	scene.queue_free()
	current_scene = null
	await process_frame
	await process_frame
	print("PORTAL_STABILITY_REVIEW: 32 native before/after frames, same scale and source sheets")
	quit()

func label(parent: Node, text: String, position: Vector2, extent: Vector2, font_size: int) -> void:
	var node := Label.new()
	node.text = text
	node.position = position
	node.size = extent
	node.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	node.add_theme_font_size_override("font_size",font_size)
	node.add_theme_color_override("font_color",QuietLoadingView.GOLD)
	parent.add_child(node)
