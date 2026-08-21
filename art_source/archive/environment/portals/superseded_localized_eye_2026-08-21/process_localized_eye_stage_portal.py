"""Build independently looping vortex and lightning sheets for StagePortal.

Generated source masters contain a pale preview matte. This processor removes
that matte, normalizes the artwork to tintable grayscale, and creates two
seamless twelve-frame loops with deliberately different motion rhythms.
"""

from __future__ import annotations

import argparse
import math
import random
from pathlib import Path

import numpy as np
from PIL import Image, ImageChops, ImageDraw


FRAME_COUNT = 12
BASE_CELL = (192, 224)
FX_CELL = (320, 288)
ALPHA_LEVELS = np.array((0, 48, 72, 96, 120, 148, 176, 208, 232, 255), dtype=np.uint8)
NORMAL_TINT = np.array((117, 189, 255), dtype=np.float32)


def _remove_preview_matte(source_path: Path) -> Image.Image:
	"""Extract blue energy from the generated near-white preview background."""
	source = np.asarray(Image.open(source_path).convert("RGB"), dtype=np.int16)
	red = source[:, :, 0]
	green = source[:, :, 1]
	blue = source[:, :, 2]
	distance = np.maximum.reduce((255 - red, blue - red, green - red))
	alpha = np.clip((distance - 7) * 2.5, 0, 255).astype(np.uint8)
	alpha[alpha < 36] = 0

	y, x = np.nonzero(alpha > 0)
	if x.size == 0:
		raise ValueError(f"No portal pixels were extracted from {source_path}")
	pad = 12
	x0 = max(int(x.min()) - pad, 0)
	x1 = min(int(x.max()) + pad + 1, source.shape[1])
	y0 = max(int(y.min()) - pad, 0)
	y1 = min(int(y.max()) + pad + 1, source.shape[0])
	source = source[y0:y1, x0:x1]
	alpha = alpha[y0:y1, x0:x1]

	# Runtime tier tinting needs neutral values, while the broad value bands
	# preserve the authored tunnel depth and lightning hierarchy.
	value = np.clip(source.max(axis=2) * 1.06, 142, 255).astype(np.uint8)
	rgba = np.dstack((value, value, value, alpha))
	rgba[alpha == 0, :3] = 0
	return Image.fromarray(rgba, "RGBA")


