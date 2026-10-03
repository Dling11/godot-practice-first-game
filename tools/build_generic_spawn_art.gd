extends SceneTree

const SOURCE := "res://art_source/generated/vfx/generic_spawn_2026_10_03/"
const DEST := "res://assets/vfx/generic_enemy_arrival/"
const ANCHORS := [Vector2i(333,520),Vector2i(312,522),Vector2i(316,435),Vector2i(310,432)]

func _initialize() -> void:
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE+"source.png"))
	assert(source != null and source.get_width() == source.get_height() and source.get_width()%2 == 0)
	var source_cell := source.get_width()/2
	assert(source.get_pixel(0,0).a == 0.0, "Source must have genuine alpha")
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var sheet := Image.create(256,64,false,Image.FORMAT_RGBA8)
	var records: Array = []
	for index in 4:
		var origin := Vector2i(index%2*source_cell,index/2*source_cell)
		var crop := source.get_region(Rect2i(origin,Vector2i(source_cell,source_cell)))
		crop.resize(48,48,Image.INTERPOLATE_NEAREST)
		for y in 48:
			for x in 48:
				var color := crop.get_pixel(x,y)
				color.a = 1.0 if color.a >= .65 else 0.0
				if color.a == 0.0: color = Color(0,0,0,0)
				crop.set_pixel(x,y,color)
		var offset := Vector2i(32,46)-Vector2i((Vector2(ANCHORS[index])*48.0/640.0).round())
		var frame := Image.create(64,64,false,Image.FORMAT_RGBA8)
		frame.blit_rect(crop,Rect2i(0,0,48,48),offset)
		var bounds := frame.get_used_rect()
		assert(bounds.has_area() and bounds.position.x > 0 and bounds.position.y > 0 and bounds.end.x < 64 and bounds.end.y < 64)
		assert(bounds.size.y <= 24, "Generic cue must stay near the ground")
		sheet.blit_rect(frame,Rect2i(0,0,64,64),Vector2i(index*64,0))
		var source_anchor := Vector2i((Vector2(ANCHORS[index])*source_cell/640.0).round())
		records.append({"crop": [origin.x,origin.y,source_cell,source_cell],"anchor": [source_anchor.x,source_anchor.y],"offset": [offset.x,offset.y],"bounds": [bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]})
		print("GENERIC_SPAWN frame=",index," bounds=",bounds)
	assert(sheet.save_png(DEST+"ground.png") == OK)
	var manifest := FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"source_size":[source.get_width(),source.get_height()],"uniform_scale":48.0/source_cell,"floor_pivot":[32,46],"alpha_threshold":.65,"drawings":records},"\t")+"\n")
	var text := "[gd_resource type=\"SpriteFrames\" load_steps=6 format=3]\n\n[ext_resource type=\"Texture2D\" path=\""+DEST+"ground.png\" id=\"1\"]\n\n"
	for index in 4:
		text += "[sub_resource type=\"AtlasTexture\" id=\"Frame_%d\"]\natlas = ExtResource(\"1\")\nregion = Rect2(%d, 0, 64, 64)\n\n" % [index,index*64]
	text += "[resource]\nanimations = [{\n\"frames\": [{\"duration\": 1.0, \"texture\": SubResource(\"Frame_0\")}],\n\"loop\": false, \"name\": &\"warning\", \"speed\": 3.333333\n}, {\n\"frames\": ["
	var release: PackedStringArray = []
	for index in range(1,4): release.append("{\"duration\": 1.0, \"texture\": SubResource(\"Frame_%d\")}" % index)
	text += ", ".join(release)+"],\n\"loop\": false, \"name\": &\"release\", \"speed\": 5.357143\n}]\n"
	var frames_file := FileAccess.open(DEST+"frames.tres",FileAccess.WRITE)
	frames_file.store_string(text)
	print("GENERIC_SPAWN: one four-drawing atlas shared by every enemy size")
	quit()
