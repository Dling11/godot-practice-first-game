from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "art_source/cleaned/characters/enemies/stage_4_armored_hog"
RUNTIME_DIR = ROOT / "assets/characters/enemies/stage_4_armored_hog"
REVIEW_DIR = ROOT / "art_source/review/characters/enemies/stage_4_armored_hog"

SOURCES = {
    "locomotion": (SOURCE_DIR / "armored_hog_locomotion_clean_v1.png", 4),
    "charge": (SOURCE_DIR / "armored_hog_charge_clean_v2.png", 6),
    "reaction": (SOURCE_DIR / "armored_hog_reaction_clean_v2.png", 6),
}
ROWS = 4
CELL_W = 64
CELL_H = 48
MAX_ACTOR_W = 60
MAX_ACTOR_H = 44
FOOT_MARGIN = 2


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


def extract_frames(source_path: Path, columns: int) -> list[Image.Image]:
    source = Image.open(source_path).convert("RGBA")
    x_edges = [round(index * source.width / columns) for index in range(columns + 1)]
    y_edges = [round(index * source.height / ROWS) for index in range(ROWS + 1)]
    frames: list[Image.Image] = []
    for row in range(ROWS):
        for col in range(columns):
            frame = source.crop((x_edges[col], y_edges[row], x_edges[col + 1], y_edges[row + 1]))
            array = np.array(frame)
            component = largest_component(array[:, :, 3] >= 128)
            array[:, :, 3] = np.where(component, 255, 0).astype(np.uint8)
            frame = Image.fromarray(array, "RGBA")
            bbox = frame.getbbox()
            if bbox is None:
                raise RuntimeError(f"Empty frame {row},{col} in {source_path.name}")
            frames.append(frame.crop(bbox))
    return frames


def checkerboard(size: tuple[int, int], scale: int = 4) -> Image.Image:
    width, height = size[0] * scale, size[1] * scale
    image = Image.new("RGBA", (width, height))
    pixels = image.load()
    colors = ((34, 45, 37, 255), (49, 61, 50, 255))
    tile = 8 * scale
    for y in range(height):
        for x in range(width):
            pixels[x, y] = colors[((x // tile) + (y // tile)) % 2]
    return image


def main() -> None:
    families: dict[str, tuple[list[Image.Image], int]] = {}
    max_width = 0
    max_height = 0
    for name, (source_path, columns) in SOURCES.items():
        frames = extract_frames(source_path, columns)
        families[name] = (frames, columns)
        max_width = max(max_width, *(frame.width for frame in frames))
        max_height = max(max_height, *(frame.height for frame in frames))
    scale = min(MAX_ACTOR_W / max_width, MAX_ACTOR_H / max_height)
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)

    for name, (frames, columns) in families.items():
        atlas = Image.new("RGBA", (CELL_W * columns, CELL_H * ROWS), (0, 0, 0, 0))
        for index, frame in enumerate(frames):
            size = (max(1, round(frame.width * scale)), max(1, round(frame.height * scale)))
            normalized = frame.resize(size, Image.Resampling.NEAREST)
            alpha = np.array(normalized.getchannel("A"))
            normalized.putalpha(Image.fromarray(np.where(alpha >= 128, 255, 0).astype(np.uint8), "L"))
            col = index % columns
            row = index // columns
            x = col * CELL_W + (CELL_W - normalized.width) // 2
            y = row * CELL_H + CELL_H - FOOT_MARGIN - normalized.height
            if x < col * CELL_W or x + normalized.width > (col + 1) * CELL_W or y < row * CELL_H:
                raise RuntimeError(f"{name} frame {row},{col} exceeds its 64x48 cell")
            atlas.alpha_composite(normalized, (x, y))
        runtime_path = RUNTIME_DIR / f"armored_hog_{name}_sheet_64x48.png"
        atlas.save(runtime_path)
        review = checkerboard(atlas.size)
        review.alpha_composite(atlas.resize(review.size, Image.Resampling.NEAREST))
        review.save(REVIEW_DIR / f"armored_hog_{name}_runtime_review.png")
        print(f"Wrote {runtime_path.relative_to(ROOT)} ({atlas.width}x{atlas.height})")
    print(f"Shared scale: {scale:.5f}; maximum source frame: {max_width}x{max_height}")


if __name__ == "__main__":
    main()
