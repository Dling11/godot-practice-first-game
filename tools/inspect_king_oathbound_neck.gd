extends SceneTree

const ROOT := "res://assets/characters/playable/king/"
const OUT := "res://art_source/review/combat/king_oathbound_neck_2026_10_05/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var gallery := Image.create(1152,1152,false,Image.FORMAT_RGBA8)
	gallery.fill(Color("202b30"))
	for view in 3:
		var direction: String = ["side","up","down"][view]
		var idle: Resource = load(ROOT+("greatsword_confidence_v2/idle.tres" if direction=="side" else "greatsword_cardinal/"+direction+"/idle.tres"))
		var attack: Resource = load(ROOT+"greatsword_oathbound/"+direction+"/sweep.tres")
		for key in 4:
			var pose: int = [0,1,4,7][key]
			var atlas: Image = idle.body_atlas.get_image() if key==0 else Image.load_from_file(attack.body_atlas.resource_path)
			var image := atlas.get_region(Rect2i(0,0,192,128) if key==0 else Rect2i(pose%4*192,pose/4*128,192,128))
			var detail := image.get_region(Rect2i(68,30,64,80))
			detail.resize(256,320,Image.INTERPOLATE_NEAREST)
			gallery.blend_rect(detail,Rect2i(Vector2i.ZERO,detail.get_size()),Vector2i(key*288,view*384))
			print(direction," key ",pose," connected components: ",components(image))
	gallery.save_png(OUT+("after_necks.png" if OS.get_cmdline_user_args().has("--after") else "before_necks.png"))
	quit()

func components(image: Image) -> Array[int]:
	var seen := PackedByteArray()
	seen.resize(192*128)
	var sizes: Array[int] = []
	for y in 128:
		for x in 192:
			var seed := y*192+x
			if seen[seed] or image.get_pixel(x,y).a<.5: continue
			seen[seed] = 1
			var todo := PackedInt32Array([seed])
			var cursor := 0
			while cursor<todo.size():
				var id := todo[cursor]
				cursor += 1
				for dy in range(-1,2):
					for dx in range(-1,2):
						var point := Vector2i(id%192+dx,id/192+dy)
						if point.x<0 or point.y<0 or point.x>=192 or point.y>=128: continue
						var next := point.y*192+point.x
						if seen[next] or image.get_pixelv(point).a<.5: continue
						seen[next] = 1
						todo.append(next)
			if todo.size()>2: sizes.append(todo.size())
	sizes.sort()
	sizes.reverse()
	return sizes
