"""Normalize approved Echoing Sever VFX boards into exact runtime atlases.

The generated 3x2 boards are source art, not runtime sheets. This processor
keeps their shared cell geometry, applies nearest-neighbour reduction, forces
binary alpha, limits the palette, and writes deterministic SpriteFrames data.
"""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
SOURCE_DIR = ROOT / "art_source/generated/characters/playable/king/simple_reboot/echoing_sever"
RUNTIME_DIR = ROOT / "assets/vfx/abilities/king"
REVIEW_DIR = ROOT / "art_source/review/characters/playable/king/simple_reboot/echoing_sever"

PRIMARY_SOURCE = SOURCE_DIR / "echoing_sever_primary_vfx_clean_v1.png"
ECHO_SOURCE = SOURCE_DIR / "echoing_sever_echo_vfx_clean_v1.png"
PRIMARY_SHEET = RUNTIME_DIR / "echoing_sever_primary_vfx_sheet_160.png"
ECHO_SHEET = RUNTIME_DIR / "echoing_sever_echo_vfx_sheet_160.png"
FRAMES_RESOURCE = RUNTIME_DIR / "echoing_sever_vfx_frames.tres"

SOURCE_COLS = 3
SOURCE_ROWS = 2
FRAME_COUNT = SOURCE_COLS * SOURCE_ROWS
SOURCE_CELL_WIDTH = 512
SOURCE_CELL_HEIGHT = 512
RUNTIME_CELL_SIZE = 160
ALPHA_THRESHOLD = 96
PALETTE_COLORS = 24


def _normalize_board(
    source_path: Path,
    output_path: Path,
    *,
    mirror_cells: bool = False,
) -> list[tuple[int, int, int, int]]:
    source = Image.open(source_path).convert("RGBA")
    expected_size = (
        SOURCE_CELL_WIDTH * SOURCE_COLS,
        SOURCE_CELL_HEIGHT * SOURCE_ROWS,
    )
    if source.size != expected_size:
        raise RuntimeError(f"{source_path.name} must be {expected_size}, got {source.size}")

    atlas = Image.new(
        "RGBA",
        (RUNTIME_CELL_SIZE * SOURCE_COLS, RUNTIME_CELL_SIZE * SOURCE_ROWS),
        (0, 0, 0, 0),
    )
    occupied_bounds: list[tuple[int, int, int, int]] = []
    for frame_index in range(FRAME_COUNT):
        row, column = divmod(frame_index, SOURCE_COLS)
        cell = source.crop(
            (
                column * SOURCE_CELL_WIDTH,
                row * SOURCE_CELL_HEIGHT,
                (column + 1) * SOURCE_CELL_WIDTH,
                (row + 1) * SOURCE_CELL_HEIGHT,
            )
        )
        cell = cell.resize(
            (RUNTIME_CELL_SIZE, RUNTIME_CELL_SIZE),
            Image.Resampling.NEAREST,
        )
        if mirror_cells:
            # The approved concept showed King cutting toward screen-left. The
            # runtime atlas is canonical +X/right-facing because AbilityPivot
            # rotates that basis to the exact confirmed aim direction.
            cell = ImageOps.mirror(cell)
        binary_alpha = cell.getchannel("A").point(
            lambda value: 255 if value >= ALPHA_THRESHOLD else 0
        )
        quantized = cell.quantize(
            colors=PALETTE_COLORS,
            method=Image.Quantize.FASTOCTREE,
        ).convert("RGBA")
        quantized.putalpha(binary_alpha)
        bbox = binary_alpha.getbbox()
        if bbox is None:
            raise RuntimeError(f"{source_path.name} frame {frame_index} is empty")
        occupied_bounds.append(bbox)
        atlas.alpha_composite(
            quantized,
            (column * RUNTIME_CELL_SIZE, row * RUNTIME_CELL_SIZE),
        )

    output_path.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(output_path, optimize=True)
    return occupied_bounds


