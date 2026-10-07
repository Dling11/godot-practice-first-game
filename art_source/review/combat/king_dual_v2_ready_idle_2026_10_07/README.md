# Twinsteel V2 — ready and idle entry correction

2026-10-07. Owner accepts installed attacks and current body size, requests uncrossed steel after travel and removal of the quick introductory head turn. No generated artwork or combat tuning changes.

Ready blades now open outward from the same palms in all four facings. The builder propagates those angles to matching carry endpoints. Proud-idle entry uses keys1–4 over1.10s, holds the neutral folded stance for1.40s, then loops5–7 with the existing slow exposures. The normal four-second AFK delay and0.28s retrieval remain. Movement/attack/equipment controls own cancellation through the existing presentation tween.

## Verification

- Native Godot4.7.2 compatibility rendering: `motion_checks.json`953/0,300frames; `gameplay/validation.json`244/0 actual Player/Bag/queues/contact/skills/dash/swaps/Stage I; `idle_checks.json`100/0 actual four-facing ready, entry, slow first glance, retrieval, delayed cancellation and swap; `greatsword_idle_console.log`21/0 preserving the default planted idle.
- First actual head-glance times2.520/2.536/2.528/2.515s after idle entry, in LEFT/RIGHT/UP/DOWN. The entry does not traverse glance keys. Each first look persists for a slow exposure.
- `sample_030.png` shows the new ready pair; `ready_live_*.png` shows actual Player after travel; `idle_live_*.png` shows the proud head loop. `motion_frames/` contains the native four-view timeline; `motion.gif` encodes these300frames at30fps. The gallery samples presentation; actual idle timing/input is verified separately by the real Player test.
- `preservation.json` protects410 King PNG/TRES files:392identical,18Twinsteel pose resources changed, zero PNG changes. Normalized pose data is otherwise identical. `pose_preservation.json` compares1056 blade-coordinate values: only ready key0 and carry recovery/closing endpoints differ; no accepted contact/queue coordinate changes. Original sources, gait, FX, canonical steel and all heavy art remain identical.
- `before_manifest.json` and `before/` contain72 pre-fix scripts/resources/registration files. Generated outputs use the same source sheets and builder, without new image generation. Historical Decision190 proof remains in its own sibling folder.

The first parallel idle run failed its wall-clock deadline and a fixture cancellation step that released velocity before the next controller physics callback. The focused test now permits rendering delays, retains movement through that callback and verifies the same first-glance minimum/slow exposure and cancellation. Its sequential final run passes100/0; the initial log is retained as `idle_initial_parallel_console.log`. No performance claim comes from parallel capture/tests.

## Owner constraints

Keep the accepted attack artwork and current body silhouette. Future King sheets must retain native density, palette and readable outlines; avoid gradually bulkier proportions. Cosmetic proof does not establish encounter balance, device performance or owner acceptance of the revised idle. Iron Reaper remains selected and deferred.

Play: F5 → F9 → F7 → Weapons → Twinsteel; or `tools/launch_king_twinsteel_training.ps1`. WASD, held world LMB, Space dodge, Tab Bag. The direct launch suppresses test-session autosave.
