"""Build the runtime Bramble Spitter atlas from the approved 4x4 source art."""

from __future__ import annotations

import argparse
from collections import deque
from pathlib import Path

from PIL import Image


CELL_COUNT = 4
RUNTIME_CELL_SIZE = 32
CONTENT_SIZE = 28


def _largest_component(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    width, height = image.size
    visible = alpha.load()
    visited: set[tuple[int, int]] = set()
    largest: list[tuple[int, int]] = []

    for y in range(height):
        for x in range(width):
            if visible[x, y] < 96 or (x, y) in visited:
                continue
            component: list[tuple[int, int]] = []
            queue = deque([(x, y)])
            visited.add((x, y))
            while queue:
                point = queue.popleft()
                component.append(point)
                px, py = point
                for nx, ny in ((px - 1, py), (px + 1, py), (px, py - 1), (px, py + 1)):
                    if 0 <= nx < width and 0 <= ny < height and visible[nx, ny] >= 96 and (nx, ny) not in visited:
                        visited.add((nx, ny))
                        queue.append((nx, ny))
            if len(component) > len(largest):
                largest = component

    if not largest:
        raise ValueError("Atlas cell has no visible subject.")

    xs = [point[0] for point in largest]
    ys = [point[1] for point in largest]
    padding = 4
    box = (
        max(min(xs) - padding, 0),
        max(min(ys) - padding, 0),
        min(max(xs) + padding + 1, width),
        min(max(ys) + padding + 1, height),
    )
    return image.crop(box)


def build_atlas(source_path: Path, output_path: Path) -> None:
    source = Image.open(source_path).convert("RGBA")
    atlas = Image.new("RGBA", (RUNTIME_CELL_SIZE * CELL_COUNT, RUNTIME_CELL_SIZE * CELL_COUNT))
    source_cell_width = source.width // CELL_COUNT
    source_cell_height = source.height // CELL_COUNT

    for row in range(CELL_COUNT):
        for column in range(CELL_COUNT):
            source_cell = source.crop((
                column * source_cell_width,
                row * source_cell_height,
                source.width if column == CELL_COUNT - 1 else (column + 1) * source_cell_width,
                source.height if row == CELL_COUNT - 1 else (row + 1) * source_cell_height,
            ))
            subject = _largest_component(source_cell)
            scale = min(CONTENT_SIZE / subject.width, CONTENT_SIZE / subject.height)
            size = (max(1, round(subject.width * scale)), max(1, round(subject.height * scale)))
            subject = subject.resize(size, Image.Resampling.NEAREST)

            # Hard alpha and a compact palette preserve the project's strict pixel-art baseline.
            pixels = subject.load()
            for y in range(subject.height):
                for x in range(subject.width):
                    red, green, blue, alpha = pixels[x, y]
                    pixels[x, y] = (red, green, blue, 255 if alpha >= 128 else 0)
            alpha = subject.getchannel("A")
            rgb = subject.convert("RGB").quantize(colors=24, method=Image.Quantize.MEDIANCUT, dither=Image.Dither.NONE).convert("RGB")
            subject = rgb.convert("RGBA")
            subject.putalpha(alpha)

            x = column * RUNTIME_CELL_SIZE + (RUNTIME_CELL_SIZE - subject.width) // 2
            y = row * RUNTIME_CELL_SIZE + RUNTIME_CELL_SIZE - subject.height - 2
            atlas.alpha_composite(subject, (x, y))

    output_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(output_path, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()
    build_atlas(args.source, args.output)


if __name__ == "__main__":
    main()
