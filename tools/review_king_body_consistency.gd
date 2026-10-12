extends SceneTree

## Offline body-only comparison. Weapons and effects cannot hide anatomy.
const OUT := "res://art_source/review/combat/king_body_consistency_2026_10_11/"
const Identity = preload("res://tools/king_native_identity.gd")
const PLAYER = preload("res://entities/player/player.tscn")
const FAMILIES := ["iron_beard","royal_greatsword_v2","twinsteel_v2"]
const VIEWS := [Vector2.RIGHT,Vector2.UP,Vector2.DOWN]

func _initialize() -> void:
	_run.call_deferred()

func _run() -> void:
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	FileAccess.open(OUT+".gdignore",FileAccess.WRITE).store_string("")
	root.size=Vector2i(1440,1100)
	root.content_scale_size=root.size
	RenderingServer.set_default_clear_color(Color("243038"))
	var records: Array = []
	var suffix := "after" if "--after" in OS.get_cmdline_user_args() else "before"
	var helper := Identity.new()
	var baseline: Player = PLAYER.instantiate()
	root.add_child(baseline)
	baseline.set_physics_process(false)
	baseline.hide()
	for family_index in 4:
		var profile: Resource = load("res://data/weapons/families/"+FAMILIES[family_index]+"/presentation.tres") if family_index<3 else null
		for view_index in 3:
			var direction: Vector2 = VIEWS[view_index]
			var view: String = ["right","up","down"][view_index]
			var clip: Resource = profile.idle_for(direction) if profile!=null else null
			var cel: Image
			var head := Rect2i()
			if clip!=null:
				cel=clip.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
				head=Rect2i(clip.identity_regions[0]) if not clip.identity_regions.is_empty() else Rect2i(clip.identity_source_region)
			else:
				var animated: AnimatedSprite2D = baseline.get_node("VisualRoot/Body")
				cel=animated.sprite_frames.get_frame_texture(StringName("idle_"+view),0).get_image()
				if cel.get_width()!=192: push_error("Wrong baseline cell"); quit(1); return
			var id: String = FAMILIES[family_index] if profile!=null else "signature"
			var socket := helper.neck(cel)
			var measured := {"family":id,"view":view,"body":str(cel.get_used_rect()),"head":str(head),"socket":str(socket),"armor_width":helper.armor_width(cel,socket)}
			records.append(measured)
			var label := Label.new()
			label.position=Vector2(view_index*480+20,family_index*275+8)
			label.text=id+" / "+view+"\n"+str(cel.get_used_rect())+(" composite includes sword" if clip==null else " body only")
			root.add_child(label)
			var sprite := Sprite2D.new()
			sprite.position=Vector2(view_index*480+240,family_index*275+162)
			sprite.scale=Vector2.ONE*3
			sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST
			sprite.texture=ImageTexture.create_from_image(cel)
			root.add_child(sprite)
			cel.save_png(OUT+id+"_"+view+"_"+suffix+".png")
	await process_frame
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"ready_"+suffix+".png")
	FileAccess.open(OUT+suffix+".json",FileAccess.WRITE).store_string(JSON.stringify(records,"\t")+"\n")
	print(JSON.stringify(records))
	if suffix=="after": await _comparison()
	quit()

func _comparison() -> void:
	for child in root.get_children():
		if child is Sprite2D or child is Label: child.queue_free()
	await process_frame
	root.size=Vector2i(960,400); root.content_scale_size=root.size
	for index in 3:
		var path: String = OUT+["iron_beard_down_before.png","iron_beard_down_after.png","royal_greatsword_v2_down_after.png"][index]
		var cel := Image.load_from_file(path)
		var sprite := Sprite2D.new(); sprite.texture=ImageTexture.create_from_image(cel)
		sprite.position=Vector2(160+320*index,195); sprite.scale=Vector2.ONE*5
		sprite.texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST; root.add_child(sprite)
		var label := Label.new(); label.position=Vector2(320*index+22,12)
		label.text=["AXE / BEFORE","AXE / SHARED BODY","ACCEPTED GREATSWORD BODY"][index]+"\n"+str(cel.get_used_rect().size)
		root.add_child(label)
	await RenderingServer.frame_post_draw
	root.get_texture().get_image().save_png(OUT+"axe_down_before_after.png")
