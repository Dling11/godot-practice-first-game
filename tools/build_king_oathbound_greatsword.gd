extends SceneTree

## Offline full-body ingestion. Identity pixels are the installed carry's pixels.
const Definition = preload("res://data/weapons/weapon_family_pose_definition.gd")
const STEEL = preload("res://assets/characters/playable/king/huge_greatsword_proof/greatsword.png")
const SOURCE := "res://art_source/generated/characters/king/greatsword_oathbound_2026_10_05/"
const DEST := "res://assets/characters/playable/king/greatsword_oathbound/"
const NAMES := ["sweep","rise","slam","turn","return"]
const BACK_LEAN_REDUCTION := 0.5
const BACK_CENTER_LIMIT := 4 # Logical texels; two pixels at normal world scale.
const HEADINGS := [
	[-153.435,-165,-145,-110,-60,-5,45,70,100,130],
	[130,130,105,60,25,-20,-65,-100,-125,-150],
	[-150,-110,-90,-70,35,50,65,80,65,45],
	[45,45,80,110,75,20,-45,-65,-80,-95],
	[-95,-80,-50,-10,15,40,70,110,155,206.565]
]
const SIDE_GUIDES := [
	[Vector2(.23,.27),Vector2(.65,.65),Vector2(.2,.27),Vector2(.87,.42),Vector2(.87,.40),Vector2(.9,.53),Vector2(.8,.78),Vector2(.55,.66),Vector2(.71,.75),Vector2(.65,.72)],
	[Vector2(.66,.71),Vector2(.68,.77),Vector2(.65,.77),Vector2(.64,.64),Vector2(.74,.60),Vector2(.84,.59),Vector2(.91,.53),Vector2(.88,.45),Vector2(.24,.22),Vector2(.26,.15)],
	[Vector2(.22,.14),Vector2(.66,.70),Vector2(.24,.22),Vector2(.25,.12),Vector2(.87,.61),Vector2(.84,.82),Vector2(.74,.77),Vector2(.26,.57),Vector2(.90,.59),Vector2(.89,.62)],
	[Vector2(.87,.59),Vector2(.55,.67),Vector2(.85,.55),Vector2(.24,.52),Vector2(.89,.42),Vector2(.86,.39),Vector2(.85,.26),Vector2(.87,.15),Vector2(.85,.55),Vector2(.85,.13)],
	[Vector2(.23,.25),Vector2(.86,.49),Vector2(.88,.52),Vector2(.88,.57),Vector2(.91,.50),Vector2(.86,.57),Vector2(.83,.70),Vector2(.85,.58),Vector2(.27,.49),Vector2(.27,.29)]
]
const DOWN_GUIDES := [
	[Vector2(.83,.62),Vector2(.15,.4),Vector2(.55,.7),Vector2(.75,.65),Vector2(.55,.7),Vector2(.5,.8),Vector2(.22,.66),Vector2(.82,.7),Vector2(.16,.38),Vector2(.5,.75)],
	[Vector2(.5,.68),Vector2(.4,.68),Vector2(.7,.48),Vector2(.67,.7),Vector2(.55,.78),Vector2(.53,.65),Vector2(.14,.57),Vector2(.8,.35),Vector2(.5,.1),Vector2(.5,.1)],
	[Vector2(.5,.1),Vector2(.5,.7),Vector2(.5,.1),Vector2(.5,.65),Vector2(.5,.8),Vector2(.5,.8),Vector2(.5,.8),Vector2(.7,.6),Vector2(.5,.8),Vector2(.5,.75)],
	[Vector2(.5,.74),Vector2(.12,.28),Vector2(.13,.4),Vector2(.13,.4),Vector2(.2,.6),Vector2(.5,.8),Vector2(.84,.74),Vector2(.16,.45),Vector2(.7,.7),Vector2(.88,.26)],
	[Vector2(.85,.37),Vector2(.12,.42),Vector2(.8,.7),Vector2(.5,.7),Vector2(.5,.8),Vector2(.5,.8),Vector2(.8,.8),Vector2(.5,.8),Vector2(.15,.76),Vector2(.86,.56)]
]
var audit: Array[Dictionary] = []
var color_cache: Dictionary = {}
var palette: Array[Color] = []
var failed := false

