# Examiner rework review - 2026-09-12

Open `Play Examiner.cmd` at the project root or press F7 during a debug game. The lab opens on the reworked Examiner; King starts invincible. Turn that toggle off to test damage, or use Force Divine Descent to review the ward mechanic. No rewards or saves are granted by this scene.

## Included

- Ten replacement body sheets and 116 named clips covering idle, walking, basic thrust/sweep, Judgment Charge, Ground Judgment, Refutation, Axiom, Divine Descent, reaction, and withdrawal.
- A dedicated complete overhead glaive wind-up supplement for Ground Judgment.
- Separate anticipation/contact spans, continuous wind-up facing, collision-stopped grounded charges, and a real phase/technique display.
- Generated slate court, exact cyan ward plates, physical perimeter, quieter overlays, and compact lab controls.
- Sixteen original synthesized action/footstep cues and the retained single encounter music foundation.

## Verification

Passed with Godot 4.7:

- `examiner_trial_smoke.gd`
- `examiner_rework_smoke.gd`
- `combat_lab_smoke.gd`
- `boss_health_hud_smoke.gd`
- `hud_action_controls_smoke.gd`
- `runtime_archive_boundary_smoke.gd`
- Deterministic saved SpriteFrames rebuild through the legacy forwarding entry point.

`examiner_showcase.mp4` and numbered PNGs are rendered by Godot using `tools/capture_examiner_rework.gd`. The helper stages actions by calling real controller methods and drives their state clocks; it is a scripted presentation review, not evidence of a human campaign playthrough. Final animation feel, sound mix, and balance remain owner review.

## Source and rollback

Art uses built-in ImageGen. Exact prompts, source boards, the overhead supplement prompt, and import measurements are in `art_source/generated/characters/disciples/examiner/rework_2026_09_12/`. Runtime frame spans are in `assets/characters/enemies/examiner/FRAME_MANIFEST.md`. Audio synthesis/provenance are in the rework SFX folder.

Previous 192x128 sheets and prior edited build/visual/test files were preserved under `art_source/archive/characters/disciples/examiner_before_rework_2026_09_12/`. This pass does not integrate Stage VII or redesign the full game's title screen and other stages.
