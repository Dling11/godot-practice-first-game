"""Build King's approved simple locomotion/basic-slash SpriteFrames package.

The generated source is a presentation board, not an exact atlas.  This tool
finds the opaque sprite islands, applies one shared nearest-neighbour scale per
direction sheet, anchors every pose at the feet, and packs strict atlases.
"""

from __future__ import annotations

from collections import deque
from pathlib import Path

from PIL import Image, ImageOps


ROOT = Path(__file__).resolve().parents[1]
LOCOMOTION_SOURCE = ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/king_simple_walk_transparent_v1.png"
ATTACK_SOURCES = {
    "down": ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/king_simple_attack_down_transparent_v2.png",
    "right": ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/king_simple_attack_right_transparent_v2.png",
    "up": ROOT / "art_source/cleaned/characters/playable/king/simple_reboot/king_simple_attack_up_transparent_v2.png",
}
RUNTIME_DIR = ROOT / "assets/characters/playable/king/simple_reboot"
REVIEW_DIR = ROOT / "art_source/review/characters/playable/king/simple_reboot"
SHEET = RUNTIME_DIR / "king_simple_locomotion_sheet_48x32.png"
ATTACK_SHEET = RUNTIME_DIR / "king_simple_basic_slash_sheet_64x32.png"
FRAMES = RUNTIME_DIR / "king_simple_sprite_frames.tres"
REVIEW = REVIEW_DIR / "king_simple_locomotion_sheet_4x.png"
ATTACK_REVIEW = REVIEW_DIR / "king_simple_basic_slash_sheet_4x.png"

LOCOMOTION_COLS = 4
ATTACK_COLS = 6
ROWS = 4
CELL_W = 48
CELL_H = 32
ATTACK_CELL_W = 64
BASELINE_Y = 30
ATTACK_SCALE_FACTOR = 0.88
ALPHA_THRESHOLD = 128
MIN_COMPONENT_PIXELS = 500
DIRECTIONS = ("down", "left", "right", "up")


def _components(image: Image.Image, expected_count: int) -> list[tuple[int, int, int, int]]:
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

    if len(components) != expected_count:
        raise RuntimeError(f"Expected {expected_count} sprite islands, found {len(components)}")
    if expected_count == ATTACK_COLS:
        # A direction attack source is one authored timeline. Height changes are
        # acting, not row changes, so preserve strict left-to-right chronology.
        components.sort(key=lambda item: item[1])
    else:
        # Locomotion is a 4x4 board. Cluster by vertical centre first so bobbing
        # inside a row cannot reorder columns.
        components.sort(key=lambda item: (item[0] + item[3]) / 2.0)
        ordered: list[tuple[int, int, int, int, int]] = []
        for row_start in range(0, expected_count, LOCOMOTION_COLS):
            row = components[row_start : row_start + LOCOMOTION_COLS]
            ordered.extend(sorted(row, key=lambda item: item[1]))
        components = ordered
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


def _body_foot_anchor_x(sprite: Image.Image) -> int:
    """Find King's boots without allowing a low silver blade to move the pivot."""
    width, height = sprite.size
    sample_top = max(0, int(height * 0.64))
    warm_xs: list[int] = []
    for y in range(sample_top, height):
        for x in range(width):
            red, green, blue, alpha = sprite.getpixel((x, y))
            if (
                alpha >= ALPHA_THRESHOLD
                and red >= 35
                and red > green * 1.12
                and red > blue * 1.20
                and green < 145
            ):
                warm_xs.append(x)
    if warm_xs:
        return round((min(warm_xs) + max(warm_xs)) / 2)
    return _feet_anchor_x(sprite)


