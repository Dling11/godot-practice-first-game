"""Normalize King's unified eight-frame sword and ground VFX."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CLEAN_DIR = ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/skill_4"
RUNTIME_DIR = ROOT / "assets/vfx/abilities/king"
REVIEW_DIR = ROOT / "art_source/review/characters/playable/king/simple_reboot/skill_4"

SWORD_SOURCE = CLEAN_DIR / "skill_4_spirit_sword_frames_clean_v2.png"
GROUND_SOURCE = CLEAN_DIR / "skill_4_ground_vfx_clean_v3.png"
SWORD_RUNTIME = RUNTIME_DIR / "king_skill_4_spirit_sword_sheet_144x192.png"
SWORD_FRAMES = RUNTIME_DIR / "king_skill_4_spirit_sword_frames.tres"
GROUND_RUNTIME = RUNTIME_DIR / "king_skill_4_ground_vfx_sheet_256.png"
GROUND_FRAMES = RUNTIME_DIR / "king_skill_4_ground_vfx_frames.tres"
REVIEW = REVIEW_DIR / "king_skill_4_vfx_review_3x.png"

SOURCE_COLS = 4
SOURCE_ROWS = 2
GROUND_CELL = 256
SWORD_SOURCE_COLS = 4
SWORD_SOURCE_ROWS = 2
SWORD_FRAME_SIZE = (144, 192)
SWORD_POINT_Y = 188
GROUND_CONTACT = (128, 152)
ALPHA_THRESHOLD = 88
PALETTE_COLORS = 40

# Reviewed contact/socket centers inside each proportional source cell. The
# generated board is 1774x887, so rounded proportional boundaries avoid losing
# a column/row while preserving one target anchor across all eight frames.
GROUND_SOURCE_ANCHORS = (
    (220, 265),
    (201, 266),
    (204, 266),
    (205, 271),
    (218, 230),
    (213, 233),
    (205, 237),
    (208, 262),
)
GROUND_RUNTIME_OFFSETS = (
    (0, 0),
    (0, 0),
    (0, 0),
    (0, 0),
    (0, 0),
    (0, 0),
	(0, 0),
	(0, 9),
)


def _binary_quantized(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A").point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0)
    if alpha.getbbox() is None:
        raise RuntimeError("Generated Skill 4 frame became empty after alpha cleanup")
    quantized = image.quantize(colors=PALETTE_COLORS, method=Image.Quantize.FASTOCTREE).convert("RGBA")
    quantized.putalpha(alpha)
    return quantized


def _process_sword() -> list[tuple[int, int, int, int]]:
    source = Image.open(SWORD_SOURCE).convert("RGBA")
    if source.size != (1536, 1024):
        raise RuntimeError(f"Skill 4 sword-frame source must be 1536x1024, got {source.size}")
    source_cell = (source.width // SWORD_SOURCE_COLS, source.height // SWORD_SOURCE_ROWS)
    atlas = Image.new(
        "RGBA",
        (SWORD_FRAME_SIZE[0] * SWORD_SOURCE_COLS, SWORD_FRAME_SIZE[1] * SWORD_SOURCE_ROWS),
        (0, 0, 0, 0),
    )
    bounds: list[tuple[int, int, int, int]] = []
    for index in range(SWORD_SOURCE_COLS * SWORD_SOURCE_ROWS):
        row, column = divmod(index, SWORD_SOURCE_COLS)
        cell = source.crop(
            (
                column * source_cell[0],
                row * source_cell[1],
                (column + 1) * source_cell[0],
                (row + 1) * source_cell[1],
            )
        ).resize(SWORD_FRAME_SIZE, Image.Resampling.NEAREST)
        cell = _binary_quantized(cell)
        bbox = cell.getchannel("A").getbbox()
        if bbox is None:
            raise RuntimeError(f"Skill 4 sword frame {index} lost its point baseline: {bbox}")
        aligned = Image.new("RGBA", SWORD_FRAME_SIZE, (0, 0, 0, 0))
        aligned.alpha_composite(cell, (0, SWORD_POINT_Y - bbox[3]))
        cell = aligned
        bbox = cell.getchannel("A").getbbox()
        if bbox is None or bbox[3] != SWORD_POINT_Y:
            raise RuntimeError(f"Skill 4 sword frame {index} could not align to y={SWORD_POINT_Y}: {bbox}")
        bounds.append(bbox)
        atlas.alpha_composite(cell, (column * SWORD_FRAME_SIZE[0], row * SWORD_FRAME_SIZE[1]))
    atlas.save(SWORD_RUNTIME, optimize=True)
    return bounds


def _source_rect(source: Image.Image, index: int) -> tuple[int, int, int, int]:
    row, column = divmod(index, SOURCE_COLS)
    return (
        round(column * source.width / SOURCE_COLS),
        round(row * source.height / SOURCE_ROWS),
        round((column + 1) * source.width / SOURCE_COLS),
        round((row + 1) * source.height / SOURCE_ROWS),
    )


def _process_ground() -> list[tuple[int, int, int, int]]:
    source = Image.open(GROUND_SOURCE).convert("RGBA")
    atlas = Image.new(
        "RGBA",
        (GROUND_CELL * SOURCE_COLS, GROUND_CELL * SOURCE_ROWS),
        (0, 0, 0, 0),
    )
    bounds: list[tuple[int, int, int, int]] = []
    for index, source_anchor in enumerate(GROUND_SOURCE_ANCHORS):
        row, column = divmod(index, SOURCE_COLS)
        source_rect = _source_rect(source, index)
        source_cell_size = (source_rect[2] - source_rect[0], source_rect[3] - source_rect[1])
        cell = source.crop(source_rect).resize((GROUND_CELL, GROUND_CELL), Image.Resampling.NEAREST)
        cell = _binary_quantized(cell)
        scaled_anchor = (
            round(source_anchor[0] * GROUND_CELL / source_cell_size[0]),
            round(source_anchor[1] * GROUND_CELL / source_cell_size[1]),
        )
        runtime_offset = GROUND_RUNTIME_OFFSETS[index]
        offset = (
            GROUND_CONTACT[0] - scaled_anchor[0] + runtime_offset[0],
            GROUND_CONTACT[1] - scaled_anchor[1] + runtime_offset[1],
        )
        aligned = Image.new("RGBA", (GROUND_CELL, GROUND_CELL), (0, 0, 0, 0))
        aligned.alpha_composite(cell, offset)
        bbox = aligned.getchannel("A").getbbox()
        if bbox is None:
            raise RuntimeError(f"Skill 4 ground frame {index} was lost during alignment")
        bounds.append(bbox)
        atlas.alpha_composite(aligned, (column * GROUND_CELL, row * GROUND_CELL))
    atlas.save(GROUND_RUNTIME, optimize=True)
    return bounds


def _atlas(index: int) -> str:
    row, column = divmod(index, SOURCE_COLS)
    return "\n".join(
        [
            f'[sub_resource type="AtlasTexture" id="Skill4Ground_{index}"]',
            'atlas = ExtResource("1_ground")',
            f'region = Rect2({column * GROUND_CELL}, {row * GROUND_CELL}, {GROUND_CELL}, {GROUND_CELL})',
            "",
        ]
    )


def _sword_atlas(index: int) -> str:
    row, column = divmod(index, SWORD_SOURCE_COLS)
    return "\n".join(
        [
            f'[sub_resource type="AtlasTexture" id="Skill4Sword_{index}"]',
            'atlas = ExtResource("1_sword")',
            f'region = Rect2({column * SWORD_FRAME_SIZE[0]}, {row * SWORD_FRAME_SIZE[1]}, {SWORD_FRAME_SIZE[0]}, {SWORD_FRAME_SIZE[1]})',
            "",
        ]
    )


def _animation(name: str, indices: list[int], speed: float, loop: bool) -> str:
    frames = ", ".join(
        f'{{"duration": 1.0, "texture": SubResource("Skill4Ground_{index}")}}'
        for index in indices
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


def _write_frames() -> None:
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=10 format=3]',
        "",
        '[ext_resource type="Texture2D" path="res://assets/vfx/abilities/king/king_skill_4_ground_vfx_sheet_256.png" id="1_ground"]',
        "",
    ]
    lines.extend(_atlas(index) for index in range(SOURCE_COLS * SOURCE_ROWS))
    animations = [
        _animation("build_up", [0, 1, 2, 3, 4, 5], 15.0, False),
        _animation("explosion", [6], 1.0, False),
        _animation("crater", [7], 1.0, True),
    ]
    lines.extend(["[resource]", "animations = [" + ", ".join(animations) + "]", ""])
    GROUND_FRAMES.write_text("\n".join(lines), encoding="utf-8")


def _write_sword_frames() -> None:
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=10 format=3]',
        "",
        '[ext_resource type="Texture2D" path="res://assets/vfx/abilities/king/king_skill_4_spirit_sword_sheet_144x192.png" id="1_sword"]',
        "",
    ]
    lines.extend(_sword_atlas(index) for index in range(SWORD_SOURCE_COLS * SWORD_SOURCE_ROWS))
    animations = [
        "\n".join(
            [
                "{",
                '"frames": [' + ", ".join(f'{{"duration": 1.0, "texture": SubResource("Skill4Sword_{index}")}}' for index in [0, 1, 2]) + "],",
                '"loop": false,',
                '"name": &"formation",',
                '"speed": 6.25',
                "}",
            ]
        ),
        "\n".join(
            [
                "{",
                '"frames": [' + ", ".join(f'{{"duration": 1.0, "texture": SubResource("Skill4Sword_{index}")}}' for index in [3, 4, 5, 6]) + "],",
                '"loop": false,',
                '"name": &"embedded",',
                '"speed": 10.0',
                "}",
            ]
        ),
        "\n".join(
            [
                "{",
                '"frames": [{"duration": 1.0, "texture": SubResource("Skill4Sword_7")}],',
                '"loop": false,',
                '"name": &"dissolve",',
                '"speed": 1.0',
                "}",
            ]
        ),
    ]
    lines.extend(["[resource]", "animations = [" + ", ".join(animations) + "]", ""])
    SWORD_FRAMES.write_text("\n".join(lines), encoding="utf-8")


def _write_review() -> None:
    ground = Image.open(GROUND_RUNTIME).convert("RGBA")
    canvas = Image.new("RGBA", ground.size, (18, 24, 34, 255))
    canvas.alpha_composite(ground)
    canvas = canvas.resize((canvas.width * 2, canvas.height * 2), Image.Resampling.NEAREST)
    canvas.save(REVIEW, optimize=True)


def main() -> None:
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    sword_bounds = _process_sword()
    ground_bounds = _process_ground()
    _write_sword_frames()
    _write_frames()
    _write_review()
    print(f"Wrote {SWORD_RUNTIME.relative_to(ROOT)} bounds={sword_bounds}")
    print(f"Wrote {SWORD_FRAMES.relative_to(ROOT)}")
    print(f"Wrote {GROUND_RUNTIME.relative_to(ROOT)} bounds={ground_bounds}")
    print(f"Wrote {GROUND_FRAMES.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
