extends SceneTree

## Reproducibly normalizes approved generated combat-UI sources.

const SOURCE_ROOT := "res://art_source/generated/ui/king_combat_ui/"
const KING_SKILL_SOURCE_ROOT := "res://art_source/generated/ui/king_skill_icons_bc_hybrid/"
const ACTION_SOURCE_ROOT := "res://art_source/generated/ui/combat_action_atlas_bc/"
const ACTION_ATLAS_PATH := "res://assets/ui/icons/combat/combat_action_atlas_bc_6x1_24.png"
const CURSOR_OUTPUT_ROOT := "res://assets/ui/cursors/generated/"
const ACTION_CELL_SIZE := 24
const ACTION_CELL_COUNT := 6

const KING_SKILL_PALETTE := [
	Color8(9, 11, 16),
	Color8(18, 21, 29),
	Color8(34, 41, 56),
	Color8(62, 73, 94),
	Color8(104, 119, 145),
	Color8(161, 176, 194),
	Color8(217, 221, 206),
	Color8(35, 76, 119),
	Color8(65, 128, 184),
	Color8(102, 164, 216),
	Color8(190, 232, 255),
	Color8(118, 90, 163),
	Color8(112, 31, 42),
	Color8(166, 48, 56),
]

const JOBS := [
	{
		"source_root": KING_SKILL_SOURCE_ROOT,
		"source": "skill_1_echoing_sever_bc_source.png",
		"output": "icon_skill_echoing_sever_bc_24.png",
		"size": 24,
		"padding_ratio": 0.10,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"hard_pixel": true,
		"atlas_index": 0,
	},
	{
		"source_root": KING_SKILL_SOURCE_ROOT,
		"source": "skill_2_riftbreak_bc_source.png",
		"output": "icon_skill_riftbreak_bc_24.png",
		"size": 24,
		"padding_ratio": 0.10,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"hard_pixel": true,
		"atlas_index": 1,
	},
	{
		"source_root": KING_SKILL_SOURCE_ROOT,
		"source": "skill_3_sovereign_pursuit_bc_source.png",
		"output": "icon_skill_sovereign_pursuit_bc_24.png",
		"size": 24,
		"padding_ratio": 0.10,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"hard_pixel": true,
		"chroma_key": true,
		"atlas_index": 2,
	},
	{
		"source_root": KING_SKILL_SOURCE_ROOT,
		"source": "skill_4_worldsplitter_bc_source.png",
		"output": "icon_skill_worldsplitter_bc_24.png",
		"size": 24,
		"padding_ratio": 0.10,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"hard_pixel": true,
		"chroma_key": true,
		"atlas_index": 3,
	},
	{
		"source_root": ACTION_SOURCE_ROOT,
		"source": "basic_attack_bc_source.png",
		"size": 24,
		"padding_ratio": 0.10,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"hard_pixel": true,
		"chroma_key": true,
		"atlas_index": 4,
	},
	{
		"source_root": ACTION_SOURCE_ROOT,
		"source": "dodge_dash_bc_source.png",
		"size": 24,
		"padding_ratio": 0.10,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"hard_pixel": true,
		"chroma_key": true,
		"atlas_index": 5,
	},
	{
		"source": "cursor_royal_pointer_source.png",
		"output": "cursor_royal_pointer_generated_32.png",
		"size": 32,
		"padding_ratio": 0.02,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"cursor": true,
	},
	{
		"source": "cursor_royal_interact_source.png",
		"output": "cursor_royal_interact_generated_32.png",
		"size": 32,
		"padding_ratio": 0.02,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"cursor": true,
	},
	{
		"source": "cursor_royal_target_source.png",
		"output": "cursor_royal_target_generated_32.png",
		"size": 32,
		"padding_ratio": 0.02,
		"interpolation": Image.INTERPOLATE_NEAREST,
		"cursor": true,
	},
]

var _action_cells: Array[Image] = []


func _initialize() -> void:
	DirAccess.make_dir_recursive_absolute(
		ProjectSettings.globalize_path(ACTION_ATLAS_PATH.get_base_dir())
	)
	DirAccess.make_dir_recursive_absolute(ProjectSettings.globalize_path(CURSOR_OUTPUT_ROOT))
	_action_cells.resize(ACTION_CELL_COUNT)
	for job: Dictionary in JOBS:
		if not _prepare(job):
			quit(1)
			return
	if not _save_action_atlas():
		quit(1)
		return
	print("Generated combat UI runtime assets prepared.")
	quit(0)


