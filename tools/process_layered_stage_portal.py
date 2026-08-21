"""Normalize generated 4x4 portal boards into two transparent runtime loops."""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image


FRAME_COUNT = 16
GRID_SIZE = 4
BASE_CELL = (160, 192)
FX_CELL = (256, 224)
ALPHA_LEVELS = np.array((0, 48, 72, 96, 120, 148, 176, 208, 232, 255), dtype=np.uint8)
NORMAL_TINT = np.array((117, 189, 255), dtype=np.float32)


def _extract_energy(cell: np.ndarray) -> Image.Image:
	"""Remove the generated pale checker matte while retaining blue-white energy."""
	pixels = cell.astype(np.int16)
	red = pixels[:, :, 0]
	green = pixels[:, :, 1]
	blue = pixels[:, :, 2]
	distance = np.maximum.reduce((255 - red, blue - red, green - red))
	alpha = np.clip((distance - 7) * 2.6, 0, 255).astype(np.uint8)
	alpha[alpha < 32] = 0
	value = np.clip(pixels.max(axis=2) * 1.06, 138, 255).astype(np.uint8)
	rgba = np.dstack((value, value, value, alpha))
	rgba[alpha == 0, :3] = 0
	return Image.fromarray(rgba, "RGBA")


def _split_board(board_path: Path) -> list[Image.Image]:
	board = np.asarray(Image.open(board_path).convert("RGB"))
	height, width = board.shape[:2]
	x_bounds = [round(index * width / GRID_SIZE) for index in range(GRID_SIZE + 1)]
	y_bounds = [round(index * height / GRID_SIZE) for index in range(GRID_SIZE + 1)]
	frames: list[Image.Image] = []
	for frame_index in range(FRAME_COUNT):
		column = frame_index % GRID_SIZE
		row = frame_index // GRID_SIZE
		cell = board[
			y_bounds[row]:y_bounds[row + 1],
			x_bounds[column]:x_bounds[column + 1],
		]
		frames.append(_extract_energy(cell))
	return frames


def _content_crop(frame: Image.Image) -> Image.Image:
	alpha = np.asarray(frame.getchannel("A"))
	y, x = np.nonzero(alpha > 0)
	if x.size == 0:
		raise ValueError("Generated portal board contains an empty frame.")
	padding = 4
	box = (
		max(int(x.min()) - padding, 0),
		max(int(y.min()) - padding, 0),
		min(int(x.max()) + padding + 1, frame.width),
		min(int(y.max()) + padding + 1, frame.height),
	)
	return frame.crop(box)


