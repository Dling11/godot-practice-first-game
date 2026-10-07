extends SceneTree

const OUT := "res://art_source/generated/characters/king/greatsword_oathbound_2026_10_05/"
func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var board := Image.create(384,384,false,Image.FORMAT_RGBA8)
	for index in 3:
		var direction: String = ["side","down","up"][index]
		var path: String = "res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres" if index==0 else "res://assets/characters/playable/king/greatsword_cardinal/"+direction+"/idle.tres"
		var clip: Resource = load(path)
		var body: Image = clip.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
		body.save_png(OUT+direction+"_carry_reference.png")
		board.blit_rect(body,Rect2i(0,0,192,128),Vector2i(0,index*128))
		print(direction," carry bounds ",body.get_used_rect())
		body.resize(768,512,Image.INTERPOLATE_NEAREST)
		body.save_png(OUT+direction+"_carry_reference_large.png")
	board.resize(1536,1536,Image.INTERPOLATE_NEAREST)
	board.save_png(OUT+"installed_identity_reference.png")
	quit()
