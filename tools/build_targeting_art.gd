extends SceneTree

const SOURCE := "res://art_source/generated/ui/targeting_2026_10_03/"
const DEST := "res://assets/ui/targeting/"
const RETIRED := "res://art_source/archive/ornate_targeting_2026_10_03/"

func _initialize() -> void:
	var source := Image.load_from_file(ProjectSettings.globalize_path(SOURCE+"source.png"))
	assert(source != null and source.get_pixel(0,0).a == 0.0)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(DEST))
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(RETIRED))
	var cell := Vector2i(source.get_width()/2, source.get_height()/2)
	var names := ["area_ring", "range_ring", "aim_cursor", "landing_sigil"]
	var sizes := [192, 192, 24, 32]
	var records: Array = []
	for index in 4:
		var region := Rect2i(Vector2i(index%2, index/2)*cell, cell)
		var crop := source.get_region(region)
		# Remove faint generation residue before measuring the visible crop/pivot.
		for y in crop.get_height():
			for x in crop.get_width():
				var color := crop.get_pixel(x,y)
				color.a = 1.0 if color.a >= .6 else 0.0
				if color.a == 0.0: color = Color(0,0,0,0)
				crop.set_pixel(x,y,color)
		var bounds := crop.get_used_rect()
		crop = crop.get_region(bounds)
		var size: int = sizes[index]
		# Normalize circular source registration once; no animated ring scaling.
		crop.resize(size-8, size-8, Image.INTERPOLATE_NEAREST)
		var result := Image.create(size,size,false,Image.FORMAT_RGBA8)
		result.blit_rect(crop,Rect2i(Vector2i.ZERO,crop.get_size()),Vector2i(4,4))
		for y in size:
			for x in size:
				var color := result.get_pixel(x,y)
				color.a = 1.0 if color.a >= .6 else 0.0
				if color.a == 0.0: color = Color(0,0,0,0)
				result.set_pixel(x,y,color)
		var output: String = DEST if index == 2 else RETIRED
		assert(result.save_png(output+names[index]+".png") == OK)
		if index < 2:
			var bins: Array[int] = []
			bins.resize(size)
			bins.fill(0)
			for y in size:
				for x in size:
					var color := result.get_pixel(x,y)
					var delta := Vector2(x+.5,y+.5)-Vector2(size,size)*.5
					if color.a > .5 and color.r > .5 and absf(delta.x)>16 and absf(delta.y)>16:
						bins[int(delta.length())] += 1
			print(names[index], " centerline_radius=", bins.find(bins.max()))
		records.append({"name":names[index],"source_cell":[region.position.x,region.position.y,cell.x,cell.y],"used_rect":[bounds.position.x,bounds.position.y,bounds.size.x,bounds.size.y],"size":size,"pivot":[size/2,size/2]})
	var manifest := FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE)
	manifest.store_string(JSON.stringify({"source_size":[source.get_width(),source.get_height()],"alpha_threshold":.6,"archived_ring_centerline_radius":80.0,"assets":records},"\t")+"\n")
	print("TARGETING_ART: compact aim cursor; ornate rings/glyph archived")
	quit()