def _animation(name: str, atlas_ids: list[str], speed: float, loop: bool) -> str:
    frame_entries = ", ".join(
        f'{{"duration": 1.0, "texture": SubResource("{atlas_id}")}}'
        for atlas_id in atlas_ids
    )
    return (
        '{\n'
        f'"frames": [{frame_entries}],\n'
        f'"loop": {str(loop).lower()},\n'
        f'"name": &"{name}",\n'
        f'"speed": {speed:.1f}\n'
        '}'
    )


def _build_resource() -> str:
    lines = [
        '[gd_resource type="SpriteFrames" load_steps=43 format=3]',
        '',
        '[ext_resource type="Texture2D" path="res://assets/characters/playable/king/simple_reboot/king_simple_locomotion_sheet_48x32.png" id="1_locomotion"]',
        '[ext_resource type="Texture2D" path="res://assets/characters/playable/king/simple_reboot/king_simple_basic_slash_sheet_64x32.png" id="2_attack"]',
        '',
    ]
    for row in range(ROWS):
        for col in range(LOCOMOTION_COLS):
            atlas_id = f"LocomotionAtlas_{row}_{col}"
            lines.extend(
                [
                    f'[sub_resource type="AtlasTexture" id="{atlas_id}"]',
                    'atlas = ExtResource("1_locomotion")',
                    f'region = Rect2({col * CELL_W}, {row * CELL_H}, {CELL_W}, {CELL_H})',
                    '',
                ]
            )
    for row in range(ROWS):
        for col in range(ATTACK_COLS):
            atlas_id = f"AttackAtlas_{row}_{col}"
            lines.extend(
                [
                    f'[sub_resource type="AtlasTexture" id="{atlas_id}"]',
                    'atlas = ExtResource("2_attack")',
                    f'region = Rect2({col * ATTACK_CELL_W}, {row * CELL_H}, {ATTACK_CELL_W}, {CELL_H})',
                    '',
                ]
            )

    animations: list[str] = []
    for row, direction in enumerate(DIRECTIONS):
        locomotion = [f"LocomotionAtlas_{row}_{col}" for col in range(LOCOMOTION_COLS)]
        attack = [f"AttackAtlas_{row}_{col}" for col in range(ATTACK_COLS)]
        animations.extend(
            [
                _animation(f"idle_{direction}", [locomotion[0]], 1.0, True),
                _animation(f"walk_{direction}", locomotion, 8.0, True),
                _animation(f"attack_{direction}", attack, 15.0, False),
                _animation(f"dash_{direction}", [locomotion[1], locomotion[2], locomotion[3]], 12.0, False),
                _animation(f"interact_{direction}", [locomotion[0]], 1.0, False),
                _animation(f"hurt_{direction}", [attack[4], locomotion[0]], 10.0, False),
                _animation(f"defeat_{direction}", [attack[4], attack[5], locomotion[0], locomotion[0]], 7.0, False),
            ]
        )

    lines.extend(['[resource]', 'animations = [' + ', '.join(animations) + ']', ''])
    return "\n".join(lines)


def _pack_locomotion(source: Image.Image, boxes: list[tuple[int, int, int, int]], scale: float) -> Image.Image:
    sheet = Image.new("RGBA", (CELL_W * LOCOMOTION_COLS, CELL_H * ROWS), (0, 0, 0, 0))
    cell_width = CELL_W
    anchor_x_in_cell = cell_width // 2
    for index, box in enumerate(boxes):
        row, col = divmod(index, LOCOMOTION_COLS)
        sprite = source.crop(box)
        sprite.putalpha(sprite.getchannel("A").point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0))
        target_size = (max(1, round(sprite.width * scale)), max(1, round(sprite.height * scale)))
        sprite = sprite.resize(target_size, Image.Resampling.NEAREST)
        anchor_x = _feet_anchor_x(sprite)
        paste_x = col * cell_width + anchor_x_in_cell - anchor_x
        paste_y = row * CELL_H + BASELINE_Y - sprite.height
        cell_left = col * cell_width
        cell_right = cell_left + cell_width
        if paste_x < cell_left or paste_x + sprite.width > cell_right or paste_y < row * CELL_H:
            raise RuntimeError(f"Frame {index} does not fit its exact {cell_width}x{CELL_H} cell")
        sheet.alpha_composite(sprite, (paste_x, paste_y))
    return sheet


