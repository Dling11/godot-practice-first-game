"""Process the approved Stage V leggings and redesigned Varkuun Core."""

from __future__ import annotations

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
LEGGINGS_SOURCE = ROOT / "art_source/generated/items/equipment/forest/stage_5_core/mirebound_leggings_source_v1.png"
CORE_SOURCE = ROOT / "art_source/generated/items/materials/forest/varkuun_core_source_v2.png"
LEGGINGS_CLEAN = ROOT / "art_source/cleaned/items/equipment/forest/stage_5_core/mirebound_leggings_clean_v1.png"
CORE_CLEAN = ROOT / "art_source/cleaned/items/materials/forest/varkuun_core_clean_v2.png"
LEGGINGS_RUNTIME = ROOT / "assets/items/equipment/forest/stage_5_core/mirebound_leggings_64x64.png"
CORE_RUNTIME = ROOT / "assets/items/materials/forest/varkuun_core_24x24.png"


def visible_crop(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    bounds = rgba.getchannel("A").getbbox()
    if bounds is None:
        raise RuntimeError("Generated source contains no visible pixels")
    return rgba.crop(bounds)


def build_icon(source: Image.Image, size: int, content_size: int, colors: int) -> Image.Image:
    cropped = visible_crop(source)
    scale = min(content_size / cropped.width, content_size / cropped.height)
    target = (
        max(1, round(cropped.width * scale)),
        max(1, round(cropped.height * scale)),
    )
    resized = cropped.resize(target, Image.Resampling.LANCZOS)
    alpha = resized.getchannel("A").point(lambda value: 255 if value >= 96 else 0)
    rgb = resized.convert("RGB").quantize(
        colors=colors,
        method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.NONE,
    ).convert("RGB")
    hardened = Image.merge("RGBA", (*rgb.split(), alpha))
    canvas = Image.new("RGBA", (size, size), (0, 0, 0, 0))
    canvas.alpha_composite(
        hardened,
        ((size - target[0]) // 2, (size - target[1]) // 2),
    )
    return canvas


def main() -> None:
    leggings = visible_crop(Image.open(LEGGINGS_SOURCE))
    core = visible_crop(Image.open(CORE_SOURCE))
    for path in [LEGGINGS_CLEAN, CORE_CLEAN, LEGGINGS_RUNTIME, CORE_RUNTIME]:
        path.parent.mkdir(parents=True, exist_ok=True)
    leggings.save(LEGGINGS_CLEAN)
    core.save(CORE_CLEAN)
    build_icon(leggings, 64, 54, 24).save(LEGGINGS_RUNTIME)
    build_icon(core, 24, 21, 18).save(CORE_RUNTIME)
    print("Processed Mirebound Leggings 64x64 and Varkuun Core 24x24.")


if __name__ == "__main__":
    main()