func _initialize() -> void:
	for direction in ["side","up","down"]:
		if not FileAccess.file_exists(SOURCE+direction+"_body_source.png"):
			push_error("Required Oathbound source is missing: "+direction)
			quit(1)
			return
		build_direction(direction)
		if failed:
			quit(1)
			return
	FileAccess.open(SOURCE+"registration.json",FileAccess.WRITE).store_string(JSON.stringify(audit,"\t")+"\n")
	print("OATHBOUND_BUILD complete identity-registered body clips")
	quit()

func extract_bodies(sheet: Image,row_count := 5) -> Array[Array]:
	sheet.convert(Image.FORMAT_RGBA8)
	var bytes := sheet.get_data()
	var width := sheet.get_width()
	var height := sheet.get_height()
	var visited := PackedByteArray()
	visited.resize(width*height)
	var rows: Array[Array] = []
	for row in row_count: rows.append([])
	for seed in width*height:
		if visited[seed] or bytes[seed*4+3]<40: continue
		visited[seed] = 1
		var pixels := PackedInt32Array([seed])
		var cursor := 0
		var low := Vector2i(seed%width,seed/width)
		var high := low
		var red_sum := Vector2.ZERO
		var reds := 0
		while cursor<pixels.size():
			var id := pixels[cursor]
			cursor += 1
			var point := Vector2i(id%width,id/width)
			low = low.min(point)
			high = high.max(point)
			if bytes[id*4]>80 and bytes[id*4]>bytes[id*4+1]*2.0 and bytes[id*4]>bytes[id*4+2]*1.5:
				red_sum += Vector2(point)
				reds += 1
			for dy in range(-1,2):
				for dx in range(-1,2):
					var next := point+Vector2i(dx,dy)
					if next.x<0 or next.y<0 or next.x>=width or next.y>=height: continue
					var nid := next.y*width+next.x
					if visited[nid] or bytes[nid*4+3]<40: continue
					visited[nid] = 1
					pixels.append(nid)
		if reds<24 or pixels.size()<200: continue
		var row := clampi(int((red_sum.y/reds)/height*row_count),0,row_count-1)
		var image := Image.create(high.x-low.x+1,high.y-low.y+1,false,Image.FORMAT_RGBA8)
		for id in pixels: image.set_pixelv(Vector2i(id%width,id/width)-low,sheet.get_pixel(id%width,id/width))
		rows[row].append({"image":image,"bounds":Rect2i(low,image.get_size()),"x":red_sum.x/reds})
	for row in rows: row.sort_custom(func(a: Dictionary,b: Dictionary) -> bool: return a.x<b.x)
	return rows

