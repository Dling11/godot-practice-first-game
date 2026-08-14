from pathlib import Path

from PIL import Image


SOURCE = Path(
    "art_source/cleaned/characters/enemies/stage_5_boss/"
    "stage_5_boss_idle_clean_v1.png"
)
OUTPUT_DIR = Path("art_source/review/characters/enemies/stage_5_boss")
CELL_SIZE = (112, 96)
FOOT_BASELINE_Y = 90
TARGET_MAX_HEIGHT = 78

# The generated board includes deliberate empty gutters. These reviewed bounds
# isolate the exact 4x4 cells without cutting neighboring oversized arms.
X_RANGES = [(41, 337), (340, 630), (631, 922), (924, 1227)]
Y_RANGES = [(23, 318), (342, 619), (639, 911), (937, 1211)]


def occupied_bounds(image: Image.Image) -> tuple[int, int, int, int]:
    alpha = image.getchannel("A").point(lambda value: 255 if value >= 128 else 0)
    bounds = alpha.getbbox()
    if bounds is None:
        raise RuntimeError("Generated Stage 5 boss cell is empty.")
    return bounds


def normalize_cell(cell: Image.Image, scale: float) -> Image.Image:
    bounds = occupied_bounds(cell)
    actor = cell.crop(bounds)
    size = (
        max(1, round(actor.width * scale)),
        max(1, round(actor.height * scale)),
    )
    actor = actor.resize(size, Image.Resampling.NEAREST)
    alpha = actor.getchannel("A").point(lambda value: 255 if value >= 128 else 0)
    actor.putalpha(alpha)
    canvas = Image.new("RGBA", CELL_SIZE, (0, 0, 0, 0))
    x = round((CELL_SIZE[0] - actor.width) / 2)
    y = FOOT_BASELINE_Y - actor.height
    if x < 0 or y < 0 or x + actor.width > CELL_SIZE[0]:
        raise RuntimeError(f"Normalized actor does not fit the declared cell: {size}")
    canvas.alpha_composite(actor, (x, y))
    return canvas


def main() -> None:
    source = Image.open(SOURCE).convert("RGBA")
    raw_cells: list[list[Image.Image]] = []
    maximum_height = 0
    for y0, y1 in Y_RANGES:
        row: list[Image.Image] = []
        for x0, x1 in X_RANGES:
            cell = source.crop((x0, y0, x1, y1))
            bounds = occupied_bounds(cell)
            maximum_height = max(maximum_height, bounds[3] - bounds[1])
            row.append(cell)
        raw_cells.append(row)
    scale = TARGET_MAX_HEIGHT / maximum_height

    sheet = Image.new(
        "RGBA", (CELL_SIZE[0] * 4, CELL_SIZE[1] * 4), (0, 0, 0, 0)
    )
    for row_index, row in enumerate(raw_cells):
        for column_index, cell in enumerate(row):
            normalized = normalize_cell(cell, scale)
            sheet.alpha_composite(
                normalized,
                (column_index * CELL_SIZE[0], row_index * CELL_SIZE[1]),
            )

    if sheet.size != (448, 384):
	    raise RuntimeError("Stage 5 idle candidate lost its exact 4x4 grid.")
    if set(sheet.getchannel("A").get_flattened_data()) - {0, 255}:
	    raise RuntimeError("Stage 5 idle candidate contains non-binary alpha.")
    for row_index in range(4):
	    for column_index in range(4):
	        cell = sheet.crop(
	            (
	                column_index * CELL_SIZE[0],
	                row_index * CELL_SIZE[1],
	                (column_index + 1) * CELL_SIZE[0],
	                (row_index + 1) * CELL_SIZE[1],
	            )
	        )
	        bounds = occupied_bounds(cell)
	        if bounds[3] != FOOT_BASELINE_Y:
	            raise RuntimeError(
	                f"Cell {row_index},{column_index} lost the shared foot baseline."
	            )

    OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    output = OUTPUT_DIR / "stage_5_boss_idle_sheet_112x96_candidate.png"
    sheet.save(output)
    review = sheet.resize((sheet.width * 3, sheet.height * 3), Image.Resampling.NEAREST)
    review.save(OUTPUT_DIR / "stage_5_boss_idle_sheet_3x_review.png")
    comparison = Image.new("RGBA", (240, 112), (24, 31, 27, 255))
    king_sheet = Image.open(
        "assets/characters/playable/king/simple_reboot/"
        "king_simple_locomotion_sheet_48x32.png"
    ).convert("RGBA")
    king = king_sheet.crop((0, 0, 48, 32))
    husk_sheet = Image.open(
        "assets/characters/enemies/rootbound_husk/"
        "rootbound_husk_walk_sheet_72x64.png"
    ).convert("RGBA")
    husk = husk_sheet.crop((0, 0, 72, 64))
    boss = sheet.crop((0, 0, CELL_SIZE[0], CELL_SIZE[1]))
    for actor, center_x in [(king, 38), (husk, 105), (boss, 188)]:
        bounds = occupied_bounds(actor)
        actor = actor.crop(bounds)
        comparison.alpha_composite(
            actor,
            (round(center_x - actor.width / 2), FOOT_BASELINE_Y - actor.height),
        )
    comparison.resize(
        (comparison.width * 4, comparison.height * 4), Image.Resampling.NEAREST
    ).save(OUTPUT_DIR / "stage_5_boss_real_scale_comparison_4x.png")
    print(f"Wrote {output} with shared scale {scale:.6f}")


if __name__ == "__main__":
    main()
