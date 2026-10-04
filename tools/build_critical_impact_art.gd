extends SceneTree

const SOURCE := "res://art_source/generated/vfx/critical_impact_2026_10_04/"
const DEST := "res://assets/vfx/combat/critical_impact/"
const SCALE := .075
const CELL := 48

func _initialize() -> void:
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE+"source.png"))
	assert(source != null and source.get_width()%4 == 0 and source.get_pixel(0,0).a == 0.0)
	var source_cell := Vector2i(source.get_width()/4,source.get_height())
	var anchors: Array[Vector2i] = []
	for index in 3:
		var crop := source.get_region(Rect2i(Vector2i(index*source_cell.x,0),source_cell))
		var sum := Vector2.ZERO
		var count := 0
		for y in range(source_cell.y/3,source_cell.y*2/3):
			for x in range(source_cell.x/4,source_cell.x*3/4):
				var color := crop.get_pixel(x,y)
				if color.a>.7 and color.r>.9 and color.g>.8 and color.b>.6:
					sum += Vector2(x,y)
					count += 1
		assert(count > 0)
		anchors.append(Vector2i((sum/count).round()))
	anchors.append(anchors[2]) # Residue keeps the third drawing's impact registration.
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var sheet := Image.create(CELL*4,CELL,false,Image.FORMAT_RGBA8)
	var records: Array = []
	for index in 4:
		var crop := source.get_region(Rect2i(Vector2i(index*source_cell.x,0),source_cell))
		crop.resize(roundi(source_cell.x*SCALE),roundi(source_cell.y*SCALE),Image.INTERPOLATE_NEAREST)
		for y in crop.get_height():
			for x in crop.get_width():
				var color := crop.get_pixel(x,y)
				color.a = 1.0 if color.a>=.65 else 0.0
				if color.a == 0.0: color = Color(0,0,0,0)
				crop.set_pixel(x,y,color)
		var offset := Vector2i(CELL/2,CELL/2)-Vector2i((Vector2(anchors[index])*SCALE).round())
		var frame := Image.create(CELL,CELL,false,Image.FORMAT_RGBA8)
		frame.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),offset)
		var bounds := frame.get_used_rect()
		assert(bounds.has_area() and bounds.position.x>0 and bounds.position.y>0 and bounds.end.x<CELL and bounds.end.y<CELL, "Critical effect clipping")
		sheet.blit_rect(frame,Rect2i(0,0,CELL,CELL),Vector2i(index*CELL,0))
		records.append({"source_crop":[index*source_cell.x,0,source_cell.x,source_cell.y],"anchor":[anchors[index].x,anchors[index].y],"offset":[offset.x,offset.y],"bounds":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]})
		print("CRITICAL_FRAME index=",index," anchor=",anchors[index]," bounds=",bounds)
	assert(sheet.save_png(DEST+"impact.png") == OK)
	var frames := "[gd_resource type=\"SpriteFrames\" load_steps=6 format=3]\n\n[ext_resource type=\"Texture2D\" path=\""+DEST+"impact.png\" id=\"1\"]\n\n"
	for index in 4:
		frames += "[sub_resource type=\"AtlasTexture\" id=\"Frame_%d\"]\natlas = ExtResource(\"1\")\nregion = Rect2(%d, 0, 48, 48)\n\n" % [index,index*CELL]
	var drawings := PackedStringArray()
	for index in 4: drawings.append("{\"duration\": 1.0, \"texture\": SubResource(\"Frame_%d\")}" % index)
	frames += "[resource]\nanimations = [{\"frames\": ["+", ".join(drawings)+"], \"loop\": false, \"name\": &\"critical\", \"speed\": 25.0}]\n"
	FileAccess.open(DEST+"frames.tres",FileAccess.WRITE).store_string(frames)
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify({"source_size":[source.get_width(),source.get_height()],"uniform_scale":SCALE,"alpha_threshold":.65,"cell_size":CELL,"contact_origin":[24,24],"registration":"offline bright-core centroid for contact drawings; last residue shares preceding registration", "frames":records},"\t")+"\n")
	quit()
