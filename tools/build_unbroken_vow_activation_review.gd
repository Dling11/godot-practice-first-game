extends SceneTree

## Art-only study. Does not change the production King SpriteFrames or loadout.
const SOURCE := "res://art_source/generated/characters/king/unbroken_vow_activation_2026_09_27/"
const OUT := "res://art_source/review/characters/king/unbroken_vow_activation_2026_09_27/"
const BARRIER := "res://art_source/review/characters/king/unbroken_vow_v2_2026_09_27/"
const KING := "res://assets/characters/playable/king/spellward/"
const CELL := Vector2i(192, 128)
const FX_CELL := Vector2i(144, 112)
const EFFECT_PALETTE: Array[Color] = [
	Color("341b34"), Color("651b3e"), Color("9e2246"), Color("d64055"),
	Color("f78391"), Color("fcd5db"), Color("273c55"), Color("49617e"),
	Color("7395a7"), Color("95cfdc"), Color("d0f4fa"), Color("effaff"),
]


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(OUT)
	var idle_texture := load(KING + "idle.png") as Texture2D
	var idle := idle_texture.get_image().get_region(Rect2i(0, 0, 192, 128))
	if OS.get_cmdline_user_args().has("--reference-only"):
		var reference := idle.get_region(Rect2i(48, 0, 96, 128))
		reference.resize(384, 512, Image.INTERPOLATE_NEAREST)
		reference.save_png(SOURCE + "exact_king_reference.png")
		var template := Image.create_empty(1536, 1024, false, Image.FORMAT_RGBA8)
		template.fill(Color.MAGENTA)
		for index in 8:
			template.blend_rect(reference, Rect2i(0, 0, 384, 512), Vector2i(index % 4 * 384, index / 4 * 512))
		template.save_png(SOURCE + "exact_king_template.png")
		quit()
		return
	var source := Image.load_from_file(SOURCE + "body_source.png")
	var pressure_source := Image.load_from_file(SOURCE + "pressure_source.png")
	var palette := _body_palette(idle)
	var cells: Array[Image] = []
	for index in 8:
		var size := Vector2i(source.get_width() / 4, source.get_height() / 2)
		var cell := source.get_region(Rect2i(Vector2i(index % 4, index / 4) * size, size))
		_binary_alpha(cell, .70)
		cells.append(cell)
	var reference_bounds := cells[0].get_used_rect()
	var factor := 56.0 / reference_bounds.size.y
	var bodies: Array[Image] = []
	var effects: Array[Image] = []
	var body_sheet := Image.create_empty(192 * 4, 128 * 2, false, Image.FORMAT_RGBA8)
	var board := Image.create_empty(192 * 4, 128 * 2, false, Image.FORMAT_RGBA8)
	board.fill(Color("17212e"))
	var measurements: Array = []
	for index in 8:
		var bounds := cells[index].get_used_rect()
		# The exact-source template supplies a common anchor; fitting each hair
		# silhouette independently would introduce sideways wobble.
		var center := cells[index].get_width() * .5
		var body := cells[index].get_region(bounds)
		body.resize(roundi(body.get_width() * factor), roundi(body.get_height() * factor), Image.INTERPOLATE_NEAREST)
		_quantize(body, palette)
		var registered := Image.create_empty(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
		var dest := Vector2i(96 + roundi((bounds.position.x - center) * factor), 96 - body.get_height())
		registered.blit_rect(body, Rect2i(Vector2i.ZERO, body.get_size()), dest)
		# Exact idle bookends prevent any redraw at the locomotion boundary.
		if index in [0, 7]:
			registered = idle.duplicate()
		# Generation duplicated the weapon-side forearm in the release poses.
		# Restore this unchanged shoulder-grip area from the approved idle;
		# all motion belongs to the opposite, free arm.
		if index in [4, 5]:
			registered.blit_rect(idle, Rect2i(108, 61, 22, 29), Vector2i(108, 61))
		_validate_frame(registered, "body %d" % index)
		registered.save_png(OUT + "body_%02d.png" % (index + 1))
		bodies.append(registered)
		body_sheet.blit_rect(registered, Rect2i(Vector2i.ZERO, CELL), Vector2i(index % 4, index / 4) * CELL)
		var used := registered.get_used_rect()
		measurements.append({"frame": index + 1, "height": used.size.y, "shared_scale": factor, "foot_y": 96, "bounds": [used.position.x, used.position.y, used.size.x, used.size.y]})
		var psize := Vector2i(pressure_source.get_width() / 4, pressure_source.get_height() / 2)
		var pressure := pressure_source.get_region(Rect2i(Vector2i(index % 4, index / 4) * psize, psize))
		pressure.resize(FX_CELL.x, FX_CELL.y, Image.INTERPOLATE_NEAREST)
		_binary_alpha(pressure, .32)
		_quantize(pressure, EFFECT_PALETTE)
		pressure.save_png(OUT + "pressure_%02d.png" % (index + 1))
		effects.append(pressure)
		var still := _compose(registered, index, pressure, true)
		board.blit_rect(still, Rect2i(Vector2i.ZERO, CELL), Vector2i(index % 4, index / 4) * CELL)
	body_sheet.save_png(OUT + "activation_body_down_4x2.png")
	board.save_png(OUT + "activation_contact_sheet.png")
	var comparison := Image.create_empty(384, 128, false, Image.FORMAT_RGBA8)
	comparison.fill(Color("17212e"))
	comparison.blend_rect(idle, Rect2i(Vector2i.ZERO, CELL), Vector2i.ZERO)
	comparison.blend_rect(bodies[0], Rect2i(Vector2i.ZERO, CELL), Vector2i(192, 0))
	comparison.save_png(OUT + "idle_size_comparison.png")
	# Actual-speed playback uses eight distinct drawings in .32 seconds.
	# Slow playback is explicitly a timing study, never a production cast duration.
	var timeline: Array = []
	var idle_view := _compose(idle, -1, null, false)
	_save_review_frame(idle_view, "idle")
	timeline.append({"file": "idle", "delay": 55, "slow_delay": 55})
	for index in 8:
		var file := "cast_%02d" % (index + 1)
		_save_review_frame(_compose(bodies[index], index, effects[index], true), file)
		timeline.append({"file": file, "delay": 4, "slow_delay": 12})
	# Exact original idle returns while the established shell keeps moving.
	for index in 9:
		var file := "sustain_%02d" % (index + 1)
		_save_review_frame(_compose(idle, 8 + index, effects[7], true), file)
		timeline.append({"file": file, "delay": 14, "slow_delay": 14})
	var walk := (load(KING + "walk.png") as Texture2D).get_image()
	for index in 8:
		var file := "walk_%02d" % (index + 1)
		var walk_cell := walk.get_region(Rect2i(index % 4 * 192, 0, 192, 128))
		_save_review_frame(_compose(walk_cell, 8 + index, effects[7], true), file)
		timeline.append({"file": file, "delay": 14, "slow_delay": 14})
	timeline.append({"file": "idle", "delay": 45, "slow_delay": 45})
	FileAccess.open(OUT + "timeline.json", FileAccess.WRITE).store_string(JSON.stringify(timeline, "\t"))
	FileAccess.open(OUT + "measurements.json", FileAccess.WRITE).store_string(JSON.stringify({"body_cell": [192, 128], "production_scale": .5, "standing_body_height": 56, "cast_seconds": .32, "frames": measurements}, "\t"))
	_write_pressure_audio()
	print("VOW_ACTIVATION_REVIEW: eight registered body slots with exact idle bookends, fixed scale %.5f, y96 feet; .32s study; production untouched" % factor)
	quit()


func _compose(body: Image, phase: int, pressure: Image, shield: bool) -> Image:
	var view := Image.create_empty(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
	view.fill(Color("17212e"))
	var barrier: Image
	if shield:
		var index: int = [1, 1, 1, 2, 3, 4, 5, 6][phase] if phase < 8 else 4 + ((phase - 8) % 3)
		barrier = Image.load_from_file(BARRIER + "frame_%02d.png" % index)
		view.blend_rect(barrier, Rect2i(0, 0, 112, 112), Vector2i(40, 8))
	if pressure != null and phase < 8:
		view.blend_rect(pressure, Rect2i(Vector2i.ZERO, FX_CELL), Vector2i(24, 0 if phase < 4 else 20))
	view.blend_rect(body, Rect2i(Vector2i.ZERO, CELL), Vector2i.ZERO)
	if barrier != null:
		view.blend_rect(barrier, Rect2i(0, 86, 112, 26), Vector2i(40, 94))
	if pressure != null:
		# Red energy is foreground; blue ground pressure remains below the body.
		var red := pressure.duplicate() as Image
		for y in red.get_height():
			for x in red.get_width():
				var c := red.get_pixel(x, y)
				if c.r < c.b * 1.2 or c.r < c.g * 1.3:
					red.set_pixel(x, y, Color.TRANSPARENT)
		view.blend_rect(red, Rect2i(Vector2i.ZERO, FX_CELL), Vector2i(24, 0 if phase < 4 else 20))
	if phase in [4, 5]:
		var shaken := Image.create_empty(CELL.x, CELL.y, false, Image.FORMAT_RGBA8)
		shaken.fill(Color("17212e"))
		shaken.blit_rect(view, Rect2i(Vector2i.ZERO, CELL), Vector2i(1, -1) if phase == 4 else Vector2i(-1, 0))
		view = shaken
	return view


func _save_review_frame(view: Image, file: String) -> void:
	view.save_png(OUT + file + ".png")
	# Four-times gameplay display size, using exact nearest-neighbor sampling.
	var enlarged := view.duplicate()
	enlarged.resize(384, 256, Image.INTERPOLATE_NEAREST)
	enlarged.save_png(OUT + file + "_large.png")
	var native := view.duplicate()
	native.resize(96, 64, Image.INTERPOLATE_NEAREST)
	native.save_png(OUT + file + "_native.png")


func _binary_alpha(image: Image, threshold: float) -> void:
	image.convert(Image.FORMAT_RGBA8)
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x, y)
			c = Color(c.r, c.g, c.b, 1.0) if c.a >= threshold else Color.TRANSPARENT
			image.set_pixel(x, y, c)


func _body_palette(image: Image) -> Array[Color]:
	var counts: Dictionary = {}
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x, y)
			if c.a > .5:
				var key := c.to_rgba32()
				counts[key] = counts.get(key, 0) + 1
	var colors := counts.keys()
	colors.sort_custom(func(a: int, b: int) -> bool: return counts[a] > counts[b])
	var palette: Array[Color] = []
	for index in mini(64, colors.size()):
		palette.append(Color.hex(colors[index]))
	return palette