def _prepare_attack_frames(source_path: Path) -> list[Image.Image]:
    source = Image.open(source_path).convert("RGBA")
    boxes = _components(source, ATTACK_COLS)
    max_height = max(bottom - top for left, top, right, bottom in boxes)
    # Generated attack sources include long sword extensions inside the actor
    # island. A small calibrated reduction keeps King's head/body scale aligned
    # with locomotion instead of normalizing the weapon to the 28-pixel body.
    scale = (28.0 / max_height) * ATTACK_SCALE_FACTOR
    frames: list[Image.Image] = []
    for box in boxes:
        sprite = source.crop(box)
        sprite.putalpha(sprite.getchannel("A").point(lambda value: 255 if value >= ALPHA_THRESHOLD else 0))
        sprite = sprite.resize(
            (max(1, round(sprite.width * scale)), max(1, round(sprite.height * scale))),
            Image.Resampling.NEAREST,
        )
        frames.append(sprite)
    return frames


def _pack_attack() -> Image.Image:
    direction_frames = {
        "down": _prepare_attack_frames(ATTACK_SOURCES["down"]),
        "right": _prepare_attack_frames(ATTACK_SOURCES["right"]),
        "up": _prepare_attack_frames(ATTACK_SOURCES["up"]),
    }
    sheet = Image.new("RGBA", (ATTACK_CELL_W * ATTACK_COLS, CELL_H * ROWS), (0, 0, 0, 0))
    for row, direction in enumerate(DIRECTIONS):
        source_direction = "right" if direction == "left" else direction
        for col, sprite in enumerate(direction_frames[source_direction]):
            anchor_x = _body_foot_anchor_x(sprite)
            local_x = ATTACK_CELL_W // 2 - anchor_x
            local_y = BASELINE_Y - sprite.height
            if local_x < 0 or local_x + sprite.width > ATTACK_CELL_W or local_y < 0:
                raise RuntimeError(f"Attack frame {direction}:{col} does not fit its exact {ATTACK_CELL_W}x{CELL_H} cell")
            cell = Image.new("RGBA", (ATTACK_CELL_W, CELL_H), (0, 0, 0, 0))
            cell.alpha_composite(sprite, (local_x, local_y))
            if direction == "left":
                cell = ImageOps.mirror(cell)
            sheet.alpha_composite(cell, (col * ATTACK_CELL_W, row * CELL_H))
    return sheet


def main() -> None:
    locomotion_source = Image.open(LOCOMOTION_SOURCE).convert("RGBA")
    locomotion_boxes = _components(locomotion_source, LOCOMOTION_COLS * ROWS)
    boxes = locomotion_boxes
    max_height = max(bottom - top for left, top, right, bottom in boxes)
    scale = 28.0 / max_height
    sheet = _pack_locomotion(locomotion_source, locomotion_boxes, scale)
    attack_sheet = _pack_attack()

    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_DIR.mkdir(parents=True, exist_ok=True)
    sheet.save(SHEET)
    attack_sheet.save(ATTACK_SHEET)
    sheet.resize((sheet.width * 4, sheet.height * 4), Image.Resampling.NEAREST).save(REVIEW)
    attack_sheet.resize((attack_sheet.width * 4, attack_sheet.height * 4), Image.Resampling.NEAREST).save(ATTACK_REVIEW)
    FRAMES.write_text(_build_resource(), encoding="utf-8")
    print(f"Wrote {SHEET.relative_to(ROOT)}")
    print(f"Wrote {ATTACK_SHEET.relative_to(ROOT)}")
    print(f"Wrote {FRAMES.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")
    print(f"Wrote {ATTACK_REVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
