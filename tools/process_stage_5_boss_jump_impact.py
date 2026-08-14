from pathlib import Path
from collections import deque

from PIL import Image


SOURCE = Path("art_source/cleaned/characters/enemies/stage_5_boss/stage_5_boss_jump_impact_clean_v1.png")
OUTPUT_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
CELL_SIZE = (192, 112)
GROUND_CENTER_Y = 82


def extract_complete_frames(source: Image.Image) -> list[Image.Image]:
    """Assign complete disconnected VFX pieces to the nearest authored frame.

    The generated horizontal board is not aligned to exact eighth boundaries.
    Cropping equal strips first therefore imports pieces of the neighboring
    impact into the current frame. The eight largest components identify the
    real frame centers; every smaller debris component follows its nearest one.
    """
    alpha = source.getchannel("A")
    occupied = {
        (x, y)
        for y in range(source.height)
        for x in range(source.width)
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
        if len(component) >= 3:
            components.append(component)
    if len(components) < 8:
        raise RuntimeError(f"Impact source exposes only {len(components)} usable components.")

    anchors = sorted(
        (
            sum(point[0] for point in component) / len(component)
            for component in sorted(components, key=len, reverse=True)[:8]
        )
    )
    masks = [Image.new("L", source.size, 0) for _frame in range(8)]
    mask_pixels = [mask.load() for mask in masks]
    for component in components:
        center_x = sum(point[0] for point in component) / len(component)
        frame_index = min(range(8), key=lambda index: abs(center_x - anchors[index]))
        for x, y in component:
            mask_pixels[frame_index][x, y] = 255

    frames: list[Image.Image] = []
    for frame_index, mask in enumerate(masks):
        bounds = mask.getbbox()
        if bounds is None:
            raise RuntimeError(f"Impact frame {frame_index} is empty after component assignment.")
        frame = source.copy()
        frame.putalpha(mask)
        frames.append(frame.crop(bounds))
    return frames


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (1942, 809):
        raise RuntimeError(f"Unexpected impact source size: {source.size}")
    cells = extract_complete_frames(source)
    maximum_width = 0
    maximum_height = 0
    for cell in cells:
        maximum_width = max(maximum_width, cell.width)
        maximum_height = max(maximum_height, cell.height)
    scale = min(176 / maximum_width, 92 / maximum_height)
    sheet = Image.new("RGBA", (CELL_SIZE[0] * 8, CELL_SIZE[1]), (0, 0, 0, 0))
    hashes: set[bytes] = set()
    for column, cell in enumerate(cells):
        size = (max(1, round(cell.width * scale)), max(1, round(cell.height * scale)))
        cell = cell.resize(size, Image.Resampling.NEAREST)
        cell.putalpha(cell.getchannel("A").point(lambda value: 255 if value >= 128 else 0))
        frame = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
        x = round((CELL_SIZE[0] - cell.width) / 2)
        y = GROUND_CENTER_Y - round(cell.height * 0.72)
        if x < 0 or y < 0 or x + cell.width > CELL_SIZE[0] or y + cell.height > CELL_SIZE[1]:
            raise RuntimeError(f"Impact frame {column} does not fit: {size}")
        frame.alpha_composite(cell, (x, y))
        hashes.add(frame.tobytes())
        sheet.alpha_composite(frame, (column * CELL_SIZE[0], 0))
    if len(hashes) != 8:
        raise RuntimeError("Impact sheet contains duplicated filler frames.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError("Impact sheet contains non-binary alpha.")

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / "stage_5_boss_jump_impact_sheet_192x112_candidate.png"
    sheet.save(output)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(OUTPUT_DIR / "stage_5_boss_jump_impact_sheet_2x_review.png")
    previews = [sheet.crop((column * CELL_SIZE[0], 0, (column + 1) * CELL_SIZE[0], CELL_SIZE[1])).resize((CELL_SIZE[0] * 3, CELL_SIZE[1] * 3), Image.Resampling.NEAREST) for column in range(8)]
    previews[0].save(OUTPUT_DIR / "stage_5_boss_jump_impact_preview.gif", save_all=True, append_images=previews[1:], duration=(100, 65, 75, 90, 110, 140, 220, 600), loop=0, disposal=2)
    print("Wrote", output, "scale", round(scale, 6))


if __name__ == "__main__":
    main()
