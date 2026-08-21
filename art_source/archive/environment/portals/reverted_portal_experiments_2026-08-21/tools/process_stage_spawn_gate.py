"""Normalize a generated 4x4 dimensional-tear board into runtime pixel cells.

The bright tear edge keeps hard, readable pixels. Its interior uses a small set
of deliberate low-alpha values so the world remains visible through the gate.
"""

from __future__ import annotations

import argparse
from pathlib import Path

import numpy as np
from PIL import Image


FRAME_SIZES = (
    (18, 28),
    (18, 82),
    (30, 98),
    (42, 106),
    (56, 110),
    (64, 112),
    *((66, 112),) * 10,
)


def _cluster_centers(coordinates: np.ndarray, cluster_count: int) -> np.ndarray:
    """Find the visual grid centers without trusting generated cell spacing."""
    centers = np.linspace(float(coordinates.min()), float(coordinates.max()), cluster_count)
    for _iteration in range(32):
        labels = np.abs(coordinates[:, None] - centers[None, :]).argmin(axis=1)
        updated = np.array(
            [coordinates[labels == index].mean() for index in range(cluster_count)],
            dtype=np.float64,
        )
        if np.allclose(updated, centers, atol=0.05):
            break
        centers = updated
    return np.sort(centers)


def _cluster_bounds(centers: np.ndarray, extent: int) -> list[tuple[int, int]]:
    dividers = [0]
    dividers.extend(round((centers[index] + centers[index + 1]) * 0.5) for index in range(3))
    dividers.append(extent)
    return [(dividers[index], dividers[index + 1]) for index in range(4)]


def main() -> None:
    parser = argparse.ArgumentParser()
    parser.add_argument("source", type=Path)
    parser.add_argument("output", type=Path)
    args = parser.parse_args()

    source = Image.open(args.source).convert("RGB")
    source_pixels = np.asarray(source)
    source_height, source_width = source_pixels.shape[:2]
    source_maximum = source_pixels.max(axis=2)
    source_minimum = source_pixels.min(axis=2)
    source_checker = (source_minimum >= 232) & ((source_maximum - source_minimum) <= 14)
    source_content = (~source_checker) & ((255 - source_maximum) >= 12)
    content_y, content_x = np.nonzero(source_content)
    column_bounds = _cluster_bounds(_cluster_centers(content_x, 4), source_width)
    row_bounds = _cluster_bounds(_cluster_centers(content_y, 4), source_height)
    sheet = Image.new("RGBA", (96 * 4, 128 * 4), (0, 0, 0, 0))

    for frame_index in range(16):
        column = frame_index % 4
        row = frame_index // 4
        cell_x0, cell_x1 = column_bounds[column]
        cell_y0, cell_y1 = row_bounds[row]
        cell_content = source_content[cell_y0:cell_y1, cell_x0:cell_x1]
        local_y, local_x = np.nonzero(cell_content)
        padding = 4
        crop_x0 = max(cell_x0 + int(local_x.min()) - padding, 0)
        crop_x1 = min(cell_x0 + int(local_x.max()) + padding + 1, source_width)
        crop_y0 = max(cell_y0 + int(local_y.min()) - padding, 0)
        crop_y1 = min(cell_y0 + int(local_y.max()) + padding + 1, source_height)
        crop = source_pixels[crop_y0:crop_y1, crop_x0:crop_x1]

        maximum = crop.max(axis=2)
        minimum = crop.min(axis=2)
        baked_checker = (minimum >= 232) & ((maximum - minimum) <= 14)
        ink = 255 - maximum
        content = (~baked_checker) & (ink >= 12)
        rgba = np.dstack((maximum, maximum, maximum, np.where(content, 255, 0).astype(np.uint8)))
        target_width, target_height = FRAME_SIZES[frame_index]
        normalized = Image.fromarray(rgba, "RGBA").resize(
            (target_width, target_height), Image.Resampling.LANCZOS
        )
        frame = Image.new("RGBA", (96, 128), (0, 0, 0, 0))
        frame.alpha_composite(normalized, ((96 - target_width) // 2, (128 - target_height) // 2))

        hard_pixels = np.asarray(frame).copy()
        content = hard_pixels[:, :, 3] >= 104
        padded = np.pad(content, 1, constant_values=False)
        interior = content.copy()
        for offset_y in range(3):
            for offset_x in range(3):
                interior &= padded[offset_y:offset_y + 128, offset_x:offset_x + 96]
        boundary = content & ~interior

        darkness = 255 - hard_pixels[:, :, :3].max(axis=2)
        alpha = np.zeros((128, 96), dtype=np.uint8)
        # Keep the world readable through the tear, but give the veil enough
        # body to feel like dense moving energy instead of a faint ghost.
        alpha[interior & (darkness < 72)] = 92
        alpha[interior & (darkness >= 72)] = 120
        alpha[interior & (darkness >= 132)] = 148
        alpha[boundary & (darkness < 64)] = 220
        alpha[boundary & (darkness >= 64)] = 240
        alpha[boundary & (darkness >= 132)] = 255
        hard_pixels[:, :, 3] = alpha

        # Preserve the source's broad interior value bands so generated
        # corkscrew motion survives runtime tinting instead of becoming one
        # flat translucent fill. The edge remains uniformly white-hot.
        interior_value = np.clip(226.0 - darkness * 0.35, 148.0, 218.0)
        energy_value = np.where(boundary, 255, interior_value).astype(np.uint8)
        hard_pixels[:, :, 0] = energy_value
        hard_pixels[:, :, 1] = energy_value
        hard_pixels[:, :, 2] = energy_value
        hard_pixels[hard_pixels[:, :, 3] == 0, :3] = 0
        frame = Image.fromarray(hard_pixels, "RGBA")
        sheet.alpha_composite(frame, (column * 96, row * 128))

    args.output.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(args.output, optimize=True)


if __name__ == "__main__":
    main()
