"""Build King's approved simple locomotion sheet and SpriteFrames resource.

The generated source is a presentation board, not an exact atlas.  This tool
finds the sixteen opaque sprite islands, applies one shared nearest-neighbour
scale, anchors every pose at the feet, and packs a strict 4x4 runtime atlas.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/king_simple_walk_transparent_v1.png"
RUNTIME_DIR = ROOT / "assets/characters/playable/king/simple_reboot"
REVIEW_DIR = ROOT / "art_source/review/characters/playable/king/simple_reboot"
SHEET = RUNTIME_DIR / "king_simple_locomotion_sheet_48x32.png"
FRAMES = RUNTIME_DIR / "king_simple_sprite_frames.tres"
REVIEW = REVIEW_DIR / "king_simple_locomotion_sheet_4x.png"

COLS = 4
ROWS = 4
CELL_W = 48
CELL_H = 32
BASELINE_Y = 30
ANCHOR_X = 24
ALPHA_THRESHOLD = 128
MIN_COMPONENT_PIXELS = 500
DIRECTIONS = ("down", "left", "right", "up")


def _components(image: Image.Image) -> list[tuple[int, int, int, int]]:
    alpha = image.getchannel("A")
    pixels = alpha.load()
    width, height = image.size
    visited = bytearray(width * height)
    components: list[tuple[int, int, int, int, int]] = []

    for y in range(height):
        for x in range(width):
            index = y * width + x
            if visited[index] or pixels[x, y] < ALPHA_THRESHOLD:
                continue
            queue: deque[tuple[int, int]] = deque([(x, y)])
            visited[index] = 1
            count = 0
            left = right = x
            top = bottom = y
            while queue:
                px, py = queue.popleft()
                count += 1
                left = min(left, px)
                right = max(right, px)
                top = min(top, py)
                bottom = max(bottom, py)
                for ny in range(max(0, py - 1), min(height, py + 2)):
                    row_start = ny * width
                    for nx in range(max(0, px - 1), min(width, px + 2)):
                        neighbor = row_start + nx
                        if not visited[neighbor] and pixels[nx, ny] >= ALPHA_THRESHOLD:
                            visited[neighbor] = 1
                            queue.append((nx, ny))
            if count >= MIN_COMPONENT_PIXELS:
                components.append((top, left, right + 1, bottom + 1, count))

    components.sort(key=lambda item: (item[0], item[1]))
    if len(components) != COLS * ROWS:
        raise RuntimeError(f"Expected 16 sprite islands, found {len(components)}")
    return [(left, top, right, bottom) for top, left, right, bottom, _ in components]


def _feet_anchor_x(sprite: Image.Image) -> int:
    alpha = sprite.getchannel("A")
    width, height = sprite.size
    sample_top = max(0, int(height * 0.72))
    xs = [
        x
        for y in range(sample_top, height)
        for x in range(width)
        if alpha.getpixel((x, y)) >= ALPHA_THRESHOLD
    ]
    if not xs:
        return width // 2
    return round((min(xs) + max(xs)) / 2)


def _build_resource() -> str:
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=18 format=3]',
        '',
        '[ext_resource type="Texture2D" path="res://assets/characters/playable/king/simple_reboot/king_simple_locomotion_sheet_48x32.png" id="1_sheet"]',
        '',
    ]
    atlas_ids: list[str] = []
    for row in range(ROWS):
        for col in range(COLS):
            atlas_id = f"AtlasTexture_{row}_{col}"
            atlas_ids.append(atlas_id)
            lines.extend(
                [
                    f'[sub_resource type="AtlasTexture" id="{atlas_id}"]',
                    'atlas = ExtResource("1_sheet")',
                    f'region = Rect2({col * CELL_W}, {row * CELL_H}, {CELL_W}, {CELL_H})',
                    '',
                ]
            )

    animations: list[str] = []
    for row, direction in enumerate(DIRECTIONS):
        animations.append(
            '{\n'
            f'"frames": [{{"duration": 1.0, "texture": SubResource("AtlasTexture_{row}_0")}}],\n'
            '"loop": true,\n'
            f'"name": &"idle_{direction}",\n'
            '"speed": 1.0\n'
            '}'
        )
        walk_frames = ', '.join(
            f'{{"duration": 1.0, "texture": SubResource("AtlasTexture_{row}_{col}")}}'
            for col in range(COLS)
        )
        animations.append(
            '{\n'
            f'"frames": [{walk_frames}],\n'
            '"loop": true,\n'
            f'"name": &"walk_{direction}",\n'
            '"speed": 8.0\n'
            '}'
        )

    lines.extend(['[resource]', 'animations = [' + ', '.join(animations) + ']', ''])
    return "\n".join(lines)


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    boxes = _components(source)
    max_height = max(bottom - top for left, top, right, bottom in boxes)
    scale = 28.0 / max_height

    sheet = Image.new("RGBA", (CELL_W * COLS, CELL_H * ROWS), (0, 0, 0, 0))
    for index, box in enumerate(boxes):
        row, col = divmod(index, COLS)
        sprite = source.crop(box)
        sprite.putalpha(sprite.getchannel("A").point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0))
        target_size = (
            max(1, round(sprite.width * scale)),
            max(1, round(sprite.height * scale)),
        )
        sprite = sprite.resize(target_size, Image.Resampling.NEAREST)
        anchor_x = _feet_anchor_x(sprite)
        paste_x = col * CELL_W + ANCHOR_X - anchor_x
        paste_y = row * CELL_H + BASELINE_Y - sprite.height
        cell_left = col * CELL_W
        cell_right = cell_left + CELL_W
        if paste_x < cell_left or paste_x + sprite.width > cell_right or paste_y < row * CELL_H:
            raise RuntimeError(f"Frame {index} does not fit its exact cell")
        sheet.alpha_composite(sprite, (paste_x, paste_y))

    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    sheet.save(SHEET)
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.Resampling.NEAREST).save(REVIEW)
    FRAMES.write_text(_build_resource(), encoding="utf-8")
    print(f"Wrote {SHEET.relative_to(ROOT)}")
    print(f"Wrote {FRAMES.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
