from __future__ import annotations

import hashlib
import json
from collections import deque
from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/cleaned/characters/playable/king/idle_down/king_idle_down_integrated_transparent_v1.png"
RUNTIME = ROOT / "assets/characters/playable/king/idle/king_idle_down_sheet_64x64.png"
REVIEW = ROOT / "art_source/review/characters/playable/king/idle_down/king_idle_down_sheet_4x.png"
ANIMATED_REVIEW = ROOT / "art_source/review/characters/playable/king/idle_down/king_idle_down_preview_8x.gif"
METRICS = ROOT / "art_source/review/characters/playable/king/idle_down/king_idle_down_metrics.json"

FRAME_COUNT = 4
CELL_SIZE = 64
TARGET_FULL_HEIGHT = 36
FOOT_BASELINE_Y = 58
FOOT_CENTER_X = 31.5
ALPHA_THRESHOLD = 128
MIN_COMPONENT_AREA = 20_000
PALETTE_SIZE = 48


def _opaque_components(image: Image.Image) -> list[dict[str, object]]:
    width, height = image.size
    alpha = image.getchannel("A")
    mask = bytearray(
        1 if value >= ALPHA_THRESHOLD else 0
        for value in alpha.get_flattened_data()
    )
    visited = bytearray(width * height)
    components: list[dict[str, object]] = []

    for start, occupied in enumerate(mask):
        if occupied == 0 or visited[start] != 0:
            continue
        queue: deque[int] = deque([start])
        visited[start] = 1
        indices: list[int] = []
        min_x = width
        min_y = height
        max_x = 0
        max_y = 0

        while queue:
            index = queue.pop()
            y, x = divmod(index, width)
            indices.append(index)
            min_x = min(min_x, x)
            min_y = min(min_y, y)
            max_x = max(max_x, x)
            max_y = max(max_y, y)

            if x > 0:
                neighbor = index - 1
                if mask[neighbor] and not visited[neighbor]:
                    visited[neighbor] = 1
                    queue.append(neighbor)
            if x + 1 < width:
                neighbor = index + 1
                if mask[neighbor] and not visited[neighbor]:
                    visited[neighbor] = 1
                    queue.append(neighbor)
            if y > 0:
                neighbor = index - width
                if mask[neighbor] and not visited[neighbor]:
                    visited[neighbor] = 1
                    queue.append(neighbor)
            if y + 1 < height:
                neighbor = index + width
                if mask[neighbor] and not visited[neighbor]:
                    visited[neighbor] = 1
                    queue.append(neighbor)

        if len(indices) >= MIN_COMPONENT_AREA:
            components.append(
                {
                    "indices": indices,
                    "bbox": (min_x, min_y, max_x + 1, max_y + 1),
                    "area": len(indices),
                }
            )

    components.sort(key=lambda component: component["bbox"][0])
    if len(components) != FRAME_COUNT:
        raise RuntimeError(
            f"Expected {FRAME_COUNT} connected King frames, found {len(components)}."
        )
    return components


def _extract_component(
    source: Image.Image,
    component: dict[str, object],
) -> Image.Image:
    source_width, _ = source.size
    min_x, min_y, max_x, max_y = component["bbox"]
    crop = Image.new("RGBA", (max_x - min_x, max_y - min_y), (0, 0, 0, 0))
    source_pixels = source.load()
    crop_pixels = crop.load()

    for index in component["indices"]:
        y, x = divmod(index, source_width)
        red, green, blue, _ = source_pixels[x, y]
        crop_pixels[x - min_x, y - min_y] = (red, green, blue, 255)
    return crop


