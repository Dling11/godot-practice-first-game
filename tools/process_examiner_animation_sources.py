"""Build stable Examiner runtime sheets from approved compact source boards.

The generated boards are immutable review sources. Their visual rows and
columns are close to a grid, but not mathematically exact, so equal rectangles
can bisect a glaive or borrow pixels from a neighbouring pose. This processor
finds low-occupancy gutters, then anchors every pose by its dense body column
and foot line. One fixed scale is used everywhere: authored joint movement
remains, while generation drift cannot make the actor grow.
"""

from __future__ import annotations

from dataclasses import dataclass
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
LEGACY_SOURCE = ROOT / "art_source/generated/characters/disciples/examiner/compact_pixel_v2"
BOSS_SOURCE = ROOT / "art_source/generated/characters/disciples/examiner/boss_combat_v3"
OUTPUT = ROOT / "assets/characters/enemies/examiner"
CELL = (192, 128)
ROWS = 4
SCALE = 0.42
BODY_ANCHOR_X = 96
FOOT_BASELINE_Y = 120


@dataclass(frozen=True)
class SheetSpec:
    source_dir: Path
    source_name: str
    output_name: str
    columns: int


SHEETS = (
    SheetSpec(LEGACY_SOURCE, "examiner_locomotion_compact_source_v2_2026-08-24.png", "examiner_locomotion_sheet_192x128.png", 6),
    SheetSpec(BOSS_SOURCE, "examiner_precision_thrust_boss_source_v3_2026-08-25.png", "examiner_thrust_sheet_192x128.png", 6),
    SheetSpec(BOSS_SOURCE, "examiner_divine_sweep_boss_source_v3_2026-08-25.png", "examiner_sweep_sheet_192x128.png", 6),
    SheetSpec(BOSS_SOURCE, "examiner_judgment_charge_boss_source_v3_2026-08-25.png", "examiner_judgment_charge_sheet_192x128.png", 6),
    SheetSpec(BOSS_SOURCE, "examiner_ground_judgment_boss_source_v3_2026-08-25.png", "examiner_ground_judgment_sheet_192x128.png", 6),
    SheetSpec(LEGACY_SOURCE, "examiner_refutation_compact_source_v2_2026-08-24.png", "examiner_refutation_sheet_192x128.png", 5),
    SheetSpec(LEGACY_SOURCE, "examiner_reaction_withdraw_compact_source_v2_2026-08-24.png", "examiner_reaction_withdraw_sheet_192x128.png", 6),
)


