from collections import deque
from pathlib import Path

from PIL import Image


SOURCE_A = Path(
    "art_source/cleaned/characters/enemies/stage_5_boss/"
    "stage_5_boss_reaction_hurt_clean_v1.png"
)
SOURCE_B = Path(
    "art_source/cleaned/characters/enemies/stage_5_boss/"
    "stage_5_boss_reaction_defeat_clean_v1.png"
)
OUTPUT_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
CELL_SIZE = (144, 112)
# The approved 112x96 sheets place contact 42 pixels below their center.
# This wider family preserves that same world-space foot/root pivot.
FOOT_BASELINE_Y = 98
TARGET_UPRIGHT_HEIGHTS = (78, 73, 72, 72)


def largest_component(image: Image.Image) -> Image.Image:
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
    if not components:
        raise RuntimeError("Generated Stage 5 reaction cell is empty.")
    keep = max(components, key=len)
    mask = Image.new("L", image.size, 0)
    pixels = mask.load()
    for x, y in keep:
        pixels[x, y] = 255
    cleaned = image.copy()
    cleaned.putalpha(mask)
    bounds = mask.getbbox()
    if bounds is None:
        raise RuntimeError("Largest reaction component unexpectedly has no bounds.")
    return cleaned.crop(bounds)


def normalize_actor(actor: Image.Image, scale: float) -> Image.Image:
    size = (max(1, round(actor.width * scale)), max(1, round(actor.height * scale)))
    actor = actor.resize(size, Image.Resampling.NEAREST)
    actor.putalpha(actor.getchannel("A").point(lambda value: 255 if value >= 128 else 0))
    canvas = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
    x = round((CELL_SIZE[0] - actor.width) / 2)
    y = FOOT_BASELINE_Y - actor.height
    if x < 0 or y < 0 or x + actor.width > CELL_SIZE[0]:
        raise RuntimeError(f"Normalized reaction actor does not fit: {size}")
    canvas.alpha_composite(actor, (x, y))
    return canvas


def main() -> None:
    sources = [Image.open(path).convert("RGBA") for path in (SOURCE_A, SOURCE_B)]
    if any(source.size != (1672, 941) for source in sources):
        raise RuntimeError(f"Unexpected reaction source sizes: {[source.size for source in sources]}")

    rows: list[list[Image.Image]] = []
    row_scales: list[float] = []
    for row in range(4):
        actors = []
        for source in sources:
            for column in range(4):
                # Rounded proportional boundaries retain every source pixel
                # when the generator's 1672x941 board is not evenly divisible.
                x0 = round(column * source.width / 4)
                x1 = round((column + 1) * source.width / 4)
                y0 = round(row * source.height / 4)
                y1 = round((row + 1) * source.height / 4)
                actors.append(largest_component(source.crop((x0, y0, x1, y1))))
        rows.append(actors)
        # Frames 1-3 are reusable hurt/recovery poses. Collapse width must not
        # force the standing boss smaller, so one row scale is derived here.
        upright_height = max(actor.height for actor in actors[:3])
        row_scales.append(TARGET_UPRIGHT_HEIGHTS[row] / upright_height)

    sheet = Image.new("RGBA", (CELL_SIZE[0] * 8, CELL_SIZE[1] * 4), (0, 0, 0, 0))
    frame_hashes: set[bytes] = set()
    for row, actors in enumerate(rows):
        for column, actor in enumerate(actors):
            normalized = normalize_actor(actor, row_scales[row])
            if normalized.getchannel("A").getbbox() is None:
                raise RuntimeError(f"Reaction cell {row},{column} is empty.")
            frame_hashes.add(normalized.tobytes())
            sheet.alpha_composite(normalized, (column * CELL_SIZE[0], row * CELL_SIZE[1]))

    if len(frame_hashes) != 32:
        raise RuntimeError("Reaction candidate contains duplicated filler frames.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError("Reaction candidate contains non-binary alpha.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / "stage_5_boss_reaction_sheet_144x112_candidate.png"
    sheet.save(output)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(
        OUTPUT_DIR / "stage_5_boss_reaction_sheet_2x_review.png"
    )

    preview_frames = []
    for column in range(8):
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
        preview_frames.append(frame.resize((frame.width * 3, frame.height * 3), Image.Resampling.NEAREST))
    preview_frames[0].save(
        OUTPUT_DIR / "stage_5_boss_reaction_all_directions_preview.gif",
        save_all=True,
        append_images=preview_frames[1:],
        duration=[95, 125, 145, 145, 170, 190, 240, 650],
        loop=0,
        disposal=2,
    )
    print("Wrote", output, "row scales", [round(value, 6) for value in row_scales])


if __name__ == "__main__":
    main()
