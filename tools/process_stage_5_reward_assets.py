from __future__ import annotations

from collections import deque
from pathlib import Path
import sys

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
KING_SOURCE = ROOT / "art_source/generated/characters/playable/king/simple_reboot/king_portrait_source_v1.png"
CHEST_SOURCE = ROOT / "art_source/generated/gameplay/loot/stage_clear_chest/varkuun_chest_source_v2.png"
KING_OUTPUT = ROOT / "assets/characters/playable/king/portraits/king_portrait_96x96.png"
CHEST_DIR = ROOT / "assets/gameplay/loot/stage_clear_chest"
CHEST_CLOSED = CHEST_DIR / "varkuun_chest_closed_74x66.png"
CHEST_OPEN = CHEST_DIR / "varkuun_chest_open_74x66.png"
CORE_ICON = ROOT / "assets/items/materials/forest/varkuun_core_24x24.png"


def trim_alpha(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    box = alpha.getbbox()
    if box is None:
        raise ValueError("source contains no visible pixels")
    return image.crop(box)


def remove_bright_connected_background(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    pixels = rgba.load()
    width, height = rgba.size
    visited = bytearray(width * height)
    queue: deque[tuple[int, int]] = deque()

    def is_background(x: int, y: int) -> bool:
        red, green, blue, _ = pixels[x, y]
        return min(red, green, blue) >= 232 and max(red, green, blue) - min(red, green, blue) <= 12

    for x in range(width):
        if is_background(x, 0):
            queue.append((x, 0))
        if is_background(x, height - 1):
            queue.append((x, height - 1))
    for y in range(height):
        if is_background(0, y):
            queue.append((0, y))
        if is_background(width - 1, y):
            queue.append((width - 1, y))

    while queue:
        x, y = queue.popleft()
        index = y * width + x
        if visited[index] or not is_background(x, y):
            continue
        visited[index] = 1
        red, green, blue, _ = pixels[x, y]
        pixels[x, y] = (red, green, blue, 0)
        if x > 0:
            queue.append((x - 1, y))
        if x + 1 < width:
            queue.append((x + 1, y))
        if y > 0:
            queue.append((x, y - 1))
        if y + 1 < height:
            queue.append((x, y + 1))
    return rgba


def contain_on_canvas(image: Image.Image, canvas_size: tuple[int, int], padding: int) -> Image.Image:
    image = trim_alpha(image)
    max_width = canvas_size[0] - padding * 2
    max_height = canvas_size[1] - padding * 2
    scale = min(max_width / image.width, max_height / image.height)
    resized = image.resize(
        (max(1, round(image.width * scale)), max(1, round(image.height * scale))),
        Image.Resampling.LANCZOS,
    )
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    x = (canvas_size[0] - resized.width) // 2
    y = canvas_size[1] - padding - resized.height
    canvas.alpha_composite(resized, (x, y))
    return canvas


def process_king() -> None:
    source = trim_alpha(Image.open(KING_SOURCE).convert("RGBA"))
    result = contain_on_canvas(source, (96, 96), 2)
    KING_OUTPUT.parent.mkdir(parents=True, exist_ok=True)
    result.save(KING_OUTPUT)


def process_chest() -> None:
    source = remove_bright_connected_background(Image.open(CHEST_SOURCE))
    midpoint = source.width // 2
    closed = source.crop((0, 0, midpoint, source.height))
    opened = source.crop((midpoint, 0, source.width, source.height))
    closed_output = contain_on_canvas(closed, (74, 66), 2)
    open_output = contain_on_canvas(opened, (74, 66), 2)
    CHEST_DIR.mkdir(parents=True, exist_ok=True)
    closed_output.save(CHEST_CLOSED)
    open_output.save(CHEST_OPEN)

    # The boss catalyst is the same core that seals the chest, keeping the
    # reward icon visually tied to the object the player opens.
    core_crop = closed.crop((closed.width * 42 // 100, closed.height * 42 // 100, closed.width * 58 // 100, closed.height * 68 // 100))
    core_output = contain_on_canvas(core_crop, (24, 24), 2)
    CORE_ICON.parent.mkdir(parents=True, exist_ok=True)
    core_output.save(CORE_ICON)


def main() -> int:
    missing = [path for path in (KING_SOURCE, CHEST_SOURCE) if not path.exists()]
    if missing:
        print("Missing generated source: %s" % ", ".join(str(path) for path in missing), file=sys.stderr)
        return 1
    process_king()
    process_chest()
    print("Processed King portrait, Varkuun chest states, and Varkuun Core icon.")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
