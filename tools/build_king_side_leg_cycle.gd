extends SceneTree

## Offline pose rendering. No rig or IK runs on the gameplay actor.
const SOURCE := "res://art_source/generated/characters/king/spellward_locomotion_2026_09_14/"
const OUT := "res://assets/characters/playable/king/spellward_preview/walk_side.png"
const REVIEW := "res://art_source/review/characters/king/spellward_legcycle_2026_09_14/"
const CELL := Vector2i(192, 128)
var viewport: SubViewport
var scene: Node2D
var parts: Array[Texture2D] = []
var traces: Array[Dictionary] = []

func _initialize() -> void:
	call_deferred("_build")

func _build() -> void:
	var source := Image.load_from_file(SOURCE + "leg_parts.png")
	for index in 3:
		var rect := Rect2i(index * source.get_width() / 3, 0, source.get_width() / 3, source.get_height())
		var cut := source.get_region(rect)
		cut.convert(Image.FORMAT_RGBA8)
		for y in cut.get_height():
			for x in cut.get_width():
				var color := cut.get_pixel(x, y)
				if color.r > color.g * 1.55 and color.b > color.g * 1.55:
					cut.set_pixel(x, y, Color.TRANSPARENT)
		cut = cut.get_region(cut.get_used_rect())
		var size: Vector2i = [Vector2i(8, 14), Vector2i(7, 13), Vector2i(10, 6)][index]
		cut.resize(size.x, size.y, Image.INTERPOLATE_NEAREST)
		parts.append(ImageTexture.create_from_image(cut))
	var upper := Image.load_from_file(SOURCE + "side_upper_approved.png")
	viewport = SubViewport.new()
	viewport.size = CELL
	viewport.transparent_bg = true
	viewport.disable_3d = true
	viewport.canvas_item_default_texture_filter = Viewport.DEFAULT_CANVAS_ITEM_TEXTURE_FILTER_NEAREST
	viewport.render_target_update_mode = SubViewport.UPDATE_ALWAYS
	root.add_child(viewport)
	var atlas := Image.create(8 * CELL.x, 2 * CELL.y, false, Image.FORMAT_RGBA8)
	for frame_index in 8:
		scene = Node2D.new()
		viewport.add_child(scene)
		var phase := frame_index / 8.0
		_leg(Vector2(97, 73), fposmod(phase + .5, 1.0), false, frame_index)
		_leg(Vector2(99, 73), phase, true, frame_index)
		# Preserve every accepted upper-body pixel, including the tunic hem.
		var body := Sprite2D.new()
		body.centered = false
		var upper_cell := _upper_body(upper.get_region(Rect2i(frame_index * CELL.x, CELL.y, CELL.x, 78)), frame_index)
		body.texture = ImageTexture.create_from_image(upper_cell)
		scene.add_child(body)
		await process_frame
		await process_frame
		await RenderingServer.frame_post_draw
		var cell := viewport.get_texture().get_image()
		cell.convert(Image.FORMAT_RGBA8)
		# Use the exact approved upper pixels, independent of render color conversion.
		cell.blend_rect(upper_cell, Rect2i(Vector2i.ZERO, upper_cell.get_size()), Vector2i.ZERO)
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, CELL), Vector2i(frame_index * CELL.x, CELL.y))
		cell.flip_x()
		atlas.blit_rect(cell, Rect2i(Vector2i.ZERO, CELL), Vector2i(frame_index * CELL.x, 0))
		scene.queue_free()
		await process_frame
	atlas.save_png(OUT)
	FileAccess.open(REVIEW + "foot_paths.json", FileAccess.WRITE).store_string(JSON.stringify(traces, "\t"))
	print("KING_LEG_CYCLE_RENDERED: continuous opposing feet; hands and upper body preserved")
	parts.clear()
	Input.set_custom_mouse_cursor(null, Input.CURSOR_ARROW)
	Input.set_custom_mouse_cursor(null, Input.CURSOR_POINTING_HAND)
	viewport.queue_free()
	await process_frame
	await process_frame
	quit()

func _upper_body(cell: Image, frame_index: int) -> Image:
	# The old lifted knee projects beyond the tunic in a few poses. Isolate the
	# hem and its outline at the join; all hand/torso pixels above y73 are exact.
	var original: Image = cell.duplicate()
	var hand_columns: Vector2i = [Vector2i(81, 90), Vector2i(86, 94), Vector2i(94, 102), Vector2i(98, 107), Vector2i(100, 111), Vector2i(95, 104), Vector2i(92, 101), Vector2i(82, 91)][frame_index]
	for y in range(73, 78):
		for x in CELL.x:
			var c := original.get_pixel(x, y)
			var keep := (x >= hand_columns.x and x <= hand_columns.y) or (c.b > c.r * 1.05 and c.g > c.r)
			for dy in range(-1, 2):
				for dx in range(-1, 2):
					var q := Vector2i(x + dx, y + dy)
					if q.x < 0 or q.x >= CELL.x or q.y >= 78:
						continue
					var n := original.get_pixelv(q)
					if n.a > .5 and minf(n.r, minf(n.g, n.b)) > .35 and maxf(n.r, maxf(n.g, n.b)) - minf(n.r, minf(n.g, n.b)) < .17:
						keep = true
			if not keep:
				cell.set_pixel(x, y, Color.TRANSPARENT)
	return cell

func _leg(hip: Vector2, phase: float, near: bool, frame_index: int) -> void:
	var ankle: Vector2
	var swing := phase >= .5
	if not swing:
		ankle = hip + Vector2(lerpf(8, -8, phase * 2), 18)
	else:
		var t := (phase - .5) * 2
		ankle = hip + Vector2(lerpf(-8, 8, smoothstep(0, 1, t)), 18 - sin(t * PI) * 4)
	var delta := ankle - hip
	var distance := delta.length()
	const THIGH := 11.0
	const SHIN := 10.0
	var along := (THIGH * THIGH - SHIN * SHIN + distance * distance) / (2 * distance)
	var outward := sqrt(maxf(0, THIGH * THIGH - along * along))
	var axis := delta / distance
	# Knees bend forward (screen right); the near leg always stays in front.
	var knee := hip + axis * along + Vector2(axis.y, -axis.x) * outward
	var tint := Color.WHITE if near else Color(.78, .78, .78, 1)
	_segment(parts[1], knee, ankle, Vector2(3.5, 1), tint)
	_segment(parts[0], hip, knee, Vector2(4, 1), tint)
	var foot := Sprite2D.new()
	foot.centered = false
	foot.texture = parts[2]
	foot.offset = Vector2(-3, -1)
	foot.position = ankle
	foot.modulate = tint
	scene.add_child(foot)
	traces.append({"frame": frame_index, "leg": "near" if near else "far", "phase": phase, "support": not swing, "hip": [hip.x, hip.y], "knee": [knee.x, knee.y], "ankle": [ankle.x, ankle.y]})

func _segment(texture: Texture2D, start: Vector2, end: Vector2, pivot: Vector2, tint: Color) -> void:
	var sprite := Sprite2D.new()
	sprite.centered = false
	sprite.texture = texture
	sprite.offset = -pivot
	sprite.position = start
	sprite.rotation = (end - start).angle() - PI * .5
	sprite.modulate = tint
	scene.add_child(sprite)
