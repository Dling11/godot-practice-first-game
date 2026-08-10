# King Greatsword Direction-Proof Provenance

Both assets were created on 2026-08-02 with the built-in image-generation workflow in reference/edit mode. They are design references, not runtime sprite sheets.

Owner review outcome:

- Greatsword design and the Opening Cut/VFX proof are approved.
- The turnaround's up/back pose is rejected: its sword-side hand hangs below the hilt, making the weapon read as mounted on King's back. Any replacement must show the sword arm bent upward and the hand visibly gripping the hilt at shoulder height, with the cord attached beside that grip.
- Do not slice either irregular review image directly. Decision 075 requires action-owned exact-grid sheets, stable scale/pivot/baseline checks, binary alpha, and source-matte residue rejection.

## `king_greatsword_turnaround_reference_v1.png`

Reference input:

- `art_source/generated/characters/playable/king/king_turnaround_direction_reference_approved.png`

Exact prompt:

> Create a revised pixel-art character turnaround reference for the exact same approved character King from the supplied image.
>
> REFERENCE ROLE: the supplied image is the strict identity and pixel-style reference. Preserve King's young-prime chibi proportions, face, messy charcoal-black hair with one pale silver forelock, navy/charcoal armor coat, silver shoulder plates, crimson waist accent, boots, palette, coarse intentional pixel clusters, and top-down three-quarter RPG viewpoint. Do not redesign his face, clothes, proportions, or rendering style.
>
> CHANGE ONLY THE WEAPON AND CARRY POSE:
> - Replace the small straight sword with King's signature heavy greatsword.
> - Greatsword must be visually broad, long, weighty, and cool: a wide silver-white blade with a dark steel spine/core, a restrained broken-halo-shaped guard, dark grip with crimson cord accent, and a heavy squared/angled tip. It should read clearly at small game scale without becoming a gigantic anime slab.
> - During idle, King carries the greatsword resting on his weapon-side shoulder. His hand and hilt sit close to the shoulder/body; the blade extends upward and outward away from his head. Never place the blade through or leaning into his face/head. It is not sheathed on his back.
> - His posture should show believable weight: slight shoulder drop, planted stance, calm dangerous confidence.
>
> LAYOUT:
> - Exactly four isolated full-body sprites in one horizontal presentation: DOWN/front three-quarter, LEFT, RIGHT, UP/back three-quarter.
> - All four show the same shoulder-rest idle pose adapted correctly to direction and perspective.
> - Equal apparent scale and consistent ground pivot.
> - Generous empty separation, no overlap, no cropped pixels.
> - Flat very dark violet-gray background for design review.
> - No labels, no text, no grid, no UI, no portrait, no shadows beyond a tiny readable contact shadow.
>
> PIXEL CONSTRAINTS:
> - Authentic coarse game-ready pixel art, nearest-neighbor hard edges, deliberately limited palette, no painterly smoothing, no antialiasing, no high-detail realism.
> - Character body should look designed for roughly 28-32 pixel visual height inside a future 64x64 runtime cell; keep chunky readable clusters and silhouette.
> - This is a directional design reference, not yet a runtime sprite sheet.

## `king_greatsword_opening_cut_vfx_reference_v1.png`

Reference inputs:

- generated greatsword turnaround above, as strict King/weapon identity;
- owner-provided pink-crescent screenshot, as composition inspiration only.

Exact prompt:

> Create a pixel-art combat animation proof for King using the supplied references.
>
> REFERENCE ROLES:
> 1) The four-direction King image is the strict character, costume, palette, pixel density, heavy greatsword, and identity reference. Preserve this exact young-prime chibi King.
> 2) The small screenshot is composition inspiration ONLY for the idea of a very thick, body-sized crescent wrapping around a swordsman. Do not copy its character, colors, silhouette, or exact curve.
>
> ACTION:
> - Exactly eight sequential full-body frames in a single horizontal row.
> - King faces RIGHT in a top-down three-quarter action-RPG view.
> - One complete, extremely forceful heavy greatsword opening slash:
>   1. stable shoulder-rest anticipation,
>   2. deep planted windup with torso/hips coiling,
>   3. blade begins to accelerate and its edge starts glowing,
>   4. greatsword overexposes silver-white and a thick crescent is born directly from the physical blade path,
>   5. main contact frame: a massive white-hot crescent wraps around King, approximately 2 to 2.5 times his body width, with a cold pale-blue inner edge and restrained pale-violet outer fragments; the physical greatsword remains visibly connected to the root of the arc,
>   6. heavy follow-through with body recoil and cape/cloth lag,
>   7. crescent fractures into chunky light shards and short embers,
>   8. low recovery returning toward shoulder-ready stance.
> - Show convincing greatsword weight through feet, knees, shoulders, torso recoil, and delayed cloth movement.
> - The sword and effect must feel like ONE attack. It must not look like a detached projectile or a thin wind slash.
> - The main effect is opaque white-hot energy with cold-blue and faint violet accents, not pink. Make the active contact frames spectacular and exaggerated while keeping King readable at the core.
> - The crescent should occupy real melee space around the body and visually communicate the whole damage arc, including its outer tip.
>
> LAYOUT AND PIXEL CONSTRAINTS:
> - Equal apparent character scale and consistent ground pivot across all frames.
> - Generous spacing so large effects do not overlap adjacent frames; no cropping.
> - Flat very dark violet-gray background for design review.
> - Authentic coarse game pixel art: nearest-neighbor hard edges, deliberately limited palette, chunky clusters, no painterly blur, no smooth antialiasing, no realistic rendering.
> - No labels, no text, no grid, no UI, no portrait.
> - This is a combined motion-plus-VFX design proof. Runtime production will separate the character animation from the VFX layer.
