extends SceneTree

## Offline art storyboard renderer. It never equips items or issues damage.
const SOURCE := "res://art_source/generated/characters/king/greatsword_combo_concepts_2026_10_04/"
const OUT := "res://art_source/review/combat/greatsword_combo_choices_2026_10_04/"
const CHOICES := [
	{"id":"a","name":"A · CROSSCUT","style":"Grounded cuts / clean ivory trails","moves":["Downward forehand","Rising backhand","Hop cleave","Upward scoop","Opposite return"],"delays":[160,110,100,180]},
	{"id":"b","name":"B · BREAKER","style":"Heavy two-handed cuts / icy impact shards","moves":["Wide forehand","Reverse backhand","Uppercut","Jump slam","Rebound cut"],"delays":[240,150,140,220]},
	{"id":"c","name":"C · ROYAL WHIRL","style":"One-handed turns / silver-violet echoes","moves":["Diagonal forehand","Orbital turn","Rising pivot","Corkscrew cleave","Backhand return"],"delays":[150,100,90,150]}
]
var _foot_heights := PackedInt32Array()
var _face_centers := PackedVector2Array()

func _initialize() -> void:
	call_deferred("_run")

func _run() -> void:
	root.get_node("SaveService").configure_storage_path_for_testing("user://greatsword_combo_art_choices.json")
	root.get_node("SaveService").suppress_autosave_for_debug_session()
	root.content_scale_size = Vector2i(640,480)
	root.size = Vector2i(640,480)
	root.title = "Greatsword motion concepts · preview only"
	var canvas := Node2D.new()
	root.add_child(canvas)
	var background := ColorRect.new()
	background.size = Vector2(640,480)
	background.color = Color("202b30")
	canvas.add_child(background)
	var heading := _label(canvas,Vector2(28,22),26,Color("eceeea"))
	var description := _label(canvas,Vector2(28,62),14,Color("afbdc0"))
	var movement := _label(canvas,Vector2(28,400),18,Color("eceeea"))
	var footer := _label(canvas,Vector2(28,439),12,Color("839497"))
	footer.text = "MOTION CONCEPT · New raster body + slash drawings · Not gameplay"
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	sprite.position = Vector2(320,250)
	canvas.add_child(sprite)
	var audit: Array[Dictionary] = []
	for choice in CHOICES:
		var sheet := Image.load_from_file(SOURCE+choice.id+"_source.png")
		assert(sheet!=null and not sheet.is_empty(),"Missing generated source "+choice.id)
		assert(absf(float(sheet.get_width())/sheet.get_height()-0.8)<0.02,"Source is not a four-by-five square-cell sheet")
		# AI sheet spacing is approximate. Isolate whole raster components before
		# registration so a blade crossing a nominal grid line isn't cut in half.
		var extracted := _extract_frames(sheet)
		var folder: String = OUT+choice.id+"/"
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder+"motion_frames/"))
		DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder+"registered_keys/"))
		var timeline: Array[Dictionary] = []
		var elapsed := 0
		heading.text = choice.name
		description.text = choice.style
		for index in 20:
			var column := index%4
			var row := index/4
			var left := roundi(column*sheet.get_width()/4.0)
			var top := roundi(row*sheet.get_height()/5.0)
			var right := roundi((column+1)*sheet.get_width()/4.0)
			var bottom := roundi((row+1)*sheet.get_height()/5.0)
			var cell: Image = extracted[index]
			assert(cell.save_png(folder+"registered_keys/key_%03d.png" % index)==OK)
			var jump := 0
			if choice.id=="a" and index==9: jump = 32
			if choice.id=="b" and index==13: jump = 42
			if choice.id=="c" and index in [12,13]: jump = 20 if index==12 else 42
			sprite.position.y = 346-(_foot_heights[index]-cell.get_height()/2.0)-jump
			var bounds := _visible_bounds(cell)
			assert(bounds.has_area(),"Empty concept frame")
			var margin := mini(mini(bounds.position.x,bounds.position.y),mini(cell.get_width()-bounds.end.x,cell.get_height()-bounds.end.y))
			assert(margin>=8,"Whole component doesn't fit padded concept frame")
			audit.append({"choice":choice.id,"frame":index,"source_region":[left,top,right-left,bottom-top],"visible_bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"transparent_margin":margin,"registered_foot_y":_foot_heights[index],"preview_foot_y":346-jump,"jump_pixels":jump})
			sprite.texture = ImageTexture.create_from_image(cell)
			# One common presentation density; no per-pose bounds fitting.
			sprite.scale = Vector2.ONE
			movement.text = str(row+1)+" / "+choice.moves[row]+"    ·    "+["Load","Swing","Contact","Follow-through"][column]
			await process_frame
			await RenderingServer.frame_post_draw
			var filename := "motion_frames/frame_%03d.png" % index
			assert(root.get_texture().get_image().save_png(folder+filename)==OK)
			timeline.append({"file":filename,"elapsed_ms":elapsed,"move":row,"key":column})
			elapsed += int(choice.delays[column])
		FileAccess.open(folder+"motion_timeline.json",FileAccess.WRITE).store_string(JSON.stringify(timeline,"\t")+"\n")
		var gallery := Image.create(1024,960,false,Image.FORMAT_RGBA8)
		for index in 20:
			var preview := Image.load_from_file(folder+timeline[index].file)
			preview.resize(256,192,Image.INTERPOLATE_NEAREST)
			gallery.blit_rect(preview,Rect2i(0,0,256,192),Vector2i(index%4,index/4)*Vector2i(256,192))
		assert(gallery.save_png(folder+"key_gallery.png")==OK)
	FileAccess.open(OUT+"frame_audit.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("GREATSWORD_COMBO_CONCEPTS 3 choices / 60 raster keys rendered; inspect audit and animation before approval")
	quit()

func _extract_frames(sheet: Image,columns := 4,rows := 5) -> Array[Image]:
	var frames: Array[Image] = []
	var count := columns*rows
	var cell_size := Vector2i(roundi(sheet.get_width()/float(columns)),roundi(sheet.get_height()/float(rows)))
	const PADDING := 96
	for index in count:
		frames.append(Image.create(cell_size.x+PADDING*2,cell_size.y+PADDING*2,false,Image.FORMAT_RGBA8))
	sheet.convert(Image.FORMAT_RGBA8)
	var bytes := sheet.get_data()
	var width := sheet.get_width()
	var height := sheet.get_height()
	var visited := PackedByteArray()
	visited.resize(width*height)
	var bodies := PackedInt32Array()
	bodies.resize(count)
	_foot_heights.resize(count)
	_foot_heights.fill(-1)
	_face_centers.resize(count)
	_face_centers.fill(Vector2(-1,-1))
	for seed in width*height:
		if visited[seed] or bytes[seed*4+3]<=20: continue
		visited[seed] = 1
		var pixels := PackedInt32Array([seed])
		var head := 0
		var low := Vector2i(seed%width,seed/width)
		var high := low
		var votes := PackedInt32Array()
		votes.resize(count)
		while head<pixels.size():
			var current := pixels[head]
			head += 1
			var point := Vector2i(current%width,current/width)
			low = low.min(point)
			high = high.max(point)
			# A red scarf identifies the BODY's cell even when steel crosses it.
			var red: float = bytes[current*4]
			var green: float = bytes[current*4+1]
			var blue: float = bytes[current*4+2]
			if red>76 and green<red*0.35 and blue<red*0.6 and blue>green*1.1:
				var scarf_cell := clampi(int(point.y/(height/float(rows))),0,rows-1)*columns+clampi(int(point.x/(width/float(columns))),0,columns-1)
				votes[scarf_cell] += 1
			for dy in range(-1,2):
				for dx in range(-1,2):
					var next := point+Vector2i(dx,dy)
					if next.x<0 or next.y<0 or next.x>=width or next.y>=height: continue
					var id := next.y*width+next.x
					if visited[id] or bytes[id*4+3]<=20: continue
					visited[id] = 1
					pixels.append(id)
		var center := (Vector2(low)+Vector2(high))*0.5
		var frame_id := clampi(int(center.y/(height/float(rows))),0,rows-1)*columns+clampi(int(center.x/(width/float(columns))),0,columns-1)
		var maximum := 0
		for index in count:
			if votes[index]>maximum:
				maximum = votes[index]
				frame_id = index
		if maximum>20:
			bodies[frame_id] += 1
			for index in count:
				assert(index==frame_id or votes[index]<maxi(20,maximum/5),"Two bodies overlap in the generated sheet")
			# Feet, not the longest slash, define the planted floor. Preserve x and
			# authored body lean; only y is registered, with explicit jump metadata.
			var boot_rows := {}
			var face_sum := Vector2.ZERO
			var face_count := 0
			for pixel in pixels:
				var red: float = bytes[pixel*4]
				var green: float = bytes[pixel*4+1]
				var blue: float = bytes[pixel*4+2]
				if red>45 and green>20 and red>green*1.2 and green>blue*1.15:
					var y := int(pixel/width)
					boot_rows[y] = boot_rows.get(y,0)+1
				if red>190 and green>130 and blue>55 and blue<175 and red-green>15 and green-blue>20:
					face_sum += Vector2(pixel%width,int(pixel/width))
					face_count += 1
			var foot := -1
			for y in boot_rows:
				if boot_rows[y]>=4: foot = maxi(foot,y+2)
			assert(foot>=0,"Unable to register boots")
			_foot_heights[frame_id] = foot-roundi(frame_id/columns*height/float(rows))+PADDING
			if face_count>0:
				_face_centers[frame_id] = face_sum/face_count-Vector2(roundi(frame_id%columns*width/float(columns)),roundi(frame_id/columns*height/float(rows)))+Vector2(PADDING,PADDING)
		# Tiny isolated alpha specks are generation noise, not blade artwork.
		if pixels.size()<6: continue
		var origin := Vector2i(roundi(frame_id%columns*width/float(columns)),roundi(frame_id/columns*height/float(rows)))
		for pixel in pixels:
			var point := Vector2i(pixel%width,pixel/width)
			var target := point-origin+Vector2i(PADDING,PADDING)
			assert(Rect2i(Vector2i.ZERO,frames[frame_id].get_size()).has_point(target),"Component exceeds registration padding")
			frames[frame_id].set_pixelv(target,sheet.get_pixelv(point))
	for body_count in bodies: assert(body_count>=1,"Missing body after full-component extraction")
	for foot in _foot_heights: assert(foot>=0,"Missing planted-foot registration")
	return frames

func _label(parent: Node,label_position: Vector2,font_size: int,color: Color) -> Label:
	var label := Label.new()
	label.position = label_position
	label.add_theme_font_size_override("font_size",font_size)
	label.add_theme_color_override("font_color",color)
	parent.add_child(label)
	return label

func _visible_bounds(image: Image) -> Rect2i:
	var low := Vector2i(image.get_width(),image.get_height())
	var high := Vector2i(-1,-1)
	for y in image.get_height():
		for x in image.get_width():
			if image.get_pixel(x,y).a>0.08:
				low.x = mini(low.x,x)
				low.y = mini(low.y,y)
				high.x = maxi(high.x,x)
				high.y = maxi(high.y,y)
	return Rect2i(low,high-low+Vector2i.ONE) if high.x>=0 else Rect2i()
