extends "res://tools/build_king_oathbound_greatsword.gd"

## Source-relative anatomy proof: coherent torso centering and preserved pixels.
const OUT := "res://art_source/review/combat/king_upward_centering_2026_10_05/"
var checks := 0
var failures := 0

func verify(ok: bool,message: String) -> void:
	checks += 1
	if not ok:
		failures += 1
		push_error(message)

func _initialize() -> void:
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_readability/up/idle.tres")
	var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var source_reference := hair_bounds(carry,red_center_y(carry)-2)
	for y in 128:
		for x in 192:
			var c := carry.get_pixel(x,y)
			if c.a>.65 and not palette.has(Color(c.r,c.g,c.b,1)): palette.append(Color(c.r,c.g,c.b,1))
	var rows := extract_bodies(Image.load_from_file(SOURCE+"up_body_source.png"))
	var density := float(carry.get_used_rect().size.y)/float(rows[0][0].image.get_height())
	var reports: Array[Dictionary] = []
	for cut in 5:
		if rows[cut].size()==11: rows[cut].remove_at(8)
		var clip: Resource = load(DEST+"up/"+NAMES[cut]+".tres")
		var atlas: Image = clip.body_atlas.get_image()
		var gallery := Image.create(1600,960,false,Image.FORMAT_RGBA8)
		gallery.fill(Color("202b30"))
		for key in 13:
			if key==9 or key==0 or (key==12 and cut==4): continue
			var source_key := key if key<10 else key-3
			var raw: Image = rows[cut][source_key].image.duplicate()
			raw.resize(roundi(raw.get_width()*density),roundi(raw.get_height()*density),Image.INTERPOLATE_NEAREST)
			var shift := Vector2i((foot_anchor(carry)-foot_anchor(raw)).round())
			var registered := Image.create(192,128,false,Image.FORMAT_RGBA8)
			registered.blit_rect(raw,Rect2i(Vector2i.ZERO,raw.get_size()),shift)
			quantize(registered)
			var scalp := hair_bounds(registered,red_center_y(registered)-2)
			var actual := atlas.get_region(Rect2i(key%4*192,key/4*128,192,128))
			var target := Rect2i(clip.identity_regions[key])
			var old_distance := absf(scalp.get_center().x-source_reference.get_center().x)
			var new_distance := absf(target.get_center().x-source_reference.get_center().x)
			var shift_x := roundi(target.get_center().x-scalp.get_center().x)
			verify(abs(shift_x)<=4 and new_distance<=old_distance and (old_distance<=1 or new_distance<old_distance),"Back torso centering enlarges lean or moves too far: %d/%d"%[cut,key])
			verify(target.end.y==scalp.end.y,"Back head floats above/below its original neck: %d/%d"%[cut,key])
			var changed_collar := 0
			var collar_pixels := 0
			var neck_line := scalp.end.y+2
			var boot_line := roundi(foot_anchor(registered).y)-3
			for y in range(scalp.end.y,128):
				var row_shift := shift_x if y<=neck_line else (0 if y>=boot_line else roundi(shift_x*float(boot_line-y)/float(boot_line-neck_line)))
				for x in 192:
					var original := registered.get_pixel(x,y)
					if original.a<.99: continue
					collar_pixels += 1
					if original.to_rgba32()!=actual.get_pixel(x+row_shift,y).to_rgba32(): changed_collar += 1
			verify(collar_pixels>100 and changed_collar==0,"Torso centering repaints or separates collar/torso: %d/%d (%d)"%[cut,key,changed_collar])
			verify(Rect2i(clip.identity_source_region)==source_reference,"Head provenance still includes old carry shoulders")
			reports.append({"cut":cut,"key":key,"source_scalp":var_to_str(scalp),"placed_head":var_to_str(target),"center_shift":shift_x,"old_lean":old_distance,"new_lean":new_distance,"preserved_torso_pixels":collar_pixels,"changed_torso_pixels":changed_collar})
			if key in [1,3,4,5,7]:
				var previous := registered.duplicate()
				var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
				attach_back_head(previous,carry,source_reference,foreground)
				var column: int = [1,3,4,5,7].find(key)
				for row in 3:
					var sample: Image = [registered,previous,actual][row].get_region(Rect2i(56,24,80,80))
					sample.resize(320,320,Image.INTERPOLATE_NEAREST)
					gallery.blend_rect(sample,Rect2i(0,0,320,320),Vector2i(column*320,row*320))
		gallery.save_png(OUT+NAMES[cut]+"_body_comparison.png")
	FileAccess.open(OUT+"anatomy_validation.json",FileAccess.WRITE).store_string(JSON.stringify({"checks":checks,"failures":failures,"poses":reports},"\t")+"\n")
	print("BACK_ATTACHMENT checks=",checks," failures=",failures)
	quit(1 if failures else 0)
