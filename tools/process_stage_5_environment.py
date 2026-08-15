"""Normalize the generated Stage 5 terrain and prop sources for Godot."""

from pathlib import Path

from PIL import Image


ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / "art_source/generated/environment/stage_5"
CLEANED = ROOT / "art_source/cleaned/environment/stage_5"
RUNTIME = ROOT / "assets/environment/forest/stage_5"
REVIEW = ROOT / "art_source/review/environment/stage_5"

TERRAIN_SOURCE = GENERATED / "stage_5_decay_ground_source_v1.png"
SHRINE_SOURCE = CLEANED / "stage_5_broken_shrine_clean_v1.png"
DEAD_FOREST_SOURCE = CLEANED / "stage_5_dead_forest_props_clean_v1.png"
DEAD_ANIMAL_SOURCE = ROOT / "art_source/handmade/environment/stage_5/stage_5_tiny_carrion_remains_source_v1.png"
EDGE_THICKET_SOURCE = CLEANED / "stage_5_edge_thicket_clean_v1.png"

TERRAIN_RUNTIME = RUNTIME / "tiles/stage_5_decay_ground_atlas_4x4.png"
SHRINE_RUNTIME = RUNTIME / "props/stage_5_broken_shrine_320x192.png"
TALL_TREE_RUNTIME = RUNTIME / "props/stage_5_tall_dead_tree_144x192.png"
SNAG_RUNTIME = RUNTIME / "props/stage_5_dead_tree_snag_128x160.png"
FALLEN_LOG_RUNTIME = RUNTIME / "props/stage_5_fallen_log_192x96.png"
UPROOTED_LOG_RUNTIME = RUNTIME / "props/stage_5_uprooted_log_192x128.png"
DEAD_ANIMAL_RUNTIME = RUNTIME / "props/stage_5_tiny_carrion_remains_48x32.png"
EDGE_THICKET_RUNTIME = RUNTIME / "props/stage_5_edge_thicket_256x192.png"

ALPHA_THRESHOLD = 8


def largest_alpha_component(image: Image.Image) -> Image.Image:
    alpha = image.getchannel("A")
    visible = {
        (x, y)
        for y in range(image.height)
        for x in range(image.width)
        if alpha.getpixel((x, y)) >= ALPHA_THRESHOLD
    }
    components: list[set[tuple[int, int]]] = []
    while visible:
        pending = [visible.pop()]
        component: set[tuple[int, int]] = set()
        while pending:
            x, y = pending.pop()
            component.add((x, y))
            for neighbor in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if neighbor in visible:
                    visible.remove(neighbor)
                    pending.append(neighbor)
        components.append(component)
    if not components:
        raise ValueError("Processed prop has no visible component")

    silhouette = max(components, key=len)
    output = image.copy()
    output_alpha = output.getchannel("A")
    for y in range(output.height):
        for x in range(output.width):
            if (x, y) not in silhouette:
                output_alpha.putpixel((x, y), 0)
    output.putalpha(output_alpha)
    return output


def normalize_prop(source_path: Path, output_path: Path, size: tuple[int, int], margin: int) -> Image.Image:
    source = Image.open(source_path).convert("RGBA")
    bounds = source.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError(f"Prop source has no visible pixels: {source_path}")
    crop = source.crop(bounds)

    max_width = size[0] - margin * 2
    max_height = size[1] - margin * 2
    scale = min(max_width / crop.width, max_height / crop.height)
    target = (
        max(1, round(crop.width * scale)),
        max(1, round(crop.height * scale)),
    )
    normalized = crop.resize(target, Image.Resampling.LANCZOS)
    normalized = largest_alpha_component(normalized)

    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    position = ((size[0] - target[0]) // 2, size[1] - margin - target[1])
    canvas.alpha_composite(normalized, position)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output_path)
    return canvas


