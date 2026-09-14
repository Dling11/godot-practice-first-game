# Targeted Riftbreak comparison

This is an opt-in Combat Lab review, not a campaign replacement. Open F7 -> KING REVIEW -> RIFTBREAK: ORIGINAL to enable TARGETED TEST; press 2, aim and confirm with left click. Right click/Esc cancels targeting. Toggle off to restore the previous loadout and original skill.

- `riftbreak_review.mp4`: real engine capture with existing Riftbreak impact audio.
- `riftbreak_review.gif`: silent animated comparison.
- `impact.png` / `debris.png`: contact and aftermath frames.
- `segments.json`: engine frame-derived capture timings.

The direct 30px core applies explicit stun, while the 68px rim flinches/pushes at 65% core damage. Stars indicate true stun only. The cast returns control after 0.38s before hit pauses; the sixteen-drawing VFX stays at contact. Enemy AI is paused in this comparison to isolate the hit response; collision/control authority remains real. Basic attacks, ordinary flinches and high damage never infer stun. King body poses retain the approved art; unique skill-body frames remain provisional.

Reproduce with `--script res://tools/capture_riftbreak_review.gd --write-movie <output.avi> --fixed-fps 60`. Production checks include explicit control kinds, core/rim contact, walls, range, free target cancellation and exact resource/loadout restoration, plus the existing King skill/animation/mastery regressions. No final balance or visual acceptance is claimed.

Generated source and the complete built-in image-generation prompts are in `art_source/generated/vfx/king/riftbreak_review_2026_09_14/PROMPTS.md`.

Validation completed: 45 stun-indicator assertions, 28 targeted-Riftbreak assertions, 232 King preview assertions, 82 responsive-kit assertions, 174 Oath assertions, 385 mastery assertions, plus four original-skill and two crowd-control smoke scripts.