func build_direction(direction: String) -> void:
	var sheet := Image.load_from_file(SOURCE+direction+"_body_source.png")
	var rows := extract_bodies(sheet)
	if rows[0].is_empty():
		push_error("No complete Oathbound source bodies: "+direction)
		failed = true
		return
	var folder := DEST+direction+"/"
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(folder))
	var idle: Resource = load("res://assets/characters/playable/king/greatsword_confidence_v2/idle.tres" if direction=="side" else "res://assets/characters/playable/king/greatsword_readability/"+direction+"/idle.tres")
	var carry: Image = idle.body_atlas.get_image().get_region(Rect2i(0,0,192,128))
	var head := Rect2i(87,41,25,24) if direction=="side" else Rect2i(idle.identity_source_region)
	# Back-facing identity is hair only. The older carry rectangle also
	# contained scarf/shoulder art, which overwrote the moving torso.
	if direction=="up": head = hair_bounds(carry,red_center_y(carry)-2)
	var density: float = float(carry.get_used_rect().size.y)/float(rows[0][0].image.get_height())
	palette.clear()
	color_cache.clear()
	for y in 128:
		for x in 192:
			var color := carry.get_pixel(x,y)
			if color.a>.65 and not palette.has(Color(color.r,color.g,color.b,1)): palette.append(Color(color.r,color.g,color.b,1))
	var clips: Array[Resource] = []
	var atlases: Array[Image] = []
	var masks: Array[Image] = []
	for cut in 5:
		if rows[cut].size()==11: rows[cut].remove_at(8) # One redundant recoil cel in the generated row.
		if rows[cut].size()!=10:
			push_error("Expected ten whole bodies in "+direction+" row "+str(cut)+", found "+str(rows[cut].size()))
			failed = true
			return
		var clip := Definition.new()
		clip.pose_count = 13
		clip.pose_order.clear()
		clip.lift_pixels.clear()
		clip.weapon_behind_body.clear()
		clip.single_hand_poses.clear()
		clip.stowed_poses.clear()
		clip.released_poses.clear()
		clip.ground_clipped_poses.clear()
		clip.weapon_texture = STEEL
		clip.weapon_primary_grip = Vector2(15,113)
		clip.weapon_tip = Vector2(15,0)
		clip.mirror_cutting_edge = false
		clip.phase_windows = PackedVector2Array([Vector2(0,3),Vector2(4,6),Vector2(7,9)])
		clip.queued_recovery_window = Vector2(10,12)
		clip.identity_source_region = Rect2(head)
		var atlas := Image.create(768,512,false,Image.FORMAT_RGBA8)
		var mask := Image.create(768,512,false,Image.FORMAT_RGBA8)
		for key in 13:
			var source_key := key if key<10 else key-3
			var component: Dictionary = rows[cut][source_key]
			var image: Image = component.image.duplicate()
			image.resize(maxi(1,roundi(image.get_width()*density)),maxi(1,roundi(image.get_height()*density)),Image.INTERPOLATE_NEAREST)
			# Grounded cels share a foot plane. Neck registration made every
			# crouch pull the boots upward, creating unintentional little hops.
			# The authored slam lift alone owns the airborne presentation.
			var sole := foot_anchor(image)
			var carry_sole := foot_anchor(carry)
			var offset := Vector2i(roundi(carry_sole.x-sole.x),roundi(carry_sole.y-sole.y))
			var body := Image.create(192,128,false,Image.FORMAT_RGBA8)
			body.blit_rect(image,Rect2i(Vector2i.ZERO,image.get_size()),offset)
			var guide: Vector2 = SIDE_GUIDES[cut][source_key] if direction!="down" else DOWN_GUIDES[cut][source_key]
			quantize(body)
			# Follow the actual drawn neck, keeping a silhouette-shaped head.
			# Clearing a fixed rectangle/gap severed shoulders and froze the head.
			var foreground := Image.create(192,128,false,Image.FORMAT_RGBA8)
			var source_scalp := hair_bounds(body,red_center_y(body)-2) if direction=="up" else Rect2i()
			var placed_head := attach_back_head(body,carry,head,foreground) if direction=="up" else attach_head(body,carry,head,direction,foreground)
			if failed: return
			remove_specks(body)
			# Slightly reduce the whole back-facing torso lean. Hair, scarf,
			# shoulders and hands move coherently; the lowest boot rows stay put.
			var center_shift := 0
			var neck_line := placed_head.end.y+2
			var boot_line := roundi(foot_anchor(body).y)-3
			if direction=="up":
				center_shift = clampi(roundi((head.get_center().x-placed_head.get_center().x)*BACK_LEAN_REDUCTION),-BACK_CENTER_LIMIT,BACK_CENTER_LIMIT)
				recenter_back_rows(body,center_shift,neck_line,boot_line)
				recenter_back_rows(foreground,center_shift,neck_line,boot_line)
				placed_head.position.x += center_shift
			# Register the final visible glove after palette/identity protection.
			# A pre-composite anchor could end up erased underneath the head.
			var expected_glove := Vector2(offset)+guide*Vector2(image.get_size())
			if direction=="up": expected_glove.x += back_row_shift(roundi(expected_glove.y),center_shift,neck_line,boot_line)
			var primary := find_glove(body,expected_glove,placed_head)
			if primary==Vector2.ZERO: primary = find_glove(body,expected_glove,placed_head,24)
			# Back-view protection also contains the installed carrying glove.
			# It is a real drawn hand, never exposed face pixels.
			if primary==Vector2.ZERO and direction=="up": primary = find_glove(body,expected_glove,Rect2i(),24)
			if primary==Vector2.ZERO:
				push_error("Missing final drawn glove: "+direction+" "+str(cut)+"/"+str(key))
				failed = true
				return
			var heading: float = float(HEADINGS[cut][source_key])+( -90.0 if direction=="up" else (90.0 if direction=="down" else 0.0))
			# Slam ACTIVE is already on the frontal ground, before any damage cue.
			if cut==2 and key>=4 and key<=6:
				heading = [25.0,35.0,45.0][key-4] if direction=="side" else (-90.0 if direction=="up" else 90.0)
			clip.primary_hands.append(primary)
			clip.secondary_hands.append(primary-Vector2.from_angle(deg_to_rad(heading))*7)
			clip.pose_order.append(key)
			clip.lift_pixels.append([-0.0,-2.0,-7.0,-12.0][key] if cut==2 and key<4 else 0.0)
			clip.weapon_behind_body.append(1 if direction=="up" else 0)
			clip.single_hand_poses.append(1)
			clip.stowed_poses.append(0)
			clip.released_poses.append(0)
			clip.ground_clipped_poses.append(0)
			clip.identity_regions.append(Rect2(placed_head))
			clip.pose_weights.append([.2,.7,.9,1.0,.65,1.0,1.0,.6,.8,1.0,.6,.8,1.0][key])
			var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
			atlas.blit_rect(body,Rect2i(0,0,192,128),origin)
			mask.blit_rect(foreground,Rect2i(0,0,192,128),origin)
			var glove_rect := Rect2i(Vector2i(primary)-Vector2i(3,3),Vector2i(7,7))
			mask.blit_rect(body,glove_rect,origin+glove_rect.position)
			audit.append({"direction":direction,"cut":cut,"key":key,"source_bounds":var_to_str(component.bounds),"density":density,"grip":var_to_str(primary),"reference_head":var_to_str(head),"placed_head":var_to_str(placed_head),"source_scalp":var_to_str(source_scalp),"center_shift":center_shift,"neck_line":neck_line,"boot_line":boot_line,"foot_anchor":var_to_str(foot_anchor(body))})
		copy_slot(clip,atlas,mask,9,idle,carry,idle.hand_atlas.get_image().get_region(Rect2i(0,0,192,128)),0,head)
		if cut==0: copy_slot(clip,atlas,mask,0,idle,carry,idle.hand_atlas.get_image().get_region(Rect2i(0,0,192,128)),0,head)
		else: copy_slot(clip,atlas,mask,0,clips[cut-1],atlases[cut-1],masks[cut-1],12,head)
		if cut==4: copy_slot(clip,atlas,mask,12,idle,carry,idle.hand_atlas.get_image().get_region(Rect2i(0,0,192,128)),0,head)
		for key in 13:
			var record: Dictionary = audit[audit.size()-13+key]
			record["final_grip"] = var_to_str(clip.primary_hands[key])
			record["installed_head"] = var_to_str(clip.identity_regions[key])
			record["installed_origin"] = "generated body cel"
			if key==9 or (key==0 and cut==0) or (key==12 and cut==4): record["installed_origin"] = "exact installed carry cel0"
			elif key==0: record["installed_origin"] = "exact previous queued endpoint12; actual rendered snapshot at WIND_UP"
		clips.append(clip)
		atlases.append(atlas)
		masks.append(mask)
		if atlas.save_png(folder+NAMES[cut]+"_body.png")!=OK or mask.save_png(folder+NAMES[cut]+"_hands.png")!=OK: failed = true
		for suffix in ["_body.png.import","_hands.png.import"]:
			var import_path: String = folder+NAMES[cut]+suffix
			if FileAccess.file_exists(import_path):
				var settings := FileAccess.get_file_as_string(import_path).replace("process/fix_alpha_border=true","process/fix_alpha_border=false")
				FileAccess.open(import_path,FileAccess.WRITE).store_string(settings)
	for cut in 5: write_clip(folder,NAMES[cut],clips[cut],NAMES.slice(1) if cut==0 else [])
	print("OATHBOUND ",direction," density ",density," /50 new source body cels")

