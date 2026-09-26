"""Pack Sovereign Pursuit's generated travel aura into three hard-pixel frames."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/sovereign_pursuit/sovereign_pursuit_travel_vfx_clean_v1.png"
RUNTIME_DIR = ROOT / "assets/vfx/abilities/king"
REVIEW_DIR = ROOT / "art_source/review/characters/playable/king/simple_reboot/sovereign_pursuit"
SHEET = RUNTIME_DIR / "sovereign_pursuit_travel_vfx_sheet_128.png"
FRAMES = RUNTIME_DIR / "sovereign_pursuit_travel_vfx_frames.tres"
REVIEW = REVIEW_DIR / "sovereign_pursuit_travel_vfx_review_4x.png"

FRAME_COUNT = 3
RUNTIME_CELL = 128
SOURCE_BORDER_CLEAR = 8
ALPHA_THRESHOLD = 96
PALETTE_COLORS = 20


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    if source.width % FRAME_COUNT != 0 or source.width // FRAME_COUNT != source.height:
        raise RuntimeError(f"Travel VFX source must be an exact 3x1 square-cell board, got {source.size}")
    source_cell = source.height
    atlas = Image.new("RGBA", (RUNTIME_CELL * FRAME_COUNT, RUNTIME_CELL), (0, 0, 0, 0))
    bounds: list[tuple[int, int, int, int]] = []

    for frame_index in range(FRAME_COUNT):
        left = frame_index * source_cell
        cell = source.crop((left, 0, left + source_cell, source_cell))
        # The generator placed white guide seams on the board perimeter. They
        # are layout artifacts, not part of the aura, so clear only that rim.
        alpha = cell.getchannel("A")
        for x in range(source_cell):
            for y in range(SOURCE_BORDER_CLEAR):
                alpha.putpixel((x, y), 0)
                alpha.putpixel((x, source_cell - 1 - y), 0)
        for y in range(source_cell):
            for x in range(SOURCE_BORDER_CLEAR):
                alpha.putpixel((x, y), 0)
                alpha.putpixel((source_cell - 1 - x, y), 0)
        cell.putalpha(alpha)
        cell = cell.resize((RUNTIME_CELL, RUNTIME_CELL), Image.Resampling.NEAREST)
        binary_alpha = cell.getchannel("A").point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0)
        bbox = binary_alpha.getbbox()
        if bbox is None:
            raise RuntimeError(f"Travel VFX frame {frame_index} is empty")
        quantized = cell.quantize(colors=PALETTE_COLORS, method=Image.Quantize.FASTOCTREE).convert("RGBA")
        quantized.putalpha(binary_alpha)
        bounds.append(bbox)
        atlas.alpha_composite(quantized, (frame_index * RUNTIME_CELL, 0))

    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    atlas.save(SHEET, optimize=True)
    review = Image.new("RGBA", (atlas.width * 4, atlas.height * 4), (18, 24, 34, 255))
    review.alpha_composite(atlas.resize((atlas.width * 4, atlas.height * 4), Image.Resampling.NEAREST), (0, 0))
    review.save(REVIEW, optimize=True)

    resources: list[str] = []
    entries: list[str] = []
    for frame_index in range(FRAME_COUNT):
        resources.extend(
            [
                f'[sub_resource type="AtlasTexture" id="TravelAtlas_{frame_index}"]',
                'atlas = ExtResource("1_vfx")',
                f'region = Rect2({frame_index * RUNTIME_CELL}, 0, {RUNTIME_CELL}, {RUNTIME_CELL})',
                "",
            ]
        )
        entries.append(f'{{"duration": 1.0, "texture": SubResource("TravelAtlas_{frame_index}")}}')
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=5 format=3]',
        "",
        '[ext_resource type="Texture2D" path="res://assets/vfx/abilities/king/sovereign_pursuit_travel_vfx_sheet_128.png" id="1_vfx"]',
        "",
        *resources,
        "[resource]",
        'animations = [{"frames": [' + ", ".join(entries) + '], "loop": false, "name": &"travel", "speed": 12.0}]',
        "",
    ]
    FRAMES.write_text("\n".join(lines), encoding="utf-8")
    print(f"Wrote {SHEET.relative_to(ROOT)} bounds={bounds}")
    print(f"Wrote {FRAMES.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
