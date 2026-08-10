from __future__ import annotations

import hashlib
import json
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
CLEAN = ROOT / "art_source/cleaned/characters/playable/king"
ASSETS = ROOT / "assets/characters/playable/king"
REVIEW = ROOT / "art_source/review/characters/playable/king/core_animation"

LOCOMOTION_CELL = 64
LOCOMOTION_FRAMES = 4
LOCOMOTION_HEIGHT = 36
FOOT_X = 31.5
FOOT_Y = 58
ATTACK_CELL = (128, 96)
ATTACK_FOOT = (40.0, 88)
VFX_CELL = (192, 128)
ALPHA_THRESHOLD = 128
PALETTE_SIZE = 48

LOCOMOTION_SOURCES = {
    "idle_left": CLEAN / "idle_left/king_idle_left_integrated_transparent_v1.png",
    "idle_up": CLEAN / "idle_up/king_idle_up_integrated_transparent_v1.png",
    "walk_down": CLEAN / "walk_down/king_walk_down_integrated_transparent_v1.png",
    "walk_left": CLEAN / "walk_left/king_walk_left_integrated_transparent_v1.png",
    "walk_up": CLEAN / "walk_up/king_walk_up_integrated_transparent_v1.png",
}

ATTACKS = {
    "opening_cut": (4, 2, 8),
    "reversal_cut": (4, 2, 8),
    "horizon_break": (5, 2, 10),
    "falling_divide": (4, 3, 12),
}

ATTACK_CELLS = {
    "opening_cut": (128, 96),
    "reversal_cut": (128, 96),
    "horizon_break": (128, 96),
    "falling_divide": (128, 128),
}


def _harden(image: Image.Image) -> Image.Image:
    image = image.convert("RGBA")
    output = Image.new("RGBA", image.size, (0, 0, 0, 0))
    src = image.load()
    dst = output.load()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = src[x, y]
            if alpha >= ALPHA_THRESHOLD:
                dst[x, y] = (red, green, blue, 255)
    return output


def _components(image: Image.Image, minimum_area: int = 4) -> list[dict[str, object]]:
    width, height = image.size
    alpha = image.getchannel("A")
    occupied = bytearray(1 if value >= ALPHA_THRESHOLD else 0 for value in alpha.get_flattened_data())
    visited = bytearray(width * height)
    result: list[dict[str, object]] = []
    for start, value in enumerate(occupied):
        if not value or visited[start]:
            continue
        queue: deque[int] = deque([start])
        visited[start] = 1
        indices: list[int] = []
        min_x, min_y, max_x, max_y = width, height, 0, 0
        while queue:
            index = queue.pop()
            y, x = divmod(index, width)
            indices.append(index)
            min_x, min_y = min(min_x, x), min(min_y, y)
            max_x, max_y = max(max_x, x), max(max_y, y)
            for neighbor in (index - 1 if x else -1, index + 1 if x + 1 < width else -1,
                             index - width if y else -1, index + width if y + 1 < height else -1):
                if neighbor >= 0 and occupied[neighbor] and not visited[neighbor]:
                    visited[neighbor] = 1
                    queue.append(neighbor)
        if len(indices) >= minimum_area:
            result.append({"indices": indices, "bbox": (min_x, min_y, max_x + 1, max_y + 1), "area": len(indices)})
    return sorted(result, key=lambda item: int(item["area"]), reverse=True)