def normalize_image_prop(source: Image.Image, output_path: Path, size: tuple[int, int], margin: int) -> Image.Image:
    bounds = source.getchannel("A").getbbox()
    if bounds is None:
        raise ValueError(f"Prop cell has no visible pixels: {output_path.name}")
    crop = source.crop(bounds)
    max_width = size[0] - margin * 2
    max_height = size[1] - margin * 2
    scale = min(max_width / crop.width, max_height / crop.height)
    target = (max(1, round(crop.width * scale)), max(1, round(crop.height * scale)))
    normalized = crop.resize(target, Image.Resampling.LANCZOS)
    canvas = Image.new("RGBA", size, (0, 0, 0, 0))
    position = ((size[0] - target[0]) // 2, size[1] - margin - target[1])
    canvas.alpha_composite(normalized, position)
    output_path.parent.mkdir(parents=True, exist_ok=True)
    canvas.save(output_path)
    return canvas


def normalize_dead_forest_props() -> tuple[Image.Image, Image.Image, Image.Image, Image.Image]:
    board = Image.open(DEAD_FOREST_SOURCE).convert("RGBA")
    half_width = board.width // 2
    half_height = board.height // 2
    cells = (
        board.crop((0, 0, half_width, half_height)),
        board.crop((half_width, 0, board.width, half_height)),
        board.crop((0, half_height, half_width, board.height)),
        board.crop((half_width, half_height, board.width, board.height)),
    )
    tall_tree = normalize_image_prop(cells[0], TALL_TREE_RUNTIME, (144, 192), 3)
    snag = normalize_image_prop(cells[1], SNAG_RUNTIME, (128, 160), 3)
    fallen_log = normalize_image_prop(cells[2], FALLEN_LOG_RUNTIME, (192, 96), 3)
    uprooted_log = normalize_image_prop(cells[3], UPROOTED_LOG_RUNTIME, (192, 128), 3)
    return tall_tree, snag, fallen_log, uprooted_log


def normalize_terrain() -> Image.Image:
    source = Image.open(TERRAIN_SOURCE).convert("RGB")
    atlas = Image.new("RGB", (256, 256))
    for row in range(4):
        for column in range(4):
            left = round(column * source.width / 4)
            right = round((column + 1) * source.width / 4)
            top = round(row * source.height / 4)
            bottom = round((row + 1) * source.height / 4)
            inset = 2
            cell = source.crop((left + inset, top + inset, right - inset, bottom - inset))
            cell = cell.resize((64, 64), Image.Resampling.LANCZOS)
            atlas.paste(cell, (column * 64, row * 64))

    TERRAIN_RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    atlas.save(TERRAIN_RUNTIME)
    return atlas


def save_review(image: Image.Image, name: str, scale: int) -> None:
    REVIEW.mkdir(parents=True, exist_ok=True)
    image.resize((image.width * scale, image.height * scale), Image.Resampling.NEAREST).save(REVIEW / name)


def main() -> None:
    for source in (TERRAIN_SOURCE, SHRINE_SOURCE, DEAD_FOREST_SOURCE, DEAD_ANIMAL_SOURCE, EDGE_THICKET_SOURCE):
        if not source.exists():
            raise FileNotFoundError(f"Missing Stage 5 environment source: {source}")

    terrain = normalize_terrain()
    shrine = normalize_prop(SHRINE_SOURCE, SHRINE_RUNTIME, (320, 192), 4)
    tall_tree, snag, fallen_log, uprooted_log = normalize_dead_forest_props()
    dead_animal = normalize_prop(DEAD_ANIMAL_SOURCE, DEAD_ANIMAL_RUNTIME, (48, 32), 2)
    edge_thicket = normalize_prop(EDGE_THICKET_SOURCE, EDGE_THICKET_RUNTIME, (256, 192), 3)

    save_review(terrain, "stage_5_decay_ground_atlas_2x_review.png", 2)
    save_review(shrine, "stage_5_broken_shrine_2x_review.png", 2)
    save_review(tall_tree, "stage_5_tall_dead_tree_2x_review.png", 2)
    save_review(snag, "stage_5_dead_tree_snag_2x_review.png", 2)
    save_review(fallen_log, "stage_5_fallen_log_2x_review.png", 2)
    save_review(uprooted_log, "stage_5_uprooted_log_2x_review.png", 2)
    save_review(dead_animal, "stage_5_dead_animal_3x_review.png", 3)
    save_review(edge_thicket, "stage_5_edge_thicket_2x_review.png", 2)
    print("Wrote Stage 5 terrain, dead-forest props, carcass, edge thicket, shrine, and review images.")


if __name__ == "__main__":
    main()
