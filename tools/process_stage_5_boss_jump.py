from collections import deque
from pathlib import Path

from PIL import Image


SOURCE_A = Path("art_source/cleaned/characters/enemies/stage_5_boss/stage_5_boss_jump_takeoff_clean_v1.png")
SOURCE_B = Path("art_source/cleaned/characters/enemies/stage_5_boss/stage_5_boss_jump_landing_clean_v1.png")
OUTPUT_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
CELL_SIZE = (144, 112)
FOOT_BASELINE_Y = 98
TARGET_TAKEOFF_HEIGHTS = (78, 73, 72, 72)
SOURCE_OVERLAP = 36


def largest_component(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    occupied = {(x, y) for y in range(image.height) for x in range(image.width) if alpha.getpixel((x, y)) >= 128}
    components: list[set[tuple[int, int]]] = []
    while occupied:
        start = occupied.pop()
        keep = {start}
        pending = deque([start])
        while pending:
            x, y = pending.popleft()
            for neighbor in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if neighbor in occupied:
                    occupied.remove(neighbor)
                    keep.add(neighbor)
                    pending.append(neighbor)
        components.append(keep)
    if not components:
        raise RuntimeError("Generated Stage 5 jump cell is empty.")
    keep = max(components, key=len)
    mask = Image.new("L", image.size, 0)
    pixels = mask.load()
    for x, y in keep:
        pixels[x, y] = 255
    image = image.copy()
    image.putalpha(mask)
    bounds = mask.getbbox()
    if bounds is None:
        raise RuntimeError("Jump actor has no bounds.")
    return image.crop(bounds)


def recover_actor(source: Image.Image, row: int, column: int) -> Image.Image:
    x0 = round(column * source.width / 4)
    x1 = round((column + 1) * source.width / 4)
    y0 = round(row * source.height / 4)
    y1 = round((row + 1) * source.height / 4)
    crop = source.crop((max(0, x0 - SOURCE_OVERLAP), max(0, y0 - 12), min(source.width, x1 + SOURCE_OVERLAP), min(source.height, y1 + 12)))
    return largest_component(crop)


def normalize(actor: Image.Image, scale: float) -> Image.Image:
    size = (max(1, round(actor.width * scale)), max(1, round(actor.height * scale)))
    actor = actor.resize(size, Image.Resampling.NEAREST)
    actor.putalpha(actor.getchannel("A").point(lambda value: 255 if value >= 128 else 0))
    resized_bounds = actor.getchannel("A").getbbox()
    if resized_bounds is None:
        raise RuntimeError("Resized jump actor became empty.")
    actor = actor.crop(resized_bounds)
    canvas = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
    x = round((CELL_SIZE[0] - actor.width) / 2)
    y = FOOT_BASELINE_Y - actor.height
    if x < 0 or y < 0 or x + actor.width > CELL_SIZE[0]:
        raise RuntimeError(f"Normalized jump actor does not fit: {size}")
    canvas.alpha_composite(actor, (x, y))
    return canvas


def main() -> None:
    sources = [Image.open(path).convert("RGBA") for path in (SOURCE_A, SOURCE_B)]
    if any(source.size != (1254, 1254) for source in sources):
        raise RuntimeError(f"Unexpected jump source sizes: {[source.size for source in sources]}")
    rows: list[list[Image.Image]] = []
    scales: list[float] = []
    for row in range(4):
        actors: list[Image.Image] = []
        for source_index, source in enumerate(sources):
            for column in range(4):
                # The generated right-facing impact/rebound cells (landing
                # columns 3-4) drift into a rear view. Use exact screen-space
                # counterparts of the approved left-profile poses instead of
                # accepting directional corruption or a different creature.
                if source_index == 1 and row == 2 and column >= 2:
                    actor = recover_actor(source, 1, column).transpose(Image.Transpose.FLIP_LEFT_RIGHT)
                else:
                    actor = recover_actor(source, row, column)
                actors.append(actor)
        rows.append(actors)
        # Frame two is the fully extended takeoff and calibrates this family's
        # stature; every other pose in the direction uses the same scale.
        scales.append(TARGET_TAKEOFF_HEIGHTS[row] / actors[1].height)

    sheet = Image.new("RGBA", (CELL_SIZE[0] * 8, CELL_SIZE[1] * 4), (0, 0, 0, 0))
    hashes: set[bytes] = set()
    for row, actors in enumerate(rows):
        for column, actor in enumerate(actors):
            frame = normalize(actor, scales[row])
            bounds = frame.getchannel("A").getbbox()
            if bounds is None or bounds[3] != FOOT_BASELINE_Y:
                raise RuntimeError(f"Jump frame {row},{column} lost its body or baseline.")
            hashes.add(frame.tobytes())
            sheet.alpha_composite(frame, (column * CELL_SIZE[0], row * CELL_SIZE[1]))
    if len(hashes) != 32:
        raise RuntimeError("Jump sheet contains duplicated filler frames.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError("Jump sheet contains non-binary alpha.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / "stage_5_boss_jump_body_sheet_144x112_candidate.png"
    sheet.save(output)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(OUTPUT_DIR / "stage_5_boss_jump_body_sheet_2x_review.png")

    arc_offsets = (0, -7, -18, -25, -18, -7, 0, 0)
    durations = (210, 85, 115, 190, 95, 65, 125, 260)
    previews: list[Image.Image] = []
    for column in range(8):
        frame = Image.new("RGBA", (CELL_SIZE[0] * 4, CELL_SIZE[1] + 28), (19, 25, 22, 255))
        for row in range(4):
            cell = sheet.crop((column * CELL_SIZE[0], row * CELL_SIZE[1], (column + 1) * CELL_SIZE[0], (row + 1) * CELL_SIZE[1]))
            frame.alpha_composite(cell, (row * CELL_SIZE[0], 28 + arc_offsets[column]))
        previews.append(frame.resize((frame.width * 3, frame.height * 3), Image.Resampling.NEAREST))
    previews[0].save(OUTPUT_DIR / "stage_5_boss_jump_body_all_directions_preview.gif", save_all=True, append_images=previews[1:], duration=durations, loop=0, disposal=2)
    print("Wrote", output, "row scales", [round(value, 6) for value in scales])


if __name__ == "__main__":
    main()
