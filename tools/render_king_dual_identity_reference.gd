extends SceneTree

func _initialize() -> void: call_deferred("render_reference")
func render_reference() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size=Vector2i(840,360)
	root.content_scale_size=root.size
	var bg := ColorRect.new()
	bg.color=Color("263339")
	bg.size=Vector2(root.size)
	root.add_child(bg)
	var specs := [["SIDE / accepted axe body","axe_proof_v3/carry.tres",6],["FRONT / existing King identity","greatsword_cardinal/down/run.tres",0],["BACK / existing King identity","greatsword_cardinal/up/run.tres",0]]
	for index in 3:
		var clip: Resource = load("res://assets/characters/playable/king/"+specs[index][1])
		var key: int = specs[index][2]
		var atlas := AtlasTexture.new()
		atlas.atlas=clip.body_atlas
		atlas.region=Rect2(key%4*192,key/4*128,192,128)
		var sprite := Sprite2D.new()
		sprite.texture=atlas
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
		sprite.position=Vector2(140+index*280,180)
		sprite.scale=Vector2.ONE*4
		root.add_child(sprite)
		var label := Label.new()
		label.text=specs[index][0]
		label.position=Vector2(10+index*280,12)
		root.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png("res://art_source/generated/characters/king/dual_unified_2026_10_05/identity_reference.png")==OK)
	quit()
