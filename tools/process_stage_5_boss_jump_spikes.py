from pathlib import Path
from collections import deque

from PIL import Image


SOURCE = Path("art_source/cleaned/characters/enemies/stage_5_boss/stage_5_boss_jump_spikes_clean_v1.png")
REVIEW_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
RUNTIME_DIR = Path("assets/characters/enemies/stage_5_boss")
CELL_SIZE = (192, 112)
GROUND_BASELINE_Y = 100
FRAME_ANCHORS = (
    (296.0, 364.0),
    (757.0, 362.0),
    (1223.0, 329.0),
    (301.0, 744.0),
    (758.0, 805.0),
    (1218.0, 820.0),
)


def extract_complete_frames(source: Image.Image) -> list[Image.Image]:
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

    masks = [Image.new("L", source.size, 0) for _frame in range(6)]
    mask_pixels = [mask.load() for mask in masks]
    for component in components:
        center_x = sum(point[0] for point in component) / len(component)
        center_y = sum(point[1] for point in component) / len(component)
        frame_index = min(
            range(6),
            key=lambda index: (
                (center_x - FRAME_ANCHORS[index][0]) ** 2
                + (center_y - FRAME_ANCHORS[index][1]) ** 2
            ),
        )
        for x, y in component:
            mask_pixels[frame_index][x, y] = 255

    frames: list[Image.Image] = []
    for frame_index, mask in enumerate(masks):
        bounds = mask.getbbox()
        if bounds is None:
            raise RuntimeError(f"Spike frame {frame_index} is empty after component assignment.")
        frame = source.copy()
        frame.putalpha(mask)
        frames.append(frame.crop(bounds))
    return frames


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    if source.size != (1536, 1024):
        raise RuntimeError(f"Unexpected spike source size: {source.size}")

    cells = extract_complete_frames(source)

    scale = min(
        176.0 / max(cell.width for cell in cells),
        100.0 / max(cell.height for cell in cells),
    )
    sheet = Image.new("RGBA", (CELL_SIZE[0] * 6, CELL_SIZE[1]), (0, 0, 0, 0))
    hashes: set[bytes] = set()
    for frame_index, cell in enumerate(cells):
        size = (max(1, round(cell.width * scale)), max(1, round(cell.height * scale)))
        cell = cell.resize(size, Image.Resampling.NEAREST)
        cell.putalpha(cell.getchannel("A").point(lambda value: 255 if value >= 128 else 0))
        frame = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
        x = round((CELL_SIZE[0] - cell.width) / 2)
        y = GROUND_BASELINE_Y - cell.height
        if x < 0 or y < 0 or x + cell.width > CELL_SIZE[0] or y + cell.height > CELL_SIZE[1]:
            raise RuntimeError(f"Spike frame {frame_index} does not fit: {size}")
        frame.alpha_composite(cell, (x, y))
        hashes.add(frame.tobytes())
        sheet.alpha_composite(frame, (frame_index * CELL_SIZE[0], 0))

    if len(hashes) != 6:
        raise RuntimeError("Spike sheet contains duplicated filler frames.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError("Spike sheet contains non-binary alpha.")

    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    review = REVIEW_DIR / "stage_5_boss_jump_spikes_sheet_192x112_candidate.png"
    runtime = RUNTIME_DIR / "stage_5_boss_jump_spikes_sheet_192x112.png"
    sheet.save(review)
    sheet.save(runtime)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(
        REVIEW_DIR / "stage_5_boss_jump_spikes_sheet_2x_review.png"
    )
    previews = [
        sheet.crop((index * CELL_SIZE[0], 0, (index + 1) * CELL_SIZE[0], CELL_SIZE[1])).resize(
            (CELL_SIZE[0] * 3, CELL_SIZE[1] * 3), Image.Resampling.NEAREST
        )
        for index in range(6)
    ]
    previews[0].save(
        REVIEW_DIR / "stage_5_boss_jump_spikes_preview.gif",
        save_all=True,
        append_images=previews[1:],
        duration=(90, 80, 85, 120, 140, 190),
        loop=0,
        disposal=2,
    )
    print("Wrote", runtime, "scale", round(scale, 6))


if __name__ == "__main__":
    main()
