extends SceneTree

## Static design scale comparison. It does not equip or animate these candidates.
const SOURCE := "res://art_source/generated/characters/king/dual_sword_design_2026_10_05/"
const IDLE = preload("res://assets/characters/playable/king/greatsword_readability/down/idle.tres")
const PAIRS := [Rect2i(45,185,430,710),Rect2i(555,185,425,710),Rect2i(1050,180,460,715)]

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	if DisplayServer.get_name()=="headless":
		push_error("Design scale comparison requires native rendering")
		quit(1)
		return
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.size = Vector2i(960,540)
	root.content_scale_size = root.size
	var background := ColorRect.new()
	background.size = root.size
	background.color = Color("202b30")
	root.add_child(background)
	var raw := Image.load_from_file(SOURCE+"source.png")
	var reports: Array[Dictionary] = []
	for index in 3:
		assert(Rect2i(Vector2i.ZERO,raw.get_size()).encloses(PAIRS[index]))
		var view := SubViewport.new()
		view.size = Vector2i(80,64)
		view.render_target_update_mode = SubViewport.UPDATE_ALWAYS
		root.add_child(view)
		var backdrop := ColorRect.new()
		backdrop.size = view.size
		backdrop.color = background.color
		view.add_child(backdrop)
		var body := Sprite2D.new()
		var cel := AtlasTexture.new()
		cel.atlas = IDLE.body_atlas
		cel.region = Rect2(0,0,192,128)
		body.texture = cel
		body.scale = Vector2.ONE*.5
		body.position = Vector2(21,35)
		body.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		view.add_child(body)
		var pair := Sprite2D.new()
		pair.texture = ImageTexture.create_from_image(raw.get_region(PAIRS[index]))
		pair.centered = false
		pair.position = Vector2(43,7)
		pair.scale = Vector2.ONE/16
		pair.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
		view.add_child(pair)
		for zoom in [1,4]:
			var display := TextureRect.new()
			display.texture = view.get_texture()
			display.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			display.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			display.size = Vector2(view.size)*zoom
			display.position = Vector2(index*320+(120 if zoom==1 else 0),80 if zoom==1 else 160)
			root.add_child(display)
		var label := Label.new()
		label.text = ["A · Twinsteel","B · Mooncut","C · Oathpair"][index]+"\n1× above / same image 4× below"
		label.position = Vector2(index*320+14,20)
		root.add_child(label)
		reports.append({"candidate":index,"source_pair_region":var_to_str(PAIRS[index]),"king_body_scale":.5,"weapons_source_scale":1.0/16.0,"preview_zooms":[1,4]})
	var note := Label.new()
	note.text = "Design scale only · current King body · no equipped blades or animation\nAll weapons use one source scale; enlarged row magnifies the same rendered pixels."
	note.position = Vector2(16,454)
	root.add_child(note)
	await process_frame
	await process_frame
	await RenderingServer.frame_post_draw
	assert(root.get_texture().get_image().save_png(SOURCE+"native_readability.png")==OK)
	FileAccess.open(SOURCE+"readability.json",FileAccess.WRITE).store_string(JSON.stringify({"source_size":[raw.get_width(),raw.get_height()],"native":true,"candidates":reports},"\t")+"\n")
	print("DUAL_DESIGN native scale comparison:3 complete pair regions / nearest1x and4x")
	quit()
