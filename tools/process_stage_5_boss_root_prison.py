from collections import deque
from pathlib import Path

from PIL import Image


SOURCE_DIR = Path("art_source/generated/characters/enemies/stage_5_boss")
REVIEW_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
RUNTIME_DIR = Path("assets/characters/enemies/stage_5_boss")


def remove_baked_checker(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, _alpha = pixels[x, y]
            spread = max(red, green, blue) - min(red, green, blue)
            alpha = 0 if min(red, green, blue) >= 214 and spread <= 18 else 255
            pixels[x, y] = (red, green, blue, alpha)
    return rgba


def extract_cells(source: Image.Image) -> list[Image.Image]:
    frames: list[Image.Image] = []
    for column in range(8):
        left = round(column * source.width / 8)
        right = round((column + 1) * source.width / 8)
        cell = source.crop((left, 0, right, source.height))
        bounds = cell.getchannel("A").getbbox()
        if bounds is None:
            raise RuntimeError(f"Generated root frame {column} is empty.")
        frames.append(cell.crop(bounds))
    return frames


def extract_frames_by_component_anchors(source: Image.Image) -> list[Image.Image]:
    """Recover complete effects before frame assignment.

    The tallest execution roots cross the generated board's nominal eighths.
    Strip-first cropping therefore imports pieces of neighboring frames. The
    eight largest connected ground/root bodies are stable anchors; every loose
    rock and spark belongs to whichever real anchor is horizontally nearest.
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
        raise RuntimeError(f"Execution source has only {len(components)} usable components.")

    anchors = sorted(
        components,
        key=len,
        reverse=True,
    )[:8]
    anchor_centers = sorted(
        sum(x for x, _y in component) / len(component)
        for component in anchors
    )
    groups: list[list[set[tuple[int, int]]]] = [[] for _index in range(8)]
    for component in components:
        center_x = sum(x for x, _y in component) / len(component)
        nearest = min(range(8), key=lambda index: abs(center_x - anchor_centers[index]))
        groups[nearest].append(component)

    frames: list[Image.Image] = []
    for index, group in enumerate(groups):
        mask = Image.new("L", source.size, 0)
        pixels = mask.load()
        for component in group:
            for x, y in component:
                pixels[x, y] = 255
        bounds = mask.getbbox()
        if bounds is None:
            raise RuntimeError(f"Execution component group {index} is empty.")
        frame = source.copy()
        frame.putalpha(mask)
        frames.append(frame.crop(bounds))
    return frames


def normalize_sheet(
    source_path: Path,
    runtime_name: str,
    cell_size: tuple[int, int],
    baseline_y: int,
    maximum_content: tuple[int, int],
    component_anchored: bool = False,
) -> Image.Image:
    source = remove_baked_checker(Image.open(source_path))
    frames = extract_frames_by_component_anchors(source) if component_anchored else extract_cells(source)
    maximum_width = max(frame.width for frame in frames)
    maximum_height = max(frame.height for frame in frames)
    scale = min(maximum_content[0] / maximum_width, maximum_content[1] / maximum_height)
    sheet = Image.new("RGBA", (cell_size[0] * 8, cell_size[1]), (0, 0, 0, 0))
    hashes: set[bytes] = set()
    for column, frame in enumerate(frames):
        size = (max(1, round(frame.width * scale)), max(1, round(frame.height * scale)))
        frame = frame.resize(size, Image.Resampling.NEAREST)
        frame.putalpha(frame.getchannel("A").point(lambda value: 255 if value >= 128 else 0))
        bounds = frame.getchannel("A").getbbox()
        if bounds is None:
            raise RuntimeError(f"Normalized root frame {column} is empty.")
        frame = frame.crop(bounds)
        canvas = Image.new("RGBA", cell_size, (0, 0, 0, 0))
        x = round((cell_size[0] - frame.width) / 2)
        y = baseline_y - frame.height
        if x < 0 or y < 0 or x + frame.width > cell_size[0]:
            raise RuntimeError(f"Root frame {column} does not fit {cell_size}: {frame.size}.")
        canvas.alpha_composite(frame, (x, y))
        actual = canvas.getchannel("A").getbbox()
        if actual is None or actual[3] != baseline_y:
            raise RuntimeError(f"Root frame {column} lost baseline {baseline_y}.")
        hashes.add(canvas.tobytes())
        sheet.alpha_composite(canvas, (column * cell_size[0], 0))
    if len(hashes) != 8:
        raise RuntimeError(f"{runtime_name} contains duplicate frames.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
        raise RuntimeError(f"{runtime_name} contains non-binary alpha.")
    output = RUNTIME_DIR / runtime_name
    output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output)
    print("Wrote", output, "scale", round(scale, 6))
    return sheet


def save_review(sheet: Image.Image, name: str, cell_size: tuple[int, int], durations: list[int]) -> None:
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    sheet.resize((sheet.width * 2, sheet.height * 2), Image.Resampling.NEAREST).save(
        REVIEW_DIR / f"{name}_2x_review.png"
    )
    frames: list[Image.Image] = []
    for column in range(8):
        cell = sheet.crop((column * cell_size[0], 0, (column + 1) * cell_size[0], cell_size[1]))
        backdrop = Image.new("RGBA", cell_size, (19, 25, 22, 255))
        backdrop.alpha_composite(cell)
        frames.append(backdrop.resize((cell_size[0] * 3, cell_size[1] * 3), Image.Resampling.NEAREST))
    frames[0].save(
        REVIEW_DIR / f"{name}_preview.gif",
        save_all=True,
        append_images=frames[1:],
        duration=durations,
        loop=0,
        disposal=2,
    )


def main() -> None:
    prison_cell = (128, 112)
    prison = normalize_sheet(
        SOURCE_DIR / "stage_5_boss_root_prison_source_v1.png",
        "stage_5_boss_root_prison_sheet_128x112.png",
        prison_cell,
        99,
        (64, 44),
    )
    save_review(prison, "stage_5_boss_root_prison_sheet_128x112", prison_cell, [180, 180, 100, 260, 180, 180, 120, 260])

    execution_cell = (192, 192)
    execution = normalize_sheet(
        SOURCE_DIR / "stage_5_boss_root_execution_source_v1.png",
        "stage_5_boss_root_execution_sheet_192x192.png",
        execution_cell,
        178,
        (178, 168),
        True,
    )
    save_review(execution, "stage_5_boss_root_execution_sheet_192x192", execution_cell, [180, 160, 85, 110, 130, 160, 220, 350])


if __name__ == "__main__":
    main()
