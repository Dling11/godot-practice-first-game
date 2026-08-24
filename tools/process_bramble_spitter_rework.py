from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "art_source/generated/characters/enemies/bramble_spitter_rework"
RUNTIME_DIR = ROOT / "assets/characters/enemies/bramble_spitter"
REVIEW_DIR = ROOT / "art_source/review/characters/enemies/bramble_spitter_rework"

DIRECTIONS = ("down", "left", "right", "up")


def _is_background(pixel: np.ndarray) -> bool:
    red, green, blue = (int(value) for value in pixel[:3])
    is_magenta = red >= 180 and blue >= 145 and green <= 90
    is_black = red <= 18 and green <= 18 and blue <= 18
    return is_magenta or is_black


def remove_border_background(image: Image.Image) -> Image.Image:
    array = np.array(image.convert("RGBA"))
    height, width = array.shape[:2]
    background = np.zeros((height, width), dtype=bool)
    queue: deque[tuple[int, int]] = deque()

    def enqueue(x: int, y: int) -> None:
        if not background[y, x] and _is_background(array[y, x]):
            background[y, x] = True
            queue.append((x, y))

    for x in range(width):
        enqueue(x, 0)
        enqueue(x, height - 1)
    for y in range(height):
        enqueue(0, y)
        enqueue(width - 1, y)
    while queue:
        x, y = queue.popleft()
        for next_x, next_y in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
            if 0 <= next_x < width and 0 <= next_y < height:
                enqueue(next_x, next_y)
    array[background, 3] = 0
    return Image.fromarray(array, "RGBA")


def largest_component(image: Image.Image) -> Image.Image:
    array = np.array(image.convert("RGBA"))
    mask = array[:, :, 3] >= 128
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    best: list[tuple[int, int]] = []
    for y in range(height):
        for x in range(width):
            if not mask[y, x] or visited[y, x]:
                continue
            visited[y, x] = True
            queue = deque([(x, y)])
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
    if not best:
        raise RuntimeError("Generated cell contains no connected sprite pixels.")
    cleaned = np.zeros_like(array)
    for x, y in best:
        cleaned[y, x] = array[y, x]
        cleaned[y, x, 3] = 255
    result = Image.fromarray(cleaned, "RGBA")
    bounds = result.getbbox()
    if bounds is None:
        raise RuntimeError("Generated cell became empty after cleanup.")
    return result.crop(bounds)


def extract_equal_cells(source_name: str, rows: int, columns: int) -> list[Image.Image]:
    source = remove_border_background(Image.open(SOURCE_DIR / source_name))
    x_edges = [round(index * source.width / columns) for index in range(columns + 1)]
    y_edges = [round(index * source.height / rows) for index in range(rows + 1)]
    frames: list[Image.Image] = []
    for row in range(rows):
        for column in range(columns):
            cell = source.crop(
                (x_edges[column], y_edges[row], x_edges[column + 1], y_edges[row + 1])
            )
            frames.append(largest_component(cell))
    return frames


def normalize(frame: Image.Image, maximum_width: int, maximum_height: int) -> Image.Image:
    scale = min(maximum_width / frame.width, maximum_height / frame.height)
    resized = frame.resize(
        (max(1, round(frame.width * scale)), max(1, round(frame.height * scale))),
        Image.Resampling.NEAREST,
    )
    alpha = np.array(resized.getchannel("A"))
    resized.putalpha(Image.fromarray(np.where(alpha >= 128, 255, 0).astype(np.uint8), "L"))
    return resized


def place_on_cell(frame: Image.Image, size: tuple[int, int], foot_y: int) -> Image.Image:
    cell = Image.new("RGBA", size, (0, 0, 0, 0))
    x = (size[0] - frame.width) // 2
    y = foot_y - frame.height
    cell.alpha_composite(frame, (x, y))
    return cell


