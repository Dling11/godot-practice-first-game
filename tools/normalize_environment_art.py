"""Normalize generated environment source art into Godot runtime assets.

The generated atlas boards are intentionally retained under art_source. This
script crops their 4x4 cells independently so source-board separators never
leak into the 64px runtime tiles. The arena seal is trimmed and fitted onto a
fixed transparent canvas while preserving its aspect ratio.
"""

from __future__ import annotations

import argparse
from pathlib import Path

from PIL import Image


ATLAS_GRID_SIZE = 4
RUNTIME_TILE_SIZE = 64


def normalize_atlas(source_path: Path, output_path: Path) -> None:
    source = Image.open(source_path).convert("RGBA")
    output = Image.new(
        "RGBA",
        (ATLAS_GRID_SIZE * RUNTIME_TILE_SIZE, ATLAS_GRID_SIZE * RUNTIME_TILE_SIZE),
    )

    for row in range(ATLAS_GRID_SIZE):
        for column in range(ATLAS_GRID_SIZE):
            left = round(column * source.width / ATLAS_GRID_SIZE)
            top = round(row * source.height / ATLAS_GRID_SIZE)
            right = round((column + 1) * source.width / ATLAS_GRID_SIZE)
            bottom = round((row + 1) * source.height / ATLAS_GRID_SIZE)

            cell_width = right - left
            cell_height = bottom - top
            # Generated boards may contain narrow dividers. Trimming 1.5% from
            # every cell edge removes them without losing the tile's identity.
            inset_x = max(2, round(cell_width * 0.015))
            inset_y = max(2, round(cell_height * 0.015))
            cell = source.crop(
                (left + inset_x, top + inset_y, right - inset_x, bottom - inset_y)
            )
            cell = cell.resize(
                (RUNTIME_TILE_SIZE, RUNTIME_TILE_SIZE), Image.Resampling.NEAREST
            )
            output.alpha_composite(
                cell, (column * RUNTIME_TILE_SIZE, row * RUNTIME_TILE_SIZE)
            )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    output.save(output_path, optimize=True)


def normalize_prop(source_path: Path, output_path: Path) -> None:
    source = Image.open(source_path).convert("RGBA")
    alpha_bounds = source.getchannel("A").getbbox()
    if alpha_bounds is None:
        raise ValueError(f"No visible pixels found in {source_path}")

    cropped = source.crop(alpha_bounds)
    canvas_size = (384, 224)
    margin = 8
    scale = min(
        (canvas_size[0] - margin * 2) / cropped.width,
        (canvas_size[1] - margin * 2) / cropped.height,
    )
    fitted_size = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    fitted = cropped.resize(fitted_size, Image.Resampling.NEAREST)
    canvas = Image.new("RGBA", canvas_size)
    position = (
        (canvas_size[0] - fitted.width) // 2,
        canvas_size[1] - margin - fitted.height,
    )
    canvas.alpha_composite(fitted, position)

    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output_path, optimize=True)


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("--forest-source", type=Path, required=True)
    parser.add_argument("--forest-output", type=Path, required=True)
    parser.add_argument("--rootbound-source", type=Path, required=True)
    parser.add_argument("--rootbound-output", type=Path, required=True)
    parser.add_argument("--seal-source", type=Path, required=True)
    parser.add_argument("--seal-output", type=Path, required=True)
    args = parser.parse_args()

    normalize_atlas(args.forest_source, args.forest_output)
    normalize_atlas(args.rootbound_source, args.rootbound_output)
    normalize_prop(args.seal_source, args.seal_output)


if __name__ == "__main__":
    main()
