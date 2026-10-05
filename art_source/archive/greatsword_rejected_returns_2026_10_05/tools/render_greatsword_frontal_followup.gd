extends "res://tools/render_greatsword_combo_concepts.gd"

## Targeted A revision; offline raster review, never gameplay authority.
const FRONT_SOURCE := "res://art_source/generated/characters/king/greatsword_a_frontal_followup_2026_10_04/"
const FRONT_OUT := "res://art_source/review/combat/greatsword_a_frontal_followup_2026_10_04/"

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://greatsword_frontal_art_review.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.content_scale_size = Vector2i(640,480)
	root.size = Vector2i(640,480)
	root.title = "A frontal follow-up · art review"
	var old := _extract_frames(Image.load_from_file(SOURCE+"a_source.png"))
	var old_feet := _foot_heights.duplicate()
	var old_faces := _face_centers.duplicate()
	var fresh := _extract_frames(Image.load_from_file(FRONT_SOURCE+"fifth_source.png"),3,3)
	var density := float(old_feet[15]-old_faces[15].y)/float(_foot_heights[0]-_face_centers[0].y)
	assert(density>0.35 and density<2.5,"Unexpected source body density")
	var face_x := 320+old_faces[15].x-old[15].get_width()/2.0
	assert(old[15].get_data()==Image.load_from_file(OUT+"a/registered_keys/key_015.png").get_data(),"Fourth endpoint changed")
	var keys: Array[Image] = []
	var placements: Array[Vector2] = []
	var scales: Array[float] = []
	var durations: Array[int] = []
	for index in 16:
		keys.append(old[index])
		placements.append(Vector2(320,346-(old_feet[index]-old[index].get_height()/2.0)-(32 if index==9 else 0)))
		scales.append(1.0)
		durations.append([160,110,100,180][index%4] if index!=15 else 70)
	# Exact old endpoint supplies entry. Generation key0 calibrates density only.
	keys.append(old[15])
	placements.append(placements[15])
	scales.append(1.0)
	durations.append(50)
	for index in range(1,9):
		assert(_face_centers[index].x>=0,"Missing front-facing skin anchor")
		keys.append(fresh[index])
		placements.append(Vector2(face_x-(_face_centers[index].x-fresh[index].get_width()/2.0)*density,346-(_foot_heights[index]-fresh[index].get_height()/2.0)*density))
		scales.append(density)
		durations.append(90)
	assert(keys[15].get_data()==keys[16].get_data() and placements[15]==placements[16] and scales[15]==scales[16],"Discontinuous 4→5 entry")
	var canvas := Node2D.new()
	root.add_child(canvas)
	var background := ColorRect.new()
	background.size = Vector2(640,480)
	background.color = Color("202b30")
	canvas.add_child(background)
	_label(canvas,Vector2(28,22),26,Color("eceeea")).text = "A · FRONTAL FOLLOW-UP"
	_label(canvas,Vector2(28,62),14,Color("afbdc0")).text = "Fourth ends front-up → fifth cuts down in front"
	var movement := _label(canvas,Vector2(28,400),18,Color("eceeea"))
	_label(canvas,Vector2(28,439),12,Color("839497")).text = "MOTION CONCEPT · A's first four retained · Not gameplay"
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	canvas.add_child(sprite)
	var audit: Array[Dictionary] = []
	for mode in ["full","pair"]:
		var folder: String = FRONT_OUT+mode+"/"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder+"motion_frames/"))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder+"registered_keys/"))
		var timeline: Array[Dictionary] = []
		var elapsed := 0
		var first := 0 if mode=="full" else 12
		for index in range(first,keys.size()):
			var image: Image = keys[index]
			var bounds := _visible_bounds(image)
			var screen_bounds := Rect2(placements[index]+(Vector2(bounds.position)-Vector2(image.get_size())/2.0)*scales[index],Vector2(bounds.size)*scales[index])
			assert(screen_bounds.position.x>8 and screen_bounds.end.x<632 and screen_bounds.position.y>95 and screen_bounds.end.y<390,"Preview crop or text overlap")
			sprite.position = placements[index]
			sprite.scale = Vector2.ONE*scales[index]
			sprite.texture = ImageTexture.create_from_image(image)
			movement.text = str(index/4+1)+" / "+CHOICES[0].moves[index/4]+" · "+["Load","Swing","Contact","Finish"][index%4] if index<16 else "5 / Frontal follow-up · "+str(index-15)+" of 9"
			await process_frame
			await RenderingServer.frame_post_draw
			var frame := timeline.size()
			var filename := "motion_frames/frame_%03d.png" % frame
			assert(root.get_texture().get_image().save_png(folder+filename)==OK)
			assert(image.save_png(folder+"registered_keys/key_%03d.png" % frame)==OK)
			timeline.append({"file":filename,"elapsed_ms":elapsed,"source_key":index})
			elapsed += durations[index]
			audit.append({"mode":mode,"key":index,"density":scales[index],"position":[placements[index].x,placements[index].y],"screen_bounds":[screen_bounds.position.x,screen_bounds.position.y,screen_bounds.size.x,screen_bounds.size.y]})
		FileAccess.open(folder+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
		var gallery := Image.create(1280,ceili(timeline.size()/4.0)*240,false,Image.FORMAT_RGBA8)
		for index in timeline.size():
			var preview := Image.load_from_file(folder+timeline[index].file)
			preview.resize(320,240,Image.INTERPOLATE_NEAREST)
			gallery.blit_rect(preview,Rect2i(0,0,320,240),Vector2i(index%4,index/4)*Vector2i(320,240))
		assert(gallery.save_png(folder+"key_gallery.png")==OK)
	FileAccess.open(FRONT_OUT+"frame_audit.json",FileAccess.WRITE).store_string(JSON.stringify({"endpoint_identical":true,"common_new_density":density,"front_face_x":face_x,"frames":audit},"\t")+"\n")
	print("GREATSWORD_FRONTAL_FOLLOWUP 25 full / 13 pair keys; exact 4→5 entry and viewport bounds passed")
	quit()
