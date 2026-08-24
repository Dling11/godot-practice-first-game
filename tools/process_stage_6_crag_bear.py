from __future__ import annotations

from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "art_source/generated/characters/enemies/stage_6_armored_bear"
RUNTIME_DIR = ROOT / "assets/characters/enemies/stage_6_crag_bear"
MATERIAL_DIR = ROOT / "assets/items/materials/forest"
PORTRAIT_DIR = ROOT / "assets/characters/enemies/portraits"
REVIEW_DIR = ROOT / "art_source/review/characters/enemies/stage_6_crag_bear"

ROWS = 4
FOOT_MARGIN = 2

FAMILIES = {
    "locomotion": (
        "armored_bear_locomotion_source.png", 4, tuple(range(4)), 64, 48,
        "crag_bear_locomotion_sheet_64x48.png",
    ),
    "basic_attack": (
        "composite_v2_claw", 8, tuple(range(8)), 96, 64,
        "crag_bear_basic_attack_v2_sheet_96x64.png",
    ),
    "body_slam": (
        "armored_bear_body_slam_v2_source.png", 8, tuple(range(8)), 96, 80,
        "crag_bear_body_slam_v2_sheet_96x80.png",
    ),
    "reaction": (
        "armored_bear_reaction_source.png", 6, tuple(range(6)), 64, 48,
        "crag_bear_reaction_sheet_64x48.png",
    ),
}


def _is_background(pixel: np.ndarray) -> bool:
    rgb = pixel[:3].astype(np.int16)
    return int(rgb.max()) >= 225 and int(rgb.max() - rgb.min()) <= 18


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
        raise RuntimeError("Generated cell contains no connected actor pixels.")
    cleaned = np.zeros_like(array)
    for x, y in best:
        cleaned[y, x] = array[y, x]
        cleaned[y, x, 3] = 255
    result = Image.fromarray(cleaned, "RGBA")
    bounds = result.getbbox()
    if bounds is None:
        raise RuntimeError("Generated cell became empty after cleanup.")
    return result.crop(bounds)


def extract_cells(source_name: str, columns: int, selected_columns: tuple[int, ...]) -> list[Image.Image]:
    source = remove_border_background(Image.open(SOURCE_DIR / source_name))
    x_edges = [round(index * source.width / columns) for index in range(columns + 1)]
    y_edges = [round(index * source.height / ROWS) for index in range(ROWS + 1)]
    frames: list[Image.Image] = []
    for row in range(ROWS):
        for column in selected_columns:
            cell = source.crop(
                (x_edges[column], y_edges[row], x_edges[column + 1], y_edges[row + 1])
            )
            frames.append(largest_component(cell))
    return frames


def extract_strip(source_name: str, columns: int) -> list[Image.Image]:
    source = remove_border_background(Image.open(SOURCE_DIR / source_name))
    x_edges = [round(index * source.width / columns) for index in range(columns + 1)]
    return [
        largest_component(source.crop((x_edges[column], 0, x_edges[column + 1], source.height)))
        for column in range(columns)
    ]


def extract_detected_components(
    source_name: str, expected_columns: int
) -> list[Image.Image]:
    """Extract irregular generated boards without pretending they use equal cells."""
    source = remove_border_background(Image.open(SOURCE_DIR / source_name))
    array = np.array(source.convert("RGBA"))
    mask = array[:, :, 3] >= 128
    height, width = mask.shape
    visited = np.zeros_like(mask, dtype=bool)
    components: list[tuple[float, float, Image.Image]] = []
    for y in range(height):
        for x in range(width):
            if not mask[y, x] or visited[y, x]:
                continue
            visited[y, x] = True
            queue = deque([(x, y)])
            points: list[tuple[int, int]] = []
            minimum_x = maximum_x = x
            minimum_y = maximum_y = y
            while queue:
                current_x, current_y = queue.popleft()
                points.append((current_x, current_y))
                minimum_x = min(minimum_x, current_x)
                maximum_x = max(maximum_x, current_x)
                minimum_y = min(minimum_y, current_y)
                maximum_y = max(maximum_y, current_y)
                for next_y in range(max(0, current_y - 1), min(height, current_y + 2)):
                    for next_x in range(max(0, current_x - 1), min(width, current_x + 2)):
                        if mask[next_y, next_x] and not visited[next_y, next_x]:
                            visited[next_y, next_x] = True
                            queue.append((next_x, next_y))
            if len(points) < 500:
                continue
            component = np.zeros(
                (maximum_y - minimum_y + 1, maximum_x - minimum_x + 1, 4),
                dtype=np.uint8,
            )
            for point_x, point_y in points:
                component[point_y - minimum_y, point_x - minimum_x] = array[point_y, point_x]
                component[point_y - minimum_y, point_x - minimum_x, 3] = 255
            components.append(
                (
                    (minimum_y + maximum_y) * 0.5,
                    (minimum_x + maximum_x) * 0.5,
                    Image.fromarray(component, "RGBA"),
                )
            )
    expected_count = ROWS * expected_columns
    if len(components) != expected_count:
        raise RuntimeError(
            f"{source_name} yielded {len(components)} actors; expected {expected_count}"
        )
    components.sort(key=lambda component: component[0])
    ordered: list[Image.Image] = []
    for row in range(ROWS):
        row_components = components[
            row * expected_columns : (row + 1) * expected_columns
        ]
        row_components.sort(key=lambda component: component[1])
        ordered.extend(component[2] for component in row_components)
    return ordered


