extends SceneTree

## Composes approved raster steel; does not regenerate or modify actor artwork.
const OUT := "res://assets/ui/inventory/weapons/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var sword := Image.load_from_file("res://assets/ui/inventory/king_sword_64.png")
	var axe := Image.load_from_file("res://assets/characters/playable/king/axe_proof/iron_beard.png")
	var twin := Image.load_from_file("res://assets/characters/playable/king/dual_twinsteel/twinsteel.png")
	_save_single(sword, "kings_sword")
	_save_single(axe, "iron_beard")
	var pair := Image.create(64,64,false,Image.FORMAT_RGBA8)
	_blit_transform(twin, pair, Transform2D(-0.20, Vector2(22,49)), Vector2(8,50), 0.86)
	_blit_transform(twin, pair, Transform2D(0.20, Vector2(42,49)), Vector2(8,50), 0.86)
	assert(pair.save_png(OUT+"twinsteel_pair.png")==OK)
	print("WEAPON_BAG_ICONS: three64px approved raster icons, Twinsteel visibly paired")
	quit()

func _save_single(source: Image, name_key: String) -> void:
	var icon := source.get_region(source.get_used_rect())
	var factor := 58.0 / maxi(icon.get_width(), icon.get_height())
	icon.resize(maxi(1,roundi(icon.get_width()*factor)),maxi(1,roundi(icon.get_height()*factor)),Image.INTERPOLATE_NEAREST)
	var canvas := Image.create(64,64,false,Image.FORMAT_RGBA8)
	canvas.blit_rect(icon,Rect2i(Vector2i.ZERO,icon.get_size()),(Vector2i(64,64)-icon.get_size())/2)
	assert(canvas.save_png(OUT+name_key+".png")==OK)

func _blit_transform(source: Image, destination: Image, basis: Transform2D, grip: Vector2, factor: float) -> void:
	# One fixed inverse transform keeps every blade complete with nearest pixels.
	for y in 64:
		for x in 64:
			var point := grip + basis.affine_inverse() * Vector2(x,y) / factor
			var sample := Vector2i(roundi(point.x),roundi(point.y))
			if sample.x<0 or sample.y<0 or sample.x>=source.get_width() or sample.y>=source.get_height(): continue
			var color := source.get_pixelv(sample)
			if color.a>0.0: destination.set_pixel(x,y,color)
