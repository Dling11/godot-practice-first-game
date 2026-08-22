#!/usr/bin/env python3
"""Normalize Umi's approved generated boards into deterministic runtime assets."""

from __future__ import annotations

from collections import deque
from pathlib import Path
import argparse

import numpy as np
from PIL import Image


def remove_connected_cyan(image: Image.Image) -> Image.Image:
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgb = rgba[:, :, :3]
    candidate = (
        (rgb[:, :, 0] < 72)
        & (rgb[:, :, 1] > 155)
        & (rgb[:, :, 2] > 175)
        & (np.abs(rgb[:, :, 1].astype(int) - rgb[:, :, 2].astype(int)) < 105)
    )
    height, width = candidate.shape
    outside = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for x in range(width):
        if candidate[0, x]:
            outside[0, x] = True
            queue.append((0, x))
        if candidate[height - 1, x]:
            outside[height - 1, x] = True
            queue.append((height - 1, x))
    for y in range(height):
        if candidate[y, 0]:
            outside[y, 0] = True
            queue.append((y, 0))
        if candidate[y, width - 1]:
            outside[y, width - 1] = True
            queue.append((y, width - 1))
    while queue:
        y, x = queue.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < height and 0 <= nx < width and candidate[ny, nx] and not outside[ny, nx]:
                outside[ny, nx] = True
                queue.append((ny, nx))
    rgba[outside, 3] = 0
    rgba[~outside, 3] = 255
    rgba[outside, :3] = 0
    return Image.fromarray(rgba, "RGBA")


def content_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = np.asarray(image.getchannel("A"))
    ys, xs = np.nonzero(alpha > 0)
    if xs.size == 0:
        raise ValueError("No foreground content found after chroma removal")
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def fit_frame(source: Image.Image, cell_size: int = 48, max_height: int = 34, max_width: int = 44) -> Image.Image:
    crop = source.crop(content_bbox(source))
    scale = min(max_width / crop.width, max_height / crop.height)
    width = max(1, round(crop.width * scale))
    height = max(1, round(crop.height * scale))
    crop = crop.resize((width, height), Image.Resampling.NEAREST)
    cell = Image.new("RGBA", (cell_size, cell_size), (0, 0, 0, 0))
    cell.alpha_composite(crop, ((cell_size - width) // 2, cell_size - 3 - height))
    return cell


def build_sheet(source_path: Path, output_path: Path) -> None:
    board = remove_connected_cyan(Image.open(source_path))
    width, height = board.size
    sheet = Image.new("RGBA", (48 * 4, 48 * 2), (0, 0, 0, 0))
    for row in range(2):
        for column in range(4):
            left = round(width * column / 4)
            right = round(width * (column + 1) / 4)
            top = round(height * row / 2)
            bottom = round(height * (row + 1) / 2)
            frame = fit_frame(board.crop((left, top, right, bottom)))
            sheet.alpha_composite(frame, (column * 48, row * 48))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path)


def build_portrait(concept_path: Path, output_path: Path) -> None:
    board = remove_connected_cyan(Image.open(concept_path))
    width, height = board.size
    frame = board.crop((0, 0, round(width / 4), round(height / 2)))
    frame = frame.crop(content_bbox(frame))
    scale = min(88 / frame.width, 88 / frame.height)
    frame = frame.resize((round(frame.width * scale), round(frame.height * scale)), Image.Resampling.NEAREST)
    portrait = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    portrait.alpha_composite(frame, ((96 - frame.width) // 2, 94 - frame.height))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    portrait.save(output_path)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--side-source", type=Path, required=True)
    parser.add_argument("--concept-source", type=Path, required=True)
    parser.add_argument("--asset-dir", type=Path, required=True)
    parser.add_argument("--review-dir", type=Path, required=True)
    args = parser.parse_args()
    sheet_path = args.asset_dir / "umi_side_service_sheet_48x48.png"
    portrait_path = args.asset_dir / "umi_portrait_96x96.png"
    build_sheet(args.side_source, sheet_path)
    build_portrait(args.concept_source, portrait_path)
    args.review_dir.mkdir(parents=True, exist_ok=True)
    sheet = Image.open(sheet_path)
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.Resampling.NEAREST).save(
        args.review_dir / "umi_side_service_sheet_4x.png"
    )


if __name__ == "__main__":
    main()
