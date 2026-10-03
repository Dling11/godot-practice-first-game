extends SceneTree

const SOURCE := "res://art_source/generated/vfx/enemy_arrival_runtime_preview_2026_10_03/"
const DEST := "res://assets/vfx/enemy_arrival_review/"
const CELL := 64
const SOURCE_CELL := 512
const RESIZED_CELL := 56
# Authored floor-seam origins reviewed against the full-resolution drawings.
# Brightest-pixel detection tracks moving rim light, not the floor, and drifts.
const FLOOR_ANCHORS := {
	"a": [Vector2i(275,435),Vector2i(282,438),Vector2i(286,448),Vector2i(277,427),Vector2i(282,429),Vector2i(273,430)],
	"b": [Vector2i(273,460),Vector2i(275,465),Vector2i(276,468),Vector2i(271,437),Vector2i(270,438),Vector2i(269,436)],
	"c": [Vector2i(271,468),Vector2i(275,470),Vector2i(280,469),Vector2i(270,435),Vector2i(275,435),Vector2i(269,434)]
}

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	var manifest := {"source_cell": SOURCE_CELL, "runtime_cell": CELL, "uniform_scale": float(RESIZED_CELL)/SOURCE_CELL, "alpha_threshold": .65, "floor_pivot": [32,52], "families": {}}
	for key: String in ["a", "b", "c"]:
		var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE + key + "_source.png"))
		assert(source != null and source.get_size() == Vector2i(1536,1024))
		assert(source.get_pixel(0,0).a == 0.0, "Generated source must have real alpha")
		var sheet := Image.create(CELL*6,CELL,false,Image.FORMAT_RGBA8)
		var records: Array = []
		for index in 6:
			var crop := source.get_region(Rect2i((index%3)*SOURCE_CELL,(index/3)*SOURCE_CELL,SOURCE_CELL,SOURCE_CELL))
			var anchor: Vector2i = FLOOR_ANCHORS[key][index]
			crop.resize(RESIZED_CELL,RESIZED_CELL,Image.INTERPOLATE_NEAREST)
			for y in crop.get_height():
				for x in crop.get_width():
					var color := crop.get_pixel(x,y)
					color.a = 1.0 if color.a >= .65 else 0.0
					if color.a == 0.0: color = Color(0,0,0,0)
					crop.set_pixel(x,y,color)
			var offset := Vector2i(32,52) - Vector2i((Vector2(anchor)*RESIZED_CELL/SOURCE_CELL).round())
			var frame := Image.create(CELL,CELL,false,Image.FORMAT_RGBA8)
			frame.blit_rect(crop,Rect2i(0,0,RESIZED_CELL,RESIZED_CELL),offset)
			var bounds := frame.get_used_rect()
			assert(bounds.has_area() and bounds.position.x > 0 and bounds.position.y > 0 and bounds.end.x < CELL and bounds.end.y < CELL, "Frame clips the cell")
			sheet.blit_rect(frame,Rect2i(0,0,CELL,CELL),Vector2i(index*CELL,0))
			records.append({"source_crop": [index%3*512,index/3*512,512,512], "source_anchor": [anchor.x,anchor.y], "offset": [offset.x,offset.y], "bounds": [bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y]})
			print("ARRIVAL_ART ",key," frame=",index," anchor=",anchor," bounds=",bounds)
		assert(sheet.save_png(DEST+key+".png") == OK)
		_write_frames(key)
		manifest.families[key] = records
	var file := FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE)
	file.store_string(JSON.stringify(manifest,"\t")+"\n")
	print("ARRIVAL_ART: three registered six-drawing previews; no campaign promotion")
	quit()

func _write_frames(key: String) -> void:
	# Text serialization allows import on the following editor pass.
	var text := "[gd_resource type=\"SpriteFrames\" load_steps=8 format=3]\n\n[ext_resource type=\"Texture2D\" path=\""+DEST+key+".png\" id=\"1\"]\n\n"
	for index in 6:
		text += "[sub_resource type=\"AtlasTexture\" id=\"Frame_%d\"]\natlas = ExtResource(\"1\")\nregion = Rect2(%d, 0, 64, 64)\n\n" % [index,index*64]
	text += "[resource]\nanimations = [{\n\"frames\": [{\"duration\": 1.0, \"texture\": SubResource(\"Frame_0\")}, {\"duration\": 1.0, \"texture\": SubResource(\"Frame_1\")}],\n\"loop\": false, \"name\": &\"warning\", \"speed\": 6.666667\n}, {\n\"frames\": ["
	var release: PackedStringArray = []
	for index in range(2,6): release.append("{\"duration\": 1.0, \"texture\": SubResource(\"Frame_%d\")}" % index)
	text += ", ".join(release)+"],\n\"loop\": false, \"name\": &\"release\", \"speed\": 7.142857\n}]\n"
	var file := FileAccess.open(DEST+key+"_frames.tres",FileAccess.WRITE)
	file.store_string(text)
