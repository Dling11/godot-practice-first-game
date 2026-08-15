"""Normalize the approved Stage 5 boss portrait into the 96x96 UI contract."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/cleaned/characters/enemies/stage_5_boss/stage_5_boss_portrait_clean_v1.png"
RUNTIME = ROOT / "assets/characters/enemies/portraits/stage_5_boss_portrait_96x96.png"
REVIEW = ROOT / "art_source/review/characters/enemies/stage_5_boss/stage_5_boss_portrait_96x96_4x_review.png"

RUNTIME_SIZE = 96
CONTENT_SIZE = 92
ALPHA_CONNECTIVITY_THRESHOLD = 8


def centered_square_from_alpha(image: Image.Image) -> Image.Image:
    alpha_bounds = image.getchannel("A").getbbox()
    if alpha_bounds is None:
        raise ValueError(f"Portrait source has no visible pixels: {SOURCE}")

    left, top, right, bottom = alpha_bounds
    square_size = min(right - left, bottom - top)
    center_x = (left + right) // 2
    crop_left = max(0, min(image.width - square_size, center_x - square_size // 2))
    return image.crop((crop_left, top, crop_left + square_size, top + square_size))


def remove_disconnected_alpha_specks(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    visible = {
        (x, y)
        for y in range(image.height)
        for x in range(image.width)
        if alpha.getpixel((x, y)) >= ALPHA_CONNECTIVITY_THRESHOLD
    }
    components: list[set[tuple[int, int]]] = []

    while visible:
        pending = [visible.pop()]
        component: set[tuple[int, int]] = set()
        while pending:
            point = pending.pop()
            component.add(point)
            x, y = point
            for neighbor in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if neighbor in visible:
                    visible.remove(neighbor)
                    pending.append(neighbor)
        components.append(component)

    if not components:
        raise ValueError("Normalized portrait has no visible alpha component")

    silhouette = max(components, key=len)
    output = image.copy()
    output_alpha = output.getchannel("A")
    for y in range(output.height):
        for x in range(output.width):
            if (x, y) not in silhouette:
                output_alpha.putpixel((x, y), 0)
    output.putalpha(output_alpha)
    return output


def main() -> None:
    if not SOURCE.exists():
        raise FileNotFoundError(f"Missing cleaned portrait source: {SOURCE}")

    source = Image.open(SOURCE).convert("RGBA")
    crop = centered_square_from_alpha(source)
    normalized = crop.resize((CONTENT_SIZE, CONTENT_SIZE), Image.Resampling.LANCZOS)
    normalized = remove_disconnected_alpha_specks(normalized)

    canvas = Image.new("RGBA", (RUNTIME_SIZE, RUNTIME_SIZE), (0, 0, 0, 0))
    inset = (RUNTIME_SIZE - CONTENT_SIZE) // 2
    canvas.alpha_composite(normalized, (inset, inset))

    RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    REVIEW.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(RUNTIME)
    canvas.resize((RUNTIME_SIZE * 4, RUNTIME_SIZE * 4), Image.Resampling.NEAREST).save(REVIEW)

    print(f"Wrote {RUNTIME.relative_to(ROOT)}")
    print(f"Wrote {REVIEW.relative_to(ROOT)}")


if __name__ == "__main__":
    main()
