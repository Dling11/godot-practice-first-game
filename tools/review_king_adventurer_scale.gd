extends SceneTree

## Import-only scale study. It does not install or replace runtime character art.
const OUT := "res://art_source/review/characters/king/adventurer_2026_09_12/"

func _initialize() -> void:
	var source := Image.load_from_file("res://art_source/generated/characters/king/adventurer_2026_09_12/king_adventurer_study.png")
	source.convert(Image.FORMAT_RGBA8)
	for y in source.get_height():
		for x in source.get_width():
			var color := source.get_pixel(x,y)
			if color.r > 0.30 and color.b > 0.30 and color.r > color.g * 1.6 and color.b > color.g * 1.6:
				source.set_pixel(x,y,Color.TRANSPARENT)
	var cells: Array[Image] = []
	var reference_height := 0
	for index in 4:
		var x0 := roundi(index * source.get_width() / 4.0)
		var x1 := roundi((index+1) * source.get_width() / 4.0)
		var region := source.get_region(Rect2i(x0,0,x1-x0,source.get_height()))
		var bounds := region.get_used_rect()
		reference_height = maxi(reference_height,bounds.size.y)
		cells.append(region.get_region(bounds))
	var scale_factor := 27.0 / reference_height
	var atlas := Image.create(48*4,32,false,Image.FORMAT_RGBA8)
	for index in 4:
		var cell := cells[index]
		var upper_body := cell.get_region(Rect2i(0,0,cell.get_width(),roundi(cell.get_height()*0.62))).get_used_rect()
		var body_center := (upper_body.position.x + upper_body.size.x * 0.5) * scale_factor
		cell.resize(roundi(cell.get_width()*scale_factor),roundi(cell.get_height()*scale_factor),Image.INTERPOLATE_NEAREST)
		atlas.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),Vector2i(index*48+24-roundi(body_center),30-cell.get_height()))
	atlas.save_png(OUT+"candidate_48x32.png")
	var old := (load("res://assets/characters/playable/king/simple_reboot/king_simple_locomotion_sheet_48x32.png") as Texture2D).get_image()
	old.convert(Image.FORMAT_RGBA8)
	var comparison := Image.create(48*4,32*2,false,Image.FORMAT_RGBA8)
	comparison.fill(Color("263139"))
	for index in 4:
		comparison.blend_rect(old,Rect2i(0,[0,2,1,3][index]*32,48,32),Vector2i(index*48,0))
	comparison.blend_rect(atlas,Rect2i(0,0,48*4,32),Vector2i(0,32))
	comparison.resize(48*4*4,32*2*4,Image.INTERPOLATE_NEAREST)
	comparison.save_png(OUT+"current_top_candidate_bottom_4x.png")
	print("King preview only: 48x32 cells, 27px body height, y=30 foot baseline. Runtime untouched.")
	quit()
