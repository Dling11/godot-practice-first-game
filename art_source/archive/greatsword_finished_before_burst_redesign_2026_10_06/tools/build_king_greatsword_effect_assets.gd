extends SceneTree
const SOURCE := "res://art_source/generated/characters/king/greatsword_2026_09_12/"
const OUT := "res://assets/vfx/abilities/king/greatsword/"
# Authored ground contact points in the original 1774x887 sheet. Debris bounds
# expand and rise, so neither cell centers nor per-frame bounding boxes anchor
# the crater. These points always map to native (96,96).
const IMPACT_ORIGINS := [Vector2i(236,384),Vector2i(672,384),Vector2i(1104,384),Vector2i(1548,384),Vector2i(232,744),Vector2i(668,744),Vector2i(1096,744),Vector2i(1540,744)]

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var trail := _matte("trail_clean",false)
	var atlas := Image.create(384,192,false,Image.FORMAT_RGBA8)
	for row in 2:
		for col in 4:
			var x0 := roundi(col*trail.get_width()/4.0)
			var x1 := roundi((col+1)*trail.get_width()/4.0)
			var y0 := roundi(row*trail.get_height()/2.0)
			var y1 := roundi((row+1)*trail.get_height()/2.0)
			var cell := trail.get_region(Rect2i(x0,y0,x1-x0,y1-y0))
			# Fixed source-cell mapping retains build-up and dissolution scale.
			cell.resize(96,96,Image.INTERPOLATE_NEAREST)
			atlas.blit_rect(cell,Rect2i(0,0,96,96),Vector2i(col*96,row*96))
	atlas.save_png(OUT+"white_slash_96x96.png")
	var impact := _matte("impact",true)
	var impacts := Image.create(768,384,false,Image.FORMAT_RGBA8)
	for row in 2:
		for col in 4:
			var x0 := roundi(col*impact.get_width()/4.0)
			var x1 := roundi((col+1)*impact.get_width()/4.0)
			var y0 := roundi(row*impact.get_height()/2.0)
			var y1 := roundi((row+1)*impact.get_height()/2.0)
			var cell := impact.get_region(Rect2i(x0,y0,x1-x0,y1-y0))
			cell.resize(roundi(cell.get_width()*.36),roundi(cell.get_height()*.36),Image.INTERPOLATE_NEAREST)
			var origin: Vector2i = IMPACT_ORIGINS[row*4+col]
			var dest := Vector2i(col*192+96-roundi((origin.x-x0)*.36),row*192+96-roundi((origin.y-y0)*.36))
			impacts.blit_rect(cell,Rect2i(Vector2i.ZERO,cell.get_size()),dest)
	impacts.save_png(OUT+"steel_impact_192x192.png")
	var portrait := _matte("portrait_clean",false)
	portrait.resize(96,96,Image.INTERPOLATE_NEAREST)
	portrait.save_png("res://assets/characters/playable/king/greatsword/king_greatsword_portrait_96x96.png")
	var icons := Image.load_from_file(SOURCE+"skill_icons.png")
	icons.convert(Image.FORMAT_RGBA8)
	var icon_atlas := Image.create(96,24,false,Image.FORMAT_RGBA8)
	for index in 4:
		var size := icons.get_width()/2
		var icon := icons.get_region(Rect2i((index%2)*size,(index/2)*size,size,size))
		icon.resize(24,24,Image.INTERPOLATE_NEAREST)
		icon_atlas.blit_rect(icon,Rect2i(0,0,24,24),Vector2i(index*24,0))
	icon_atlas.save_png("res://assets/ui/icons/combat/king_greatsword_skills_24.png")
	print("KING_EFFECTS_AND_PORTRAIT_BUILT")
	quit()

func _matte(key: String, black: bool) -> Image:
	var image := Image.load_from_file(SOURCE+key+".png")
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			var background := maxf(c.r,maxf(c.g,c.b)) < .08 if black else c.r>.3 and c.b>.3 and c.r>c.g*1.6 and c.b>c.g*1.6
			if background:
				image.set_pixel(x,y,Color.TRANSPARENT)
	return image
