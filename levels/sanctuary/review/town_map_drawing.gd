extends Control

var entries: Array[Dictionary] = []
var routes: Array[PackedVector2Array] = []
var player: Node2D
var selected_id := ""

func _draw() -> void:
	var map_scale := Vector2.ONE * minf(size.x / 1152.0,size.y / 768.0)
	var offset := (size - Vector2(1152,768) * map_scale) / 2
	draw_rect(Rect2(Vector2.ZERO,size),Color(.105,.155,.12))
	for route in routes:
		var points := PackedVector2Array()
		for point in route: points.append(point*map_scale+offset)
		draw_polyline(points,Color(.36,.36,.3),5)
	for rectangle in [Rect2(142,248,176,142),Rect2(800,248,248,142),Rect2(132,464,200,184),Rect2(816,500,176,168)]:
		draw_rect(Rect2(rectangle.position*map_scale+offset,rectangle.size*map_scale),Color(.31,.36,.43))
	draw_circle(Vector2(576,452)*map_scale+offset,10,Color(.24,.5,.58))
	for entry in entries:
		var point: Vector2 = entry.node.global_position*map_scale+offset
		if str(entry.id) == selected_id: draw_circle(point,7,Color(.95,.88,.55),false,1)
		draw_circle(point,4,entry.color)
	if is_instance_valid(player):
		var point := player.global_position*map_scale+offset
		draw_colored_polygon(PackedVector2Array([point+Vector2(0,-5),point+Vector2(4,4),point+Vector2(-4,4)]),Color.WHITE)
