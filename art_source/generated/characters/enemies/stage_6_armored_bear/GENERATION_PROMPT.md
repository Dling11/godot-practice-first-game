# Stage VI Crag Bear generation provenance

Built-in image generation was used on 2026-08-24 after owner approval of the armored-bear concept.

The approved identity is a recognizable dark-brown bear wearing crafted pale-steel shoulder plates, paired leather-and-metal foreleg bracers, a dark leather harness, and a small forehead guard. Tiny faded-teal engravings connect the equipment to the Elder Ascent without turning the bear into a boss or making armor grow from its body.

Initial generated source families:

- `armored_bear_locomotion_source.png`: `4x4`, rows `down/left/right/up`, four real gait phases.
- The original four-frame claw and six-frame ground-slam sources were rejected after no-VFX runtime review: the claw lacked a connected whole-body swing and the slam did not consistently communicate a genuine rise/drop/contact. They and their superseded runtime sheets are archived under `art_source/archive/characters/enemies/crag_bear_rejected_attacks_2026-08-24/`.
- `armored_bear_reaction_source.png`: `6x4`, two hurt frames and four non-gory defeat frames.
- `armored_bear_materials_source.png`: two cells for Crag Iron and Echo Claw.

Every request required the approved identity, ordinary-mob scale, slightly angled top-down perspective, stable armor placement, upper-left light, transparent background, and no embedded VFX. The generator baked a pale checkerboard, so `tools/process_stage_6_crag_bear.py` removes only border-connected pale neutral pixels, retains the intended actor/item component, and exports binary-alpha runtime images.

## Fresh action redraws

Built-in image generation was used again after direct inspection proved that code timing, VFX, scaling, and repositioning could not repair the weak body poses.

- `armored_bear_basic_attack_v2_anticipation_source.png`: new `4x4` body-only anticipation half—planted stance, whole-body brace, connected shoulder/paw draw, and pre-release weight transfer.
- `armored_bear_basic_attack_v2_execution_source.png`: new `4x4` body-only execution half—release, physical contact, follow-through, and recovery. It uses the anticipation board as an identity reference and explicitly forbids stretched limbs or VFX-defined contact.
- `armored_bear_body_slam_v2_source.png`: new eight-pose, four-direction body-only slam—stance, crouch, half-rise, full hind-leg rise/roar, downward pitch, two-paw impact, compressed recoil, and recovery.

The processor combines both claw halves into eight chronological frames per direction. Because the slam generator placed strong isolated poses on a visually irregular board, the processor detects the 32 connected actor components and orders them by direction/time instead of forcing false equal-cell crops. Runtime uses `96x64` claw cells and `96x80` slam cells so natural-length reach and the genuinely taller upright pose are never shrunk to fit. One scale is derived per direction from the approved locomotion stance; binary alpha, stable bottom pivot, and body-only review sheets remain mandatory.

Normalized prompts preserved the owner's required action beats, exact identity, palette, proportions, top-down cardinal perspective, transparent body-only output, stable pivot, and explicit bans on VFX, particles, shadows, labels, neighboring overlap, rubber arms, static torsos, and changing armor/anatomy. Built-in output files were copied into this project before runtime processing.
