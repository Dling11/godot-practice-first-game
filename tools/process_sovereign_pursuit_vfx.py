"""Normalize Sovereign Pursuit's generated 3x2 VFX board for Godot."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/sovereign_pursuit/sovereign_pursuit_vfx_clean_v1.png"
RUNTIME_DIR = ROOT / "assets/vfx/abilities/king"
REVIEW_DIR = ROOT / "art_source/review/characters/playable/king/simple_reboot/sovereign_pursuit"
SHEET = RUNTIME_DIR / "sovereign_pursuit_vfx_sheet_192.png"
FRAMES = RUNTIME_DIR / "sovereign_pursuit_vfx_frames.tres"
REVIEW = REVIEW_DIR / "sovereign_pursuit_vfx_review_4x.png"

COLS = 3
ROWS = 2
FRAME_COUNT = COLS * ROWS
SOURCE_CELL = 512
RUNTIME_CELL = 192
ALPHA_THRESHOLD = 88
PALETTE_COLORS = 32


def _atlas_resource(frame_index: int) -> str:
    row, column = divmod(frame_index, COLS)
    return "\n".join(
        [
            f'[sub_resource type="AtlasTexture" id="PursuitAtlas_{frame_index}"]',
            'atlas = ExtResource("1_vfx")',
            f'region = Rect2({column * RUNTIME_CELL}, {row * RUNTIME_CELL}, {RUNTIME_CELL}, {RUNTIME_CELL})',
            "",
        ]
    )


def _animation(name: str, frame_indices: list[int], speed: float, loop: bool) -> str:
    entries = ", ".join(
        f'{{"duration": 1.0, "texture": SubResource("PursuitAtlas_{index}")}}'
        for index in frame_indices
    )
    return "\n".join(
        ["{", f'"frames": [{entries}],', f'"loop": {str(loop).lower()},', f'"name": &"{name}",', f'"speed": {speed:.1f}', "}"]
    )


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    expected = (SOURCE_CELL * COLS, SOURCE_CELL * ROWS)
    if source.size != expected:
        raise RuntimeError(f"Sovereign Pursuit source must be {expected}, got {source.size}")

    atlas = Image.new("RGBA", (RUNTIME_CELL * COLS, RUNTIME_CELL * ROWS), (0, 0, 0, 0))
    bounds: list[tuple[int, int, int, int]] = []
    for frame_index in range(FRAME_COUNT):
        row, column = divmod(frame_index, COLS)
        cell = source.crop((column * SOURCE_CELL, row * SOURCE_CELL, (column + 1) * SOURCE_CELL, (row + 1) * SOURCE_CELL)).resize(
            (RUNTIME_CELL, RUNTIME_CELL), Image.Resampling.NEAREST
        )
        binary_alpha = cell.getchannel("A").point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0)
        bbox = binary_alpha.getbbox()
        if bbox is None:
            raise RuntimeError(f"Sovereign Pursuit frame {frame_index} is empty")
        quantized = cell.quantize(colors=PALETTE_COLORS, method=Image.Quantize.FASTOCTREE).convert("RGBA")
        quantized.putalpha(binary_alpha)
        bounds.append(bbox)
        atlas.alpha_composite(quantized, (column * RUNTIME_CELL, row * RUNTIME_CELL))

    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    atlas.save(SHEET, optimize=True)
    review = Image.new("RGBA", (atlas.width * 4, atlas.height * 4), (18, 24, 34, 255))
    review.alpha_composite(atlas.resize((atlas.width * 4, atlas.height * 4), Image.Resampling.NEAREST), (0, 0))
    review.save(REVIEW, optimize=True)

    lines = [
        '[gd_resource type="SpriteFrames" load_steps=8 format=3]',
        "",
        '[ext_resource type="Texture2D" path="res://assets/vfx/abilities/king/sovereign_pursuit_vfx_sheet_192.png" id="1_vfx"]',
        "",
    ]
    for frame_index in range(FRAME_COUNT):
        lines.append(_atlas_resource(frame_index))
    animations = [
        _animation("descent", [0, 1], 14.0, False),
        _animation("impact", [2, 3, 4], 18.0, False),
        _animation("residual", [5], 1.0, True),
    ]
    lines.extend(["[resource]", "animations = [" + ", ".join(animations) + "]", ""])
    FRAMES.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {SHEET.relative_to(ROOT)} bounds={bounds}")
    print(f"Wrote {FRAMES.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
