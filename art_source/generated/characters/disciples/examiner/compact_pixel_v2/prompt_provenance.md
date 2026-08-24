# Examiner Compact-Pixel V2 Source Provenance

- Date: 2026-08-24
- Generator: OpenAI built-in ImageGen
- Style reference: `art_source/review/characters/disciples/examiner/examiner_compact_pixel_style_lock_v3_2026-08-24.png`
- Runtime processing: `tools/process_examiner_animation_sources.py`
- Runtime destination: `assets/characters/enemies/examiner/`

Each accepted board requested the same tall masculine Examiner identity, smooth ivory mask, simplified ivory/charcoal/gold materials, four-tick halo, bold Split Glaive, large pixel clusters, four cardinal top-down rows, generous gutters, transparent background, fixed proportions, and no scaling or camera drift. Action-specific prompts requested:

- locomotion: two restrained idle poses followed by four deliberate walk poses;
- thrust: neutral, coil, retract, committed thrust, contact, and recovery;
- sweep: six full-body preparation, swing, contact, follow-through, and recovery poses;
- Zero Interval: five compression, launch, low travel, braking, and recovery poses;
- Refutation: five guarded interception, deflection, and reset poses with the weapon participating;
- reaction/withdrawal: three unmistakable non-lethal hurt/recovery poses followed by three dignified recognition/withdrawal poses.

The runtime processor uses the approved left-facing row as side-view authority and derives the right-facing row by exact horizontal mirroring. This deliberately discards small independent-generation differences between those two source rows.

Two Axiom-specific generations were rejected before import: one allowed detached weapon pieces to cross frame cells, and the correction returned only five columns and three rows. Neither was copied into the project. Runtime Axiom body motion therefore composes accepted sweep and Zero Interval frames while its lane geometry and energy remain separate presentation.