func copy_slot(clip: Resource,body: Image,hand: Image,key: int,source: Resource,source_body: Image,source_hand: Image,pose: int,head: Rect2i) -> void:
	for property in ["primary_hands","secondary_hands","lift_pixels","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses"]:
		var values = clip.get(property)
		values[key] = source.get(property)[pose]
		clip.set(property,values)
	clip.identity_regions[key] = Rect2(head)
	if source.get("identity_source_region")!=null and source.identity_source_region.size!=Vector2.ZERO:
		# Carry may retain the original wider provenance rectangle. Remap
		# the narrower hair-only reference without changing its actual pixels.
		clip.identity_regions[key] = Rect2(source.identity_regions[pose].position+Vector2(head.position)-source.identity_source_region.position,Vector2(head.size))
	var rectangle := Rect2i(pose%4*192,pose/4*128,192,128)
	var destination := Vector2i(key%4*192,key/4*128)
	body.fill_rect(Rect2i(destination,Vector2i(192,128)),Color.TRANSPARENT)
	hand.fill_rect(Rect2i(destination,Vector2i(192,128)),Color.TRANSPARENT)
	body.blit_rect(source_body,rectangle,destination)
	hand.blit_rect(source_hand,rectangle,destination)

func is_crimson(c: Color) -> bool:
	return c.a>.65 and c.r>.28 and c.r>c.g*2.5 and c.r>c.b*1.5 and c.b>c.g*.85