func _prepare(job: Dictionary) -> bool:
	var source_path := str(job.get("source_root", SOURCE_ROOT)) + str(job.source)
	var source := Image.load_from_file(source_path)
	if source == null or source.is_empty():
		push_error("Could not load generated UI source: %s" % source_path)
		return false
	source.convert(Image.FORMAT_RGBA8)
	if bool(job.get("chroma_key", false)):
		_remove_magenta_chroma(source)
	var used_rect := source.get_used_rect()
	if used_rect.size.x <= 0 or used_rect.size.y <= 0:
		push_error("Generated UI source has no visible pixels: %s" % source_path)
		return false
	var cropped := source.get_region(used_rect)
	var content_edge := maxi(cropped.get_width(), cropped.get_height())
	var padding := ceili(content_edge * float(job.padding_ratio))
	var square_edge := content_edge + padding * 2
	var square := Image.create(square_edge, square_edge, false, Image.FORMAT_RGBA8)
	square.fill(Color(0.0, 0.0, 0.0, 0.0))
	var destination := Vector2i(
		(square_edge - cropped.get_width()) / 2,
		(square_edge - cropped.get_height()) / 2
	)
	square.blit_rect(cropped, Rect2i(Vector2i.ZERO, cropped.get_size()), destination)
	var output_size := int(job.size)
	if bool(job.get("hard_pixel", false)):
		# The generated source is authored as coarse pixel art on a larger canvas.
		# Normalize once at the declared 48 px logical grid before the final exact
		# 2:1 nearest reduction so thin silhouettes do not disappear by sampling.
		square.resize(output_size * 2, output_size * 2, Image.INTERPOLATE_LANCZOS)
		_apply_hard_pixel_palette(square)
		square.resize(output_size, output_size, Image.INTERPOLATE_NEAREST)
		_apply_hard_pixel_palette(square)
	else:
		square.resize(output_size, output_size, int(job.interpolation))
	if job.has("atlas_index"):
		_action_cells[int(job.atlas_index)] = square
		print("%s used=%s atlas_cell=%s" % [job.source, used_rect, job.atlas_index])
		return true
	var output_root := CURSOR_OUTPUT_ROOT
	var output_path := output_root + str(job.output)
	var error := square.save_png(output_path)
	if error != OK:
		push_error("Could not save generated UI runtime asset: %s" % output_path)
		return false
	print(
		"%s used=%s output=%s"
		% [job.source, used_rect, output_path]
	)
	return true


func _save_action_atlas() -> bool:
	var atlas := Image.create(
		ACTION_CELL_SIZE * ACTION_CELL_COUNT,
		ACTION_CELL_SIZE,
		false,
		Image.FORMAT_RGBA8
	)
	atlas.fill(Color.TRANSPARENT)
	for index in ACTION_CELL_COUNT:
		var cell := _action_cells[index]
		if cell == null or cell.get_size() != Vector2i(ACTION_CELL_SIZE, ACTION_CELL_SIZE):
			push_error("Combat action atlas is missing normalized cell %s." % index)
			return false
		atlas.blit_rect(
			cell,
			Rect2i(Vector2i.ZERO, Vector2i(ACTION_CELL_SIZE, ACTION_CELL_SIZE)),
			Vector2i(index * ACTION_CELL_SIZE, 0)
		)
	var error := atlas.save_png(ACTION_ATLAS_PATH)
	if error != OK:
		push_error("Could not save combat action atlas: %s" % ACTION_ATLAS_PATH)
		return false
	print("Saved six-cell combat action atlas: %s" % ACTION_ATLAS_PATH)
	return true


func _remove_magenta_chroma(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var color := image.get_pixel(x, y)
			if (
				color.r > 0.55
				and color.b > 0.55
				and color.r > color.g * 1.3
				and color.b > color.g * 1.3
			):
				image.set_pixel(x, y, Color.TRANSPARENT)


func _apply_hard_pixel_palette(image: Image) -> void:
	for y in image.get_height():
		for x in image.get_width():
			var source_color := image.get_pixel(x, y)
			if source_color.a < 0.5:
				image.set_pixel(x, y, Color.TRANSPARENT)
				continue
			var nearest: Color = KING_SKILL_PALETTE[0]
			var nearest_distance := INF
			for candidate: Color in KING_SKILL_PALETTE:
				var delta := Vector3(
					source_color.r - candidate.r,
					source_color.g - candidate.g,
					source_color.b - candidate.b
				)
				var distance := delta.length_squared()
				if distance < nearest_distance:
					nearest = candidate
					nearest_distance = distance
			image.set_pixel(x, y, Color(nearest.r, nearest.g, nearest.b, 1.0))
