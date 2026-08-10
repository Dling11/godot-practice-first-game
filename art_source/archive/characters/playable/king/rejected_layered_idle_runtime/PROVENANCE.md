# King Idle Source Provenance

The approved body source is `king_idle_body_only_source_v1.png`. The built-in ImageGen environment removed the inconsistent generated weapon, then deterministic processing constructs one exact straight greatsword axis and composites it with the normalized body. This prevents the blade, guard, grip, hand, and pommel from drifting independently.

The earlier integrated-weapon v1-v3 boards are rejected because their grips remained outside the blade rails even when the blade looked straight. They are retained only under `art_source/archive/characters/playable/king/rejected_idle_sword_alignment/` and never enter runtime processing.

## Rejected initial generation prompt

```text
Use case: identity-preserve
Asset type: source board for a Godot 4.7 top-down pixel character idle animation
Primary request: create one clean 4-column by 3-row source board for King, with exactly twelve separate full-body poses. Row 1 is idle_down, row 2 is idle_left, row 3 is idle_up/back. Each row contains exactly four subtle idle frames from left to right. Do not include a right-facing row because runtime will mirror left exactly.

Identity: preserve the approved King turnaround direction reference exactly: young-prime adult male chibi warrior, compact but broader and taller than Opaw, spiky dark charcoal hair, warm light skin, stern readable face, dark navy layered tunic and short coat, steel shoulder plate and bracers, muted crimson cloth accents, dark boots, oversized rectangular silver-gray greatsword with dark inner channel and gold/brown hilt. No cape, crown, shield, helmet, text, emblems, extra weapons, or decorative particles.

Pose and grip continuity: the greatsword rests over the sword-side shoulder in every idle direction. The handle must visibly connect to the sword-side hand and shoulder; the blade tip points outward and never into the head. For the back/up row, the sword-side arm bends upward and the hand visibly grips the hilt at shoulder height while the off-hand hangs naturally. Do not copy the rejected low dangling rear hand.

Animation: four genuinely distinct but restrained idle poses per row: settle, small breath rise, cloth/weight response, return. Preserve exact body mass, head size, clothing silhouette, sword length, hilt location, foot baseline, and direction across frames. Do not fake animation with only floating or scaling. No attack motion and no magic VFX.

Composition and grid: exact straight 4x3 matrix, equal rectangular cells, generous clear gutters, one centered character in every cell, identical scale, fixed foot baseline within each row, no overlap, no cropping, no captions, no labels, no grid lines, no borders, no UI. Keep every sword tip safely inside its cell. Landscape board.

Pixel-art rules: authentic low-resolution game sprite appearance, hard square pixel clusters, crisp one-pixel dark outline, nearest-neighbor look, limited compact palette, no antialiasing, no blur, no painterly shading, no glow, no gradients, no subpixel detail. The result should read cleanly when reduced for top-down gameplay.

Background: perfectly flat single-color chroma magenta #FF00FF across the entire background and gutters, with no texture, shadow, vignette, lighting variation, or transparency simulation. Do not use magenta or bright lime in the character.

Hard negatives: no isometric tiles, no scenery, no floor shadow, no checkerboard, no lime fringe, no magenta fringe, no duplicated character inside a cell, no missing limbs, no detached hands, no sword through the head, no sword on the back, no pure front-only row, no inconsistent camera angle, no changing costume, and no changing weapon proportions.
```

## Rejected rear-grip corrective prompt

```text
Edit only the bottom row (the four back/up-facing idle poses). Keep the top two rows, the 4-column by 3-row layout, exact identity, scale, pixel style, flat magenta background, and every other detail unchanged.

In every bottom-row pose, correct the greatsword grip: the sword-side arm must visibly bend upward from the shoulder, with the hand clearly wrapped around the hilt at shoulder height. The hilt and hand must visibly connect to the greatsword resting over that shoulder. The other/off-hand must hang naturally at the character's side. Remove the rejected low dangling sword-side hand. Keep the blade tip pointing outward to the upper-right, safely away from the head and inside each cell. Preserve the same foot baseline and four subtle idle phases. No added text, grid, effects, shadow, or scenery.
```

## Approved body-only edit prompt

```text
Use case: precise-object-edit
Asset type: body-only source board for a Godot 4.7 top-down pixel character idle animation
Input image: the most recent full 4-column by 3-row magenta King idle board is the edit target.
Primary request: remove the greatsword and every weapon-specific piece from all twelve frames: delete the entire blade, ricasso, guard, grip, pommel, crimson cord/tassel, and any detached hilt parts. Reconstruct the pixels hidden by the weapon so King becomes a clean weaponless idle body in every frame. Give him two simple natural visible arms: the future sword-side arm is bent comfortably with its hand held close beside the upper torso/shoulder, ready to receive a separately rendered grip; the other arm hangs naturally at his side. No arm reaches far outward and no hand holds an invisible object.
Invariants: preserve exactly the existing 4x3 layout and frame positions, King identity, young-prime face, hair including pale streak, body proportions, navy/charcoal/crimson costume, armor, idle phases, scale, feet, baseline, top-down three-quarter directions, palette, lighting, hard-pixel style, and perfectly flat uniform magenta background. Preserve all non-weapon pixels as closely as possible. The four top frames remain down/front, middle four remain left/profile, bottom four remain up/back.
Pixel constraints: crisp square pixel clusters, one-pixel dark outline, no antialiasing, blur, gradients, shadows, text, labels, grid, VFX, or extra objects.
Reject: any remaining blade, guard, grip, pommel, red weapon cord, sheath, weapon shadow, invisible-object gripping pose, missing arm, detached hand, changed costume/face, changed frame count, cropping, or background variation.
```

## Deterministic processing

- Chroma cleanup: ImageGen skill `remove_chroma_key.py` with border auto-key, soft matte, transparent threshold 12, opaque threshold 220, despill, and one-pixel edge contraction.
- Exact runtime packing: `tools/process_king_idle_assets.py`.
- Runtime body layer: `assets/characters/playable/king/king_idle_body_sheet_64x64.png`.
- Runtime sword/hand layer: `assets/characters/playable/king/king_idle_sword_sheet_64x64.png`.
- Combined runtime output: `assets/characters/playable/king/king_idle_sheet_64x64.png`.
- Layout: four columns by four direction rows (`down`, `left`, mirrored `right`, `up`), 64x64 cells.
- Sword contract: blade tip, blade core, guard center, wrapped hand, grip, and pommel use one deterministic 45-degree axis in every frame. The smoke test samples every axis pixel and fails any gap, kink, offset, or ordering error.
- Runtime requirements: binary alpha, shared foot baseline, geometric foot center, 20-color maximum, no matte residue, exact left/right mirroring, and continuous sword geometry.
