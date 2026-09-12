"""Import generated Examiner boards: matte removal, fixed-scale atlas packing.

This is asset preparation, not pose synthesis. Source PNGs are immutable.
All actions share one scale measured from the standing locomotion reference.
"""
from __future__ import annotations

import json
from collections import deque
from pathlib import Path

import numpy as np
from PIL import Image, ImageOps

ROOT = Path(__file__).resolve().parents[1]
SOURCE = ROOT / "art_source/generated/characters/disciples/examiner/rework_2026_09_12"
POLISH = ROOT / "art_source/generated/characters/disciples/examiner/polish_2026_09_12"
OUTPUT = ROOT / "assets/characters/enemies/examiner"
NAMES = {
    "locomotion": "locomotion", "thrust": "thrust", "sweep": "sweep",
    "charge": "judgment_charge", "slam": "ground_judgment",
    "refutation": "refutation", "axiom": "axiom_divide",
    "launch": "divine_descent_launch", "land": "divine_descent_land",
    "reaction": "reaction_withdraw",
}
CELL = (192, 160)
BASELINE = 128


def clean_source(path: Path) -> Image.Image:
    image = Image.open(path).convert("RGBA")
    a = np.array(image)
    rgb = a[:, :, :3].astype(np.int16)
    # Some ImageGen outputs bake a neutral checkerboard into RGB. Only the
    # exterior-connected neutral matte is removed; enclosed armor stays intact.
    if a[:, :, 3].min() == 255:
        candidate = (rgb.max(2) - rgb.min(2) < 24) & (rgb.min(2) > 92)
        h, w = candidate.shape
        exterior = np.zeros((h, w), dtype=bool)
        queue = deque()
        for x in range(w):
            for y in (0, h - 1):
                if candidate[y, x]:
                    exterior[y, x] = True
                    queue.append((x, y))
        for y in range(h):
            for x in (0, w - 1):
                if candidate[y, x] and not exterior[y, x]:
                    exterior[y, x] = True
                    queue.append((x, y))
        while queue:
            x, y = queue.popleft()
            for nx, ny in ((x - 1, y), (x + 1, y), (x, y - 1), (x, y + 1)):
                if 0 <= nx < w and 0 <= ny < h and candidate[ny, nx] and not exterior[ny, nx]:
                    exterior[ny, nx] = True
                    queue.append((nx, ny))
        a[exterior, 3] = 0
    # Discard anti-aliased fringe instead of promoting faint generated matte.
    a[:, :, 3] = np.where(a[:, :, 3] >= 210, 255, 0)
    a[a[:, :, 3] == 0, :3] = 0
    return Image.fromarray(a)


def cells(image: Image.Image) -> list[list[Image.Image]]:
    from examiner_source_components import extract_cells
    return extract_cells(image)


def anchor(frame: Image.Image, action: str, row: int, column: int) -> tuple[float, int]:
    a = np.array(frame)
    mask = a[:, :, 3] > 0
    if not mask.any():
        raise ValueError("Empty source cell")
    rgb = a[:, :, :3].astype(float)
    # Feet and charcoal legs are dark, while the downward blade is gold. The
    # bottommost dense dark body row therefore excludes the extending blade.
    dark = mask & (rgb.mean(2) < 108)
    ys = np.where(dark.sum(1) >= 18)[0]
    foot_y = int(ys[-1]) if len(ys) else int(np.where(mask)[0].max())
    lower = dark[max(0, foot_y - 9):foot_y + 1]
    xx = np.where(lower)[1]
    body_x = float(np.median(xx)) if len(xx) else frame.width / 2
    return body_x, foot_y


def main() -> None:
    reference = cells(clean_source(SOURCE / "locomotion.png"))
    ref_bounds = reference[0][0].getbbox()
    scale = 85.0 / (ref_bounds[3] - ref_bounds[1])
    report = {"cell": CELL, "foot_baseline": BASELINE, "scale": scale, "directions": ["down", "right", "left", "up"], "sheets": {}}
    for action, filename in NAMES.items():
        path = SOURCE / (action + ".png")
        if action == "slam":
            path = POLISH / "slam.png"
        if not path.exists():
            continue
        board = cells(clean_source(path))
        if action == "slam":
            # The repaired board has a different source density. Normalize once
            # using its standing pose, never fit individual extended poses.
            standing = board[0][0].getbbox()
            density = (ref_bounds[3] - ref_bounds[1]) / (standing[3] - standing[1])
            board = [[pose.resize((round(pose.width * density), round(pose.height * density)), Image.Resampling.NEAREST) for pose in row] for row in board]
            raised = clean_source(SOURCE / "slam_raise.png")
            # Supplement is a 2x2 source board. Normalize source pixel density
            # once to the eight-column reference before the common runtime scale.
            density = Image.open(SOURCE / "locomotion.png").width / 8 / (raised.width / 2)
            for row in range(4):
                x, y = row % 2, row // 2
                pose = raised.crop((round(x * raised.width / 2), round(y * raised.height / 2),
                                   round((x + 1) * raised.width / 2), round((y + 1) * raised.height / 2)))
                board[row][2] = pose.resize((round(pose.width * density), round(pose.height * density)), Image.Resampling.NEAREST)
        if action == "land":
            # The generated landing source's profile rows face left/right;
            # normalize them to the shared runtime right/left contract.
            board[1], board[2] = board[2], board[1]
        if action != "locomotion":
            # Profile attacks are symmetric. Mirror the reviewed right sequence
            # so the left contact cannot silently become a second wind-up pose.
            board[2] = [ImageOps.mirror(frame) for frame in board[1]]
        sheet = Image.new("RGBA", (CELL[0] * 8, CELL[1] * 4))
        bounds = []
        for row in range(4):
            for column in range(8):
                frame = board[row][column]
                x, y = anchor(frame, action, row, column)
                resized = frame.resize((round(frame.width * scale), round(frame.height * scale)), Image.Resampling.NEAREST)
                target = Image.new("RGBA", CELL)
                target.paste(resized, (round(96 - x * scale), round(BASELINE - y * scale)))
                bbox = target.getbbox()
                if bbox is None or bbox[0] == 0 or bbox[1] == 0 or bbox[2] == CELL[0] or bbox[3] == CELL[1]:
                    raise ValueError(f"Clipped or empty runtime pose: {action}/{row}/{column}: {bbox}")
                sheet.paste(target, (column * CELL[0], row * CELL[1]))
                bounds.append(bbox)
        out = OUTPUT / f"examiner_{filename}_sheet_192x160.png"
        sheet.save(out)
        report["sheets"][action] = {"source": str(path.relative_to(ROOT)), "output": str(out.relative_to(ROOT)), "bounds": bounds}
        print(action, sheet.size, "32 poses")
    (SOURCE / "import_report.json").write_text(json.dumps(report, indent=2) + "\n")
    floor = SOURCE / "court.png"
    if floor.exists():
        Image.open(floor).convert("RGB").resize((650, 390), Image.Resampling.NEAREST).save(
            ROOT / "assets/environment/arenas/divine_order/court_of_first_measure/court_slate_floor.png")


if __name__ == "__main__":
    main()
    from process_examiner_polish import main as import_polish
    import_polish()
