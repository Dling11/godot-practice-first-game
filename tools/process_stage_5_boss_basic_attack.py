from collections import deque
from pathlib import Path

from PIL import Image


SOURCE_A = Path(
    "art_source/cleaned/characters/enemies/stage_5_boss/"
    "stage_5_boss_basic_attack_windup_clean_v1.png"
)
SOURCE_B = Path(
    "art_source/cleaned/characters/enemies/stage_5_boss/"
    "stage_5_boss_basic_attack_contact_clean_v1.png"
)
OUTPUT_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
CELL_SIZE = (144, 112)
FOOT_BASELINE_Y = 98
TARGET_ROW_HEIGHTS = (78, 73, 72, 72)


def extract_grid_actors(image: Image.Image) -> list[list[Image.Image]]:
    """Recover complete actors before assigning them to generated grid cells.

    Long sweep poses cross the source board's equal-quarter boundaries. Cropping
    those quarters first silently amputates the root arm. The cleaned source has
    exactly one connected actor per authored cell, so extract globally and use
    each component's centroid only to recover its row/column identity.
    """
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
        if len(component) >= 30:
            components.append(component)
    if len(components) != 16:
        raise RuntimeError(f"Expected 16 complete basic-attack actors, found {len(components)}.")

    grid: list[list[Image.Image | None]] = [[None for _column in range(4)] for _row in range(4)]
    for component in components:
        center_x = sum(point[0] for point in component) / len(component)
        center_y = sum(point[1] for point in component) / len(component)
        column = min(3, int(center_x * 4 / image.width))
        row = min(3, int(center_y * 4 / image.height))
        if grid[row][column] is not None:
            raise RuntimeError(f"Multiple basic-attack actors map to source cell {row},{column}.")
        mask = Image.new("L", image.size, 0)
        pixels = mask.load()
        for x, y in component:
            pixels[x, y] = 255
        bounds = mask.getbbox()
        if bounds is None:
            raise RuntimeError("Basic-attack actor component has no bounds.")
        cleaned = image.copy()
        cleaned.putalpha(mask)
        grid[row][column] = cleaned.crop(bounds)

    if any(actor is None for row in grid for actor in row):
        raise RuntimeError("Basic-attack source grid lost an authored actor.")
    return [[actor for actor in row if actor is not None] for row in grid]


def normalize_actor(actor: Image.Image, scale: float) -> Image.Image:
    size = (max(1, round(actor.width * scale)), max(1, round(actor.height * scale)))
    actor = actor.resize(size, Image.Resampling.NEAREST)
    actor.putalpha(actor.getchannel("A").point(lambda value: 255 if value >= 128 else 0))
    canvas = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
    x = round((CELL_SIZE[0] - actor.width) / 2)
    y = FOOT_BASELINE_Y - actor.height
    if x < 0 or y < 0 or x + actor.width > CELL_SIZE[0]:
        raise RuntimeError(f"Normalized basic-attack actor does not fit: {size}")
    canvas.alpha_composite(actor, (x, y))
    return canvas


def main() -> None:
    sources = [Image.open(path).convert("RGBA") for path in (SOURCE_A, SOURCE_B)]
    if any(source.size != (1254, 1254) for source in sources):
        raise RuntimeError(f"Unexpected basic-attack source sizes: {[source.size for source in sources]}")

    source_grids = [extract_grid_actors(source) for source in sources]
    rows: list[list[Image.Image]] = []
    row_scales: list[float] = []
    for row in range(4):
        actors: list[Image.Image] = []
        for source_grid in source_grids:
            actors.extend(source_grid[row])
        rows.append(actors)
        maximum_height = max(actor.height for actor in actors)
        row_scales.append(TARGET_ROW_HEIGHTS[row] / maximum_height)

    sheet = Image.new("RGBA", (CELL_SIZE[0] * 8, CELL_SIZE[1] * 4), (0, 0, 0, 0))
    hashes: set[bytes] = set()
    for row, actors in enumerate(rows):
        for column, actor in enumerate(actors):
            normalized = normalize_actor(actor, row_scales[row])
            bounds = normalized.getchannel("A").getbbox()
            if bounds is None:
                raise RuntimeError(f"Basic-attack cell {row},{column} is empty.")
            if bounds[3] != FOOT_BASELINE_Y:
                raise RuntimeError(f"Basic-attack cell {row},{column} lost the shared baseline.")
            hashes.add(normalized.tobytes())
            sheet.alpha_composite(normalized, (column * CELL_SIZE[0], row * CELL_SIZE[1]))

    if len(hashes) != 32:
        raise RuntimeError("Basic-attack candidate contains duplicated filler frames.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError("Basic-attack candidate contains non-binary alpha.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / "stage_5_boss_basic_attack_sheet_144x112_candidate.png"
    sheet.save(output)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(
        OUTPUT_DIR / "stage_5_boss_basic_attack_sheet_2x_review.png"
    )

    durations = [150, 165, 210, 75, 65, 110, 155, 210]
    previews: list[Image.Image] = []
    for column in range(8):
        frame = Image.new("RGBA", (CELL_SIZE[0] * 4, CELL_SIZE[1]), (19, 25, 22, 255))
        for row in range(4):
            cell = sheet.crop(
                (column * CELL_SIZE[0], row * CELL_SIZE[1], (column + 1) * CELL_SIZE[0], (row + 1) * CELL_SIZE[1])
            )
            frame.alpha_composite(cell, (row * CELL_SIZE[0], 0))
        previews.append(frame.resize((frame.width * 3, frame.height * 3), Image.Resampling.NEAREST))
    previews[0].save(
        OUTPUT_DIR / "stage_5_boss_basic_attack_all_directions_preview.gif",
        save_all=True,
        append_images=previews[1:],
        duration=durations,
        loop=0,
        disposal=2,
    )
    print("Wrote", output, "row scales", [round(value, 6) for value in row_scales])


if __name__ == "__main__":
    main()