def _fit(
	source: Image.Image,
	cell_size: tuple[int, int],
	fill: float,
	x_stretch: float = 1.0,
) -> Image.Image:
	cell_width, cell_height = cell_size
	scale = min(cell_width * fill / source.width, cell_height * fill / source.height)
	target = (
		max(1, min(cell_width, round(source.width * scale * x_stretch))),
		max(1, round(source.height * scale)),
	)
	resized = source.resize(target, Image.Resampling.LANCZOS)
	cell = Image.new("RGBA", cell_size, (0, 0, 0, 0))
	cell.alpha_composite(resized, ((cell_width - target[0]) // 2, (cell_height - target[1]) // 2))
	return cell


def _quantize_alpha(image: Image.Image) -> Image.Image:
	pixels = np.asarray(image).copy()
	alpha = pixels[:, :, 3]
	distance = np.abs(alpha[:, :, None].astype(np.int16) - ALPHA_LEVELS[None, None, :])
	pixels[:, :, 3] = ALPHA_LEVELS[distance.argmin(axis=2)]
	pixels[pixels[:, :, 3] == 0, :3] = 0
	return Image.fromarray(pixels, "RGBA")


def _ellipse_mask(
	size: tuple[int, int], radius_x: float, radius_y: float, center_y: float
) -> Image.Image:
	width, height = size
	y, x = np.mgrid[:height, :width]
	cx = (width - 1) * 0.5
	cy = center_y
	distance = ((x - cx) / radius_x) ** 2 + ((y - cy) / radius_y) ** 2
	mask = np.clip((1.08 - distance) * 760.0, 0, 255).astype(np.uint8)
	return Image.fromarray(mask, "L")


def _build_base_frames(source: Image.Image) -> list[Image.Image]:
	master = _fit(source, BASE_CELL, 0.91, 1.16)
	vortex_center = (BASE_CELL[0] * 0.5, 132.0)
	# Only the compact vortex eye rotates. The doorway, outer energy, and broad
	# interior bands remain fixed so the portal does not tumble as one object.
	interior_mask = _ellipse_mask(BASE_CELL, 35.0, 35.0, vortex_center[1])
	outer_mask = ImageChops.invert(interior_mask)
	frames: list[Image.Image] = []
	for index in range(FRAME_COUNT):
		phase = index / FRAME_COUNT
		rotated = master.rotate(
			-phase * 360.0,
			resample=Image.Resampling.BICUBIC,
			center=vortex_center,
		)
		outer = Image.new("RGBA", BASE_CELL, (0, 0, 0, 0))
		outer.paste(master, (0, 0), ImageChops.multiply(master.getchannel("A"), outer_mask))
		inner = Image.new("RGBA", BASE_CELL, (0, 0, 0, 0))
		inner_alpha = ImageChops.multiply(rotated.getchannel("A"), interior_mask)
		inner.paste(rotated, (0, 0), inner_alpha)
		frame = Image.alpha_composite(outer, inner)
		pixels = np.asarray(frame).copy()
		mask = np.asarray(interior_mask, dtype=np.float32) / 255.0
		pulse = 0.92 + 0.08 * math.sin(phase * math.tau)
		alpha_scale = 0.78 + mask * (0.72 * pulse - 0.78)
		pixels[:, :, 3] = np.clip(pixels[:, :, 3] * alpha_scale, 0, 255).astype(np.uint8)
		frames.append(_quantize_alpha(Image.fromarray(pixels, "RGBA")))
	return frames


def _lightning_path(
	start: tuple[float, float], end: tuple[float, float], seed: int
) -> list[tuple[int, int]]:
	rng = random.Random(seed)
	dx = end[0] - start[0]
	dy = end[1] - start[1]
	length = max(math.hypot(dx, dy), 1.0)
	perpendicular = (-dy / length, dx / length)
	points: list[tuple[int, int]] = []
	for sample in range(15):
		progress = sample / 14.0
		jitter = rng.uniform(-9.0, 9.0) * math.sin(progress * math.pi)
		points.append((
			round(start[0] + dx * progress + perpendicular[0] * jitter),
			round(start[1] + dy * progress + perpendicular[1] * jitter),
		))
	return points


def _build_fx_frames() -> list[Image.Image]:
	# These are sparse discharges across a deliberately oversized field—not a
	# second portal outline. Each bolt flashes outward and leaves a short echo.
	events = (
		(0, (111.0, 94.0), (7.0, 18.0)),
		(2, (209.0, 102.0), (314.0, 27.0)),
		(4, (108.0, 168.0), (3.0, 256.0)),
		(6, (212.0, 170.0), (316.0, 274.0)),
		(8, (146.0, 51.0), (69.0, 2.0)),
		(10, (178.0, 232.0), (268.0, 286.0)),
	)
	frames: list[Image.Image] = []
	for index in range(FRAME_COUNT):
		frame = Image.new("RGBA", FX_CELL, (0, 0, 0, 0))
		draw = ImageDraw.Draw(frame, "RGBA")
		for event_index, (start_frame, start, end) in enumerate(events):
			age = (index - start_frame) % FRAME_COUNT
			if age > 2:
				continue
			strength = (255, 150, 64)[age]
			path = _lightning_path(start, end, event_index * 97 + age * 13)
			draw.line(path, fill=(205, 205, 205, max(24, strength // 4)), width=5)
			draw.line(path, fill=(255, 255, 255, strength), width=1)
			if age <= 1:
				branch_start = path[7]
				branch_end = (
					branch_start[0] + round((end[0] - start[0]) * 0.22),
					branch_start[1] - round((end[1] - start[1]) * 0.18),
				)
				branch = _lightning_path(branch_start, branch_end, event_index * 131 + age)
				draw.line(branch, fill=(238, 238, 238, strength // 2), width=1)

		# Motes travel through the same far field, giving the large overlap a
		# continuous presence while individual lightning bolts remain brief.
		phase = index / FRAME_COUNT
		for particle_index in range(24):
			rng = random.Random(4000 + particle_index)
			angle = rng.uniform(0.0, math.tau) + phase * math.tau * rng.uniform(0.08, 0.2)
			radius = 62.0 + ((rng.uniform(0.0, 112.0) + phase * 72.0) % 112.0)
			x = round(FX_CELL[0] * 0.5 + math.cos(angle) * radius)
			y = round(FX_CELL[1] * 0.5 + math.sin(angle) * radius * 0.72)
			alpha = 96 + (particle_index % 4) * 32
			size = 1 + (particle_index % 3 == 0)
			draw.rectangle((x, y, x + size, y + size), fill=(235, 235, 235, alpha))
			if particle_index % 5 == 0:
				draw.line((x - 3, y, x + 3, y), fill=(210, 210, 210, alpha // 2), width=1)
		frames.append(_quantize_alpha(frame))
	return frames


def _save_sheet(frames: list[Image.Image], output_path: Path) -> None:
	cell_width, cell_height = frames[0].size
	sheet = Image.new("RGBA", (cell_width * len(frames), cell_height), (0, 0, 0, 0))
	for index, frame in enumerate(frames):
		sheet.alpha_composite(frame, (index * cell_width, 0))
	output_path.parent.mkdir(parents=True, exist_ok=True)
	sheet.save(output_path, optimize=True)


def _normal_tint(image: Image.Image) -> Image.Image:
	pixels = np.asarray(image).copy()
	pixels[:, :, :3] = np.clip(
		pixels[:, :, :3].astype(np.float32) * NORMAL_TINT[None, None, :] / 255.0,
		0,
		255,
	).astype(np.uint8)
	return Image.fromarray(pixels, "RGBA")


def _save_preview(
	base_frames: list[Image.Image], fx_frames: list[Image.Image], output_path: Path
) -> None:
	preview_cell = FX_CELL
	preview = Image.new("RGBA", (preview_cell[0] * 4, preview_cell[1] * 3), (12, 18, 32, 255))
	animated_frames: list[Image.Image] = []
	for index, (base, fx) in enumerate(zip(base_frames, fx_frames)):
		cell = Image.new("RGBA", preview_cell, (12, 18, 32, 255))
		cell.alpha_composite(
			_normal_tint(base),
			((preview_cell[0] - BASE_CELL[0]) // 2, (preview_cell[1] - BASE_CELL[1]) // 2),
		)
		cell.alpha_composite(_normal_tint(fx))
		preview.alpha_composite(cell, ((index % 4) * preview_cell[0], (index // 4) * preview_cell[1]))
		gameplay_preview = Image.new("RGBA", (448, 320), (12, 18, 32, 255))
		gameplay_preview.alpha_composite(cell, ((448 - preview_cell[0]) // 2, 32))
		animated_frames.append(gameplay_preview.convert("RGB"))
	output_path.parent.mkdir(parents=True, exist_ok=True)
	preview.save(output_path, optimize=True)
	animated_output = output_path.with_name("portal_layers_12frame_animated_review.gif")
	animated_frames[0].save(
		animated_output,
		save_all=True,
		append_images=animated_frames[1:],
		duration=110,
		loop=0,
		optimize=False,
	)


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("base_source", type=Path)
	parser.add_argument("base_output", type=Path)
	parser.add_argument("fx_output", type=Path)
	parser.add_argument("preview_output", type=Path)
	args = parser.parse_args()

	base_frames = _build_base_frames(_remove_preview_matte(args.base_source))
	fx_frames = _build_fx_frames()
	_save_sheet(base_frames, args.base_output)
	_save_sheet(fx_frames, args.fx_output)
	_save_preview(base_frames, fx_frames, args.preview_output)


if __name__ == "__main__":
	main()
