"""Build King's first exact-grid runtime idle sheet from the approved source board.

The generated source intentionally contains down, left, and corrected up/back
rows. The right row is an exact mirror of left so both profile directions share
one identity, scale, grip, and weapon length.
"""

from __future__ import annotations

import argparse
import json
from collections import deque
from pathlib import Path
from typing import Iterable

from PIL import Image, ImageDraw


SOURCE_COLUMNS = 4
SOURCE_ROWS = 3
RUNTIME_DIRECTIONS = ("down", "left", "right", "up")
RUNTIME_CELL_SIZE = 64
RUNTIME_COLUMNS = 4
RUNTIME_ROWS = 4
BODY_TARGET_HEIGHT = 32
FOOT_PIXEL_Y = 57
# Even-width cells have their geometric center between pixels 31 and 32.
# Accept either adjacent foot midpoint so exact mirroring remains stable.
FOOT_CENTER_X = 31.5
SAFE_MARGIN = 2

# King's idle body is generated without a weapon. The greatsword is built here
# on one exact 45-degree axis so blade, guard, grip, hand, and pommel cannot
# drift into the disconnected construction rejected during owner review.
SWORD_AXIS = (1, -1)
SWORD_BLADE_LENGTH = 16
SWORD_GRIP_LENGTH = 7
SWORD_COLORS = {
    "outline": (9, 11, 16, 255),
    "blade": (211, 210, 204, 255),
    "edge": (249, 246, 228, 255),
    "channel": (49, 48, 51, 255),
    "gold": (211, 164, 89, 255),
    "grip": (145, 94, 55, 255),
    "cord": (198, 75, 65, 255),
    "skin": (239, 181, 121, 255),
    "sleeve": (25, 37, 58, 255),
}

# Measured only from each row's first corrected source pose. These heights
# exclude the greatsword projection while preserving head-to-foot scale. One
# scale is then used unchanged for all four frames in that direction.
SOURCE_BODY_HEIGHTS = {
    "down": 238,
    "left": 204,
    "up": 176,
}

# Runtime colors are deliberately compact and contain no source-matte magenta.
KING_PALETTE = (
    (9, 11, 16),
    (20, 22, 29),
    (33, 35, 42),
    (49, 48, 51),
    (69, 65, 63),
    (17, 25, 40),
    (25, 37, 58),
    (38, 55, 83),
    (91, 39, 43),
    (139, 52, 52),
    (198, 75, 65),
    (91, 57, 39),
    (145, 94, 55),
    (211, 164, 89),
    (215, 137, 83),
    (239, 181, 121),
    (250, 211, 158),
    (154, 157, 159),
    (211, 210, 204),
    (249, 246, 228),
)


def _rounded_bounds(index: int, count: int, extent: int) -> tuple[int, int]:
    return round(index * extent / count), round((index + 1) * extent / count)


