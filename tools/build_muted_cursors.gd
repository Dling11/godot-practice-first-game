extends SceneTree

const SOURCE := "res://art_source/generated/ui/muted_cursors_2026_10_03/"
const DEST := "res://assets/ui/targeting/"

func _initialize() -> void:
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE+"source.png"))
	assert(source != null and source.get_width() == source.get_height()*3)
	var cell := source.get_height()
	var names := ["pointer", "interact", "selected"]
	var records: Array = []
	for index in 3:
		var crop := source.get_region(Rect2i(index*cell,0,cell,cell))
		for y in cell:
			for x in cell:
				var color := crop.get_pixel(x,y)
				color.a = 1.0 if color.a >= .6 else 0.0
				if color.a == 0.0: color = Color(0,0,0,0)
				crop.set_pixel(x,y,color)
		var bounds := crop.get_used_rect()
		crop = crop.get_region(bounds)
		var factor := 20.0/maxf(bounds.size.x,bounds.size.y)
		crop.resize(maxi(1,roundi(bounds.size.x*factor)),maxi(1,roundi(bounds.size.y*factor)),Image.INTERPOLATE_NEAREST)
		var image := Image.create(24,24,false,Image.FORMAT_RGBA8)
		image.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),Vector2i(2,2))
		assert(image.save_png(DEST+names[index]+".png") == OK)
		records.append({"name":names[index],"source_cell":[index*cell,0,cell,cell],"used_rect":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"scale":factor,"size":24,"hotspot":[7,6] if index == 1 else [2,2]})
	var manifest := FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"source_size":[source.get_width(),source.get_height()],"alpha_threshold":.6,"assets":records},"\t")+"\n")
	print("MUTED_CURSORS: three silver/slate/violet hardware cursors")
	quit()
