"""Normalize the generated Stage 3 west-decay transition board."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = (
    ROOT
    / "art_source/generated/environment/stage_3/"
    / "stage_3_west_decay_transition_source_v1.png"
)
RUNTIME = (
    ROOT
    / "assets/environment/forest/rootbound_hollow/tiles/"
    / "stage_3_west_decay_transition_atlas_3x4.png"
)
STAGE_4_RUNTIME = (
    ROOT
    / "assets/environment/forest/rootbound_hollow/tiles/"
    / "stage_4_east_decay_transition_atlas_3x4.png"
)
REVIEW = (
    ROOT
    / "art_source/review/environment/stage_3/"
    / "stage_3_west_decay_transition_review_4x.png"
)

SOURCE_COLUMNS = 3
SOURCE_ROWS = 4
RUNTIME_CELL = 64
SOURCE_INSET = 3
PALETTE_COLORS = 72


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    atlas = Image.new(
        "RGBA",
        (SOURCE_COLUMNS * RUNTIME_CELL, SOURCE_ROWS * RUNTIME_CELL),
        (0, 0, 0, 255),
    )
    for index in range(SOURCE_COLUMNS * SOURCE_ROWS):
        row, column = divmod(index, SOURCE_COLUMNS)
        left = round(column * source.width / SOURCE_COLUMNS) + SOURCE_INSET
        top = round(row * source.height / SOURCE_ROWS) + SOURCE_INSET
        right = round((column + 1) * source.width / SOURCE_COLUMNS) - SOURCE_INSET
        bottom = round((row + 1) * source.height / SOURCE_ROWS) - SOURCE_INSET
        cell = source.crop((left, top, right, bottom))
        cell = cell.resize((RUNTIME_CELL, RUNTIME_CELL), Image.Resampling.LANCZOS)
        cell = cell.quantize(
            colors=PALETTE_COLORS,
            method=Image.Quantize.FASTOCTREE,
        ).convert("RGBA")
        atlas.paste(cell, (column * RUNTIME_CELL, row * RUNTIME_CELL))
    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    REVIEW.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(RUNTIME, optimize=True)
    atlas.transpose(Image.Transpose.FLIP_LEFT_RIGHT).save(
        STAGE_4_RUNTIME,
        optimize=True,
    )
    atlas.resize(
        (atlas.width * 4, atlas.height * 4),
        Image.Resampling.NEAREST,
    ).save(REVIEW, optimize=True)
    print(f"Wrote {RUNTIME.relative_to(ROOT)}")
    print(f"Wrote {STAGE_4_RUNTIME.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