func foot_anchor(image: Image) -> Vector2:
	var bounds := image.get_used_rect()
	var low := image.get_width()
	var high := 0
	# The lowest four opaque boot rows, excluding raised arms/scarf width.
	for y in range(maxi(bounds.position.y,bounds.end.y-4),bounds.end.y):
		for x in range(bounds.position.x,bounds.end.x):
			if image.get_pixel(x,y).a>.65:
				low = mini(low,x)
				high = maxi(high,x)
	return Vector2((low+high)*.5,bounds.end.y-1)

func back_row_shift(y: int,shift: int,neck_line: int,boot_line: int) -> int:
	if y<=neck_line: return shift
	if y>=boot_line: return 0
	return roundi(shift*float(boot_line-y)/float(boot_line-neck_line))

func recenter_back_rows(image: Image,shift: int,neck_line: int,boot_line: int) -> void:
	if shift==0: return
	var original: Image = image.duplicate()
	image.fill(Color.TRANSPARENT)
	for y in image.get_height():
		image.blit_rect(original,Rect2i(0,y,image.get_width(),1),Vector2i(back_row_shift(y,shift,neck_line,boot_line),y))

func attach_back_head(body: Image,carry: Image,reference: Rect2i,foreground: Image) -> Rect2i:
	var drawn: Image = body.duplicate()
	var scalp := hair_bounds(body,red_center_y(body)-2)
	if scalp.size.x<12 or scalp.size.y<8:
		push_error("Missing complete back-view scalp")
		failed = true
		return reference
	# Keep the head on the drawn neck, independent of asymmetric scarf tails.
	# Align the hair's center and bottom; do not transplant the old collar.
	var shift := Vector2i(roundi(scalp.get_center().x-reference.get_center().x),scalp.end.y-reference.end.y)
	var destination := reference.position+shift
	for y in range(scalp.position.y,scalp.end.y):
		for x in range(scalp.position.x,scalp.end.x):
			var c := body.get_pixel(x,y)
			var glove := c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25
			if is_crimson(c) or c.b>c.r+.005 or glove: continue
			body.set_pixel(x,y,Color.TRANSPARENT)
	body.blend_rect(carry,reference,destination)
	# Only a genuinely raised fist can cover the crown, never old carry cloth.
	for y in range(scalp.position.y,roundi(scalp.position.y+scalp.size.y*.4)):
		for x in range(scalp.position.x,scalp.end.x):
			var c := drawn.get_pixel(x,y)
			if c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25:
				body.set_pixel(x,y,c)
				foreground.set_pixel(x,y,c)
	return Rect2i(destination,reference.size)