def checkerboard(size: tuple[int, int], scale: int = 4) -> Image.Image:
    review = Image.new("RGBA", (size[0] * scale, size[1] * scale))
    pixels = review.load()
    colors = ((34, 45, 37, 255), (49, 61, 50, 255))
    tile = 8 * scale
    for y in range(review.height):
        for x in range(review.width):
            pixels[x, y] = colors[((x // tile) + (y // tile)) % 2]
    return review


def normalize_frame(frame: Image.Image, scale: float) -> Image.Image:
    size = (max(1, round(frame.width * scale)), max(1, round(frame.height * scale)))
    normalized = frame.resize(size, Image.Resampling.NEAREST)
    alpha = np.array(normalized.getchannel("A"))
    normalized.putalpha(
        Image.fromarray(np.where(alpha >= 128, 255, 0).astype(np.uint8), "L")
    )
    return largest_component(normalized)


def build_character_sheets() -> None:
    families: dict[
        str, tuple[list[Image.Image], int, int, int, str]
    ] = {}
    for family, (
        source_name, columns, selected, cell_width, cell_height, output_name
    ) in FAMILIES.items():
        if family == "basic_attack":
            anticipation = extract_cells(
                "armored_bear_basic_attack_v2_anticipation_source.png",
                4,
                tuple(range(4)),
            )
            execution = extract_cells(
                "armored_bear_basic_attack_v2_execution_source.png",
                4,
                tuple(range(4)),
            )
            frames = []
            for row in range(ROWS):
                frames.extend(anticipation[row * 4 : (row + 1) * 4])
                frames.extend(execution[row * 4 : (row + 1) * 4])
        elif family == "body_slam":
            frames = extract_detected_components(source_name, columns)
        else:
            frames = extract_cells(source_name, columns, selected)
        families[family] = (
            frames, len(selected), cell_width, cell_height, output_name
        )
    reference_frames = families["locomotion"][0]
    max_width = max(frame.width for frame in reference_frames)
    max_height = max(frame.height for frame in reference_frames)
    shared_scale = min(60 / max_width, 44 / max_height)
    target_row_heights = [
        round(reference_frames[row * 4].height * shared_scale)
        for row in range(ROWS)
    ]

    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    for family, (
        frames, columns, cell_width, cell_height, output_name
    ) in families.items():
        atlas = Image.new(
            "RGBA", (cell_width * columns, cell_height * ROWS), (0, 0, 0, 0)
        )
        for index, frame in enumerate(frames):
            column = index % columns
            row = index // columns
            scale = shared_scale
            if family in ("basic_attack", "body_slam"):
                row_reference = frames[row * columns]
                scale = target_row_heights[row] / row_reference.height
            normalized = normalize_frame(frame, scale)
            x = column * cell_width + (cell_width - normalized.width) // 2
            y = row * cell_height + cell_height - FOOT_MARGIN - normalized.height
            if x < column * cell_width or x + normalized.width > (column + 1) * cell_width:
                raise RuntimeError(f"{family} frame {row},{column} exceeds its cell width")
            if y < row * cell_height:
                raise RuntimeError(f"{family} frame {row},{column} exceeds its cell height")
            atlas.alpha_composite(normalized, (x, y))
        runtime_path = RUNTIME_DIR / output_name
        atlas.save(runtime_path)
        review = checkerboard(atlas.size)
        review.alpha_composite(atlas.resize(review.size, Image.Resampling.NEAREST))
        review.save(REVIEW_DIR / f"crag_bear_{family}_runtime_review.png")
        print(f"Wrote {runtime_path.relative_to(ROOT)} ({atlas.width}x{atlas.height})")
    print(f"Shared actor scale: {shared_scale:.5f}; source max {max_width}x{max_height}")


def build_portrait() -> None:
    frames = extract_cells("armored_bear_locomotion_source.png", 4, (0,))
    down_idle = frames[0]
    crop_height = max(1, round(down_idle.height * 0.70))
    head = down_idle.crop((0, down_idle.height - crop_height, down_idle.width, down_idle.height))
    bounds = head.getbbox()
    if bounds is None:
        raise RuntimeError("Unable to extract Crag Bear portrait.")
    head = head.crop(bounds)
    scale = min(88 / head.width, 88 / head.height)
    head = head.resize(
        (max(1, round(head.width * scale)), max(1, round(head.height * scale))),
        Image.Resampling.NEAREST,
    )
    portrait = Image.new("RGBA", (96, 96), (0, 0, 0, 0))
    portrait.alpha_composite(head, ((96 - head.width) // 2, 96 - head.height - 3))
    PORTRAIT_DIR.mkdir(parents=True, exist_ok=True)
    portrait.save(PORTRAIT_DIR / "crag_bear_portrait_96x96.png")


def build_body_only_action_previews() -> None:
    previews = (
        (
            "crag_bear_basic_attack_v2_sheet_96x64.png",
            96,
            64,
            [84, 84, 84, 84, 84, 140, 310, 310],
            "crag_bear_basic_attack_v2_no_vfx_preview.gif",
        ),
        (
            "crag_bear_body_slam_v2_sheet_96x80.png",
            96,
            80,
            [160, 160, 160, 160, 160, 150, 500, 500],
            "crag_bear_body_slam_v2_no_vfx_preview.gif",
        ),
    )
    scale = 4
    for source_name, cell_width, cell_height, durations, output_name in previews:
        sheet = Image.open(RUNTIME_DIR / source_name).convert("RGBA")
        animation_frames: list[Image.Image] = []
        for column in range(8):
            preview = checkerboard((cell_width * ROWS, cell_height), scale)
            for row in range(ROWS):
                frame = sheet.crop(
                    (
                        column * cell_width,
                        row * cell_height,
                        (column + 1) * cell_width,
                        (row + 1) * cell_height,
                    )
                )
                preview.alpha_composite(
                    frame.resize(
                        (cell_width * scale, cell_height * scale),
                        Image.Resampling.NEAREST,
                    ),
                    (row * cell_width * scale, 0),
                )
            animation_frames.append(preview.convert("P", palette=Image.Palette.ADAPTIVE))
        animation_frames[0].save(
            REVIEW_DIR / output_name,
            save_all=True,
            append_images=animation_frames[1:],
            duration=durations,
            loop=0,
            disposal=2,
        )


def build_material_icons() -> None:
    source = remove_border_background(
        Image.open(SOURCE_DIR / "armored_bear_materials_source.png")
    )
    names = ("crag_iron_24x24.png", "echo_claw_24x24.png")
    MATERIAL_DIR.mkdir(parents=True, exist_ok=True)
    review = Image.new("RGBA", (192, 96), (30, 38, 32, 255))
    for index, name in enumerate(names):
        left = round(index * source.width / 2)
        right = round((index + 1) * source.width / 2)
        item = largest_component(source.crop((left, 0, right, source.height)))
        scale = min(20 / item.width, 20 / item.height)
        item = normalize_frame(item, scale)
        icon = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
        icon.alpha_composite(item, ((24 - item.width) // 2, (24 - item.height) // 2))
        icon.save(MATERIAL_DIR / name)
        review.alpha_composite(icon.resize((96, 96), Image.Resampling.NEAREST), (index * 96, 0))
    review.save(REVIEW_DIR / "crag_bear_materials_24x24_review.png")


def main() -> None:
    build_character_sheets()
    build_body_only_action_previews()
    build_portrait()
    build_material_icons()
    print("Wrote Crag Bear portrait and two material icons.")


if __name__ == "__main__":
    main()