def _atlas_resource(resource_id: str, texture_id: str, frame_index: int) -> str:
    row, column = divmod(frame_index, SOURCE_COLS)
    return "\n".join(
        [
            f'[sub_resource type="AtlasTexture" id="{resource_id}"]',
            f'atlas = ExtResource("{texture_id}")',
            (
                "region = Rect2("
                f"{column * RUNTIME_CELL_SIZE}, {row * RUNTIME_CELL_SIZE}, "
                f"{RUNTIME_CELL_SIZE}, {RUNTIME_CELL_SIZE})"
            ),
            "",
        ]
    )


def _animation(name: str, resource_ids: list[str], speed: float, loop: bool) -> str:
    frames = ", ".join(
        f'{{"duration": 1.0, "texture": SubResource("{resource_id}")}}'
        for resource_id in resource_ids
    )
    return "\n".join(
        [
            "{",
            f'"frames": [{frames}],',
            f'"loop": {str(loop).lower()},',
            f'"name": &"{name}",',
            f'"speed": {speed:.1f}',
            "}",
        ]
    )


def _write_frames_resource() -> None:
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=15 format=3]',
        "",
        '[ext_resource type="Texture2D" path="res://assets/vfx/abilities/king/echoing_sever_primary_vfx_sheet_160.png" id="1_primary"]',
        '[ext_resource type="Texture2D" path="res://assets/vfx/abilities/king/echoing_sever_echo_vfx_sheet_160.png" id="2_echo"]',
        "",
    ]
    for index in range(FRAME_COUNT):
        lines.append(_atlas_resource(f"PrimaryAtlas_{index}", "1_primary", index))
    for index in range(FRAME_COUNT):
        lines.append(_atlas_resource(f"EchoAtlas_{index}", "2_echo", index))

    animations = [
        _animation("wind_up", ["PrimaryAtlas_0", "PrimaryAtlas_1"], 12.0, False),
        _animation(
            "primary",
            ["PrimaryAtlas_2", "PrimaryAtlas_3", "PrimaryAtlas_4", "PrimaryAtlas_5"],
            24.0,
            False,
        ),
        _animation("rift_hold", ["EchoAtlas_0", "EchoAtlas_1"], 4.0, True),
        _animation(
            "echo",
            ["EchoAtlas_2", "EchoAtlas_3", "EchoAtlas_4", "EchoAtlas_5"],
            24.0,
            False,
        ),
    ]
    lines.extend(["[resource]", "animations = [" + ", ".join(animations) + "]", ""])
    FRAMES_RESOURCE.write_text("\n".join(lines), encoding="utf-8")


def _write_review(primary: Image.Image, echo: Image.Image) -> None:
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    review = Image.new("RGBA", (primary.width * 4, primary.height * 2 * 4), (18, 24, 34, 255))
    review.alpha_composite(primary.resize((primary.width * 4, primary.height * 4), Image.Resampling.NEAREST), (0, 0))
    review.alpha_composite(echo.resize((echo.width * 4, echo.height * 4), Image.Resampling.NEAREST), (0, primary.height * 4))
    review.save(REVIEW_DIR / "echoing_sever_vfx_review_4x.png", optimize=True)


def main() -> None:
    primary_bounds = _normalize_board(PRIMARY_SOURCE, PRIMARY_SHEET, mirror_cells=True)
    echo_bounds = _normalize_board(ECHO_SOURCE, ECHO_SHEET)
    primary_peak = primary_bounds[2]
    if (primary_peak[0] + primary_peak[2]) / 2.0 <= RUNTIME_CELL_SIZE / 2.0:
        raise RuntimeError("Primary cleave peak still reads behind the canonical +X origin")
    _write_frames_resource()
    primary = Image.open(PRIMARY_SHEET).convert("RGBA")
    echo = Image.open(ECHO_SHEET).convert("RGBA")
    _write_review(primary, echo)
    print(f"Wrote {PRIMARY_SHEET.relative_to(ROOT)} bounds={primary_bounds}")
    print(f"Wrote {ECHO_SHEET.relative_to(ROOT)} bounds={echo_bounds}")
    print(f"Wrote {FRAMES_RESOURCE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
