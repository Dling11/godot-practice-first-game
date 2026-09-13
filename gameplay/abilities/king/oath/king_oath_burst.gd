extends Node2D

## Finite raster animation; owns no collision or combat state.
var texture: Texture2D
var radius := 64.0
var life := .5
var age := 0.0
var cleave := false
var reverse := false
var charge := false
var points := PackedVector2Array()
var follow_actor: Node2D

func _ready() -> void:
	texture_filter=CanvasItem.TEXTURE_FILTER_NEAREST

func _process(delta: float) -> void:
	if is_instance_valid(follow_actor):
		global_position=follow_actor.global_position+Vector2(0,-12)
	age+=delta
	if age>=life:
		queue_free()
		return
	queue_redraw()

func _draw() -> void:
	if texture==null:
		return
	var progress := clampf(age/life,0,1)
	var alpha := 1.0-smoothstep(.62,1.0,progress)
	if cleave:
		var frame := mini(int(progress*8),7)
		var uvs := PackedVector2Array()
		for point in points:
			var uv := Vector2(point.x/radius,point.y/(radius*2)+.5)
			if reverse:
				uv.y=1.0-uv.y
			uvs.append((uv+Vector2(frame%4,frame/4))/Vector2(4,2))
		draw_polygon(points,PackedColorArray([Color(1,1,1,alpha)]),uvs,texture)
	else:
		# Preparation plays 0..3. Contact opens on the rupture, reaches its peak
		# within the real .1s hit window, then settles through the remaining art.
		var frame := mini(int(progress*4),3) if charge else mini(int(lerpf(4,9,minf(age/.1,1)) if age<.1 else lerpf(9,16,(age-.1)/maxf(life-.1,.01))),15)
		# Whole-cell fixed origin and scale: contact stays grounded as debris rises.
		var extent := radius*192.0/142.0
		draw_texture_rect_region(texture,Rect2(-extent,-extent,extent*2,extent*2),Rect2((frame%4)*192,(frame/4)*192,192,192),Color(1,1,1,alpha))