def build_body_sheets() -> None:
    locomotion_board = extract_equal_cells("bramble_locomotion_reaction_source.png", 4, 8)
    down_strip = extract_equal_cells("bramble_locomotion_down_source.png", 1, 8)
    locomotion_rows = {
        "down": down_strip,
        "left": locomotion_board[8:16],
        "right": locomotion_board[16:24],
        "up": locomotion_board[24:32],
    }

    attack_side_board = extract_equal_cells("bramble_attack_four_direction_source.png", 4, 8)
    attack_front_back = extract_equal_cells("bramble_attack_front_back_source.png", 2, 8)
    attack_rows = {
        "down": attack_front_back[0:8],
        # The accepted generated side board placed the visually right-facing
        # strip in row two and the left-facing strip in row three. Route by
        # actual facing rather than the rejected generation label.
        "left": attack_side_board[16:24],
        "right": attack_side_board[8:16],
        "up": attack_front_back[8:16],
    }

    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)

    locomotion_sheet = Image.new("RGBA", (48 * 8, 48 * 4), (0, 0, 0, 0))
    for row, direction in enumerate(DIRECTIONS):
        frames = locomotion_rows[direction]
        reference_height = max(frame.height for frame in frames[:6])
        reference_width = max(frame.width for frame in frames[:6])
        # Bramble Spitter is a normal ranged mob, not a Hog/Bear-sized heavy.
        # Rasterize its runtime pixels near the original 32px silhouette while
        # retaining generous atlas cells for the newly authored poses.
        scale_width = 30 / reference_width
        scale_height = 30 / reference_height
        shared_scale = min(scale_width, scale_height)
        for column, frame in enumerate(frames):
            if column < 7:
                resized = frame.resize(
                    (max(1, round(frame.width * shared_scale)), max(1, round(frame.height * shared_scale))),
                    Image.Resampling.NEAREST,
                )
            else:
                resized = normalize(frame, 32, 24)
            cell = place_on_cell(resized, (48, 48), 45)
            locomotion_sheet.alpha_composite(cell, (column * 48, row * 48))
    locomotion_sheet.save(RUNTIME_DIR / "bramble_spitter_locomotion_sheet_48x48.png")

    attack_sheet = Image.new("RGBA", (64 * 8, 56 * 4), (0, 0, 0, 0))
    for row, direction in enumerate(DIRECTIONS):
        frames = attack_rows[direction]
        largest_width = max(frame.width for frame in frames)
        largest_height = max(frame.height for frame in frames)
        # Match the actor mass of the approved locomotion family. The wider
        # cell still preserves the contact-frame mouth/thrust extension, but
        # entering an attack must not make the whole creature grow.
        shared_scale = min(38 / largest_width, 29 / largest_height)
        for column, frame in enumerate(frames):
            resized = frame.resize(
                (max(1, round(frame.width * shared_scale)), max(1, round(frame.height * shared_scale))),
                Image.Resampling.NEAREST,
            )
            cell = place_on_cell(resized, (64, 56), 53)
            attack_sheet.alpha_composite(cell, (column * 64, row * 56))
    attack_sheet.save(RUNTIME_DIR / "bramble_spitter_attack_sheet_64x56.png")

    preview = Image.new("RGBA", (512, 448), (31, 39, 31, 255))
    preview.alpha_composite(locomotion_sheet.resize((768, 384), Image.Resampling.NEAREST).crop((128, 0, 640, 192)), (0, 0))
    preview.alpha_composite(attack_sheet.resize((1024, 448), Image.Resampling.NEAREST).crop((256, 0, 768, 256)), (0, 192))
    preview.save(REVIEW_DIR / "bramble_spitter_runtime_review.png")


def build_projectile_sheet() -> None:
    # The eighth generated pose is a purple-brown spent-seed remnant that reads
    # like a carrot at gameplay speed. Keep the four flight poses and the
    # three-frame expanding impact, ending on the clean bright explosion.
    frames = extract_equal_cells("bramble_thorn_seed_source.png", 1, 8)[:7]
    atlas = Image.new("RGBA", (24 * 7, 24), (0, 0, 0, 0))
    for column, frame in enumerate(frames):
        normalized = normalize(frame, 20 if column < 4 else 22, 20 if column < 4 else 22)
        cell = place_on_cell(normalized, (24, 24), 23)
        atlas.alpha_composite(cell, (column * 24, 0))
    atlas.save(RUNTIME_DIR / "bramble_thorn_seed_sheet_24x24.png")


if __name__ == "__main__":
    build_body_sheets()
    build_projectile_sheet()
    print("Processed Bramble Spitter body, attack, reaction, and projectile sheets.")