func attach_head(body: Image,carry: Image,reference: Rect2i,direction: String,foreground: Image,raised_hands := true) -> Rect2i:
	var drawn: Image = body.duplicate()
	var scalp := hair_bounds(body,red_center_y(body)-2)
	if scalp.size.x<12 or scalp.size.y<8:
		push_error("Missing complete drawn scalp: "+direction)
		failed = true
		return reference
	var center := Vector2(scalp.get_center())
	var source_socket := nearest_crimson(body,Vector2(center.x,scalp.end.y+2),Rect2i(scalp.position.x-3,scalp.end.y-2,scalp.size.x+6,12))
	var reference_socket := nearest_crimson(carry,Vector2(reference.get_center().x,reference.end.y-1),reference)
	if source_socket==Vector2i(-1,-1) or reference_socket==Vector2i(-1,-1):
		push_error("Missing actual neck scarf landmark: "+direction)
		failed = true
		return reference
	var destination := reference.position+source_socket-reference_socket
	var erase := Rect2i(scalp.position,Vector2i(scalp.size.x,maxi(scalp.size.y,source_socket.y-scalp.position.y)))
	for y in range(erase.position.y,erase.end.y):
		for x in range(erase.position.x,erase.end.x):
			var c := body.get_pixel(x,y)
			# Preserve brown foreground gloves outside the face's central strip.
			var glove := c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25
			if is_crimson(c) or c.b>c.r+.005 or (raised_hands and glove and (absf(x-center.x)>scalp.size.x*.28 or y<scalp.position.y+scalp.size.y*.4)): continue
			body.set_pixel(x,y,Color.TRANSPARENT)
	# Alpha compositing retains torso/arm pixels beneath transparent head edges.
	# There is no rectangular halo and no empty scanline at the collar.
	body.blend_rect(carry,reference,destination)
	# Raised fists are foreground anatomy. Do not bury them under the crown.
	for y in range(scalp.position.y,roundi(scalp.position.y+scalp.size.y*.4) if raised_hands else scalp.position.y):
		for x in range(scalp.position.x,scalp.end.x):
			var c := drawn.get_pixel(x,y)
			if c.a>.65 and c.r>.18 and c.r<.8 and c.r>c.g*1.35 and c.g>c.b*1.25:
				body.set_pixel(x,y,c)
				foreground.set_pixel(x,y,c)
	return Rect2i(destination,reference.size)

func nearest_crimson(image: Image,expected: Vector2,rectangle: Rect2i) -> Vector2i:
	var best := Vector2i(-1,-1)
	var distance := INF
	for y in range(maxi(0,rectangle.position.y),mini(image.get_height(),rectangle.end.y)):
		for x in range(maxi(0,rectangle.position.x),mini(image.get_width(),rectangle.end.x)):
			if not is_crimson(image.get_pixel(x,y)): continue
			var delta := Vector2(x,y).distance_squared_to(expected)
			if delta<distance:
				distance = delta
				best = Vector2i(x,y)
	return best

func hair_bounds(image: Image,limit_y: float) -> Rect2i:
	var seen := PackedByteArray()
	seen.resize(192*128)
	var biggest := 0
	var bounds := Rect2i()
	for y in range(maxi(0,roundi(limit_y))):
		for x in range(68,130):
			var seed := y*192+x
			if seen[seed] or not dense_hair_pixel(image,Vector2i(x,y)): continue
			seen[seed] = 1
			var todo := PackedInt32Array([seed])
			var cursor := 0
			var low := Vector2i(x,y)
			var high := low
			while cursor<todo.size():
				var id := todo[cursor]
				cursor += 1
				var point := Vector2i(id%192,id/192)
				low = low.min(point)
				high = high.max(point)
				for dy in range(-1,2):
					for dx in range(-1,2):
						var next := point+Vector2i(dx,dy)
						if next.x<68 or next.x>=130 or next.y<0 or next.y>=roundi(limit_y): continue
						var nid := next.y*192+next.x
						if seen[nid] or not dense_hair_pixel(image,next): continue
						seen[nid] = 1
						todo.append(nid)
			if todo.size()>biggest:
				biggest = todo.size()
				bounds = Rect2i(low,high-low+Vector2i.ONE).grow(1)
	return bounds

func dense_hair_pixel(image: Image,point: Vector2i) -> bool:
	if not hair_pixel(image.get_pixelv(point)): return false
	var count := 0
	for y in range(point.y-1,point.y+2):
		for x in range(point.x-1,point.x+2):
			if x>=0 and x<192 and y>=0 and y<128 and hair_pixel(image.get_pixel(x,y)): count += 1
	return count>=6

func hair_pixel(c: Color) -> bool:
	return c.a>.65 and c.r<.6 and absf(c.r-c.g)<.09 and absf(c.r-c.b)<.12 and c.b<c.r+.025

