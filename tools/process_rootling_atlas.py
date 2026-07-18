"""Normalize approved Rootling source boards into compact runtime atlases."""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


def _trim_visible(cell: Image.Image) -> Image.Image:
    alpha = cell.getchannel("A")
    bounds = alpha.point(lambda value: 255 if value >= 96 else 0).getbbox()
    if bounds is None:
        raise ValueError("Rootling source cell has no visible pixels.")
    padding = 3
    left = max(0, bounds[0] - padding)
    top = max(0, bounds[1] - padding)
    right = min(cell.width, bounds[2] + padding)
    bottom = min(cell.height, bounds[3] + padding)
    return cell.crop((left, top, right, bottom))


def _normalize(
    subject: Image.Image,
    maximum_content: tuple[int, int],
    scale_override: float | None = None,
) -> Image.Image:
    scale = scale_override if scale_override is not None else min(
        maximum_content[0] / subject.width,
        maximum_content[1] / subject.height,
    )
    size = (max(1, round(subject.width * scale)), max(1, round(subject.height * scale)))
    subject = subject.resize(size, Image.Resampling.NEAREST)
    pixels = subject.load()
    for y in range(subject.height):
        for x in range(subject.width):
            red, green, blue, alpha = pixels[x, y]
            pixels[x, y] = (red, green, blue, 255 if alpha >= 128 else 0)
    alpha = subject.getchannel("A")
    palette = subject.convert("RGB").quantize(
        colors=28,
        method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.NONE,
    ).convert("RGB")
    result = palette.convert("RGBA")
    result.putalpha(alpha)
    return result


def _crop_to_visible(subject: Image.Image) -> Image.Image:
    bounds = subject.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError("Rootling source cell has no visible pixels.")
    return subject.crop(bounds)


def _subjects_from_grid(source: Image.Image, columns: int, rows: int) -> list[list[Image.Image]]:
    source_cell_width = source.width // columns
    source_cell_height = source.height // rows
    subjects: list[list[Image.Image]] = []
    for row in range(rows):
        row_subjects: list[Image.Image] = []
        for column in range(columns):
            right = source.width if column == columns - 1 else (column + 1) * source_cell_width
            bottom = source.height if row == rows - 1 else (row + 1) * source_cell_height
            source_cell = source.crop((column * source_cell_width, row * source_cell_height, right, bottom))
            row_subjects.append(_trim_visible(source_cell))
        subjects.append(row_subjects)
    return subjects


def build_atlas(
    source_path: Path,
    output_path: Path,
    columns: int,
    rows: int,
    cell_width: int,
    cell_height: int,
    content_width: int,
    content_height: int,
    preserve_first_row_height: bool,
) -> None:
    source = Image.open(source_path).convert("RGBA")
    atlas = Image.new("RGBA", (cell_width * columns, cell_height * rows))
    subjects = _subjects_from_grid(source, columns, rows)

    # Every runtime direction comes from one approved Rootling board. Its front
    # poses have different arm/root spreads, so normalize their visible body
    # heights rather than fitting them independently by width.

    for row in range(rows):
        for column in range(columns):
            source_subject = subjects[row][column]
            presentation_subject = _crop_to_visible(source_subject) if preserve_first_row_height and row == 0 else source_subject
            scale_override = (content_height - 1) / presentation_subject.height if preserve_first_row_height and row == 0 else None
            subject = _normalize(presentation_subject, (content_width, content_height), scale_override)
            x = column * cell_width + (cell_width - subject.width) // 2
            y = row * cell_height + cell_height - subject.height - 2
            atlas.alpha_composite(subject, (x, y))
    output_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(output_path, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    parser.add_argument("--columns", type=int, required=True)
    parser.add_argument("--rows", type=int, required=True)
    parser.add_argument("--cell-width", type=int, required=True)
    parser.add_argument("--cell-height", type=int, required=True)
    parser.add_argument("--content-width", type=int, required=True)
    parser.add_argument("--content-height", type=int, required=True)
    parser.add_argument("--preserve-first-row-height", action="store_true")
    args = parser.parse_args()
    build_atlas(
        args.source,
        args.output,
        args.columns,
        args.rows,
        args.cell_width,
        args.cell_height,
        args.content_width,
        args.content_height,
        args.preserve_first_row_height,
    )


if __name__ == "__main__":
    main()
