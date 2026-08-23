"""Build reusable top-down Stage VI terrain art without replacing its ground tiles."""

from __future__ import annotations

from pathlib import Path

from PIL import Image, ImageEnhance


ROOT = Path(__file__).resolve().parents[1]
GENERATED = ROOT / "art_source/generated/environment/forest/stage_6/modular_topdown"
RUNTIME = ROOT / "assets/environment/forest/stage_6"
REVIEW = ROOT / "art_source/review/environment/forest/stage_6/modular_topdown"

CLIFF_SOURCE = GENERATED / "stage_6_cliff_kit_source_v1.png"
WATERFALL_SOURCE = GENERATED / "stage_6_waterfall_4f_source_v2.png"
WATERFALL_ALPHA_REFERENCE = GENERATED / "stage_6_waterfall_4f_source_v1.png"
GROUND_SOURCE = ROOT / "assets/environment/forest/shared/tiles/verdant_forest_ground_atlas_4x4.png"
GROUND_RUNTIME = RUNTIME / "tiles/elder_ascent_ground_atlas_4x4.png"
WATERFALL_RUNTIME = RUNTIME / "waterfall/upper_terrace_waterfall_4f_192x256.png"
WATERFALL_LIP_RUNTIME = RUNTIME / "waterfall/modules/waterfall_cliff_lip_static_192x96.png"
WATERFALL_FLOW_RUNTIME = RUNTIME / "waterfall/modules/waterfall_flow_4f_64x96.png"
WATERFALL_BASIN_RUNTIME = RUNTIME / "waterfall/modules/waterfall_basin_static_192x96.png"

# Source board contract: three columns by two rows. Output canvases intentionally
# differ because the pieces are props, not a monolithic background or TileSet.
CLIFF_PIECES = (
    ("cliff_straight_256x160.png", 0, 0, (256, 160)),
    ("cliff_outer_corner_192x224.png", 1, 0, (192, 224)),
    ("cliff_inner_corner_224x208.png", 2, 0, (224, 208)),
    ("rocky_outcrop_208x208.png", 0, 1, (208, 208)),
    ("boulder_cluster_192x176.png", 1, 1, (192, 176)),
    ("cliff_ramp_192x224.png", 2, 1, (192, 224)),
)


def _pixel_finish(image: Image.Image, colors: int) -> Image.Image:
    """Reduce generated gradients into stable hard-pixel palette clusters."""
    alpha = image.getchannel("A").point(lambda value: 255 if value >= 128 else 0)
    rgb = ImageEnhance.Contrast(image.convert("RGB")).enhance(1.05)
    rgb = rgb.quantize(
        colors=colors,
        method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.NONE,
    ).convert("RGB")
    output = rgb.convert("RGBA")
    output.putalpha(alpha)
    return output


