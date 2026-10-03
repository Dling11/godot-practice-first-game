class_name SummonEffect
extends Node2D

## A planted pixel seam. EncounterController owns arrival timing and actors.
const OUTLINE := Color("141522")
const VIOLET := Color("9569ae")
const CORE := Color("e3bd88")
const SEAM := [Vector2(-22, 0), Vector2(-12, -3), Vector2(-4, 1), Vector2(4, -2), Vector2(13, 2), Vector2(22, 0)]
const RING := [Vector2(-24, -4), Vector2(-16, -10), Vector2(16, -10), Vector2(24, -4), Vector2(24, 4), Vector2(16, 10), Vector2(-16, 10), Vector2(-24, 4)]
var released := false
var _tick := 0

func _ready() -> void:
	texture_filter = CanvasItem.TEXTURE_FILTER_NEAREST
	z_index = -1
	var clock := Timer.new()
	clock.wait_time = 0.07
	clock.timeout.connect(_step)
	add_child(clock)
	clock.start()
	queue_redraw()

func release() -> void:
	released = true
	_tick = 0
	queue_redraw()

func _step() -> void:
	_tick += 1
	if released and _tick >= 8:
		queue_free()
	else:
		queue_redraw()

func _draw() -> void:
	# Every vertex remains fixed during the warning; no scaling or lightning.
	for index in RING.size():
		var next: Vector2 = RING[(index + 1) % RING.size()]
		draw_line(RING[index], next, OUTLINE, 3.0)
		if not released:
			draw_line(RING[index], next, VIOLET if _tick % 3 != 0 else CORE, 1.0)
	for index in range(SEAM.size() - 1):
		draw_line(SEAM[index], SEAM[index + 1], OUTLINE, 5.0)
		draw_line(SEAM[index], SEAM[index + 1], CORE if released else VIOLET, 1.0)
	if released:
		# Six discrete dust pixels rise away from the planted feet and disappear.
		for index in 6:
			var x := -20 + index * 8 + (-_tick if index < 3 else _tick)
			var y := -2 - ((_tick * (2 + index % 2)) % 18)
			draw_rect(Rect2(x, y, 2, 2), CORE if index % 2 == 0 else VIOLET)
