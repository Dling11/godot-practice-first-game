extends RefCounted

## Offline whole-cel registration, never a runtime body-part transform.
## Lower torso landmarks reviewed against the native equipped DOWN sheets.
## Keep soles/lift unchanged; move head, scarf, chest, hips and grips together.
const PIVOTS := {
	"axe": [
		[91,93,95,95,99,106,104,102,104,91,104,102,104],
		[104,100,97,97,102,101,94,99,103,91,94,99,103],
		[103,93,97,97,98,96,95,96,98,91,95,96,98],
		[98,91,94,93,102,102,91,91,97,91,102,91,97],
		[97,94,94,93,97,101,107,104,102,91,107,104,91]
	],
	"dual": [
		[95,94,97,97,95,89,92,91,92,95,92,91,92],
		[92,96,95,95,88,92,96,93,93,95,96,93,93],
		[93,100,90,90,95,97,95,95,96,95,95,95,96],
		[96,94,95,95,98,96,96,96,96,95,96,96,96],
		[96,94,94,94,95,97,95,93,95,95,95,93,95]
	]
}

static func offset(family: String,step: int,key: int) -> Vector2i:
	# These endpoints are copied from ready or the previous cut after registration.
	if key==0 or key==9 or (step==4 and key==12): return Vector2i.ZERO
	return Vector2i(clampi(96-int(PIVOTS[family][step][key]),-8,8),0)

static func apply(clip: Resource,family: String,step: int) -> void:
	assert(clip.pose_count==13,"DOWN registration requires its authored thirteen keys")
	var bodies: Image = clip.body_atlas.get_image().duplicate()
	var hands: Image = clip.hand_atlas.get_image().duplicate()
	for key in clip.pose_count:
		var shift := offset(family,step,key)
		if shift==Vector2i.ZERO: continue
		var origin := Vector2i(key%4,key/4)*Vector2i(192,128)
		var box := Rect2i(origin,Vector2i(192,128))
		for sheet in [bodies,hands]:
			var cel: Image = sheet.get_region(box)
			assert(Rect2i(0,0,192,128).encloses(Rect2i(cel.get_used_rect().position+shift,cel.get_used_rect().size)),"Registered DOWN cel would be cropped")
			sheet.fill_rect(box,Color.TRANSPARENT)
			sheet.blit_rect(cel,Rect2i(0,0,192,128),origin+shift)
		clip.primary_hands[key]+=Vector2(shift)
		clip.secondary_hands[key]+=Vector2(shift)
		clip.identity_regions[key].position+=Vector2(shift)
		if clip.offhand!=null:
			clip.offhand.hands[key]+=Vector2(shift)
			clip.offhand.axes[key]+=Vector2(shift)
	clip.body_atlas=ImageTexture.create_from_image(bodies)
	clip.hand_atlas=ImageTexture.create_from_image(hands)
