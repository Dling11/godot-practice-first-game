from pathlib import Path

import numpy as np
from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/cleaned/items/materials/forest/armored_hog_materials_clean_v1.png"
OUTPUT = ROOT / "assets/items/materials/forest"
REVIEW = ROOT / "art_source/review/items/materials/forest/armored_hog_materials_24x24_review.png"
NAMES = ("armored_hog_hide_24x24.png", "living_bark_plate_24x24.png")


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    output_icons: list[Image.Image] = []
    for index, name in enumerate(NAMES):
        left = round(index * source.width / 2)
        right = round((index + 1) * source.width / 2)
        cell = source.crop((left, 0, right, source.height))
        bbox = cell.getbbox()
        if bbox is None:
            raise RuntimeError(f"Empty material cell {index}")
        item = cell.crop(bbox)
        scale = min(20 / item.width, 20 / item.height)
        size = (max(1, round(item.width * scale)), max(1, round(item.height * scale)))
        item = item.resize(size, Image.Resampling.NEAREST)
        alpha = np.array(item.getchannel("A"))
        item.putalpha(Image.fromarray(np.where(alpha >= 128, 255, 0).astype(np.uint8), "L"))
        icon = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
        icon.alpha_composite(item, ((24 - item.width) // 2, (24 - item.height) // 2))
        OUTPUT.mkdir(parents=True, exist_ok=True)
        icon.save(OUTPUT / name)
        output_icons.append(icon)
    review = Image.new("RGBA", (192, 96), (30, 38, 32, 255))
    for index, icon in enumerate(output_icons):
        review.alpha_composite(icon.resize((96, 96), Image.Resampling.NEAREST), (index * 96, 0))
    REVIEW.parent.mkdir(parents=True, exist_ok=True)
    review.save(REVIEW)
    print("Wrote Armored Hog material icons and review.")


if __name__ == "__main__":
    main()
