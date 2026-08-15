"""Build the small, stylized Stage 5 carrion detail without realistic anatomy."""

from pathlib import Path

from PIL import Image, ImageDraw


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/handmade/environment/stage_5/stage_5_tiny_carrion_remains_source_v1.png"


def main() -> None:
    image = Image.new("RGBA", (48, 32), (0, 0, 0, 0))
    draw = ImageDraw.Draw(image)

    # Ground-hugging, deliberately abstract remains: curled body, skull, ribs, and one dry tail.
    shadow = (20, 12, 22, 180)
    bark = (57, 42, 49, 255)
    fur = (78, 55, 59, 255)
    bone = (151, 127, 98, 255)
    bone_light = (191, 166, 126, 255)
    rot = (89, 104, 64, 255)
    rot_light = (128, 143, 74, 255)

    draw.rectangle((6, 25, 39, 27), fill=shadow)
    draw.polygon([(11, 20), (14, 15), (23, 13), (31, 16), (34, 21), (28, 24), (17, 24)], fill=bark)
    draw.polygon([(14, 18), (20, 14), (28, 16), (31, 20), (27, 22), (18, 22)], fill=fur)
    draw.rectangle((15, 17, 17, 19), fill=rot)
    draw.rectangle((19, 15, 21, 17), fill=rot_light)
    draw.rectangle((23, 16, 24, 21), fill=bone)
    draw.rectangle((26, 16, 27, 21), fill=bone_light)
    draw.rectangle((29, 17, 30, 21), fill=bone)
    draw.rectangle((22, 19, 31, 20), fill=bone_light)
    draw.polygon([(9, 20), (12, 18), (15, 20), (14, 23), (10, 23)], fill=bone)
    draw.rectangle((10, 21, 11, 22), fill=(33, 23, 29, 255))
    draw.rectangle((13, 21, 14, 22), fill=(33, 23, 29, 255))
    draw.line([(33, 20), (38, 19), (40, 16), (43, 15)], fill=fur, width=2)
    draw.point((44, 14), fill=rot_light)
    draw.rectangle((17, 23, 20, 24), fill=bone)
    draw.rectangle((29, 22, 33, 23), fill=bone)
    draw.point((7, 24), fill=rot)
    draw.point((38, 23), fill=rot)

    SOURCE.parent.mkdir(parents=True, exist_ok=True)
    image.save(SOURCE)
    print(f"Wrote {SOURCE.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
