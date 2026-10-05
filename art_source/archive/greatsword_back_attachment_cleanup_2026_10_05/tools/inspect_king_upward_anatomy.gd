extends "res://tools/build_king_oathbound_greatsword.gd"

## Offline raw/registered/head-composited comparison, with lost alpha in red.
const OUT := "res://art_source/review/combat/king_upward_cut_2026_10_05/"

func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(OUT))
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_readability/up/idle.tres")
	var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var reference := Rect2i(idle.identity_source_region)
	var complete_scalp := hair_bounds(carry,red_center_y(carry)-2)
	var omitted := 0
	for y in range(complete_scalp.position.y,complete_scalp.end.y):
		for x in range(complete_scalp.position.x,complete_scalp.end.x):
			if carry.get_pixel(x,y).a>.99 and hair_pixel(carry.get_pixel(x,y)) and not reference.has_point(Vector2i(x,y)): omitted += 1
	print("UP_REFERENCE ",reference," SCALP ",complete_scalp," omitted scalp pixels ",omitted)
	palette.clear()
	for y in 128:
		for x in 192:
			var c := carry.get_pixel(x,y)
			if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	var rows := extract_bodies(Image.load_from_file(SOURCE+"up_body_source.png"))
	var density: float = float(carry.get_used_rect().size.y)/float(rows[0][0].image.get_height())
	var reports: Array[Dictionary] = []
	for cut in 5:
		if rows[cut].size()==11: rows[cut].remove_at(8)
		var gallery := Image.create(1920,960,false,Image.FORMAT_RGBA8)
		gallery.fill(Color("202b30"))
		for column in 5:
			var key: int = [1,3,4,5,7][column]
			var part: Image = rows[cut][key].image.duplicate()
			part.resize(roundi(part.get_width()*density),roundi(part.get_height()*density),Image.INTERPOLATE_NEAREST)
			var shift := Vector2i((foot_anchor(carry)-foot_anchor(part)).round())
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(part,Rect2i(Vector2i.ZERO,part.get_size()),shift)
			quantize(body)
			var raw := body.duplicate()
			var scalp := hair_bounds(body,red_center_y(body)-2)
			var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
			var placed := attach_head(body,carry,reference,"up",foreground)
			var difference := raw.duplicate()
			var missing := 0
			for y in 128:
				for x in 192:
					if raw.get_pixel(x,y).a>.99 and body.get_pixel(x,y).a<.5:
						missing += 1
						difference.set_pixel(x,y,Color.RED)
			for row in 3:
				var sample: Image = [raw,body,difference][row].get_region(Rect2i(48,32,96,80))
				sample.resize(384,320,Image.INTERPOLATE_NEAREST)
				gallery.blend_rect(sample,Rect2i(Vector2i.ZERO,sample.get_size()),Vector2i(column*384,row*320))
			reports.append({"cut":cut,"key":key,"scalp":var_to_str(scalp),"head":var_to_str(placed),"removed_opaque":missing})
		gallery.save_png(OUT+NAMES[cut]+"_anatomy.png")
	FileAccess.open(OUT+"anatomy_inspection.json",FileAccess.WRITE).store_string(JSON.stringify(reports,"\t")+"\n")
	quit()
