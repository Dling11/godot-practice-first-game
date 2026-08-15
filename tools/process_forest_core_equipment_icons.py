"""Build the six Stage V Forest core-equipment icons from approved sources."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
CONCEPT_SOURCE = ROOT / "art_source/cleaned/items/equipment/forest/forest_varkuun_core_gear_concept_clean_v1.png"
HELM_SOURCE = ROOT / "art_source/generated/items/equipment/forest/stage_5_core/old_bark_helm_source_v1.png"
LEGGINGS_SOURCE = ROOT / "art_source/generated/items/equipment/forest/stage_5_core/mirebound_leggings_source_v1.png"
CLEAN_DIR = ROOT / "art_source/cleaned/items/equipment/forest/stage_5_core"
RUNTIME_DIR = ROOT / "assets/items/equipment/forest/stage_5_core"
REVIEW_PATH = ROOT / "art_source/review/items/equipment/forest/stage_5_core_set_preview_4x.png"

ICON_SIZE = 64
CONTENT_SIZE = 54
PALETTE_COLORS = 24


def _visible_crop(image: Image.Image) -> Image.Image:
    rgba = image.convert("RGBA")
    bounds = rgba.getchannel("A").getbbox()
    if bounds is None:
        raise RuntimeError("Equipment source contains no visible pixels")
    return rgba.crop(bounds)


def _quadrant(image: Image.Image, column: int, row: int) -> Image.Image:
    width, height = image.size
    left = round(width * column / 2)
    top = round(height * row / 2)
    right = round(width * (column + 1) / 2)
    bottom = round(height * (row + 1) / 2)
    return _visible_crop(image.crop((left, top, right, bottom)))


def _build_icon(source: Image.Image) -> Image.Image:
    source = _visible_crop(source)
    scale = min(CONTENT_SIZE / source.width, CONTENT_SIZE / source.height)
    target = (max(1, round(source.width * scale)), max(1, round(source.height * scale)))
    resized = source.resize(target, Image.Resampling.LANCZOS)

    alpha = resized.getchannel("A").point(lambda value: 255 if value >= 96 else 0)
    rgb = resized.convert("RGB").quantize(
        colors=PALETTE_COLORS,
        method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.NONE,
    ).convert("RGB")
    hardened = Image.merge("RGBA", (*rgb.split(), alpha))

    canvas = Image.new("RGBA", (ICON_SIZE, ICON_SIZE), (0, 0, 0, 0))
    destination = ((ICON_SIZE - target[0]) // 2, (ICON_SIZE - target[1]) // 2)
    canvas.alpha_composite(hardened, destination)
    return canvas


def main() -> None:
    if not CONCEPT_SOURCE.exists() or not HELM_SOURCE.exists() or not LEGGINGS_SOURCE.exists():
        raise FileNotFoundError("Stage V equipment source package is incomplete")

    concept = Image.open(CONCEPT_SOURCE).convert("RGBA")
    helm = Image.open(HELM_SOURCE).convert("RGBA")
    leggings = Image.open(LEGGINGS_SOURCE).convert("RGBA")
    sources = {
        "varkuun_edge_essence_64x64.png": _quadrant(concept, 0, 0),
        "heartwood_plate_64x64.png": _quadrant(concept, 1, 0),
        "rootfiber_gloves_64x64.png": _quadrant(concept, 0, 1),
        "mirehide_boots_64x64.png": _quadrant(concept, 1, 1),
        "old_bark_helm_64x64.png": _visible_crop(helm),
        "mirebound_leggings_64x64.png": _visible_crop(leggings),
    }

    CLEAN_DIR.mkdir(parents=True, exist_ok=True)
    RUNTIME_DIR.mkdir(parents=True, exist_ok=True)
    REVIEW_PATH.parent.mkdir(parents=True, exist_ok=True)

    icons: list[tuple[str, Image.Image]] = []
    for filename, source in sources.items():
        clean_path = CLEAN_DIR / filename.replace("_64x64", "_clean_v1")
        source.save(clean_path)
        icon = _build_icon(source)
        icon.save(RUNTIME_DIR / filename)
        icons.append((filename, icon))

    review = Image.new("RGBA", (6 * 272, 320), (7, 10, 16, 255))
    draw = ImageDraw.Draw(review)
    for index, (filename, icon) in enumerate(icons):
        x = index * 272
        review.alpha_composite(icon.resize((256, 256), Image.Resampling.NEAREST), (x + 8, 8))
        draw.text((x + 8, 278), filename.removesuffix("_64x64.png").replace("_", " ").upper(), fill=(220, 208, 178, 255))
    review.save(REVIEW_PATH)
    print("Processed six Stage V Forest core-equipment icons and one 4x review sheet.")


if __name__ == "__main__":
    main()
