extends SceneTree

const OUT := "res://art_source/review/combat/king_cardinal_proportions_2026_10_07/"
const Check = preload("res://tests/king_cardinal_proportions_smoke.gd")
const Registration = preload("res://tools/king_cardinal_body_registration.gd")

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.size = Vector2i(1000,900)
	root.content_scale_size = root.size
	RenderingServer.set_default_clear_color(Color("202b30"))
	var scene := Node2D.new()
	root.add_child(scene)
	var results := []
	var audit := Check.new()
	var simulate := OS.get_cmdline_user_args().has("--simulate")
	var specs := [["up","hop_spin",5],["down","hop_spin",8],["down","cross_finish",6],["down","cross_finish",7]]
	for index in specs.size():
		var spec: Array = specs[index]
		var relative := "assets/characters/playable/king/dual_v2/"+str(spec[0])+"/"+str(spec[1])
		for version in 2:
			var prefix := OUT+"before/" if version==0 or simulate else "res://"
			var clip: Resource = load(prefix+relative+".tres")
			var full := Image.new()
			full.load_png_from_buffer(FileAccess.get_file_as_bytes(prefix+relative+"_body.png"))
			if version==1 and simulate:
				var mask := Image.new()
				mask.load_png_from_buffer(FileAccess.get_file_as_bytes(prefix+relative+"_hands.png"))
				var normalized := Registration.register(clip,full,mask,str(spec[0]),"dual","spin" if spec[1]=="hop_spin" else "attack",func(resource: Resource,_image: Image,pose: int,_view: String) -> Rect2i: return Rect2i(resource.identity_regions[pose]))
				full = normalized.body
			var key: int = spec[2]
			var image := full.get_region(Rect2i(key%4*192,key/4*128,192,128))
			var seed := Vector2i(clip.primary_hands[key].round())
			var far := Vector2i(clip.offhand.hands[key].round())
			var linked: PackedByteArray = audit.connected(image,seed)
			results.append({"view":spec[0],"clip":spec[1],"key":key,"version":version,"head":var_to_str(clip.identity_regions[key]),"near":var_to_str(seed),"far":var_to_str(far),"far_linked":linked[far.y*192+far.x]>0})
			var atlas := AtlasTexture.new()
			atlas.atlas = ImageTexture.create_from_image(image)
			atlas.region = Rect2(image.get_used_rect().grow(3))
			var sprite := Sprite2D.new()
			sprite.texture = atlas
			sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.scale = Vector2.ONE*3
			sprite.position = Vector2(260+version*470,140+index*215)
			scene.add_child(sprite)
			var label := Label.new()
			label.position = Vector2(25+version*470,15+index*215)
			label.text = ("BEFORE" if version==0 else "CURRENT")+" · "+str(spec)
			scene.add_child(label)
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"connection_comparison.png")
	FileAccess.open(OUT+"connection_comparison.json",FileAccess.WRITE).store_string(JSON.stringify(results,"\t")+"\n")
	print(JSON.stringify(results))
	scene.queue_free()
	audit.free()
	await process_frame
	quit()