def _used_rect(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A")
    bbox = alpha.getbbox()
    if bbox is None:
        raise RuntimeError("Processed frame became empty.")
    return bbox


def _bottom_midpoint(image: Image.Image) -> float:
    min_x, min_y, max_x, max_y = _used_rect(image)
    occupied_height = max_y - min_y
    band_top = max(min_y, max_y - max(2, occupied_height // 12))
    alpha = image.getchannel("A")
    pixels = alpha.load()
    occupied_x = [
        x
        for y in range(band_top, max_y)
        for x in range(min_x, max_x)
        if pixels[x, y] >= ALPHA_THRESHOLD
    ]
    if not occupied_x:
        raise RuntimeError("Processed frame has no readable foot band.")
    return (min(occupied_x) + max(occupied_x)) / 2.0


def _harden_alpha(image: Image.Image) -> Image.Image:
    hardened = Image.new("RGBA", image.size, (0, 0, 0, 0))
    source_pixels = image.load()
    output_pixels = hardened.load()
    for y in range(image.height):
        for x in range(image.width):
            red, green, blue, alpha = source_pixels[x, y]
            if alpha >= ALPHA_THRESHOLD:
                output_pixels[x, y] = (red, green, blue, 255)
    return hardened


def _quantize_sheet(sheet: Image.Image) -> Image.Image:
    original_alpha = sheet.getchannel("A")
    quantized = sheet.quantize(
        colors=PALETTE_SIZE,
        method=Image.Quantize.FASTOCTREE,
        dither=Image.Dither.NONE,
    ).convert("RGBA")
    quantized.putalpha(original_alpha)
    return _harden_alpha(quantized)


def _validate_sheet(sheet: Image.Image) -> list[dict[str, object]]:
    if sheet.size != (CELL_SIZE * FRAME_COUNT, CELL_SIZE):
        raise RuntimeError(f"Unexpected runtime dimensions: {sheet.size}.")

    metrics: list[dict[str, object]] = []
    hashes: set[str] = set()
    colors: set[tuple[int, int, int]] = set()

    for frame_index in range(FRAME_COUNT):
        frame = sheet.crop(
            (
                frame_index * CELL_SIZE,
                0,
                (frame_index + 1) * CELL_SIZE,
                CELL_SIZE,
            )
        )
        bounds = _used_rect(frame)
        if bounds[0] < 4 or bounds[2] > CELL_SIZE - 4:
            raise RuntimeError(f"Frame {frame_index} violates horizontal safety margins: {bounds}.")
        if bounds[1] < 4 or bounds[3] != FOOT_BASELINE_Y + 1:
            raise RuntimeError(f"Frame {frame_index} violates its baseline contract: {bounds}.")

        opaque_pixels = 0
        for red, green, blue, alpha in frame.get_flattened_data():
            if alpha not in (0, 255):
                raise RuntimeError(f"Frame {frame_index} contains partial alpha {alpha}.")
            if alpha == 0:
                continue
            opaque_pixels += 1
            colors.add((red, green, blue))
            if red > 150 and blue > 150 and green < 100 and abs(red - blue) < 90:
                raise RuntimeError(
                    f"Frame {frame_index} retains a magenta-family matte pixel: {(red, green, blue)}."
                )

        digest = hashlib.sha256(frame.tobytes()).hexdigest()
        hashes.add(digest)
        metrics.append(
            {
                "frame": frame_index,
                "runtime_bounds": list(bounds),
                "foot_midpoint_x": _bottom_midpoint(frame),
                "opaque_pixels": opaque_pixels,
                "sha256": digest,
            }
        )

    if len(hashes) != FRAME_COUNT:
        raise RuntimeError("Idle-down frames contain duplicated filler.")
    if len(colors) > PALETTE_SIZE:
        raise RuntimeError(f"Runtime palette contains {len(colors)} colors, expected <= {PALETTE_SIZE}.")
    return metrics


def _write_image_atomic(image: Image.Image, path: Path) -> None:
    path.parent.mkdir(parents=True, exist_ok=True)
    temporary = path.with_name(f"{path.stem}.tmp{path.suffix}")
    image.save(temporary)
    temporary.replace(path)


def _write_animated_review(sheet: Image.Image) -> None:
    scale = 8
    review_frames: list[Image.Image] = []
    for frame_index in range(FRAME_COUNT):
        frame = sheet.crop(
            (
                frame_index * CELL_SIZE,
                0,
                (frame_index + 1) * CELL_SIZE,
                CELL_SIZE,
            )
        ).resize(
            (CELL_SIZE * scale, CELL_SIZE * scale),
            Image.Resampling.NEAREST,
        )
        backdrop = Image.new("RGBA", frame.size, (20, 28, 22, 255))
        backdrop.alpha_composite(frame)
        review_frames.append(backdrop.convert("P", palette=Image.Palette.ADAPTIVE, colors=64))

    ANIMATED_REVIEW.parent.mkdir(parents=True, exist_ok=True)
    temporary = ANIMATED_REVIEW.with_name(f"{ANIMATED_REVIEW.stem}.tmp{ANIMATED_REVIEW.suffix}")
    review_frames[0].save(
        temporary,
        save_all=True,
        append_images=review_frames[1:],
        duration=333,
        loop=0,
        disposal=2,
    )
    temporary.replace(ANIMATED_REVIEW)


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    components = _opaque_components(source)
    tallest_source_height = max(
        component["bbox"][3] - component["bbox"][1] for component in components
    )
    scale = TARGET_FULL_HEIGHT / float(tallest_source_height)
    sheet = Image.new("RGBA", (CELL_SIZE * FRAME_COUNT, CELL_SIZE), (0, 0, 0, 0))
    source_metrics: list[dict[str, object]] = []

    for frame_index, component in enumerate(components):
        crop = _extract_component(source, component)
        resized = crop.resize(
            (
                max(1, round(crop.width * scale)),
                max(1, round(crop.height * scale)),
            ),
            Image.Resampling.NEAREST,
        )
        resized = _harden_alpha(resized)
        resized_bounds = _used_rect(resized)
        destination_x = round(FOOT_CENTER_X - _bottom_midpoint(resized))
        destination_y = FOOT_BASELINE_Y - (resized_bounds[3] - 1)
        sheet.alpha_composite(
            resized,
            (frame_index * CELL_SIZE + destination_x, destination_y),
        )
        source_metrics.append(
            {
                "frame": frame_index,
                "source_bbox": list(component["bbox"]),
                "source_component_area": component["area"],
                "resized_size": list(resized.size),
                "destination": [destination_x, destination_y],
            }
        )

    sheet = _quantize_sheet(sheet)
    runtime_metrics = _validate_sheet(sheet)
    for source_entry, runtime_entry in zip(source_metrics, runtime_metrics, strict=True):
        runtime_entry.update(source_entry)

    _write_image_atomic(sheet, RUNTIME)
    _write_image_atomic(
        sheet.resize(
            (sheet.width * 4, sheet.height * 4),
            Image.Resampling.NEAREST,
        ),
        REVIEW,
    )
    _write_animated_review(sheet)
    METRICS.parent.mkdir(parents=True, exist_ok=True)
    METRICS.write_text(
        json.dumps(
            {
                "source": SOURCE.relative_to(ROOT).as_posix(),
                "runtime": RUNTIME.relative_to(ROOT).as_posix(),
                "cell_size": [CELL_SIZE, CELL_SIZE],
                "frame_count": FRAME_COUNT,
                "target_full_height": TARGET_FULL_HEIGHT,
                "foot_baseline_y": FOOT_BASELINE_Y,
                "foot_center_x": FOOT_CENTER_X,
                "shared_scale": scale,
                "palette_limit": PALETTE_SIZE,
                "frames": runtime_metrics,
            },
            indent=2,
        )
        + "\n",
        encoding="utf-8",
    )
    print(f"Wrote {RUNTIME.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")
    print(f"Wrote {ANIMATED_REVIEW.relative_to(ROOT)}")
    print(f"Wrote {METRICS.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
