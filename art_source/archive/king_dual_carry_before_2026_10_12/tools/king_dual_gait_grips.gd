extends RefCounted

## Offline landmarks for the frozen complete gait bodies, reviewed at source
## pixel scale. Brown shoulders/belt/boots must never compete with real palms.
const NEAR := {
	"side":[Vector2(91,74),Vector2(91,75),Vector2(94,73),Vector2(92,72),Vector2(92,72),Vector2(92,74),Vector2(92,73),Vector2(92,71)],
	"up":[Vector2(83,70),Vector2(85,75),Vector2(87,72),Vector2(90,70),Vector2(91,72),Vector2(92,72),Vector2(92,71),Vector2(90,72)],
	"down":[Vector2(85,71),Vector2(84,76),Vector2(84,65),Vector2(83,69),Vector2(85,73),Vector2(83,71),Vector2(85,74),Vector2(84,72)]
}
const FAR := {
	"side":[Vector2(114,72),Vector2(112,73),Vector2(113,71),Vector2(114,70),Vector2(114,72),Vector2(112,71),Vector2(111,70),Vector2(114,69)],
	"up":[Vector2(107,71),Vector2(108,71),Vector2(110,69),Vector2(113,71),Vector2(114,72),Vector2(113,70),Vector2(116,71),Vector2(113,71)],
	"down":[Vector2(108,70),Vector2(108,71),Vector2(103,70),Vector2(108,68),Vector2(107,73),Vector2(106,74),Vector2(108,67),Vector2(108,72)]
}

static func palms(view: String,key: int) -> Array[Vector2]:
	return [NEAR[view][key],FAR[view][key]]

static func glove_box(grip: Vector2) -> Rect2i:
	# Copy the entire closed native fist and charcoal cuff edge. This mask
	# overlays the steel; it cannot redraw or move a hand independently.
	return Rect2i(Vector2i(grip)-Vector2i(5,5),Vector2i(11,11))
