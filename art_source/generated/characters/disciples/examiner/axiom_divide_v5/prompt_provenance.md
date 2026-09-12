# Examiner Axiom Divide V5 Provenance

- Generated: 2026-08-25
- Generator: built-in OpenAI image generation
- Final vertical source: `examiner_axiom_vertical_source_v5_2026-08-25.png`
- Preserved approved side source: `examiner_axiom_side_source_v4_2026-08-25.png`

## Final source contract

The V4 right-facing row was accepted and is mirrored deterministically for the left row. V4's diagonal front/back contacts were rejected. V5 generated only six down-facing and six up-facing poses so image generation could focus on true cardinal depth.

The final vertical prompt required the down contacts to place the complete glaive shaft across the mask/chest/pelvis centerline and finish the blade below the midpoint between both feet. Up contacts use the opposite centerline and finish the blade above the halo/head. Both rows preserve the approved masculine mask, measurement halo, ivory/gold armor, black undersuit, split cloth, long legs, complete glaive, compact hard-pixel palette, and constant proportions. Diagonal, horizontal, profile, realistic, blurred, broken-weapon, detached-limb, and redesigned results were forbidden.

`tools/process_examiner_animation_sources.py` applies one shared `0.31` vertical-source scale derived from the approved standing height, the existing `0.42` side-source scale, one lower-body anchor, and the shared runtime foot baseline. It produces the final 6-by-4 `192x128` runtime sheet without per-frame fitting.
