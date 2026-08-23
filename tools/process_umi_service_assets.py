#!/usr/bin/env python3
"""Build deterministic Umi dialogue and Echo Crucible runtime assets."""

from __future__ import annotations

from collections import deque
from pathlib import Path
import argparse

import numpy as np
from PIL import Image


def content_bbox(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = np.asarray(image.getchannel("A"))
    ys, xs = np.nonzero(alpha > 8)
    if xs.size == 0:
        raise ValueError("No foreground content found")
    return int(xs.min()), int(ys.min()), int(xs.max() + 1), int(ys.max() + 1)


def remove_connected_light_background(image: Image.Image) -> Image.Image:
    """Remove the generated white/gray checker only when connected to an edge."""
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgb = rgba[:, :, :3].astype(np.int16)
    spread = rgb.max(axis=2) - rgb.min(axis=2)
    candidate = (rgb.min(axis=2) > 150) & (spread < 30)
    height, width = candidate.shape
    outside = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for x in range(width):
        for y in (0, height - 1):
            if candidate[y, x] and not outside[y, x]:
                outside[y, x] = True
                queue.append((y, x))
    for y in range(height):
        for x in (0, width - 1):
            if candidate[y, x] and not outside[y, x]:
                outside[y, x] = True
                queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for y_offset in (-1, 0, 1):
            for x_offset in (-1, 0, 1):
                if y_offset == 0 and x_offset == 0:
                    continue
                ny, nx = y + y_offset, x + x_offset
                if 0 <= ny < height and 0 <= nx < width and candidate[ny, nx] and not outside[ny, nx]:
                    outside[ny, nx] = True
                    queue.append((ny, nx))
    rgba[outside, :3] = 0
    rgba[outside, 3] = 0
    return Image.fromarray(rgba.astype(np.uint8), "RGBA")


def keep_largest_alpha_component(image: Image.Image) -> Image.Image:
    """Discard detached generation debris while preserving the main prop."""
    rgba = np.asarray(image.convert("RGBA")).copy()
    solid = rgba[:, :, 3] > 8
    height, width = solid.shape
    visited = np.zeros((height, width), dtype=bool)
    largest: list[tuple[int, int]] = []
    for start_y in range(height):
        for start_x in range(width):
            if not solid[start_y, start_x] or visited[start_y, start_x]:
                continue
            component: list[tuple[int, int]] = []
            queue: deque[tuple[int, int]] = deque([(start_y, start_x)])
            visited[start_y, start_x] = True
            while queue:
                y, x = queue.popleft()
                component.append((y, x))
                for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
                    if 0 <= ny < height and 0 <= nx < width and solid[ny, nx] and not visited[ny, nx]:
                        visited[ny, nx] = True
                        queue.append((ny, nx))
            if len(component) > len(largest):
                largest = component
    keep = np.zeros((height, width), dtype=bool)
    for y, x in largest:
        keep[y, x] = True
    rgba[~keep, :3] = 0
    rgba[~keep, 3] = 0
    return Image.fromarray(rgba.astype(np.uint8), "RGBA")


def remove_connected_cyan_background(image: Image.Image) -> Image.Image:
    """Remove only edge-connected chroma cyan from generated prop sources."""
    rgba = np.asarray(image.convert("RGBA")).copy()
    rgb = rgba[:, :, :3].astype(np.int16)
    candidate = (
        (rgb[:, :, 0] < 90)
        & (rgb[:, :, 1] > 145)
        & (rgb[:, :, 2] > 165)
        & (np.abs(rgb[:, :, 1] - rgb[:, :, 2]) < 120)
    )
    height, width = candidate.shape
    outside = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()
    for x in range(width):
        for y in (0, height - 1):
            if candidate[y, x] and not outside[y, x]:
                outside[y, x] = True
                queue.append((y, x))
    for y in range(height):
        for x in (0, width - 1):
            if candidate[y, x] and not outside[y, x]:
                outside[y, x] = True
                queue.append((y, x))
    while queue:
        y, x = queue.popleft()
        for ny, nx in ((y - 1, x), (y + 1, x), (y, x - 1), (y, x + 1)):
            if 0 <= ny < height and 0 <= nx < width and candidate[ny, nx] and not outside[ny, nx]:
                outside[ny, nx] = True
                queue.append((ny, nx))
    rgba[outside, :3] = 0
    rgba[outside, 3] = 0
    return Image.fromarray(rgba.astype(np.uint8), "RGBA")


def fit_to_canvas(source: Image.Image, size: tuple[int, int], margin: int, bottom_margin: int) -> Image.Image:
    crop = source.crop(content_bbox(source))
    max_width = size[0] - margin * 2
    max_height = size[1] - margin - bottom_margin
    scale = min(max_width / crop.width, max_height / crop.height)
    fitted = crop.resize(
        (max(1, round(crop.width * scale)), max(1, round(crop.height * scale))),
        Image.Resampling.NEAREST,
    )
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    canvas.alpha_composite(fitted, ((size[0] - fitted.width) // 2, size[1] - bottom_margin - fitted.height))
    return canvas


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--portrait-source", type=Path, required=True)
    parser.add_argument("--station-source", type=Path, required=True)
    parser.add_argument("--portrait-output", type=Path, required=True)
    parser.add_argument("--station-output", type=Path, required=True)
    parser.add_argument("--review-dir", type=Path, required=True)
    args = parser.parse_args()

    portrait_source = remove_connected_light_background(Image.open(args.portrait_source))
    portrait = fit_to_canvas(portrait_source, (96, 96), 1, 0)
    station_source = keep_largest_alpha_component(remove_connected_cyan_background(Image.open(args.station_source)))
    station = fit_to_canvas(station_source, (72, 64), 1, 1)

    args.portrait_output.parent.mkdir(parents=True, exist_ok=True)
    args.station_output.parent.mkdir(parents=True, exist_ok=True)
    args.review_dir.mkdir(parents=True, exist_ok=True)
    portrait.save(args.portrait_output)
    station.save(args.station_output)
    portrait.resize((384, 384), Image.Resampling.NEAREST).save(args.review_dir / "umi_dialogue_portrait_4x.png")
    station.resize((432, 384), Image.Resampling.NEAREST).save(args.review_dir / "umi_echo_crucible_workbench_6x.png")


if __name__ == "__main__":
    main()
