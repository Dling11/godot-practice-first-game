from collections import deque
from pathlib import Path

from PIL import Image


SOURCE = Path(
    "art_source/cleaned/characters/enemies/stage_5_boss/"
    "stage_5_boss_slap_clean_v1.png"
)
OUTPUT_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
RUNTIME = Path(
    "assets/characters/enemies/stage_5_boss/"
    "stage_5_boss_slap_sheet_144x112.png"
)
CELL_SIZE = (144, 112)
FOOT_BASELINE_Y = 101
TARGET_ROW_HEIGHTS = (88, 82, 82, 88)


def extract_actors(image: Image.Image) -> list[list[Image.Image]]:
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
    if len(components) != 32:
        raise RuntimeError(f"Expected 32 complete slap actors, found {len(components)}.")

    grid: list[list[Image.Image | None]] = [[None for _column in range(8)] for _row in range(4)]
    for component in components:
        center_x = sum(point[0] for point in component) / len(component)
        center_y = sum(point[1] for point in component) / len(component)
        column = min(7, int(center_x * 8 / image.width))
        row = min(3, int(center_y * 4 / image.height))
        if grid[row][column] is not None:
            raise RuntimeError(f"Multiple slap actors map to source cell {row},{column}.")
        mask = Image.new("L", image.size, 0)
        pixels = mask.load()
        for x, y in component:
            pixels[x, y] = 255
        bounds = mask.getbbox()
        if bounds is None:
            raise RuntimeError("Slap actor component has no bounds.")
        actor = image.copy()
        actor.putalpha(mask)
        grid[row][column] = actor.crop(bounds)
    if any(actor is None for row in grid for actor in row):
        raise RuntimeError("Slap source grid lost an authored actor.")
    return [[actor for actor in row if actor is not None] for row in grid]


def normalize(actor: Image.Image, scale: float) -> Image.Image:
    size = (max(1, round(actor.width * scale)), max(1, round(actor.height * scale)))
    actor = actor.resize(size, Image.Resampling.NEAREST)
    actor.putalpha(actor.getchannel("A").point(lambda value: 255 if value >= 128 else 0))
    binary_bounds = actor.getchannel("A").getbbox()
    if binary_bounds is None:
        raise RuntimeError("Normalized slap actor became empty.")
    actor = actor.crop(binary_bounds)
    canvas = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
    x = round((CELL_SIZE[0] - actor.width) / 2)
    y = FOOT_BASELINE_Y - actor.height
    if x < 0 or y < 0 or x + actor.width > CELL_SIZE[0]:
        raise RuntimeError(f"Normalized slap actor does not fit: {size}")
    canvas.alpha_composite(actor, (x, y))
    return canvas


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    grid = extract_actors(source)
    sheet = Image.new("RGBA", (CELL_SIZE[0] * 8, CELL_SIZE[1] * 4), (0, 0, 0, 0))
    hashes: set[bytes] = set()
    scales: list[float] = []
    for row, actors in enumerate(grid):
        maximum_height = max(actor.height for actor in actors)
        maximum_width = max(actor.width for actor in actors)
        scale = min(TARGET_ROW_HEIGHTS[row] / maximum_height, 134 / maximum_width)
        scales.append(scale)
        for column, actor in enumerate(actors):
            frame = normalize(actor, scale)
            bounds = frame.getchannel("A").getbbox()
            if bounds is None or bounds[3] != FOOT_BASELINE_Y:
                raise RuntimeError(f"Slap cell {row},{column} lost its shared baseline.")
            hashes.add(frame.tobytes())
            sheet.alpha_composite(frame, (column * CELL_SIZE[0], row * CELL_SIZE[1]))
    if len(hashes) != 32:
        raise RuntimeError("Slap sheet contains duplicated filler frames.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError("Slap sheet contains non-binary alpha.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    candidate = OUTPUT_DIR / "stage_5_boss_slap_sheet_144x112_candidate.png"
    sheet.save(candidate)
    sheet.save(RUNTIME)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(
        OUTPUT_DIR / "stage_5_boss_slap_sheet_2x_review.png"
    )

    durations = [130, 145, 180, 230, 70, 115, 155, 220]
    previews: list[Image.Image] = []
    for column in range(8):
        frame = Image.new("RGBA", (CELL_SIZE[0] * 4, CELL_SIZE[1]), (19, 25, 22, 255))
        for row in range(4):
            cell = sheet.crop((column * 144, row * 112, (column + 1) * 144, (row + 1) * 112))
            frame.alpha_composite(cell, (row * 144, 0))
        previews.append(frame.resize((frame.width * 3, frame.height * 3), Image.Resampling.NEAREST))
    previews[0].save(
        OUTPUT_DIR / "stage_5_boss_slap_all_directions_preview.gif",
        save_all=True,
        append_images=previews[1:],
        duration=durations,
        loop=0,
        disposal=2,
    )
    print("Wrote", RUNTIME, "row scales", [round(value, 6) for value in scales])


if __name__ == "__main__":
    main()
