# Examiner Axiom Divide V6 Down-Thrust Provenance

- Generated: 2026-08-25
- Generator: built-in OpenAI image generation
- Approved source: `examiner_axiom_down_thrust_source_v6_2026-08-25.png`
- Scope: down-facing Axiom body poses only

## Owner-approved direction

The owner approved a direct thrust toward a player standing at screen-bottom. The Examiner's mask, chest, stance midpoint, hands, glaive shaft, and blade endpoint remain aimed at bottom-center rather than drifting toward screen-right. The six poses show ready stance, compression, aim, launch, maximum extension, and recoil.

The generation prompt preserved the approved masculine mask, measurement halo, ivory-and-gold armor, black underlayers, split cloth, long legs, complete glaive, compact hard-pixel palette, and down-facing top-down camera direction. It explicitly prohibited side/profile turns, diagonal endpoints, sideways sweeps, overhead chops, static weapon sliding, detached hands, broken weapons, VFX, particles, motion blur, text, and scenery.

## Processing contract

The generated preview contains a baked neutral checkerboard. `tools/process_examiner_animation_sources.py` removes only the neutral near-white matte, hardens alpha to binary, reads the 3-by-2 board in chronological order, and applies one fixed `0.26` scale. A thrust-specific body anchor excludes the centerline blade when finding the foot baseline so the long weapon cannot make the Examiner float upward.

V6 replaces only runtime Axiom row 0 (`down`). V5 remains the accepted source for `up` and the right-facing side row; left remains the deterministic mirror of right. No state duration, damage window, lane geometry, dash, hitbox, VFX, audio, phase transition, or AI authority changes with this art revision.
