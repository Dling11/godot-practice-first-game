"""Normalize approved Divine Descent source art into runtime-owned assets."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/generated/characters/disciples/examiner/divine_descent_v5"
OUTPUT = ROOT / "assets/characters/enemies/examiner"
ARENA_OUTPUT = ROOT / "assets/environment/arenas/divine_order/court_of_first_measure"
CELL = (192, 128)
SCALE = 0.42
ANCHOR_X = 96
BASELINE_Y = 120


def _remove_connected_matte(source: Image.Image) -> Image.Image:
    rgba = source.convert("RGBA")
    # V5 sources deliberately use one saturated magenta chroma field. It is
    # visually disjoint from the Examiner's ivory, gold, and black palette, so
    # removing it directly is both safer and more complete than flood-filling
    # the uneven V4 brown matte.
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            is_magenta_matte = (
                red >= 120
                and blue >= 100
                and red - green >= 50
                and blue - green >= 40
            )
            if is_magenta_matte:
                pixels[x, y] = (0, 0, 0, 0)
            elif alpha >= 24:
                pixels[x, y] = (red, green, blue, 255)
            else:
                pixels[x, y] = (0, 0, 0, 0)
    return rgba


def _cell_bounds(image: Image.Image, columns: int, rows: int) -> list[list[tuple[int, int, int, int]]]:
    return [[(
        round(column * image.width / columns),
        round(row * image.height / rows),
        round((column + 1) * image.width / columns),
        round((row + 1) * image.height / rows),
    ) for column in range(columns)] for row in range(rows)]


def _body_anchor(frame: Image.Image) -> tuple[int, int]:
    alpha = frame.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("Empty Divine Descent frame")
    left, top, right, bottom = bbox
    pixels = alpha.load()
    lower_top = top + round((bottom - top) * 0.42)
    density = [sum(1 for y in range(lower_top, bottom) if pixels[x, y] > 0) for x in range(frame.width)]
    body_x = max(
        range(left, right),
        key=lambda x: sum(density[max(0, x - 22):min(frame.width, x + 23)]),
    )
    core_left = max(0, body_x - 58)
    core_right = min(frame.width, body_x + 59)
    row_density = [sum(1 for x in range(core_left, core_right) if pixels[x, y] > 0) for y in range(frame.height)]
    grounded = [y for y in range(top, bottom) if row_density[y] >= 8]
    return body_x, grounded[-1] if grounded else bottom - 1


def _normalize_frame(frame: Image.Image) -> Image.Image:
    alpha = frame.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("Empty Divine Descent frame")
    body_x, body_y = _body_anchor(frame)
    resized = frame.resize((round(frame.width * SCALE), round(frame.height * SCALE)), Image.Resampling.NEAREST)
    target = Image.new("RGBA", CELL)
    x = round(ANCHOR_X - body_x * SCALE)
    y = round(BASELINE_Y - body_y * SCALE)
    resized_bbox = resized.getchannel("A").getbbox()
    if resized_bbox is not None:
        left, top, right, bottom = resized_bbox
        x += max(2 - (x + left), 0)
        x -= max((x + right) - (CELL[0] - 2), 0)
        y += max(2 - (y + top), 0)
        y -= max((y + bottom) - (CELL[1] - 2), 0)
    target.alpha_composite(resized, (x, y))
    return target


def _build_sheet(source_name: str, output_name: str) -> None:
    source = _remove_connected_matte(Image.open(SOURCE / source_name))
    bounds = _cell_bounds(source, 6, 4)
    sheet = Image.new("RGBA", (CELL[0] * 6, CELL[1] * 4))
    normalized_rows: list[list[Image.Image]] = []
    for row in range(4):
        if row == 2:
            # The two profile rows must have identical mass, scale, and weapon
            # construction. Mirroring the approved screen-right row eliminates
            # generation drift without changing authored motion.
            normalized_row = [frame.transpose(Image.Transpose.FLIP_LEFT_RIGHT) for frame in normalized_rows[1]]
        else:
            normalized_row = [
                _normalize_frame(source.crop(bounds[row][column]))
                for column in range(6)
            ]
        for column, frame in enumerate(normalized_row):
            sheet.alpha_composite(frame, (column * CELL[0], row * CELL[1]))
        normalized_rows.append(normalized_row)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    sheet.save(OUTPUT / output_name, optimize=True)


def _build_circle() -> None:
    circle_source = SOURCE / "examiner_divine_descent_circle_source_v5_2026-08-25.png"
    source = Image.open(circle_source).convert("RGBA")
    pixels = source.load()
    # ImageGen returned a preview checkerboard. It is near-neutral and bright;
    # preserve the warmer gold/ivory linework and remove only the neutral matte.
    for y in range(source.height):
        for x in range(source.width):
            red, green, blue, _alpha = pixels[x, y]
            neutral = max(red, green, blue) - min(red, green, blue) <= 13
            alpha = 0 if neutral and min(red, green, blue) >= 223 else 255
            pixels[x, y] = (red, green, blue, alpha)
    bbox = source.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("Divine Descent circle lost all pixels")
    source = source.crop(bbox).resize((512, 512), Image.Resampling.LANCZOS)
    ARENA_OUTPUT.mkdir(parents=True, exist_ok=True)
    source.save(ARENA_OUTPUT / "examiner_divine_descent_circle_512.png", optimize=True)


def main() -> None:
    _build_sheet("examiner_divine_descent_launch_source_v5_2026-08-25.png", "examiner_divine_descent_launch_sheet_192x128.png")
    _build_sheet("examiner_divine_descent_land_source_v5_2026-08-25.png", "examiner_divine_descent_land_sheet_192x128.png")
    _build_circle()


if __name__ == "__main__":
    main()
