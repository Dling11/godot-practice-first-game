from collections import deque
from pathlib import Path

from PIL import Image


SOURCE = Path(
    "art_source/cleaned/characters/enemies/stage_5_boss/"
    "stage_5_boss_walk_clean_v1.png"
)
OUTPUT_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
RUNTIME_OUTPUT = Path(
    "assets/characters/enemies/stage_5_boss/stage_5_boss_walk_sheet_112x96.png"
)
CELL_SIZE = (112, 96)
SOURCE_CELL = (256, 256)
FOOT_BASELINE_Y = 90
# Preserve the approved idle stature for each top-down view. One scale is used
# across all six frames within a direction; no cell is independently fitted.
TARGET_ROW_HEIGHTS = (78, 73, 72, 72)


def connected_components(image: Image.Image) -> list[set[tuple[int, int]]]:
    alpha = image.getchannel("A")
    occupied = {
        (x, y)
        for y in range(image.height)
        for x in range(image.width)
        if alpha.getpixel((x, y)) >= 128
    }
    components: list[set[tuple[int, int]]] = []
    while occupied:
        start = occupied.pop()
        component = {start}
        pending = deque([start])
        while pending:
            x, y = pending.popleft()
            for neighbor in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if neighbor in occupied:
                    occupied.remove(neighbor)
                    component.add(neighbor)
                    pending.append(neighbor)
        components.append(component)
    return components


def crop_component(image: Image.Image, keep: set[tuple[int, int]]) -> Image.Image:
    mask = Image.new("L", image.size, 0)
    pixels = mask.load()
    for x, y in keep:
        pixels[x, y] = 255
    cleaned = image.copy()
    cleaned.putalpha(mask)
    bounds = mask.getbbox()
    if bounds is None:
        raise RuntimeError("Stage 5 boss walk component unexpectedly has no bounds.")
    return cleaned.crop(bounds)


def normalize_actor(actor: Image.Image, scale: float) -> Image.Image:
    size = (
        max(1, round(actor.width * scale)),
        max(1, round(actor.height * scale)),
    )
    actor = actor.resize(size, Image.Resampling.NEAREST)
    alpha = actor.getchannel("A").point(lambda value: 255 if value >= 128 else 0)
    actor.putalpha(alpha)
    canvas = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
    x = round((CELL_SIZE[0] - actor.width) / 2)
    y = FOOT_BASELINE_Y - actor.height
    if x < 0 or y < 0 or x + actor.width > CELL_SIZE[0]:
        raise RuntimeError(f"Normalized walk actor does not fit: {size}")
    canvas.alpha_composite(actor, (x, y))
    return canvas


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (1536, 1024):
        raise RuntimeError(f"Unexpected walk source size: {source.size}")

    # Several generated actors cross their nominal 256px cells. Most visibly,
    # every up-facing crown begins 22-24px above the fourth row. Extracting
    # inside cells amputates those heads, so recover the 24 real actors from
    # the complete board first and order them by their actual centers.
    components = sorted(connected_components(source), key=len, reverse=True)
    if len(components) < 24 or len(components[23]) < 1000:
        raise RuntimeError("Walk source does not expose 24 complete actor components.")
    actor_components = components[:24]
    centered_components: list[tuple[float, float, set[tuple[int, int]]]] = []
    for component in actor_components:
        center_x = sum(point[0] for point in component) / len(component)
        center_y = sum(point[1] for point in component) / len(component)
        centered_components.append((center_x, center_y, component))
    centered_components.sort(key=lambda entry: entry[1])

    raw_rows: list[list[Image.Image]] = []
    row_scales: list[float] = []
    for row in range(4):
        actors: list[Image.Image] = []
        maximum_height = 0
        row_components = sorted(centered_components[row * 6 : (row + 1) * 6])
        for _center_x, _center_y, component in row_components:
            actor = crop_component(source, component)
            actors.append(actor)
            maximum_height = max(maximum_height, actor.height)
        if row == 3 and any(actor.height < 190 for actor in actors):
            raise RuntimeError("Up-facing walk recovery lost a boundary-crossing crown.")
        raw_rows.append(actors)
        row_scales.append(TARGET_ROW_HEIGHTS[row] / maximum_height)

    sheet = Image.new("RGBA", (CELL_SIZE[0] * 6, CELL_SIZE[1] * 4), (0, 0, 0, 0))
    for row, actors in enumerate(raw_rows):
        for column, actor in enumerate(actors):
            normalized = normalize_actor(actor, row_scales[row])
            sheet.alpha_composite(normalized, (column * CELL_SIZE[0], row * CELL_SIZE[1]))

    if sheet.size != (672, 384):
        raise RuntimeError("Stage 5 walk candidate lost its exact 6x4 grid.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError("Stage 5 walk candidate contains non-binary alpha.")
    occupied_cells = 0
    frame_hashes: set[bytes] = set()
    for row in range(4):
        for column in range(6):
            cell = sheet.crop(
                (
                    column * CELL_SIZE[0],
                    row * CELL_SIZE[1],
                    (column + 1) * CELL_SIZE[0],
                    (row + 1) * CELL_SIZE[1],
                )
            )
            bounds = cell.getchannel("A").getbbox()
            if bounds is None:
                raise RuntimeError(f"Walk cell {row},{column} is empty.")
            if bounds[3] != FOOT_BASELINE_Y:
                raise RuntimeError(f"Walk cell {row},{column} lost the shared baseline.")
            frame_hashes.add(cell.tobytes())
            occupied_cells += 1
    if occupied_cells != 24:
        raise RuntimeError("Stage 5 walk candidate does not preserve all 24 frames.")
    if len(frame_hashes) != 24:
        raise RuntimeError("Stage 5 walk candidate contains duplicated filler frames.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / "stage_5_boss_walk_sheet_112x96_candidate.png"
    sheet.save(output)
    RUNTIME_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(RUNTIME_OUTPUT)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(
        OUTPUT_DIR / "stage_5_boss_walk_sheet_2x_review.png"
    )
    preview_frames: list[Image.Image] = []
    for column in range(6):
        frame = Image.new("RGBA", (CELL_SIZE[0] * 4, CELL_SIZE[1]), (19, 25, 22, 255))
        for row in range(4):
            cell = sheet.crop(
                (
                    column * CELL_SIZE[0],
                    row * CELL_SIZE[1],
                    (column + 1) * CELL_SIZE[0],
                    (row + 1) * CELL_SIZE[1],
                )
            )
            frame.alpha_composite(cell, (row * CELL_SIZE[0], 0))
        preview_frames.append(
            frame.resize((frame.width * 3, frame.height * 3), Image.Resampling.NEAREST)
        )
    preview_frames[0].save(
        OUTPUT_DIR / "stage_5_boss_walk_all_directions_preview.gif",
        save_all=True,
        append_images=preview_frames[1:],
        duration=130,
        loop=0,
        disposal=2,
    )
    print("Wrote", output, "row scales", [round(value, 6) for value in row_scales])


if __name__ == "__main__":
    main()