def _hard_alpha(image: Image.Image) -> Image.Image:
    result = image.convert("RGBA")
    pixels = result.load()
    for y in range(result.height):
        for x in range(result.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha < 128 or _is_matte_magenta(red, green, blue):
                pixels[x, y] = (0, 0, 0, 0)
            else:
                pixels[x, y] = (red, green, blue, 255)
    return result


def _is_matte_magenta(red: int, green: int, blue: int) -> bool:
    return red > 150 and blue > 120 and green < 110 and min(red, blue) - green > 60


def _nearest_palette_color(color: tuple[int, int, int]) -> tuple[int, int, int]:
    red, green, blue = color
    return min(
        KING_PALETTE,
        key=lambda candidate: (
            (candidate[0] - red) ** 2
            + (candidate[1] - green) ** 2
            + (candidate[2] - blue) ** 2
        ),
    )


def _quantize_to_king_palette(image: Image.Image) -> Image.Image:
    result = image.convert("RGBA")
    pixels = result.load()
    color_cache: dict[tuple[int, int, int], tuple[int, int, int]] = {}
    for y in range(result.height):
        for x in range(result.width):
            red, green, blue, alpha = pixels[x, y]
            if alpha == 0:
                pixels[x, y] = (0, 0, 0, 0)
                continue
            source = (red, green, blue)
            mapped = color_cache.get(source)
            if mapped is None:
                mapped = _nearest_palette_color(source)
                color_cache[source] = mapped
            pixels[x, y] = (*mapped, 255)
    return result


def _visible_bounds(image: Image.Image) -> tuple[int, int, int, int]:
    bounds = image.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("King source cell has no visible pixels.")
    return bounds


def _foot_center_x(image: Image.Image) -> float:
    bounds = _visible_bounds(image)
    # Measure only the two lowest occupied rows. Presentation above the feet
    # (including King's pommel cord) must never move the actor's foot anchor.
    bottom_band_height = 2
    minimum_y = bounds[3] - bottom_band_height
    points: list[int] = []
    alpha = image.getchannel("A")
    for y in range(minimum_y, bounds[3]):
        for x in range(bounds[0], bounds[2]):
            if alpha.getpixel((x, y)) == 255:
                points.append(x)
    if not points:
        raise ValueError("King source frame has no foot-plane pixels.")
    return (min(points) + max(points)) / 2.0


def _extract_source_cells(source: Image.Image) -> dict[str, list[Image.Image]]:
    rows: dict[str, list[Image.Image]] = {"down": [], "left": [], "up": []}
    source_directions = ("down", "left", "up")
    for row, direction in enumerate(source_directions):
        top, bottom = _rounded_bounds(row, SOURCE_ROWS, source.height)
        for column in range(SOURCE_COLUMNS):
            left, right = _rounded_bounds(column, SOURCE_COLUMNS, source.width)
            cell = _hard_alpha(source.crop((left, top, right, bottom)))
            bounds = _visible_bounds(cell)
            rows[direction].append(cell.crop(bounds))
    return rows


def _normalize_row(source_frames: list[Image.Image], direction: str) -> list[Image.Image]:
    scale = BODY_TARGET_HEIGHT / SOURCE_BODY_HEIGHTS[direction]
    normalized: list[Image.Image] = []
    for source in source_frames:
        target_size = (
            max(1, round(source.width * scale)),
            max(1, round(source.height * scale)),
        )
        resized = source.resize(target_size, Image.Resampling.NEAREST)
        resized = _quantize_to_king_palette(_hard_alpha(resized))
        normalized.append(resized)
    return normalized


def _place_frame(content: Image.Image) -> Image.Image:
    frame = Image.new("RGBA", (RUNTIME_CELL_SIZE, RUNTIME_CELL_SIZE), (0, 0, 0, 0))
    foot_center = _foot_center_x(content)
    destination_x = round(FOOT_CENTER_X - foot_center)
    destination_y = FOOT_PIXEL_Y - (content.height - 1)
    if (
        destination_x < SAFE_MARGIN
        or destination_y < SAFE_MARGIN
        or destination_x + content.width > RUNTIME_CELL_SIZE - SAFE_MARGIN
        or destination_y + content.height > RUNTIME_CELL_SIZE - SAFE_MARGIN
    ):
        raise ValueError(
            "King normalized frame exceeds its safe 64x64 cell: "
            f"destination=({destination_x},{destination_y}), size={content.size}."
        )
    frame.alpha_composite(content, (destination_x, destination_y))
    return frame


def _mirror_frame(frame: Image.Image) -> Image.Image:
    return frame.transpose(Image.Transpose.FLIP_LEFT_RIGHT)


def _sword_guard_anchor(body: Image.Image, direction: str) -> tuple[int, int]:
    bounds = _visible_bounds(body)
    if direction == "down":
        return bounds[2] + 1, bounds[1] + 11
    if direction == "left":
        return bounds[2] + 1, bounds[1] + 14
    if direction == "up":
        return bounds[2], bounds[1] + 18
    raise ValueError(f"Unsupported King sword direction: {direction}.")


def _draw_straight_idle_sword(body: Image.Image, direction: str) -> tuple[Image.Image, dict[str, object]]:
    """Return one rigid sword/hand layer on a single 45-degree axis."""

    guard_x, guard_y = _sword_guard_anchor(body, direction)
    axis_x, axis_y = SWORD_AXIS
    blade_root = (guard_x + axis_x, guard_y + axis_y)
    blade_tip = (
        guard_x + axis_x * SWORD_BLADE_LENGTH,
        guard_y + axis_y * SWORD_BLADE_LENGTH,
    )
    pommel = (
        guard_x - axis_x * SWORD_GRIP_LENGTH,
        guard_y - axis_y * SWORD_GRIP_LENGTH,
    )
    hand = (
        guard_x - axis_x * 4,
        guard_y - axis_y * 4,
    )

    if not (
        SAFE_MARGIN <= blade_tip[0] < RUNTIME_CELL_SIZE - SAFE_MARGIN
        and SAFE_MARGIN <= blade_tip[1] < RUNTIME_CELL_SIZE - SAFE_MARGIN
        and SAFE_MARGIN <= pommel[0] < RUNTIME_CELL_SIZE - SAFE_MARGIN
        and SAFE_MARGIN <= pommel[1] < RUNTIME_CELL_SIZE - SAFE_MARGIN
    ):
        raise ValueError(
            f"King {direction} idle sword exceeds its safe cell: "
            f"tip={blade_tip}, pommel={pommel}."
        )

    layer = Image.new("RGBA", body.size, (0, 0, 0, 0))
    draw = ImageDraw.Draw(layer)

    # The bent armored forearm reaches the same grip point; it is deliberately
    # short and overlaps the body's sword-side shoulder rather than creating a
    # third floating hand.
    shoulder = (guard_x - 2, guard_y + 3)
    draw.line((shoulder, hand), fill=SWORD_COLORS["outline"], width=3)
    draw.line((shoulder, hand), fill=SWORD_COLORS["sleeve"], width=1)

    # One collinear weapon: broad outlined blade and core channel, then the
    # grip on the exact inverse extension of the same axis.
    draw.line((blade_root, blade_tip), fill=SWORD_COLORS["outline"], width=7)
    draw.line((blade_root, blade_tip), fill=SWORD_COLORS["blade"], width=5)
    draw.line((blade_root, blade_tip), fill=SWORD_COLORS["channel"], width=2)
    draw.point((blade_tip[0] - 1, blade_tip[1]), fill=SWORD_COLORS["edge"])
    draw.point((blade_tip[0], blade_tip[1] + 1), fill=SWORD_COLORS["edge"])

    draw.line(((guard_x, guard_y), pommel), fill=SWORD_COLORS["outline"], width=3)
    draw.line(((guard_x, guard_y), pommel), fill=SWORD_COLORS["grip"], width=1)

    # Guard is perpendicular to the shared blade/grip axis.
    perpendicular = (1, 1)
    guard_start = (guard_x - perpendicular[0] * 3, guard_y - perpendicular[1] * 3)
    guard_end = (guard_x + perpendicular[0] * 3, guard_y + perpendicular[1] * 3)
    draw.line((guard_start, guard_end), fill=SWORD_COLORS["outline"], width=3)
    draw.line((guard_start, guard_end), fill=SWORD_COLORS["gold"], width=1)

    # Hand wraps around the actual grip; the pommel and cord originate from
    # that same grip rather than a second offset object.
    draw.rectangle(
        (hand[0] - 1, hand[1] - 1, hand[0] + 1, hand[1] + 1),
        fill=SWORD_COLORS["outline"],
    )
    draw.point(hand, fill=SWORD_COLORS["skin"])
    draw.rectangle(
        (pommel[0] - 1, pommel[1] - 1, pommel[0] + 1, pommel[1] + 1),
        fill=SWORD_COLORS["outline"],
    )
    draw.point(pommel, fill=SWORD_COLORS["gold"])
    cord_start = (pommel[0], pommel[1] + 1)
    # Keep the cord visibly below the pommel but above the foot-measurement
    # band so presentation cannot corrupt the actor's gameplay anchor.
    cord_end = (pommel[0], min(RUNTIME_CELL_SIZE - SAFE_MARGIN - 1, pommel[1] + 4))
    draw.line((cord_start, cord_end), fill=SWORD_COLORS["cord"], width=1)
    draw.line(
        (cord_end, (cord_end[0] + 2, min(RUNTIME_CELL_SIZE - SAFE_MARGIN - 1, cord_end[1] + 2))),
        fill=SWORD_COLORS["cord"],
        width=1,
    )

    return layer, {
        "guard": [guard_x, guard_y],
        "blade_tip": list(blade_tip),
        "hand": list(hand),
        "pommel": list(pommel),
        "axis": [axis_x, axis_y],
    }


def _add_idle_swords(
    body_rows: dict[str, list[Image.Image]],
) -> tuple[dict[str, list[Image.Image]], dict[str, list[Image.Image]], list[dict[str, object]]]:
    sword_rows: dict[str, list[Image.Image]] = {direction: [] for direction in RUNTIME_DIRECTIONS}
    combined_rows: dict[str, list[Image.Image]] = {direction: [] for direction in RUNTIME_DIRECTIONS}
    sword_metrics: list[dict[str, object]] = []

    for direction in ("down", "left", "up"):
        for column, body in enumerate(body_rows[direction]):
            sword, metric = _draw_straight_idle_sword(body, direction)
            combined = body.copy()
            combined.alpha_composite(sword)
            sword_rows[direction].append(sword)
            combined_rows[direction].append(combined)
            sword_metrics.append({"direction": direction, "column": column, **metric})

    sword_rows["right"] = [_mirror_frame(frame) for frame in sword_rows["left"]]
    combined_rows["right"] = [_mirror_frame(frame) for frame in combined_rows["left"]]
    for column, metric in enumerate([entry for entry in sword_metrics if entry["direction"] == "left"]):
        sword_metrics.append(
            {
                "direction": "right",
                "column": column,
                "guard": [RUNTIME_CELL_SIZE - 1 - metric["guard"][0], metric["guard"][1]],
                "blade_tip": [RUNTIME_CELL_SIZE - 1 - metric["blade_tip"][0], metric["blade_tip"][1]],
                "hand": [RUNTIME_CELL_SIZE - 1 - metric["hand"][0], metric["hand"][1]],
                "pommel": [RUNTIME_CELL_SIZE - 1 - metric["pommel"][0], metric["pommel"][1]],
                "axis": [-1, -1],
            }
        )
    sword_metrics.sort(key=lambda entry: (RUNTIME_DIRECTIONS.index(entry["direction"]), entry["column"]))
    return sword_rows, combined_rows, sword_metrics


def _opaque_points(image: Image.Image) -> set[tuple[int, int]]:
    alpha = image.getchannel("A")
    return {
        (x, y)
        for y in range(image.height)
        for x in range(image.width)
        if alpha.getpixel((x, y)) == 255
    }


def _largest_component_ratio(image: Image.Image) -> float:
    remaining = _opaque_points(image)
    total = len(remaining)
    if total == 0:
        return 0.0
    largest = 0
    neighbors = (
        (-1, -1),
        (0, -1),
        (1, -1),
        (-1, 0),
        (1, 0),
        (-1, 1),
        (0, 1),
        (1, 1),
    )
    while remaining:
        start = remaining.pop()
        queue: deque[tuple[int, int]] = deque((start,))
        count = 1
        while queue:
            x, y = queue.popleft()
            for offset_x, offset_y in neighbors:
                neighbor = (x + offset_x, y + offset_y)
                if neighbor not in remaining:
                    continue
                remaining.remove(neighbor)
                queue.append(neighbor)
                count += 1
        largest = max(largest, count)
    return largest / total


def _frame_metrics(frame: Image.Image, direction: str, column: int) -> dict[str, object]:
    bounds = _visible_bounds(frame)
    alpha = frame.getchannel("A")
    opaque_count = sum(
        1
        for y in range(frame.height)
        for x in range(frame.width)
        if alpha.getpixel((x, y)) == 255
    )
    foot_center = _foot_center_x(frame)
    component_ratio = _largest_component_ratio(frame)
    if bounds[3] != FOOT_PIXEL_Y + 1:
        raise ValueError(f"{direction} frame {column} lost the shared foot baseline: {bounds}.")
    if abs(foot_center - FOOT_CENTER_X) > 0.5:
        raise ValueError(
            f"{direction} frame {column} foot center drifted to {foot_center:.2f}."
        )
    if component_ratio < 0.86:
        raise ValueError(
            f"{direction} frame {column} has disconnected art "
            f"(largest component ratio {component_ratio:.3f})."
        )
    return {
        "direction": direction,
        "column": column,
        "bounds": list(bounds),
        "opaque_pixels": opaque_count,
        "foot_center_x": foot_center,
        "largest_component_ratio": round(component_ratio, 4),
    }


def _validate_runtime_sheet(sheet: Image.Image) -> None:
    expected_size = (
        RUNTIME_CELL_SIZE * RUNTIME_COLUMNS,
        RUNTIME_CELL_SIZE * RUNTIME_ROWS,
    )
    if sheet.size != expected_size:
        raise ValueError(f"King idle sheet is {sheet.size}; expected {expected_size}.")
    colors: set[tuple[int, int, int]] = set()
    for y in range(sheet.height):
        for x in range(sheet.width):
            red, green, blue, alpha = sheet.getpixel((x, y))
            if alpha not in (0, 255):
                raise ValueError(f"Non-binary alpha at ({x},{y}).")
            if alpha == 0:
                continue
            if _is_matte_magenta(red, green, blue):
                raise ValueError(f"Source-matte residue at ({x},{y}).")
            colors.add((red, green, blue))
    if len(colors) > len(KING_PALETTE):
        raise ValueError(f"King idle sheet has {len(colors)} colors; expected <= {len(KING_PALETTE)}.")


def _make_review(sheet: Image.Image, scale: int = 4) -> Image.Image:
    # Mid-value Forest/Rootbound checks keep King's charcoal outline visible;
    # a nearly black review surface can hide disconnected weapon pixels.
    checker = Image.new("RGBA", sheet.size, (58, 67, 52, 255))
    draw = ImageDraw.Draw(checker)
    for row in range(RUNTIME_ROWS):
        for column in range(RUNTIME_COLUMNS):
            if (row + column) % 2 == 0:
                draw.rectangle(
                    (
                        column * RUNTIME_CELL_SIZE,
                        row * RUNTIME_CELL_SIZE,
                        (column + 1) * RUNTIME_CELL_SIZE - 1,
                        (row + 1) * RUNTIME_CELL_SIZE - 1,
                    ),
                    fill=(55, 47, 66, 255),
                )
    checker.alpha_composite(sheet)
    grid = ImageDraw.Draw(checker)
    for index in range(1, RUNTIME_COLUMNS):
        x = index * RUNTIME_CELL_SIZE
        grid.line((x, 0, x, checker.height), fill=(96, 78, 112, 255), width=1)
    for index in range(1, RUNTIME_ROWS):
        y = index * RUNTIME_CELL_SIZE
        grid.line((0, y, checker.width, y), fill=(96, 78, 112, 255), width=1)
    return checker.resize((checker.width * scale, checker.height * scale), Image.Resampling.NEAREST)


def _runtime_rows(source: Image.Image) -> dict[str, list[Image.Image]]:
    extracted = _extract_source_cells(source)
    down = [_place_frame(frame) for frame in _normalize_row(extracted["down"], "down")]
    left = [_place_frame(frame) for frame in _normalize_row(extracted["left"], "left")]
    up = [_place_frame(frame) for frame in _normalize_row(extracted["up"], "up")]
    right = [_mirror_frame(frame) for frame in left]
    return {"down": down, "left": left, "right": right, "up": up}


def _pack_sheet(rows: dict[str, list[Image.Image]]) -> Image.Image:
    sheet = Image.new(
        "RGBA",
        (RUNTIME_COLUMNS * RUNTIME_CELL_SIZE, RUNTIME_ROWS * RUNTIME_CELL_SIZE),
        (0, 0, 0, 0),
    )
    for row, direction in enumerate(RUNTIME_DIRECTIONS):
        for column, frame in enumerate(rows[direction]):
            sheet.alpha_composite(
                frame,
                (column * RUNTIME_CELL_SIZE, row * RUNTIME_CELL_SIZE),
            )
    return sheet


def process(
    input_path: Path,
    output_path: Path,
    review_path: Path,
    metrics_path: Path,
    body_output_path: Path | None = None,
    sword_output_path: Path | None = None,
) -> None:
    source = Image.open(input_path).convert("RGBA")
    body_rows = _runtime_rows(source)
    sword_rows, rows, sword_metrics = _add_idle_swords(body_rows)
    metrics = [
        _frame_metrics(frame, direction, column)
        for direction in RUNTIME_DIRECTIONS
        for column, frame in enumerate(rows[direction])
    ]
    sheet = _pack_sheet(rows)
    body_sheet = _pack_sheet(body_rows)
    sword_sheet = _pack_sheet(sword_rows)
    _validate_runtime_sheet(sheet)
    _validate_runtime_sheet(body_sheet)
    _validate_runtime_sheet(sword_sheet)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    review_path.parent.mkdir(parents=True, exist_ok=True)
    metrics_path.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(output_path, optimize=True)
    if body_output_path is not None:
        body_output_path.parent.mkdir(parents=True, exist_ok=True)
        body_sheet.save(body_output_path, optimize=True)
    if sword_output_path is not None:
        sword_output_path.parent.mkdir(parents=True, exist_ok=True)
        sword_sheet.save(sword_output_path, optimize=True)
    _make_review(sheet).save(review_path, optimize=True)
    metrics_path.write_text(
        json.dumps(
            {
                "source": input_path.as_posix(),
                "runtime": output_path.as_posix(),
                "directions": list(RUNTIME_DIRECTIONS),
                "columns": RUNTIME_COLUMNS,
                "cell_size": [RUNTIME_CELL_SIZE, RUNTIME_CELL_SIZE],
                "sheet_size": list(sheet.size),
                "body_target_height": BODY_TARGET_HEIGHT,
                "foot_pixel_y": FOOT_PIXEL_Y,
                "foot_center_x": FOOT_CENTER_X,
                "opaque_palette_colors": len(KING_PALETTE),
                "right_row_derived_from": "exact horizontal mirror of left",
                "sword_construction": "single deterministic 45-degree tip-to-pommel axis",
                "sword_frames": sword_metrics,
                "frames": metrics,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )


def main(arguments: Iterable[str] | None = None) -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument(
        "--input",
        type=Path,
        default=Path(
            "art_source/cleaned/characters/playable/king/idle/"
            "king_idle_body_only_transparent_v1.png"
        ),
    )
    parser.add_argument(
        "--output",
        type=Path,
        default=Path("assets/characters/playable/king/king_idle_sheet_64x64.png"),
    )
    parser.add_argument(
        "--body-output",
        type=Path,
        default=Path("assets/characters/playable/king/king_idle_body_sheet_64x64.png"),
    )
    parser.add_argument(
        "--sword-output",
        type=Path,
        default=Path("assets/characters/playable/king/king_idle_sword_sheet_64x64.png"),
    )
    parser.add_argument(
        "--review",
        type=Path,
        default=Path(
            "art_source/review/characters/playable/king/king_idle_sheet_4x.png"
        ),
    )
    parser.add_argument(
        "--metrics",
        type=Path,
        default=Path(
            "art_source/review/characters/playable/king/king_idle_metrics.json"
        ),
    )
    args = parser.parse_args(arguments)
    process(
        args.input,
        args.output,
        args.review,
        args.metrics,
        args.body_output,
        args.sword_output,
    )
    print(f"Built King idle sheet: {args.output}")
    print(f"Built King idle review: {args.review}")
    print(f"Wrote King idle metrics: {args.metrics}")


if __name__ == "__main__":
    main()