func _quantize(image: Image, palette: Array[Color]) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var c := image.get_pixel(x, y)
			if c.a < .5:
				continue
			var best := palette[0]
			var distance := INF
			for entry in palette:
				var next := Vector3(c.r - entry.r, c.g - entry.g, c.b - entry.b).length_squared()
				if next < distance:
					distance = next
					best = entry
			image.set_pixel(x, y, best)


func _validate_frame(image: Image, label: String) -> void:
	var bounds := image.get_used_rect()
	assert(bounds.position.x > 0 and bounds.position.y > 0 and bounds.end.x < CELL.x and bounds.end.y < CELL.y, "Clipped " + label)
	assert(bounds.end.y == 96, "Foot anchor drift: " + label)


func _write_pressure_audio() -> void:
	# Original deterministic sound study: rounded bass contact, filtered air,
	# quiet harmonic tail. No sharp full-scale transient or external source.
	const RATE := 44100
	var samples := PackedFloat32Array()
	var rng := RandomNumberGenerator.new()
	rng.seed = 159927
	var filtered := 0.0
	var peak := .001
	for index in int(RATE * .65):
		var t := float(index) / RATE
		filtered = lerpf(filtered, rng.randf_range(-1.0, 1.0), .10)
		var onset := 1.0 - exp(-420.0 * t)
		var phase := TAU * (58.0 * t + 100.0 * .075 * (1.0 - exp(-t / .075)))
		var value := sin(phase) * exp(-11.0 * t) * .55
		value += filtered * exp(-8.0 * t) * .38
		value += (sin(TAU * 348.0 * t) + sin(TAU * 522.0 * t)) * exp(-7.0 * t) * .018
		value *= onset * minf(1.0, (.65 - t) / .08)
		samples.append(value)
		peak = maxf(peak, absf(value))
	var bytes := PackedByteArray()
	bytes.resize(samples.size() * 2)
	for index in samples.size():
		bytes.encode_s16(index * 2, roundi(samples[index] / peak * .50 * 32767.0))
	var wav := AudioStreamWAV.new()
	wav.format = AudioStreamWAV.FORMAT_16_BITS
	wav.mix_rate = RATE
	wav.data = bytes
	assert(wav.save_to_wav(OUT + "pressure_contact.wav") == OK)
