from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/cleaned/characters/enemies/stage_4_armored_beast/armored_beast_locomotion_clean_v2.png"
RUNTIME = ROOT / "assets/characters/enemies/stage_4_armored_beast/armored_beast_locomotion_sheet_64x48.png"
REVIEW = ROOT / "art_source/review/characters/enemies/stage_4_armored_beast/armored_beast_locomotion_runtime_review.png"

COLS = 4
ROWS = 4
CELL_W = 64
CELL_H = 48
MAX_ACTOR_W = 58
MAX_ACTOR_H = 44
FOOT_Y = 46


def largest_component(mask: np.ndarray) -> np.ndarray:
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    best: list[tuple[int, int]] = []
    for y in range(height):
        for x in range(width):
            if not mask[y, x] or visited[y, x]:
                continue
            queue = deque([(x, y)])
            visited[y, x] = True
            component: list[tuple[int, int]] = []
            while queue:
                current_x, current_y = queue.popleft()
                component.append((current_x, current_y))
                for next_y in range(max(0, current_y - 1), min(height, current_y + 2)):
                    for next_x in range(max(0, current_x - 1), min(width, current_x + 2)):
                        if mask[next_y, next_x] and not visited[next_y, next_x]:
                            visited[next_y, next_x] = True
                            queue.append((next_x, next_y))
            if len(component) > len(best):
                best = component
    result = np.zeros_like(mask, dtype=bool)
    for x, y in best:
        result[y, x] = True
    return result


def checkerboard(size: tuple[int, int], scale: int = 4) -> Image.Image:
    width, height = size
    image = Image.new("RGBA", (width * scale, height * scale), (28, 34, 30, 255))
    pixels = image.load()
    tile = 8 * scale
    colors = ((35, 47, 38, 255), (53, 64, 49, 255))
    for y in range(image.height):
        for x in range(image.width):
            pixels[x, y] = colors[((x // tile) + (y // tile)) % 2]
    return image


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    x_edges = [round(index * source.width / COLS) for index in range(COLS + 1)]
    y_edges = [round(index * source.height / ROWS) for index in range(ROWS + 1)]
    cropped: list[Image.Image] = []
    bounds: list[tuple[int, int]] = []

    for row in range(ROWS):
        for col in range(COLS):
            frame = source.crop((x_edges[col], y_edges[row], x_edges[col + 1], y_edges[row + 1]))
            array = np.array(frame)
            component = largest_component(array[:, :, 3] >= 128)
            array[:, :, 3] = np.where(component, 255, 0).astype(np.uint8)
            frame = Image.fromarray(array, "RGBA")
            bbox = frame.getbbox()
            if bbox is None:
                raise RuntimeError(f"Empty source frame at row {row}, column {col}")
            frame = frame.crop(bbox)
            cropped.append(frame)
            bounds.append(frame.size)

    max_width = max(width for width, _height in bounds)
    max_height = max(height for _width, height in bounds)
    scale = min(MAX_ACTOR_W / max_width, MAX_ACTOR_H / max_height)
    atlas = Image.new("RGBA", (CELL_W * COLS, CELL_H * ROWS), (0, 0, 0, 0))

    for index, frame in enumerate(cropped):
        target_size = (
            max(1, round(frame.width * scale)),
            max(1, round(frame.height * scale)),
        )
        frame = frame.resize(target_size, Image.Resampling.NEAREST)
        alpha = np.array(frame.getchannel("A"))
        frame.putalpha(Image.fromarray(np.where(alpha >= 128, 255, 0).astype(np.uint8), "L"))
        col = index % COLS
        row = index // COLS
        x = col * CELL_W + (CELL_W - frame.width) // 2
        y = row * CELL_H + FOOT_Y - frame.height
        if x < col * CELL_W or x + frame.width > (col + 1) * CELL_W or y < row * CELL_H:
            raise RuntimeError(f"Normalized frame {index} exceeds its runtime cell")
        atlas.alpha_composite(frame, (x, y))

    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    REVIEW.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(RUNTIME)
    review = checkerboard(atlas.size)
    review.alpha_composite(atlas.resize(review.size, Image.Resampling.NEAREST))
    review.save(REVIEW)
    print(f"Wrote {RUNTIME.relative_to(ROOT)} ({atlas.width}x{atlas.height})")
    print(f"Shared scale: {scale:.4f}; largest clean source frame: {max_width}x{max_height}")


if __name__ == "__main__":
    main()
