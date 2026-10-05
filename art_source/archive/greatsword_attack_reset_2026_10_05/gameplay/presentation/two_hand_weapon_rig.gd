extends RefCounted

## Presentation-only two-bone arms. Wrists are derived from the same rigid
## weapon transform as the steel; they cannot change gameplay contact.
const UPPER_LENGTH := 14.0
const FOREARM_LENGTH := 15.0
var arms: Node2D
var far_arms: Node2D
var gloves: Node2D
var upper: Array[Sprite2D] = []
var forearms: Array[Sprite2D] = []
var hands: Array[Sprite2D] = []
var shoulders := [Vector2.ZERO,Vector2.ZERO]
var wrists := [Vector2.ZERO,Vector2.ZERO]
var elbows := [Vector2.ZERO,Vector2.ZERO]
var reach_error := 0.0
var support_engagement := 0.0

func configure(parent: Node2D) -> void:
	arms = Node2D.new()
	arms.name = "ControlledArms"
	far_arms = Node2D.new()
	far_arms.name = "FarArm"
	gloves = Node2D.new()
	gloves.name = "HandleGrips"
	parent.add_child(arms)
	parent.add_child(far_arms)
	parent.add_child(gloves)
	for index in 2:
		var layer := far_arms if index==0 else arms
		upper.append(_sprite(layer))
		forearms.append(_sprite(layer))
		hands.append(_sprite(gloves))
	set_visible(false)

func _sprite(parent: Node2D) -> Sprite2D:
	var sprite := Sprite2D.new()
	sprite.texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	parent.add_child(sprite)
	return sprite

func set_visible(shown: bool) -> void:
	arms.visible = shown
	far_arms.visible = shown
	gloves.visible = shown

func update(clip: Resource, basis: Transform2D, near: Vector2, far: Vector2, support: float) -> void:
	set_visible(true)
	support_engagement = support
	reach_error = 0
	shoulders = [far,near]
	wrists[1] = basis.origin
	var resting_hand := far+Vector2(-2,16)
	wrists[0] = resting_hand.lerp(basis*(clip.weapon_support_grip-clip.weapon_primary_grip),support)
	for index in 2:
		upper[index].texture = clip.arm_upper_texture
		forearms[index].texture = clip.arm_forearm_texture
		hands[index].texture = clip.arm_hand_texture
		var delta: Vector2 = wrists[index]-shoulders[index]
		var distance := delta.length()
		reach_error = maxf(reach_error,maxf(distance-UPPER_LENGTH-FOREARM_LENGTH,0))
		var length := clampf(distance,absf(UPPER_LENGTH-FOREARM_LENGTH)+.001,UPPER_LENGTH+FOREARM_LENGTH-.001)
		var along := (UPPER_LENGTH*UPPER_LENGTH-FOREARM_LENGTH*FOREARM_LENGTH+length*length)/(2*length)
		var perpendicular := sqrt(maxf(UPPER_LENGTH*UPPER_LENGTH-along*along,0))
		var direction := delta.normalized() if distance>.001 else Vector2.DOWN
		# Stable elbow side throughout the cut avoids the pole flipping at
		# overhead/low crossings. Both elbows extend away from the chest.
		var pole := -1.0 if index==0 else 1.0
		elbows[index] = shoulders[index]+direction*along+Vector2(-direction.y,direction.x)*perpendicular*pole
		_segment(upper[index],shoulders[index],elbows[index])
		_segment(forearms[index],elbows[index],wrists[index])
		hands[index].position = wrists[index]
		hands[index].rotation = basis.get_rotation() if index==1 or support>.95 else 0.0

func _segment(sprite: Sprite2D, start: Vector2, finish: Vector2) -> void:
	var delta := finish-start
	sprite.position = (start+finish)*.5
	sprite.rotation = delta.angle()-PI/2
	# Match the registered bone length without changing blade or body scale.
	sprite.scale = Vector2(1,delta.length()/sprite.texture.get_height())
