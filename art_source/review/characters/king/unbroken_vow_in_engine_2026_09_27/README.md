# Unbroken Vow in-engine test

Open **F7 -> KING REVIEW -> BUFF TEST**. Press **T** or **REPLAY**. After the .32s activation, use normal movement, Dodge and basic/skill attacks while the barrier follows the real Player for6s. SPEED slows only the test cast to .96s. SOUND toggles the contact cue. VIEW switches native/close camera. RESET cancels the effect; CLOSE/Esc restores previous enemy-AI and camera settings.

Direct launch: `tools/launch_unbroken_vow_test.ps1`, or Godot with `--path . --script res://tools/launch_unbroken_vow_test.gd`. Direct launch suppresses disk saves and clears the opening Lab enemy. Normal F7 entry pauses enemy AI while the test is open, without deleting the existing encounter. This is a **down-facing visual rehearsal**: Skill4 remains Worldsplitter and the barrier grants no shield, damage or speed bonus. Normal hit shapes/equipment remain live.

## Verification, 2026-09-27

- `tests/unbroken_vow_test_smoke.gd`:31 checks, zero failures. Tests normal/slow contact timing, single release cue, control return, actual movement/dodge/attack during sustain, scale/foot anchor, preservation of production frames/stats/slots, replay rejection, timed end, close mid-cast, freeing mid-cast and AI/camera restoration.
- `tests/king_production_kit_smoke.gd`:zero failures.
- `tests/combat_lab_smoke.gd`:passed roster, admin/rewards, arena, AI, spawn/clear and invincibility checks.
- `tools/capture_unbroken_vow_test.gd`:five real GPU renders at960x540, using Compatibility on local AMD graphics. `01_controls.png`, `02_release.png`, `03_sustain_native.png`, `04_sustain_close.png`, `05_restored.png` were captured. Release and close view visually inspected.
- GPU shutdown reports two5460-byte texture RID leaks and late RenderingServer destruction messages. The same errors reproduce on ordinary title-screen startup/exit without entering this test. Runtime rendering/captures and headless checks passed; the shared shutdown cleanup remains unresolved.

Owner combat feel and sound mix remain subjective review. Shield absorption/depletion, upgrades, other activation directions, Mature finisher and slot5 migration are still unimplemented.
