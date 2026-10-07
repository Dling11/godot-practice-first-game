extends SceneTree
const SOURCE := "res://art_source/generated/characters/king/dual_twinsteel_2026_10_05/"
const DEST := "res://assets/characters/playable/king/dual_twinsteel/"
func _initialize() -> void:
	var image := Image.load_from_file(SOURCE+"fx_source.png")
	image.convert(Image.FORMAT_RGBA8)
	var atlas := Image.create(512,640,false,Image.FORMAT_RGBA8)
	var audit: Array[Dictionary] = []
	for row in 5:
		for frame in 4:
			var begin := Vector2i(roundi(frame*image.get_width()/4.0),roundi(row*image.get_height()/5.0))
			var end := Vector2i(roundi((frame+1)*image.get_width()/4.0),roundi((row+1)*image.get_height()/5.0))
			var cell := image.get_region(Rect2i(begin,end-begin))
			# One density for every frame in a row: sparse ignition/fade art
			# must not be enlarged to match contact bounds independently.
			var width := 104 if row==3 else 80
			cell.resize(width,roundi(width*cell.get_height()/float(cell.get_width())),Image.INTERPOLATE_NEAREST)
			var center := Vector2i(64,64) if row==3 else Vector2i(92,64)
			var placed := Vector2i(frame*128,row*128)+center-cell.get_size()/2
			atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),placed)
			audit.append({"row":row,"frame":frame,"source":var_to_str(Rect2i(begin,end-begin)),"density_width":width,"center":var_to_str(center),"used":var_to_str(cell.get_used_rect())})
	assert(atlas.save_png(DEST+"swing.png")==OK)
	FileAccess.open(SOURCE+"fx_registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("TWINSTEEL_FX_BUILD: twenty generated silver raster frames with registered transparent padding")
	quit()