func remove_specks(image: Image) -> void:
	var seen := PackedByteArray()
	seen.resize(192*128)
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
						if point.x<0 or point.x>=192 or point.y<0 or point.y>=128: continue
						var next := point.y*192+point.x
						if seen[next] or image.get_pixelv(point).a<.5: continue
						seen[next] = 1
						todo.append(next)
			if todo.size()<5:
				for id in todo: image.set_pixel(id%192,id/192,Color.TRANSPARENT)

func find_glove(body: Image,expected: Vector2,head: Rect2i,radius := 12) -> Vector2:
	var best := Vector2.ZERO
	var distance := INF
	for y in range(maxi(0,roundi(expected.y)-radius),mini(95,roundi(expected.y)+radius+1)):
		for x in range(maxi(0,roundi(expected.x)-radius),mini(192,roundi(expected.x)+radius+1)):
			# A raised brown fist may legitimately occlude the upper crown.
			# Face/lower hair remain excluded from glove registration.
			if head.has_point(Vector2i(x,y)) and y>=head.position.y+head.size.y*.4: continue
			var c := body.get_pixel(x,y)
			if c.a<.65 or c.r<.18 or c.r>.79 or c.r<c.g*1.35 or c.g<c.b*1.25: continue
			var delta := Vector2(x,y).distance_squared_to(expected)
			if delta<distance:
				distance = delta
				best = Vector2(x,y)
	return best

func red_center_y(image: Image) -> float:
	var total := 0.0
	var count := 0
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x,y)
			# Scarf is crimson, unlike the orange/brown skin, gloves and boots.
			if c.a>.65 and c.r>.28 and c.r>c.g*2.5 and c.r>c.b*1.5 and c.b>c.g*.85:
				total += y
				count += 1
	return total/maxi(count,1)

func quantize(image: Image) -> void:
	for y in 128:
		for x in 192:
			var color := image.get_pixel(x,y)
			if color.a<.65:
				image.set_pixel(x,y,Color.TRANSPARENT)
				continue
			var id := color.to_rgba32()
			if not color_cache.has(id):
				var closest := palette[0]
				var score := INF
				for candidate in palette:
					var delta := Vector3(color.r,color.g,color.b).distance_squared_to(Vector3(candidate.r,candidate.g,candidate.b))
					if delta<score:
						score = delta
						closest = candidate
				color_cache[id] = closest
			image.set_pixel(x,y,color_cache[id])

func write_clip(folder: String,label: String,clip: Resource,followups: Array) -> void:
	var output := "[gd_resource type=\"Resource\" load_steps="+str(5+followups.size())+" format=3]\n"
	var paths := ["res://data/weapons/weapon_family_pose_definition.gd",folder+label+"_body.png",folder+label+"_hands.png",STEEL.resource_path]
	for index in paths.size(): output += "[ext_resource type=\""+("Script" if index==0 else "Texture2D")+"\" path=\""+paths[index]+"\" id=\""+str(index+1)+"\"]\n"
	for index in followups.size(): output += "[ext_resource type=\"Resource\" path=\""+folder+followups[index]+".tres\" id=\""+str(index+5)+"\"]\n"
	output += "[resource]\nscript = ExtResource(\"1\")\nbody_atlas = ExtResource(\"2\")\nhand_atlas = ExtResource(\"3\")\nweapon_texture = ExtResource(\"4\")\n"
	for property in ["pose_count","pose_order","primary_hands","secondary_hands","weapon_primary_grip","weapon_tip","mirror_cutting_edge","phase_windows","queued_recovery_window","weapon_behind_body","single_hand_poses","stowed_poses","released_poses","ground_clipped_poses","lift_pixels","pose_weights","identity_regions","identity_source_region"]: output += property+" = "+var_to_str(clip.get(property))+"\n"
	if not followups.is_empty():
		output += "follow_up_clips = Array[Resource](["
		for index in followups.size(): output += ("," if index>0 else "")+"ExtResource(\""+str(index+5)+"\")"
		output += "])\n"
	FileAccess.open(folder+label+".tres",FileAccess.WRITE).store_string(output)
	if folder.ends_with("side/") and label=="sweep":
		FileAccess.open("res://data/weapons/families/royal_greatsword/poses.tres",FileAccess.WRITE).store_string(output)
