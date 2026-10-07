extends SceneTree
const SOURCE := "res://art_source/generated/characters/king/dual_polish_2026_10_05/"
const DEST := "res://assets/characters/playable/king/dual_twinsteel/"
const THRUST_HEIGHT := 16
const THRUST_CENTER := Vector2i(112,102)
func _initialize() -> void:
	var image := Image.load_from_file(ProjectSettings.globalize_path(SOURCE+"fx_clean_source.png"))
	image.convert(Image.FORMAT_RGBA8)
	var atlas := Image.create(768,960,false,Image.FORMAT_RGBA8)
	var audit: Array[Dictionary] = []
	for row in 5:
		for frame in 4:
			var begin := Vector2i(roundi(frame*image.get_width()/4.0),roundi(row*image.get_height()/5.0))
			var end := Vector2i(roundi((frame+1)*image.get_width()/4.0),roundi((row+1)*image.get_height()/5.0))
			var cell := image.get_region(Rect2i(begin,end-begin))
			# One registration per row retains ignition/contact/fade proportion.
			var width := 192 if row==3 else 160
			var height := THRUST_HEIGHT if row==0 else roundi(width*cell.get_height()/float(cell.get_width()))
			cell.resize(width,height,Image.INTERPOLATE_NEAREST)
			# The first cut is a narrow paired thrust. Its old broad curve was
			# almost entirely outside the actual contact lane. Compact the
			# same four raster cels into a forward wave before runtime clipping.
			# This band is shared by horizontal and rotated vertical samples.
			var center := THRUST_CENTER if row==0 else (Vector2i(96,96) if row==3 else Vector2i(112,96))
			var placed := Vector2i(frame*192,row*192)+center-cell.get_size()/2
			atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),placed)
			audit.append({"row":row,"frame":frame,"source":var_to_str(Rect2i(begin,end-begin)),"density_width":width,"density_height":height,"center":var_to_str(center),"used":var_to_str(cell.get_used_rect())})
	assert(atlas.save_png(DEST+"swing.png")==OK)
	FileAccess.open(SOURCE+"fx_registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("DUAL_POLISH_FX: 20 generated silver frames / 192px cells / authority-clipped reach")
	quit()
