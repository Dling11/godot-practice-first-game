extends RefCounted

## Offline body registration only. Steel, FX, controller scale and combat stay fixed.
## One anatomical density per lane; crouches/turns never receive per-cel zoom.
static func register(clip: Resource,body: Image,mask: Image,view: String,family: String,lane: String,head_finder: Callable) -> Dictionary:
	var torso_x := (0.82 if view=="up" else 0.86) if family=="dual" and lane=="attack" else 1.0
	if family=="greatsword" and lane=="attack": torso_x = 0.96
	if lane=="spin": torso_x = 1.0 # Shared complete turn already has side-body density.
	var torso_y := 1.0
	if lane in ["idle","run"]:
		var first := body.get_region(Rect2i(0,0,192,128))
		var head: Rect2i = head_finder.call(clip,first,0,view)
		var head_height := 24 if view=="up" else 29
		# Front provenance includes transparent crown padding; count visible height.
		var crown_padding := first.get_region(head).get_used_rect().position.y
		var visible_head_height := head_height-roundi(crown_padding*head_height/float(head.size.y))
		var reference_height := 54.0 if lane=="idle" else (51.0 if family=="dual" else 56.0)
		torso_y = (reference_height-visible_head_height)/maxf(1,first.get_used_rect().end.y-1-head.end.y)
	var atlas := Image.create(body.get_width(),body.get_height(),false,Image.FORMAT_RGBA8)
	var hands := Image.create(mask.get_width(),mask.get_height(),false,Image.FORMAT_RGBA8)
	var registrations: Array[Dictionary] = []
	for key in clip.pose_count:
		var cell := Rect2i(key%4*192,key/4*128,192,128)
		var cel := body.get_region(cell)
		var original := cel.duplicate()
		var glove := mask.get_region(cell)
		var old_head: Rect2i = head_finder.call(clip,cel,key,view)
		var rear := view=="up" if lane!="spin" else old_head.size.x<29
		var size := Vector2i(25,24) if rear else Vector2i(27,29)
		var pivot := Vector2(old_head.get_center().x,cel.get_used_rect().end.y-1)
		var transform := Transform2D(0,Vector2(torso_x,torso_y),0,Vector2(pivot.x,94)-pivot*Vector2(torso_x,torso_y))
		var face := cel.get_region(old_head)
		var palms: Array[Vector2] = [clip.primary_hands[key]]
		if clip.offhand!=null: palms.append(clip.offhand.hands[key])
		# Preserve genuinely foreground palms/forearms through the head transplant.
		for y in old_head.size.y:
			for x in old_head.size.x:
				var point := old_head.position+Vector2i(x,y)
				var forearm: bool = family=="dual" and clip.released_poses[key]==0 and forearm_pixel(original,point,old_head,palms)
				if glove.get_pixelv(point).a>.65 or forearm:
					face.set_pixel(x,y,Color.TRANSPARENT)
				else:
					cel.set_pixelv(point,Color.TRANSPARENT)
		var placed := sample(cel,transform)
		var placed_hands := sample(glove,transform)
		face.resize(size.x,size.y,Image.INTERPOLATE_NEAREST)
		var head_bottom := transform*Vector2(old_head.get_center().x,old_head.end.y)
		var new_head := Rect2i(Vector2i(roundi(head_bottom.x-size.x*.5),roundi(head_bottom.y-size.y)),size)
		placed.blend_rect(face,Rect2i(Vector2i.ZERO,size),new_head.position)
		var visible_hands: bool = not clip.hands_are_occluded(key) and (clip.primary_visible_poses.is_empty() or clip.primary_visible_poses[key]>0)
		if visible_hands: placed.blend_rect(placed_hands,Rect2i(0,0,192,128),Vector2i.ZERO)
		if clip.released_poses[key]==0:
			var primary: Vector2 = clip.primary_hands[key]
			var secondary: Vector2 = clip.secondary_hands[key]
			clip.primary_hands[key] = transform*primary
			clip.secondary_hands[key] = clip.primary_hands[key]+(secondary-primary) if clip.single_hand_poses[key]>0 else transform*secondary
			preserve_palm(original,glove,placed,placed_hands,primary,clip.primary_hands[key],visible_hands)
			if clip.single_hand_poses[key]==0: preserve_palm(original,glove,placed,placed_hands,secondary,clip.secondary_hands[key],visible_hands)
			if clip.offhand!=null:
				var far: Vector2 = clip.offhand.hands[key]
				var axis: Vector2 = clip.offhand.axes[key]
				clip.offhand.hands[key] = transform*far
				clip.offhand.axes[key] = clip.offhand.hands[key]+(axis-far)
				if clip.offhand.visible_poses[key]>0: preserve_palm(original,glove,placed,placed_hands,far,clip.offhand.hands[key],visible_hands)
		if clip.identity_regions.size()==clip.pose_count: clip.identity_regions[key] = Rect2(new_head)
		atlas.blit_rect(placed,Rect2i(0,0,192,128),cell.position)
		hands.blit_rect(placed_hands,Rect2i(0,0,192,128),cell.position)
		registrations.append({"key":key,"head":var_to_str(new_head),"body_scale":var_to_str(Vector2(torso_x,torso_y)),"foot":94,"lane":lane,"family":family,"view":view})
	return {"body":atlas,"hands":hands,"poses":registrations}

static func sample(source: Image,transform: Transform2D) -> Image:
	var output := Image.create(192,128,false,Image.FORMAT_RGBA8)
	var inverse := transform.affine_inverse()
	for y in 128:
		for x in 192:
			var point := Vector2i((inverse*Vector2(x,y)).round())
			if Rect2i(0,0,192,128).has_point(point): output.set_pixel(x,y,source.get_pixelv(point))
	# Native contraction can otherwise discard a one-texel wrist/neck connection.
	# Keep original coverage and colors; no blur or invented limb pixels.
	for y in 128:
		for x in 192:
			var color := source.get_pixel(x,y)
			if color.a<.65: continue
			var point := Vector2i((transform*Vector2(x,y)).round())
			if Rect2i(0,0,192,128).has_point(point) and output.get_pixelv(point).a<.65: output.set_pixelv(point,color)
	return output

static func preserve_palm(source: Image,mask: Image,body: Image,foreground: Image,old: Vector2,current: Vector2,visible: bool) -> void:
	var original := Vector2i(old.round())
	var target := Vector2i(current.round())
	var color := (source if visible else mask).get_pixelv(original)
	if color.a>.65 and visible: body.set_pixelv(target,color)
	var finger := mask.get_pixelv(original)
	if finger.a>.65: foreground.set_pixelv(target,finger)

static func forearm_pixel(image: Image,point: Vector2i,head: Rect2i,palms: Array[Vector2]) -> bool:
	var color := image.get_pixelv(point)
	if color.a<.65 or (color.r>.45 and color.r>color.g*2.5 and color.r>color.b*2.0): return false
	# Frontal head provenance also contains blue collar/shoulder pixels.
	if color.b>color.r+.005: return true
	if absf(color.r-color.g)<.08 and absf(color.g-color.b)<.08 and color.r>.35: return true
	if point.y<head.position.y+head.size.y*.55: return false
	if absf(point.x-head.get_center().x)<head.size.x*.28: return false
	for palm in palms:
		var side := -1 if palm.x<head.get_center().x else 1
		var shoulder := Vector2(head.get_center().x+side*7,head.end.y+(-7 if head.size.x>=29 else 3))
		if Vector2(point).distance_to(Geometry2D.get_closest_point_to_segment(Vector2(point),palm,shoulder))<=6: return true
	return false
