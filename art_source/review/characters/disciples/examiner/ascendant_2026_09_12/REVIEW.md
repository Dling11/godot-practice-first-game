# Examiner: breakable seal, Borrowed Sun and Unbound

Rendered Godot review: [ascendant.mp4](ascendant.mp4). The capture uses real actor/guard/projectile states and a scripted King path; injected review hits demonstrate interrupt success without changing the player's actual loadout or saved stats.

- Gold seal absorbs damage independently of red HP. Breaking either charge cancels its attack, clears pending cuts and exposes a 2.6-second kneeling stun plus standing recovery.
- Borrowed Sun raises the approved glaive pose under a growing energy orb. Failure throws it to a fixed, warned point; it does not track King after release.
- First/Second/Unbound approach speeds: 66/86/106 px/s. Thresholds: 60% and 35%. Unbound adds 1.65x normal damage, a larger Sun and three staggered Crownfall impacts.
- The first failed Trial still releases 800 raw Verdict through ordinary dodge, with armor and ward mitigation. Guard success now cancels the jump instead of opening a sanctuary.

Approved body PNGs and all 116 named clips are unchanged. Charging, release and kneeling reuse existing poses. New art is an eight-frame VFX-only atlas, processed with fixed scale and explicit padding checks. [Exact generation prompt](../../../../../generated/characters/disciples/examiner/ascendant_2026_09_12/prompt.md) and source are under `art_source/generated/characters/disciples/examiner/ascendant_2026_09_12/`; six original audio cues are reproducible with `tools/generate_examiner_ascendant_sfx.py`.

Validation: nine focused Godot checks passed cleanly (Ascendant, Worth, Trial, rework, effects, boss HUD, Combat Lab, player evade, archive boundary). Armor assertions also passed; that pre-existing fixture still reports two ObjectDB instances and one resource at exit. Rendered review is error-free and the MP4 decodes successfully. Body hashes and atlas padding are checked separately.

Use `Play Examiner.cmd` or F7. King starts invincible; disable that toggle to judge actual damage. The current gear cannot establish final Stage XX difficulty or later-equipment survival. This remains a rewardless, non-saving combat proof.