def _clean_alpha(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    for y in range(rgba.height):
        for x in range(rgba.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha < 24:
                pixels[x, y] = (0, 0, 0, 0)
                continue
            # Several approved boards contain the renderer's near-white preview
            # matte. Character whites are protected by their dark/gold outline.
            neutral = max(red, green, blue) - min(red, green, blue) <= 10
            if neutral and min(red, green, blue) >= 235:
                pixels[x, y] = (0, 0, 0, 0)
            else:
                pixels[x, y] = (red, green, blue, 255)
    return rgba


def _counts(alpha: Image.Image, axis: str, bounds: tuple[int, int, int, int]) -> list[int]:
    left, top, right, bottom = bounds
    pixels = alpha.load()
    if axis == "x":
        return [sum(1 for y in range(top, bottom) if pixels[x, y] > 0) for x in range(left, right)]
    return [sum(1 for x in range(left, right) if pixels[x, y] > 0) for y in range(top, bottom)]


def _gutter_boundaries(alpha: Image.Image, count: int, axis: str, band: tuple[int, int, int, int]) -> list[int]:
    left, top, right, bottom = band
    start = left if axis == "x" else top
    finish = right if axis == "x" else bottom
    span = finish - start
    projection = _counts(alpha, axis, band)
    boundaries = [start]
    for index in range(1, count):
        expected = start + round(span * index / count)
        radius = max(8, round(span / count * 0.36))
        low = max(boundaries[-1] + 8, expected - radius)
        high = min(finish - 8, expected + radius)
        choice = min(
            range(low, high + 1),
            key=lambda position: (projection[position - start], abs(position - expected)),
        )
        boundaries.append(choice)
    boundaries.append(finish)
    return boundaries


def _body_anchor(frame: Image.Image) -> tuple[int, int]:
    alpha = frame.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise ValueError("Encountered an empty Examiner frame")
    left, top, right, bottom = bbox
    pixels = alpha.load()
    # Anchor the lower body rather than the full silhouette. Long glaives and
    # deliberate upper-body leans must not drag the actor's planted feet sideways.
    lower_top = top + round((bottom - top) * 0.45)
    column_density = [sum(1 for y in range(lower_top, bottom) if pixels[x, y] > 0) for x in range(frame.width)]
    half_window = 18
    body_x = max(
        range(left, right),
        key=lambda x: sum(column_density[max(0, x - half_window):min(frame.width, x + half_window + 1)]),
    )
    core_left = max(0, body_x - 54)
    core_right = min(frame.width, body_x + 55)
    row_density = [sum(1 for x in range(core_left, core_right) if pixels[x, y] > 0) for y in range(frame.height)]
    grounded = [y for y in range(top, bottom) if row_density[y] >= 7]
    body_y = grounded[-1] if grounded else bottom - 1
    return body_x, body_y


def _place_frame(frame: Image.Image) -> tuple[Image.Image, tuple[int, int, int, int]]:
    body_x, body_y = _body_anchor(frame)
    resized = frame.resize(
        (max(1, round(frame.width * SCALE)), max(1, round(frame.height * SCALE))),
        Image.Resampling.NEAREST,
    )
    target = Image.new("RGBA", CELL)
    paste_x = round(BODY_ANCHOR_X - body_x * SCALE)
    paste_y = round(FOOT_BASELINE_Y - body_y * SCALE)
    resized_bbox = resized.getchannel("A").getbbox()
    if resized_bbox is not None:
        left, top, right, bottom = resized_bbox
        paste_x += max(2 - (paste_x + left), 0)
        paste_x -= max((paste_x + right) - (CELL[0] - 2), 0)
        paste_y += max(2 - (paste_y + top), 0)
        paste_y -= max((paste_y + bottom) - (CELL[1] - 2), 0)
    target.alpha_composite(resized, (paste_x, paste_y))
    bbox = target.getchannel("A").getbbox()
    if bbox is None:
        raise ValueError("Normalization erased an Examiner frame")
    return target, bbox


def _normalize(spec: SheetSpec) -> None:
    source = _clean_alpha(Image.open(spec.source_dir / spec.source_name))
    alpha = source.getchannel("A")
    row_bounds = _gutter_boundaries(alpha, ROWS, "y", (0, 0, source.width, source.height))
    sheet = Image.new("RGBA", (CELL[0] * spec.columns, CELL[1] * ROWS))
    normalized_rows: list[list[Image.Image]] = []
    for row in range(ROWS):
        normalized_row: list[Image.Image] = []
        metrics: list[str] = []
        if row == 2:
            # Examiner is bilaterally symmetrical. Exact mirroring guarantees
            # identical scale, mass, stride, and weapon construction on both sides.
            normalized_row = [frame.transpose(Image.Transpose.FLIP_LEFT_RIGHT) for frame in normalized_rows[1]]
        else:
            top, bottom = row_bounds[row], row_bounds[row + 1]
            column_bounds = _gutter_boundaries(alpha, spec.columns, "x", (0, top, source.width, bottom))
            for column in range(spec.columns):
                frame = source.crop((column_bounds[column], top, column_bounds[column + 1], bottom))
                normalized, _bbox = _place_frame(frame)
                normalized_row.append(normalized)
        for column, normalized in enumerate(normalized_row):
            bbox = normalized.getchannel("A").getbbox()
            if bbox is None:
                raise ValueError(f"Empty normalized frame in {spec.output_name} row {row} column {column}")
            sheet.alpha_composite(normalized, (column * CELL[0], row * CELL[1]))
            metrics.append(f"{bbox[0]},{bbox[1]}-{bbox[2]},{bbox[3]}")
        print(f"{spec.output_name} row {row}: {' | '.join(metrics)}")
        normalized_rows.append(normalized_row)
    OUTPUT.mkdir(parents=True, exist_ok=True)
    output_path = OUTPUT / spec.output_name
    sheet.save(output_path, optimize=True)
    print(output_path)


def main() -> None:
    for spec in SHEETS:
        _normalize(spec)


if __name__ == "__main__":
    main()