def _isolate_largest(image: Image.Image) -> Image.Image:
    components = _components(image, max(8, image.width * image.height // 5000))
    if not components:
        raise RuntimeError("Animation cell became empty after chroma cleanup.")
    largest = components[0]
    min_x, min_y, max_x, max_y = largest["bbox"]
    output = Image.new("RGBA", (max_x - min_x, max_y - min_y), (0, 0, 0, 0))
    source = image.load()
    target = output.load()
    for index in largest["indices"]:
        y, x = divmod(index, image.width)
        red, green, blue, _ = source[x, y]
        target[x - min_x, y - min_y] = (red, green, blue, 255)
    return output


def _split_grid(image: Image.Image, columns: int, rows: int) -> list[Image.Image]:
    frames: list[Image.Image] = []
    for row in range(rows):
        for column in range(columns):
            left = round(column * image.width / columns)
            right = round((column + 1) * image.width / columns)
            top = round(row * image.height / rows)
            bottom = round((row + 1) * image.height / rows)
            frames.append(image.crop((left, top, right, bottom)))
    return frames


def _bottom_midpoint(image: Image.Image) -> float:
    bbox = image.getchannel("A").getbbox()
    if bbox is None:
        raise RuntimeError("Cannot anchor an empty frame.")
    min_x, min_y, max_x, max_y = bbox
    band_top = max(min_y, max_y - max(2, (max_y - min_y) // 12))
    alpha = image.getchannel("A").load()
    xs = [x for y in range(band_top, max_y) for x in range(min_x, max_x) if alpha[x, y] >= ALPHA_THRESHOLD]
    return (min(xs) + max(xs)) / 2.0


def _quantize(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    output = image.quantize(colors=PALETTE_SIZE, method=Image.Quantize.FASTOCTREE,
                            dither=Image.Dither.NONE).convert("RGBA")
    output.putalpha(alpha)
    return _harden(output)


def _normalize_actor_frames(frames: list[Image.Image], cell: tuple[int, int], target_height: int,
                            foot: tuple[float, int]) -> list[Image.Image]:
    actors = [_isolate_largest(_harden(frame)) for frame in frames]
    tallest = max(actor.height for actor in actors)
    scale = target_height / float(tallest)
    max_width = max(actor.width * scale for actor in actors)
    max_height = max(actor.height * scale for actor in actors)
    if max_width > cell[0] - 8 or max_height > cell[1] - 8:
        scale *= min((cell[0] - 8) / max_width, (cell[1] - 8) / max_height)
    output: list[Image.Image] = []
    for actor in actors:
        resized = _harden(actor.resize((max(1, round(actor.width * scale)), max(1, round(actor.height * scale))),
                                       Image.Resampling.NEAREST))
        canvas = Image.new("RGBA", cell, (0, 0, 0, 0))
        x = round(foot[0] - _bottom_midpoint(resized))
        y = foot[1] - resized.height + 1
        canvas.alpha_composite(resized, (x, y))
        output.append(canvas)
    return output


def _normalize_attack_frames(frames: list[Image.Image], cell: tuple[int, int]) -> list[Image.Image]:
    """Keep the complete generated attack silhouette visible.

    Attack swords sometimes extend below the boots. A locomotion-style bottom-band
    anchor would mistake that blade tip for a foot and clip the actor. Attack art is
    therefore centered as a complete connected silhouette with one shared scale.
    """
    actors = [_isolate_largest(_harden(frame)) for frame in frames]
    scale = min(
        (cell[0] - 8) / max(actor.width for actor in actors),
        (cell[1] - 8) / max(actor.height for actor in actors),
    )
    output: list[Image.Image] = []
    for actor in actors:
        resized = _harden(actor.resize(
            (max(1, round(actor.width * scale)), max(1, round(actor.height * scale))),
            Image.Resampling.NEAREST,
        ))
        canvas = Image.new("RGBA", cell, (0, 0, 0, 0))
        canvas.alpha_composite(resized, (
            (cell[0] - resized.width) // 2,
            cell[1] - 4 - resized.height,
        ))
        output.append(canvas)
    return output


def _mirror_frames(frames: list[Image.Image]) -> list[Image.Image]:
    return [frame.transpose(Image.Transpose.FLIP_LEFT_RIGHT) for frame in frames]


def _strip(frames: list[Image.Image]) -> Image.Image:
    sheet = Image.new("RGBA", (frames[0].width * len(frames), frames[0].height), (0, 0, 0, 0))
    for index, frame in enumerate(frames):
        sheet.alpha_composite(frame, (index * frame.width, 0))
    return _quantize(sheet)


def _direction_sheet(rows: list[list[Image.Image]]) -> Image.Image:
    sheet = Image.new("RGBA", (LOCOMOTION_CELL * LOCOMOTION_FRAMES, LOCOMOTION_CELL * len(rows)), (0, 0, 0, 0))
    for row_index, frames in enumerate(rows):
        for frame_index, frame in enumerate(frames):
            sheet.alpha_composite(frame, (frame_index * LOCOMOTION_CELL, row_index * LOCOMOTION_CELL))
    return _quantize(sheet)


def _vfx_frames(source: Image.Image, columns: int, rows: int) -> list[Image.Image]:
    raw = [_harden(frame) for frame in _split_grid(source, columns, rows)]
    crops: list[Image.Image] = []
    for frame in raw:
        bbox = frame.getchannel("A").getbbox()
        crops.append(frame.crop(bbox) if bbox else Image.new("RGBA", (1, 1), (0, 0, 0, 0)))
    largest_width = max(crop.width for crop in crops)
    largest_height = max(crop.height for crop in crops)
    scale = min((VFX_CELL[0] - 8) / largest_width, (VFX_CELL[1] - 8) / largest_height)
    output: list[Image.Image] = []
    for crop in crops:
        canvas = Image.new("RGBA", VFX_CELL, (0, 0, 0, 0))
        if crop.getchannel("A").getbbox() is not None:
            resized = _harden(crop.resize((max(1, round(crop.width * scale)), max(1, round(crop.height * scale))),
                                          Image.Resampling.NEAREST))
            canvas.alpha_composite(resized, ((VFX_CELL[0] - resized.width) // 2,
                                             (VFX_CELL[1] - resized.height) // 2))
        output.append(canvas)
    return output


def _save(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f"{path.stem}.tmp{path.suffix}")
    image.save(temporary)
    temporary.replace(path)


def _review(image: Image.Image, name: str, scale: int = 4) -> None:
    REVIEW.mkdir(parents=True, exist_ok=True)
    backdrop = Image.new("RGBA", image.size, (24, 27, 35, 255))
    backdrop.alpha_composite(image)
    _save(backdrop.resize((image.width * scale, image.height * scale), Image.Resampling.NEAREST), REVIEW / f"{name}_4x.png")


def _validate_unique(frames: list[Image.Image], name: str) -> None:
    hashes = {hashlib.sha256(frame.tobytes()).hexdigest() for frame in frames}
    if len(hashes) != len(frames):
        raise RuntimeError(f"{name} contains duplicated filler frames.")


def _write_sprite_frames(path: Path, textures: list[tuple[str, str]],
                         animations: list[dict[str, object]]) -> None:
    lines = ['[gd_resource type="SpriteFrames" format=3]', '']
    for resource_id, texture_path in textures:
        lines.append(f'[ext_resource type="Texture2D" path="res://{texture_path}" id="{resource_id}"]')
    lines.append('')
    atlas_ids: dict[tuple[str, int, int, int], str] = {}
    atlas_index = 0
    for animation in animations:
        resource_id = str(animation["resource"])
        cell_width, cell_height = animation["cell"]
        row = int(animation.get("row", 0))
        for frame_index in range(int(animation["frames"])):
            key = (resource_id, row, frame_index, cell_width)
            atlas_id = f"AtlasTexture_{atlas_index}"
            atlas_ids[key] = atlas_id
            atlas_index += 1
            lines.extend([
                f'[sub_resource type="AtlasTexture" id="{atlas_id}"]',
                f'atlas = ExtResource("{resource_id}")',
                f'region = Rect2({frame_index * cell_width}, {row * cell_height}, {cell_width}, {cell_height})',
                '',
            ])
    animation_blocks: list[str] = []
    for animation in animations:
        resource_id = str(animation["resource"])
        row = int(animation.get("row", 0))
        cell_width, _ = animation["cell"]
        frame_entries = []
        for frame_index in range(int(animation["frames"])):
            atlas_id = atlas_ids[(resource_id, row, frame_index, cell_width)]
            frame_entries.append('{\n"duration": 1.0,\n"texture": SubResource("%s")\n}' % atlas_id)
        animation_blocks.append('{\n"frames": [%s],\n"loop": %s,\n"name": &"%s",\n"speed": %.1f\n}' % (
            ', '.join(frame_entries),
            'true' if animation["loop"] else 'false',
            animation["name"],
            animation["speed"],
        ))
    lines.extend(['[resource]', 'animations = [%s]' % ', '.join(animation_blocks), ''])
    path.parent.mkdir(parents=True, exist_ok=True)
    path.write_text('\n'.join(lines), encoding='utf-8')


def main() -> None:
    old_idle = Image.open(ASSETS / "idle/king_idle_down_sheet_64x64.png").convert("RGBA")
    idle_down = _split_grid(old_idle, 4, 1)
    normalized: dict[str, list[Image.Image]] = {}
    for name, path in LOCOMOTION_SOURCES.items():
        source = Image.open(path).convert("RGBA")
        frames = _split_grid(source, 4, 1)
        normalized[name] = _normalize_actor_frames(frames, (64, 64), LOCOMOTION_HEIGHT, (FOOT_X, FOOT_Y))
        _validate_unique(normalized[name], name)

    idle_left = normalized["idle_left"]
    idle_right = _mirror_frames(idle_left)
    idle_sheet = _direction_sheet([idle_down, idle_left, idle_right, normalized["idle_up"]])
    _save(idle_sheet, ASSETS / "idle/king_idle_sheet_64x64.png")
    _review(idle_sheet, "king_idle_sheet")

    walk_left = normalized["walk_left"]
    walk_sheet = _direction_sheet([
        normalized["walk_down"], walk_left, _mirror_frames(walk_left), normalized["walk_up"]
    ])
    _save(walk_sheet, ASSETS / "walk/king_walk_sheet_64x64.png")
    _review(walk_sheet, "king_walk_sheet")

    metrics: dict[str, object] = {
        "direction_rows": ["down", "left", "right", "up"],
        "locomotion_cell": [64, 64],
        "attack_cells": {name: list(cell) for name, cell in ATTACK_CELLS.items()},
        "vfx_cell": list(VFX_CELL),
        "attacks": {},
    }
    body_textures = [
        ("1_idle", "assets/characters/playable/king/idle/king_idle_sheet_64x64.png"),
        ("2_walk", "assets/characters/playable/king/walk/king_walk_sheet_64x64.png"),
    ]
    body_animations: list[dict[str, object]] = []
    for row, direction in enumerate(("down", "left", "right", "up")):
        body_animations.append({"name": f"idle_{direction}", "resource": "1_idle", "cell": (64, 64),
                                "row": row, "frames": 4, "loop": True, "speed": 3.0})
        body_animations.append({"name": f"walk_{direction}", "resource": "2_walk", "cell": (64, 64),
                                "row": row, "frames": 4, "loop": True, "speed": 8.0})
    vfx_textures: list[tuple[str, str]] = []
    vfx_animations: list[dict[str, object]] = []
    for name, (columns, rows, frame_count) in ATTACKS.items():
        folder = CLEAN / f"attacks/{name}_right"
        body_source = Image.open(folder / f"king_{name}_right_body_transparent_v1.png").convert("RGBA")
        body_cells = _split_grid(body_source, columns, rows)[:frame_count]
        attack_cell = ATTACK_CELLS[name]
        right = _normalize_attack_frames(body_cells, attack_cell)
        _validate_unique(right, f"{name}_right")
        left = _mirror_frames(right)
        size_label = f"{attack_cell[0]}x{attack_cell[1]}"
        right_path = f"assets/characters/playable/king/attacks/{name}/king_{name}_right_sheet_{size_label}.png"
        left_path = f"assets/characters/playable/king/attacks/{name}/king_{name}_left_sheet_{size_label}.png"
        _save(_strip(right), ROOT / right_path)
        _save(_strip(left), ROOT / left_path)
        right_resource = f"body_{name}_right"
        left_resource = f"body_{name}_left"
        body_textures.extend([(right_resource, right_path), (left_resource, left_path)])
        for direction, resource in (("right", right_resource), ("left", left_resource)):
            body_animations.append({"name": f"{name}_{direction}", "resource": resource, "cell": attack_cell,
                                    "frames": frame_count, "loop": False, "speed": 12.0})

        vfx_source = Image.open(folder / f"king_{name}_right_vfx_transparent_v1.png").convert("RGBA")
        vfx_right = _vfx_frames(vfx_source, columns, rows)[:frame_count]
        vfx_left = _mirror_frames(vfx_right)
        _save(_strip(vfx_right), ASSETS / f"attacks/{name}/king_{name}_right_vfx_sheet_192x128.png")
        _save(_strip(vfx_left), ASSETS / f"attacks/{name}/king_{name}_left_vfx_sheet_192x128.png")
        for direction in ("right", "left"):
            resource = f"vfx_{name}_{direction}"
            texture_path = f"assets/characters/playable/king/attacks/{name}/king_{name}_{direction}_vfx_sheet_192x128.png"
            vfx_textures.append((resource, texture_path))
            vfx_animations.append({"name": f"{name}_{direction}", "resource": resource, "cell": VFX_CELL,
                                   "frames": frame_count, "loop": False, "speed": 12.0})
        _review(_strip(right), f"king_{name}_right_body", 3)
        _review(_strip(vfx_right), f"king_{name}_right_vfx", 2)
        metrics["attacks"][name] = {"frames": frame_count, "body_direction": "right authored, left exact mirror"}

    _write_sprite_frames(ASSETS / "king_core_sprite_frames.tres", body_textures, body_animations)
    _write_sprite_frames(ASSETS / "king_attack_vfx_sprite_frames.tres", vfx_textures, vfx_animations)

    REVIEW.mkdir(parents=True, exist_ok=True)
    (REVIEW / "king_core_animation_metrics.json").write_text(json.dumps(metrics, indent=2) + "\n", encoding="utf-8")
    print("KING_CORE_ANIMATION_PROCESSING_OK")


if __name__ == "__main__":
    main()