def _fit_piece(cell: Image.Image, canvas_size: tuple[int, int]) -> Image.Image:
    alpha = cell.getchannel("A").point(lambda value: 255 if value >= 128 else 0)
    bounds = alpha.getbbox()
    if bounds is None:
        raise ValueError("Generated cliff cell contains no usable opaque pixels")
    crop = cell.crop(bounds)
    available_width = canvas_size[0] - 8
    available_height = canvas_size[1] - 8
    scale = min(available_width / crop.width, available_height / crop.height)
    target_size = (
        max(1, round(crop.width * scale)),
        max(1, round(crop.height * scale)),
    )
    crop = crop.resize(target_size, Image.Resampling.LANCZOS)
    crop = _pixel_finish(crop, 64)
    canvas = Image.new("RGBA", canvas_size, (0, 0, 0, 0))
    canvas.alpha_composite(
        crop,
        ((canvas_size[0] - crop.width) // 2, canvas_size[1] - crop.height - 4),
    )
    return canvas


def build_cliff_pieces() -> list[Path]:
    source = Image.open(CLIFF_SOURCE).convert("RGBA")
    if source.size != (1536, 1024):
        raise ValueError(f"Unexpected cliff source size: {source.size}")
    output_directory = RUNTIME / "props/modular_cliffs"
    output_directory.mkdir(parents=True, exist_ok=True)
    outputs: list[Path] = []
    for filename, column, row, canvas_size in CLIFF_PIECES:
        cell = source.crop((column * 512, row * 512, (column + 1) * 512, (row + 1) * 512))
        piece = _fit_piece(cell, canvas_size)
        destination = output_directory / filename
        piece.save(destination)
        outputs.append(destination)
    return outputs


def build_waterfall() -> Image.Image:
    source = Image.open(WATERFALL_SOURCE).convert("RGBA")
    alpha_reference = Image.open(WATERFALL_ALPHA_REFERENCE).convert("RGBA")
    if source.width % 4 != 0 or alpha_reference.size != source.size:
        raise ValueError("Waterfall source must contain exactly four equal horizontal frames")
    frame_width = source.width // 4
    processed_frames: list[Image.Image] = []
    for frame_index in range(4):
        bounds = (frame_index * frame_width, 0, (frame_index + 1) * frame_width, source.height)
        frame = source.crop(bounds)
        # The v2 edit returned a checkerboard matte. Reuse the matching v1 alpha
        # silhouette and fall back to v1 color wherever that matte intrudes into
        # the silhouette. This avoids pale checker fringe without keying valid
        # pale water/foam to transparency.
        reference_frame = alpha_reference.crop(bounds)
        frame_pixels = frame.load()
        reference_pixels = reference_frame.load()
        for y in range(frame.height):
            for x in range(frame.width):
                red, green, blue, _alpha = frame_pixels[x, y]
                if min(red, green, blue) > 220 and max(red, green, blue) - min(red, green, blue) < 10:
                    frame_pixels[x, y] = reference_pixels[x, y]
        alpha = reference_frame.getchannel("A")
        frame.putalpha(alpha)
        frame = frame.resize((192, 256), Image.Resampling.LANCZOS)
        processed_frames.append(_pixel_finish(frame, 80))

    # Frame zero owns every terrain, bank, source-pool, basin, and curtain-edge
    # pixel. Only water texture inside one fixed curtain mask travels downward.
    canonical = processed_frames[0]
    canonical_pixels = canonical.load()
    curtain_left, curtain_top = 69, 62
    curtain_right, curtain_bottom = 123, 174

    def is_water_pixel(x: int, y: int) -> bool:
        red, green, blue, alpha = canonical_pixels[x, y]
        if alpha == 0:
            return False
        cool_water = blue > red * 1.07 and green > red * 1.04 and blue > 86
        pale_foam = red > 168 and green >= red and blue >= green * 0.97
        return cool_water or pale_foam

    curtain_mask = {
        (x, y)
        for y in range(curtain_top, curtain_bottom)
        for x in range(curtain_left, curtain_right)
        if is_water_pixel(x, y)
    }

    sheet = Image.new("RGBA", (192 * 4, 256), (0, 0, 0, 0))
    stable_frames: list[Image.Image] = []
    for frame_index, phase in enumerate((0, 4, 8, 12)):
        frame = canonical.copy()
        frame_pixels = frame.load()
        for x, y in curtain_mask:
            source_y = curtain_top + ((y - curtain_top - phase) % (curtain_bottom - curtain_top))
            if (x, source_y) in curtain_mask:
                frame_pixels[x, y] = canonical_pixels[x, source_y]

        # Foam changes brightness in place; its position and silhouette do not.
        foam_factor = (1.0, 1.06, 0.96, 1.03)[frame_index]
        for y in range(158, 207):
            for x in range(48, 145):
                if not is_water_pixel(x, y):
                    continue
                red, green, blue, alpha = frame_pixels[x, y]
                if red < 150:
                    continue
                frame_pixels[x, y] = (
                    min(255, round(red * foam_factor)),
                    min(255, round(green * foam_factor)),
                    min(255, round(blue * foam_factor)),
                    alpha,
                )
        stable_frames.append(frame)
        sheet.alpha_composite(frame, (frame_index * 192, 0))

    WATERFALL_RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    sheet.save(WATERFALL_RUNTIME)

    # Reusable height/location kit: fixed carved lip, looping water-only middle,
    # and fixed basin. Future maps can compose these without regenerating art.
    WATERFALL_LIP_RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    canonical.crop((0, 0, 192, 96)).save(WATERFALL_LIP_RUNTIME)
    canonical.crop((0, 160, 192, 256)).save(WATERFALL_BASIN_RUNTIME)
    flow_sheet = Image.new("RGBA", (64 * 4, 96), (0, 0, 0, 0))
    for frame_index, frame in enumerate(stable_frames):
        flow = frame.crop((64, 70, 128, 166))
        flow_pixels = flow.load()
        for y in range(flow.height):
            for x in range(flow.width):
                world_x, world_y = x + 64, y + 70
                if (world_x, world_y) not in curtain_mask:
                    red, green, blue, _alpha = flow_pixels[x, y]
                    flow_pixels[x, y] = (red, green, blue, 0)
        flow_sheet.alpha_composite(flow, (frame_index * 64, 0))
    flow_sheet.save(WATERFALL_FLOW_RUNTIME)
    return sheet


def build_ground_atlas() -> Image.Image:
    """Preserve the approved Stage VI recolor derived from the shared forest atlas."""
    source = Image.open(GROUND_SOURCE).convert("RGB")
    output = Image.new("RGB", source.size)
    source_pixels = source.load()
    output_pixels = output.load()
    for y in range(source.height):
        for x in range(source.width):
            red, green, blue = source_pixels[x, y]
            if green > red * 1.08 and green > blue * 1.12:
                new_red = round(red * 0.42 + blue * 0.12)
                new_green = round(green * 0.62 + blue * 0.08)
                new_blue = round(blue * 0.55 + green * 0.25)
            else:
                new_red = round(red * 0.76 + 8)
                new_green = round(green * 0.78 + 10)
                new_blue = round(blue * 0.82 + 14)
            output_pixels[x, y] = (
                max(0, min(255, new_red)),
                max(0, min(255, new_green)),
                max(0, min(255, new_blue)),
            )
    output = output.quantize(
        colors=72,
        method=Image.Quantize.MEDIANCUT,
        dither=Image.Dither.NONE,
    ).convert("RGB")
    GROUND_RUNTIME.parent.mkdir(parents=True, exist_ok=True)
    output.save(GROUND_RUNTIME)
    return output


def main() -> None:
    for source in (CLIFF_SOURCE, WATERFALL_SOURCE, WATERFALL_ALPHA_REFERENCE, GROUND_SOURCE):
        if not source.exists():
            raise FileNotFoundError(f"Missing Stage VI art source: {source}")
    cliff_paths = build_cliff_pieces()
    waterfall = build_waterfall()
    ground = build_ground_atlas()
    REVIEW.mkdir(parents=True, exist_ok=True)
    for path in cliff_paths:
        image = Image.open(path).convert("RGBA")
        image.resize((image.width * 2, image.height * 2), Image.Resampling.NEAREST).save(REVIEW / path.name)
    waterfall.resize((1536, 512), Image.Resampling.NEAREST).save(REVIEW / "upper_terrace_waterfall_2x.png")
    ground.resize((512, 512), Image.Resampling.NEAREST).save(REVIEW / "elder_ascent_ground_2x.png")
    print("Wrote reusable Stage VI cliff props, four-frame waterfall, and preserved ground atlas.")


if __name__ == "__main__":
    main()