def _normalize_frames(
	frames: list[Image.Image],
	cell_size: tuple[int, int],
	fill: float,
	lock_visual_center: bool = False,
) -> list[Image.Image]:
	crops = [_content_crop(frame) for frame in frames]
	stage_size = (
		max(crop.width for crop in crops),
		max(crop.height for crop in crops),
	)
	staged: list[Image.Image] = []
	for crop in crops:
		stage = Image.new("RGBA", stage_size, (0, 0, 0, 0))
		stage.alpha_composite(
			crop,
			((stage_size[0] - crop.width) // 2, (stage_size[1] - crop.height) // 2),
		)
		staged.append(stage)
	scale = min(cell_size[0] * fill / stage_size[0], cell_size[1] * fill / stage_size[1])
	target_size = (round(stage_size[0] * scale), round(stage_size[1] * scale))
	result: list[Image.Image] = []
	for stage in staged:
		resized = stage.resize(target_size, Image.Resampling.LANCZOS)
		cell = Image.new("RGBA", cell_size, (0, 0, 0, 0))
		position = (
			(cell_size[0] - target_size[0]) // 2,
			(cell_size[1] - target_size[1]) // 2,
		)
		if lock_visual_center:
			alpha = np.asarray(resized.getchannel("A"), dtype=np.float64)
			weights = np.square(alpha / 255.0)
			weight_total = weights.sum()
			if weight_total > 0.0:
				y, x = np.indices(weights.shape)
				visual_center = (
					float((x * weights).sum() / weight_total),
					float((y * weights).sum() / weight_total),
				)
				position = (
					round(cell_size[0] * 0.5 - visual_center[0]),
					round(cell_size[1] * 0.5 - visual_center[1]),
				)
		cell.alpha_composite(
			resized,
			position,
		)
		result.append(cell)
	return result


def _erode(mask: np.ndarray) -> np.ndarray:
	padded = np.pad(mask, 1, constant_values=False)
	eroded = mask.copy()
	for offset_y in range(3):
		for offset_x in range(3):
			eroded &= padded[offset_y:offset_y + mask.shape[0], offset_x:offset_x + mask.shape[1]]
	return eroded


def _quantize_alpha(image: Image.Image, base_layer: bool) -> Image.Image:
	pixels = np.asarray(image).copy()
	alpha = pixels[:, :, 3]
	if base_layer:
		content = alpha >= 32
		interior = _erode(content)
		boundary = content & ~interior
		alpha[interior] = np.minimum((alpha[interior] * 0.78).astype(np.uint8), 208)
		alpha[boundary] = np.maximum(alpha[boundary], 232)
	distance = np.abs(alpha[:, :, None].astype(np.int16) - ALPHA_LEVELS[None, None, :])
	pixels[:, :, 3] = ALPHA_LEVELS[distance.argmin(axis=2)]
	pixels[pixels[:, :, 3] == 0, :3] = 0
	return Image.fromarray(pixels, "RGBA")


def _prepare_base(board_path: Path) -> list[Image.Image]:
	return [
		_quantize_alpha(frame, True)
		for frame in _normalize_frames(
			_split_board(board_path), BASE_CELL, 0.9, lock_visual_center=True
		)
	]


def _prepare_fx(board_path: Path) -> list[Image.Image]:
	return [
		_quantize_alpha(frame, False)
		for frame in _normalize_frames(_split_board(board_path), FX_CELL, 0.96)
	]


def _save_sheet(frames: list[Image.Image], output_path: Path) -> None:
	cell_width, cell_height = frames[0].size
	sheet = Image.new("RGBA", (cell_width * FRAME_COUNT, cell_height), (0, 0, 0, 0))
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


def _compose(base: Image.Image, fx: Image.Image, canvas_size: tuple[int, int]) -> Image.Image:
	canvas = Image.new("RGBA", canvas_size, (12, 18, 32, 255))
	canvas.alpha_composite(
		_normal_tint(base),
		((canvas_size[0] - BASE_CELL[0]) // 2, (canvas_size[1] - BASE_CELL[1]) // 2),
	)
	canvas.alpha_composite(
		_normal_tint(fx),
		((canvas_size[0] - FX_CELL[0]) // 2, (canvas_size[1] - FX_CELL[1]) // 2),
	)
	return canvas


def _save_reviews(
	base_frames: list[Image.Image], fx_frames: list[Image.Image], output_path: Path
) -> None:
	cell_size = (288, 240)
	review = Image.new("RGBA", (cell_size[0] * 4, cell_size[1] * 4), (12, 18, 32, 255))
	animated: list[Image.Image] = []
	for index, (base, fx) in enumerate(zip(base_frames, fx_frames)):
		cell = _compose(base, fx, cell_size)
		review.alpha_composite(cell, ((index % 4) * cell_size[0], (index // 4) * cell_size[1]))
		animated.append(_compose(base, fx, (448, 320)).convert("RGB"))
	output_path.parent.mkdir(parents=True, exist_ok=True)
	review.save(output_path, optimize=True)
	animated[0].save(
		output_path.with_name("abyssal_veil_16frame_animated_review.gif"),
		save_all=True,
		append_images=animated[1:],
		duration=95,
		loop=0,
		optimize=False,
	)


def main() -> None:
	parser = argparse.ArgumentParser()
	parser.add_argument("base_board", type=Path)
	parser.add_argument("fx_board", type=Path)
	parser.add_argument("base_output", type=Path)
	parser.add_argument("fx_output", type=Path)
	parser.add_argument("review_output", type=Path)
	args = parser.parse_args()

	base_frames = _prepare_base(args.base_board)
	fx_frames = _prepare_fx(args.fx_board)
	_save_sheet(base_frames, args.base_output)
	_save_sheet(fx_frames, args.fx_output)
	_save_reviews(base_frames, fx_frames, args.review_output)


if __name__ == "__main__":
	main()
